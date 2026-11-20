# Appendix B — Technical Code Listings & Implementation Architecture

**Project:** PrepPath — AI-Powered Adaptive Placement Preparation Platform  
**Document:** Source Code Evidence & Algorithmic Analysis  
**Output Location:** `docs/report_appendices/Appendix_B_Code_Listings/`  
**Generated On:** November 20, 2026  

---

## Overview

This document presents rigorous technical explanations for four representative source-code implementations that define the core engineering innovations of PrepPath:
1. **Listing B.1:** Student Mastery Update Function (`update_mastery`)
2. **Listing B.2:** Company Readiness Score (CRS) Engine (`readiness` / `gather`)
3. **Listing B.3:** Knowledge Base Retrieval-Augmented Generation (RAG) Pipeline (`search`)
4. **Listing B.4:** Multi-Tier AI Guardrail & Verification Subsystem (`clean_input`, `check_citations`, `strip_verdict_contradictions`)

All code excerpts represent exact production logic extracted from the project repository without modification, refactoring, or synthetic simplification.

---

## Listing B.1 — Student Mastery Update Function

### 1. Specification & Location
- **Listing File:** `B1_Mastery_Update.py`
- **Original Repository File:** `major1/backend/app/services/mastery.py`
- **Database Persistence Source:** `major1/backend/app/services/skill_graph.py` (`apply_evidence`)
- **Primary Function:** `update_mastery(s: SkillState, e: Evidence) -> SkillState`

### 2. Architectural Purpose
The mastery update engine maintains an adaptive, real-time estimate of a student's proficiency for every node in the hierarchical curriculum skill graph. To preserve academic integrity, avoid non-deterministic drift, and maintain total auditability during evaluations, this calculation is designed as a **pure, deterministic mathematical function** completely isolated from LLM inference.

### 3. Detailed Algorithmic Explanation
The algorithm implements an adaptive error-correction model inspired by Item Response Theory (IRT) and learning-rate decay:
$$\Delta = \text{clamp}\left(\eta \cdot w \cdot (T - M), -\Delta_{\max}, +\Delta_{\max}\right)$$
Where:
- $M$ is the prior mastery score in $[0, 100]$.
- $T$ is the target value ($100.0$ if the question was answered correctly, $0.0$ if incorrect).
- $\eta$ is an adaptive learning rate:
  $$\eta = \max\left(\eta_{\text{floor}}, \frac{1}{N_{\text{attempts}} + 2}\right), \quad \eta_{\text{floor}} = 0.15$$
  This allows a novice learner's score to move rapidly during diagnostic assessments while stabilizing as empirical sample size increases.
- $w$ is a composite weighting factor:
  - **For correct attempts ($T = 100$):**
    $$w = d \cdot f_{\text{speed}} \cdot f_{\text{conf}}$$
    Where difficulty weight $d \in \{0.7 \text{ (easy)}, 1.0 \text{ (medium)}, 1.3 \text{ (hard)}\}$. Solving a hard problem yields higher positive gain. The speed factor $f_{\text{speed}} \in [0.8, 1.1]$ rewards fast solves, while low confidence penalizes lucky guesses.
  - **For incorrect attempts ($T = 0$):**
    $$w = (2.0 - d) \cdot (1.0 + 0.3 \cdot c_{\text{norm}})$$
    Failing an easy question ($d = 0.7 \implies 2.0 - 0.7 = 1.3$) incurs a greater penalty than failing a hard problem ($2.0 - 1.3 = 0.7$). Furthermore, high confidence on an incorrect answer flags an ingrained cognitive misconception and scales down mastery more aggressively.
- Maximum step size $\Delta_{\max} = 15.0$ prevents single-question outliers from distorting proficiency.
- Running time is tracked via an Exponential Moving Average (EMA: 80% historical, 20% current attempt).

### 4. Interface Definition
- **Inputs:**
  - `s: SkillState`: Frozen dataclass containing prior `mastery_score`, `attempt_count`, `correct_count`, `accuracy`, `average_time_ms`, and `confidence`.
  - `e: Evidence`: Dataclass containing `correct: bool`, `difficulty: str`, `time_ms: int`, `expected_time_ms: int`, and `confidence: int` (1–5 scale).
- **Return Value:**
  - A newly instantiated, immutable `SkillState` with updated proficiency bounded strictly in $[0.0, 100.0]$.

