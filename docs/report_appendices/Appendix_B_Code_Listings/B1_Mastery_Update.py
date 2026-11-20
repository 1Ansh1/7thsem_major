# ==============================================================================
# Listing B.1 — Student Mastery Update Implementation
#
# Primary Source: major1/backend/app/services/mastery.py
# Persistence Source: major1/backend/app/services/skill_graph.py (apply_evidence)
# Function: update_mastery(s: SkillState, e: Evidence) -> SkillState
# ==============================================================================

"""Deterministic, pure mastery update for one skill-graph node.

No I/O and no randomness: the same (state, evidence) always yields the same new state,
so it is unit-testable and auditable. The LLM never touches this.

Model (per attempt):
    delta = lr * w * (target - mastery),   clipped to ±MAX_STEP, result clipped to [0, 100]

    target = 100 if correct else 0
    lr     = max(LR_FLOOR, 1 / (attempt_count + 2))     -> moves fast early, stabilises later
    w (correct) = difficulty weight * speed factor * confidence factor
                  (hard > easy; fast > slow; a low-confidence correct answer counts partly as luck)
    w (wrong)   = inverse difficulty weight * confidence factor
                  (missing an easy question hurts more; a *confident* wrong answer signals a
                   misconception and hurts more than an unsure one)
"""

from dataclasses import dataclass, replace
from datetime import datetime

MAX_STEP = 15.0
LR_FLOOR = 0.15
DIFFICULTY_WEIGHT = {"easy": 0.7, "medium": 1.0, "hard": 1.3}
DEFAULT_EXPECTED_MS = {"easy": 60_000, "medium": 120_000, "hard": 240_000}


@dataclass(frozen=True)
class SkillState:
    mastery_score: float = 0.0
    attempt_count: int = 0
    correct_count: int = 0
    accuracy: float = 0.0
    average_time_ms: float = 0.0
    confidence: float | None = None  # running mean of self-reported confidence, in [0, 1]
    last_attempt: datetime | None = None


@dataclass(frozen=True)
class Evidence:
    correct: bool
    difficulty: str  # easy | medium | hard
    at: datetime
    time_ms: int | None = None
    expected_time_ms: int | None = None
    confidence: int | None = None  # self-reported 1..5


def _clamp(x: float, lo: float, hi: float) -> float:
    return max(lo, min(hi, x))


def confidence_norm(c: int | None) -> float | None:
    return None if c is None else (_clamp(c, 1, 5) - 1) / 4


def update_mastery(s: SkillState, e: Evidence) -> SkillState:
    d = DIFFICULTY_WEIGHT.get(e.difficulty, 1.0)
    conf = confidence_norm(e.confidence)
    lr = max(LR_FLOOR, 1 / (s.attempt_count + 2))

    if e.correct:
        target = 100.0
        w = d
        expected = e.expected_time_ms or DEFAULT_EXPECTED_MS.get(e.difficulty, 120_000)
        if e.time_ms and e.time_ms > 0:
            w *= _clamp(1.2 - 0.2 * (e.time_ms / expected), 0.8, 1.1)
        if conf is not None:
            w *= 0.85 + 0.15 * conf
    else:
        target = 0.0
        w = 2.0 - d
        if conf is not None:
            w *= 1.0 + 0.3 * conf

    delta = _clamp(lr * w * (target - s.mastery_score), -MAX_STEP, MAX_STEP)
    n = s.attempt_count + 1
    correct = s.correct_count + int(e.correct)
    avg_time = s.average_time_ms
    if e.time_ms and e.time_ms > 0:
        # exponential moving average over attempts that reported a time
        avg_time = (e.time_ms if s.average_time_ms == 0
                    else s.average_time_ms * 0.8 + e.time_ms * 0.2)
    new_conf = s.confidence
    if conf is not None:
        new_conf = conf if s.confidence is None else s.confidence * 0.7 + conf * 0.3

    return replace(
        s,
        mastery_score=round(_clamp(s.mastery_score + delta, 0.0, 100.0), 2),
        attempt_count=n,
        correct_count=correct,
        accuracy=round(correct / n, 4),
        average_time_ms=round(avg_time, 1),
        confidence=None if new_conf is None else round(new_conf, 4),
        last_attempt=e.at,
    )


def target_difficulty(mastery: float | None) -> str:
    """Adaptive difficulty for the next question on a skill."""
    m = mastery or 0.0
    return "easy" if m < 35 else "medium" if m < 70 else "hard"


# ------------------------------------------------------------------------------
# Database Persistence Integration (from app/services/skill_graph.py)
# ------------------------------------------------------------------------------

# async def apply_evidence(db: AsyncSession, user_id: int, q: Question, correct: bool,
#                          time_ms: int | None, confidence: int | None) -> MasteryChange | None:
#     sk = await skill_for_topic(db, q.topic_id)
#     if sk is None:
#         return None
#     m = await db.scalar(select(Mastery).where(Mastery.user_id == user_id,
#                                               Mastery.skill_id == sk.id))
#     if m is None:
#         m = Mastery(user_id=user_id, skill_id=sk.id, mastery_score=0.0, attempt_count=0,
#                     correct_count=0, accuracy=0.0, average_time_ms=0.0)
#         db.add(m)
#     before = m.mastery_score or 0.0
#     new = update_mastery(_to_state(m), Evidence(
#         correct=correct, difficulty=q.difficulty, at=utcnow(), time_ms=time_ms,
#         expected_time_ms=expected_time_ms(q), confidence=confidence))
#     for field in ("mastery_score", "attempt_count", "correct_count", "accuracy",
#                   "average_time_ms", "confidence", "last_attempt"):
#         setattr(m, field, getattr(new, field))
#     m.difficulty = {"easy": 0.3, "medium": 0.6, "hard": 0.9}.get(q.difficulty, 0.5)
#     return MasteryChange(sk.id, sk.name, round(before, 2), new.mastery_score)
