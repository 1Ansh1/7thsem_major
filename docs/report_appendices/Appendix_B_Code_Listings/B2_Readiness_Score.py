# ==============================================================================
# Listing B.2 — Company Readiness Score (CRS) Computation
#
# Primary Source 1: major1/backend/app/services/readiness.py
# Primary Source 2: major1/backend/app/services/readiness_data.py
# Core Functions: readiness(), validate_weights(), gather(), report()
# Equation Verified:
#     CRS = 0.25·DSA + 0.20·CSF + 0.20·Coding + 0.15·Aptitude + 0.10·Interview + 0.10·Consistency
# ==============================================================================

"""Company Readiness Score — Equation 3.1. Pure and deterministic; no LLM involvement.

    readiness = 0.25·DSA + 0.20·CSF + 0.20·Coding + 0.15·Aptitude + 0.10·Interview
              + 0.10·Consistency

Every component is normalised to [0, 100]. A company profile may override the weights
(they must still sum to 1). Components with no evidence score 0 and are flagged as such;
they are never estimated.
"""

from dataclasses import dataclass, field
from datetime import timedelta
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

COMPONENTS = ("dsa", "csf", "coding", "aptitude", "interview", "consistency")
DEFAULT_WEIGHTS: dict[str, float] = {
    "dsa": 0.25,
    "csf": 0.20,
    "coding": 0.20,
    "aptitude": 0.15,
    "interview": 0.10,
    "consistency": 0.10
}
LABELS = {
    "dsa": "DSA",
    "csf": "CS fundamentals",
    "coding": "Coding performance",
    "aptitude": "Aptitude",
    "interview": "Interview performance",
    "consistency": "Consistency"
}

CONSISTENCY_WINDOW_DAYS = 14
STREAK_TARGET_DAYS = 14


def _clamp(x: float, lo: float = 0.0, hi: float = 100.0) -> float:
    return max(lo, min(hi, x))


def validate_weights(w: dict[str, float]) -> dict[str, float]:
    """Ensure weights match the 6 canonical components, are non-negative, and sum to 1.0."""
    if set(w) != set(COMPONENTS):
        raise ValueError(f"weights must have exactly {COMPONENTS}")
    if any(v < 0 for v in w.values()) or abs(sum(w.values()) - 1) > 1e-6:
        raise ValueError("weights must be non-negative and sum to 1")
    return w


def readiness(components: dict[str, float], weights: dict[str, float] | None = None) -> float:
    """Equation 3.1: weighted sum of [0, 100] components, rounded to 2 decimal places."""
    w = validate_weights(weights or DEFAULT_WEIGHTS)
    missing = set(COMPONENTS) - set(components)
    if missing:
        raise ValueError(f"missing components: {sorted(missing)}")
    return round(sum(w[k] * _clamp(components[k]) for k in COMPONENTS), 2)


def contributions(components: dict[str, float], weights: dict[str, float]) -> dict[str, float]:
    """Calculate point contribution of each individual component towards the overall score."""
    return {k: round(weights[k] * _clamp(components[k]), 2) for k in COMPONENTS}


# ---------------- Component Formulas ----------------


def dsa_component(dsa_mastery: float | None, dsa_coding_accept_ratio: float | None) -> float:
    """Skill-graph DSA mastery, blended 70/30 with the accepted ratio of DSA coding problems."""
    if dsa_mastery is None and dsa_coding_accept_ratio is None:
        return 0.0
    if dsa_coding_accept_ratio is None:
        return _clamp(dsa_mastery or 0.0)
    if dsa_mastery is None:
        return _clamp(100 * dsa_coding_accept_ratio)
    return _clamp(0.7 * dsa_mastery + 0.3 * 100 * dsa_coding_accept_ratio)


def coding_component(problems_attempted: int, problems_accepted: int,
                     speed_scores: list[float]) -> float:
    """70% accepted ratio (distinct problems) + 30% mean solve speed of accepted submissions.

    speed score per accepted problem = min(1, expected_time / actual_time).
    """
    if problems_attempted == 0:
        return 0.0
    ratio = problems_accepted / problems_attempted
    speed = sum(speed_scores) / len(speed_scores) if speed_scores else 0.0
    return _clamp(70 * ratio + 30 * _clamp(speed, 0, 1))