### 5. Platform Integration & Discrepancy Analysis
- **Integration:** When a submission is evaluated in `app/routers/submissions.py`, the result triggers `apply_evidence()` in `skill_graph.py`. It updates `mastery` table records in SQLite/PostgreSQL and recalibrates the student's next question difficulty using `target_difficulty(mastery)`.
- **Discrepancy:** None. The production implementation perfectly mirrors the mathematical design specified in the Chapter 3 specification.

---

## Listing B.2 — Company Readiness Score (CRS) Engine

### 1. Specification & Location
- **Listing File:** `B2_Readiness_Score.py`
- **Original Repository Files:**
  - Pure calculation: `major1/backend/app/services/readiness.py` (`readiness`, `contributions`)
  - Database telemetry aggregator: `major1/backend/app/services/readiness_data.py` (`gather`, `report`)
- **Primary Function:** `readiness(components: dict[str, float], weights: dict[str, float] | None = None) -> float`

### 2. Architectural Purpose
The Company Readiness Score represents the flagship metric of PrepPath. It computes a unified, probabilistic readiness percentage indicating a student's preparedness for technical placement interviews at tier-1 and product companies.

### 3. Verification of Report Equation (Equation 3.1)
The project documentation defines the standard canonical formula:
$$\text{CRS} = 0.25 \cdot \text{DSA} + 0.20 \cdot \text{CSF} + 0.20 \cdot \text{Coding} + 0.15 \cdot \text{Aptitude} + 0.10 \cdot \text{Interview} + 0.10 \cdot \text{Consistency}$$

**Audit Finding: EXACT 100% MATCH.**  
In `app/services/readiness.py`, lines 13–15 declare:
```python
COMPONENTS = ("dsa", "csf", "coding", "aptitude", "interview", "consistency")
DEFAULT_WEIGHTS: dict[str, float] = {
    "dsa": 0.25, "csf": 0.20, "coding": 0.20, "aptitude": 0.15,
    "interview": 0.10, "consistency": 0.10
}
```
In `app/services/readiness_data.py`, lines 231–232 return:
```python
"formula": "0.25·DSA + 0.20·CSF + 0.20·Coding + 0.15·Aptitude + 0.10·Interview + 0.10·Consistency"
```

### 4. Component Implementations
Each of the 6 components is strictly normalized into $[0, 100]$:
1. **DSA ($0.25$):** Blends skill-tree DSA mastery ($70\%$) with the accepted ratio of DSA coding challenges ($30\%$).
2. **Computer Science Fundamentals ($0.20$):** Weighted mean of masteries across the core engineering disciplines: DBMS, Operating Systems, Computer Networks, and Object-Oriented Programming (`CSF_AREAS`).
3. **Coding Performance ($0.20$):** Derived purely from Judge0 verified executions: $70\%$ based on the ratio of distinct solved problems to attempted problems, and $30\%$ based on solve speed relative to expected execution time.
4. **Aptitude ($0.15$):** Strict accuracy percentage across numerical and logical MCQ questions.
5. **Interview ($0.10$):** Arithmetic mean of completed AI mock interview evaluation scores across all rubric dimensions. Missing mock interview data cleanly defaults to $0.0$ and is flagged as unmeasured rather than hallucinated.
6. **Consistency ($0.10$):** Evaluated over a rolling 14-day window: $50\%$ current study streak (capped at 14 days) and $50\%$ proportion of active practice days in the trailing fortnight.

### 5. Missing Data & Corporate Customization
- **Strict Evidence Guard:** When evidence for a component is missing, `gather()` assigns $0.0$ and sets `available[key] = False`. The platform never fabricates or synthesizes placement readiness.
- **Company Weight Overrides:** Corporate profiles (`companies.readiness_weights`) can alter the component distribution (e.g., higher coding weight for competitive product companies), provided `validate_weights()` enforces $\sum w_i = 1.0$.

---

## Listing B.3 — Knowledge Base Retrieval-Augmented Generation (RAG) Pipeline

### 1. Specification & Location
- **Listing File:** `B3_RAG_Retrieval.py`
- **Original Repository File:** `major1/backend/app/services/rag.py`
- **Integration Caller:** `major1/backend/app/services/tutor.py` (`_run`, `explain`, `hint`)
- **Primary Function:** `search(db: AsyncSession, query: str, *, k: int = 5, ...) -> list[Chunk]`

### 2. Architectural Purpose
The RAG pipeline provides context grounding for the AI Tutor and mock interviewer. By feeding curriculum chunks into prompts, the LLM is prevented from generating hallucinations or unverified technical solutions.

### 3. Detailed Algorithmic Explanation
1. **Embedding Generation:** The natural language user query is encoded into a 768-dimensional dense vector using Google Gemini Embedding (`gemini-embedding-001`, task type `RETRIEVAL_QUERY`).
2. **Dual-Dialect Vector Search:**
   - **PostgreSQL (Production):** Employs `Document.embedding.cosine_distance(qv)` with the native PostgreSQL `<=>` operator, leveraging the HNSW index created during Alembic migration.
   - **SQLite (Development):** Queries all embedded records and computes pairwise cosine similarity in Python using `_cos(qv, d.embedding)`.
3. **Domain Boosting:** An architectural bonus ($+0.05$ similarity score) is granted to candidate chunks whose metadata matches the student's active topic or target company profile.
4. **Relevance Floor:** Chunks scoring below `MIN_SCORE_REAL = 0.55` are dropped to prevent injecting irrelevant context into the prompt.
5. **Context Grounding Block:** Retrieved chunks are formatted into numbered reference citations (`[S12] Title: Content`) passed into the LLM system prompt. If zero chunks survive the threshold, the AI Tutor halts and returns an explicit refusal: *"The course knowledge base doesn't cover this yet, so I won't guess."*

---

## Listing B.4 — AI Guardrail Validation & Input/Output Pipeline

### 1. Specification & Location
- **Listing File:** `B4_AI_Guardrails.py`
- **Original Repository File:** `major1/backend/app/services/guardrails.py`
- **Core Functions:** `clean_input()`, `wrap_student()`, `check_citations()`, `forbidden_fragments()`, `strip_verdict_contradictions()`

### 2. Architectural Purpose
The guardrail subsystem guarantees system safety, prevents prompt injection, halts academic cheating, and enforces grounding across all AI interactions.

### 3. Layered Defense Architecture
1. **Input Sanitization & Injection Defense (`clean_input`, `wrap_student`):**
   - Normalizes text with Unicode NFKC, removing non-printable control characters.
   - Bounds user queries to `MAX_INPUT_CHARS = 4000`.
   - Regular expression scanning intercepts prompt injection patterns (`ignore previous instructions`, `you are now`, `jailbreak`) and unsafe topics (weapons, self-harm, PII).
   - Sanitized student input is enclosed in XML encapsulation tags (`<student_input>...</student_input>`), transforming user prompts into passive data rather than executable instructions.
2. **Anti-Hallucination Citation Verification (`check_citations`):**
   - The LLM is instructed to cite sources in the format `[S#]`.
   - `check_citations()` parses cited identifiers and cross-references them against the exact chunk IDs returned by RAG retrieval.
   - Any hallucinated citation (an ID not present in the retrieved sources) is stripped, and the response is flagged in `ai_traces`.
3. **Hint Leakage Prevention (`forbidden_fragments`, `leaks`):**
   - When a student requests a hint during practice mode, the system extracts the canonical answer key (correct MCQ option text, numerical value, or code fix snippet).
   - The AI output is screened; if the hint leaks the exact answer, it is blocked before transmission.
4. **Verdict Contradiction Guard (`strip_verdict_contradictions`):**
   - Compilers and judges (Judge0) are the sole deterministic source of truth for code correctness.
   - If an LLM code explanation states a solution is "incorrect" when Judge0 marked it `Accepted`, the contradictory sentences are stripped using regular expression tokenizers to avoid confusing the student.

---

## Summary of Discrepancy Findings

| Listing | Expected Spec | Source Implementation | Status |
|---|---|---|---|
| **B.1 Mastery Update** | Dynamic IRT-style update with speed & confidence | `mastery.py::update_mastery` | Fully verified; identical |
| **B.2 Readiness Score** | $\text{CRS} = 0.25\text{DSA} + 0.20\text{CSF} + 0.20\text{Coding} + 0.15\text{Apt} + 0.10\text{Int} + 0.10\text{Cons}$ | `readiness.py::readiness` | Fully verified; identical |
| **B.3 RAG Retrieval** | Vector similarity retrieval with metadata boosting | `rag.py::search` | Fully verified; identical |
| **B.4 AI Guardrails** | Multi-tier input/output guardrails & hint leak protection | `guardrails.py::clean_input` | Fully verified; identical |