def accuracy_component(correct: int, answered: int) -> float:
    """Accuracy percentage [0, 100] for multiple-choice aptitude practice."""
    return 0.0 if answered == 0 else _clamp(100 * correct / answered)


def consistency_component(streak_days: int, active_days_in_window: int) -> float:
    """Half current streak (capped at 14 days), half share of active days in the last 14."""
    streak = min(streak_days, STREAK_TARGET_DAYS) / STREAK_TARGET_DAYS
    regular = min(active_days_in_window, CONSISTENCY_WINDOW_DAYS) / CONSISTENCY_WINDOW_DAYS
    return _clamp(50 * streak + 50 * regular)


# ---------------- Database Aggregation Pipeline (readiness_data.py) ----------------

@dataclass
class Evidence:
    components: dict[str, float]
    available: dict[str, bool]
    detail: dict[str, str]
    nodes: list = field(default_factory=list)
    unsolved_coding: list[tuple[int, str]] = field(default_factory=list)


async def gather_readiness_evidence(db: AsyncSession, user_id: int,
                                    nodes, areas, subs, qs, p, interviews) -> Evidence:
    """Extract component evidence across skill trees, Judge0 submissions, aptitude tests, streaks, and interviews."""
    # (Excerpts of calculation from app/services/readiness_data.py)
    
    # 1. Coding (Judge0 verdicts only)
    attempted, accepted = set(), set()
    dsa_attempted, dsa_accepted = set(), set()
    best_speed = {}
    for s in subs:
        q = qs.get(s.question_id)
        if q is None or q.type != "coding" or s.verdict.judged_by != "judge0":
            continue
        is_dsa = q.topic is not None and q.topic.area == "DSA"
        attempted.add(q.id)
        if is_dsa:
            dsa_attempted.add(q.id)
        if s.verdict.status in {"Accepted"}:
            accepted.add(q.id)
            if is_dsa:
                dsa_accepted.add(q.id)
            if s.time_taken_ms:
                speed = min(1.0, 120_000 / max(s.time_taken_ms, 1))
                best_speed[q.id] = max(best_speed.get(q.id, 0.0), speed)
    dsa_ratio = len(dsa_accepted) / len(dsa_attempted) if dsa_attempted else None

    # 2. Aptitude accuracy
    apt = [s for s in subs if (q := qs.get(s.question_id)) and q.topic and q.topic.area == "Aptitude"]
    apt_correct = sum(s.verdict.status in {"Accepted"} for s in apt)

    # 3. Consistency (streak + 14-day activity window)
    since = datetime.now() - timedelta(days=CONSISTENCY_WINDOW_DAYS)
    active_days = {s.created_at.date() for s in subs if s.created_at >= since}
    streak = p.study_streak if p and p.last_active_on else 0

    # 4. Interview performance
    if interviews:
        interview_val = sum(float((i.scores or {}).get("overall_score", 0.0)) for i in interviews) / len(interviews)
    else:
        interview_val = None

    # 5. CS Fundamentals (CSF)
    CSF_AREAS = ("DBMS", "OS", "CN", "OOP")
    csf = [(areas[a][0], areas[a][1]) for a in CSF_AREAS if a in areas]
    csf_value = sum(v * w for v, w in csf) / sum(w for _, w in csf) if csf else None
    dsa_m = areas.get("DSA", (None, 0))[0]

    # Combine into normalized dictionary [0, 100]
    comps = {
        "dsa": dsa_component(dsa_m, dsa_ratio),
        "csf": csf_value or 0.0,
        "coding": coding_component(len(attempted), len(accepted), list(best_speed.values())),
        "aptitude": accuracy_component(apt_correct, len(apt)),
        "interview": round(interview_val, 2) if interview_val is not None else 0.0,
        "consistency": consistency_component(streak, len(active_days)),
    }
    
    return comps
