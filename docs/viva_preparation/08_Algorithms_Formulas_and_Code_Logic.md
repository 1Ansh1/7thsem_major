# Document 8: Algorithms, Mathematical Formulas & Implementation Logic

> **Focus**: Step-by-Step Algorithmic Logic, Mathematical Formulations, Worked Numerical Examples, and Complexity Analysis  
> **Source Repository Location**: `major1/backend/app/services/`  

---

## 1. Algorithm Inventory & Categorization

To answer examiners with academic precision, we strictly distinguish between **deterministic Python algorithms**, **database vector operations**, and **LLM structured generation workflows**:

| ID | Algorithm / Formula | Category | Exact File & Lines | Core Mathematical Model |
|---|---|---|---|---|
| **A01** | Skill Mastery Update | Deterministic Python | `app/services/mastery.py:56-96` | Bayesian/Elo Differential Update with Learning Rate Decay |
| **A02** | Target Difficulty Stepping | Deterministic Heuristic | `app/services/mastery.py:99-102`| 3-Tier Threshold Classifier ($<35, <70, \ge 70$) |
| **A03** | Company Readiness Score | Deterministic Python | `app/services/readiness.py:36-85`| Equation 3.1: 6-Component Weighted Multi-Criteria Metric |
| **A04** | Assessment Test Grading | Deterministic Python | `app/services/grading.py` | Marks Arithmetic with Configurable Negative Marking |
| **A05** | Interview Rubric Scaling | Deterministic Python | `app/services/interview.py:229-245`| 5-Dimension Mean Normalized to 0–100 Scale |
| **A06** | RAG Vector Search & Boost | DB & Vector Distance | `app/services/rag.py:106-141` | Cosine Distance $+ 0.05$ Topic/Company Boost with Floor |
| **A07** | Paragraph-Aware Chunking | Deterministic Python | `app/services/rag.py:41-68` | Paragraph Split with Overlap and Sentence Boundary Snapping |
| **A08** | Resume Skill Gap Matcher | Deterministic Python | `app/services/career.py:171-229`| Canonical Alias Normalization & Weighted Requirement Ratio |
| **A09** | Weakest Gap Recommendation | Deterministic Python | `app/services/readiness_data.py:150-182`| Largest Weighted Deficit Minimization ($\max[w_i(100 - c_i)]$) |
| **A10** | Smart Notification Trigger | Rule-Based Query | `app/services/notifications.py:122-194`| Timestamp Delta Scan ($\Delta t > 4\text{ days}$) on Weak Topics |
| **A11** | Dynamic Roadmap Revision | LLM + Deterministic DB | `app/services/roadmap.py:129-193`| Performance Threshold Trigger ($<50\%$) with Plan Versioning |

---

## 2. Deep Dive: The Core Mathematical Algorithms

---

### Algorithm 1: Deterministic Skill Mastery Update (`app/services/mastery.py`)

#### 1. Problem It Solves
Traditional platforms treat topic competence as a crude binary count (e.g. "Solved 10 problems"). This fails to account for:
- Whether the solved problems were trivial or difficult.
- How fast the student solved them.
- How many attempts have been made (statistical confidence).
- Whether a wrong answer was an unlucky mistake or a dangerous misconception.

#### 2. Inputs & Data Structures
- **Current State (`SkillState`)**: `mastery_score` ($0.0–100.0$), `attempt_count` ($n$), `correct_count`, `average_time_ms`, `confidence` ($[0, 1]$).
- **Attempt Evidence (`Evidence`)**: `correct` (bool), `difficulty` (`easy`, `medium`, `hard`), `time_ms` (int), `expected_time_ms` (int), `confidence` (int $1–5$).

#### 3. Mathematical Formula
$$\Delta = \text{clamp}\left(\text{lr} \times w \times (\text{target} - \text{mastery}), -15.0, +15.0\right)$$
$$\text{New Mastery} = \text{clamp}(\text{mastery} + \Delta, 0.0, 100.0)$$

Where:
1. **Target**: $\text{target} = 100.0$ if correct, $0.0$ if incorrect.
2. **Learning Rate Decay**:
   $$\text{lr} = \max\left(0.15, \frac{1}{n + 2}\right)$$
   *(First attempt $n=0 \to \text{lr} = 0.50$; tenth attempt $n=10 \to \text{lr} = 0.15$. High mobility early, high stability later).*
3. **Difficulty Weight ($d$)**:
   $$\text{easy} = 0.7, \quad \text{medium} = 1.0, \quad \text{hard} = 1.3$$
4. **Weight on Correct Answer ($w_{\text{correct}}$)**:
   $$w = d \times \text{clamp}\left(1.2 - 0.2 \times \frac{\text{time\_ms}}{\text{expected\_ms}}, 0.8, 1.1\right) \times (0.85 + 0.15 \times \text{conf})$$
   *(Speed bonus if faster than expected; low confidence slightly discounts luck).*
5. **Weight on Incorrect Answer ($w_{\text{wrong}}$)**:
   $$w = (2.0 - d) \times (1.0 + 0.3 \times \text{conf})$$
   *(Missing an easy question penalizes more: $2.0 - 0.7 = 1.3$; missing a hard question penalizes less: $2.0 - 1.3 = 0.7$. High confidence on wrong answer triggers up to a 30% misconception penalty).*

#### 4. Step-by-Step Worked Numerical Example
- **Initial State**: Student has mastery = $40.0$, attempt_count = $2$.
- **Attempt Event**: Student answers an **Easy** question ($d=0.7$) **incorrectly**, with **high self-reported confidence** ($5/5 \to \text{conf} = 1.0$).
- **Calculations**:
  1. Learning rate: $\text{lr} = \max(0.15, 1/(2 + 2)) = 1/4 = 0.25$.
  2. Weight: $w = (2.0 - 0.7) \times (1.0 + 0.3 \times 1.0) = 1.3 \times 1.3 = 1.69$.
  3. Raw delta: $\text{delta} = 0.25 \times 1.69 \times (0.0 - 40.0) = 0.4225 \times (-40.0) = -16.90$.
  4. Clamping: $\text{clamp}(-16.90, -15.0, +15.0) = \mathbf{-15.0}$.
  5. New Mastery: $40.0 - 15.0 = \mathbf{25.0}$.
*(Notice how a confident wrong answer on an easy question penalizes the maximum possible 15 points!)*

#### 5. Complexity & Implementation
- **Time Complexity**: $O(1)$ — constant time algebraic arithmetic.
- **Space Complexity**: $O(1)$ — pure immutable dataclass replacement (`dataclasses.replace`).
- **Code Path**: `backend/app/services/mastery.py:56-96`.

---

### Algorithm 2: Company Readiness Score (Equation 3.1) (`app/services/readiness.py`)

#### 1. Problem It Solves
Students lack an objective, single-number assessment of how prepared they are for a target company's hiring threshold. Simple averages fail because they don't reflect company-specific weighting (e.g. Amazon caring much more about DSA than general aptitude).

#### 2. Inputs
Stored database attempt records across 6 components:
- $\text{DSA} \in [0, 100]$: DSA Mastery blended with coding acceptance ratio.
- $\text{CSF} \in [0, 100]$: Weighted mastery across DBMS, OS, Computer Networks, and OOP.
- $\text{Coding} \in [0, 100]$: Accepted distinct problem ratio blended with solve speed.
- $\text{Aptitude} \in [0, 100]$: Quantitative & logical aptitude accuracy percentage.
- $\text{Interview} \in [0, 100]$: Scaled mean score from completed mock interviews.
- $\text{Consistency} \in [0, 100]$: Preparation streak and active day ratio in a 14-day window.

#### 3. Mathematical Formula (Equation 3.1)
$$\text{CRS} = w_{\text{dsa}} \cdot \text{DSA} + w_{\text{csf}} \cdot \text{CSF} + w_{\text{coding}} \cdot \text{Coding} + w_{\text{apt}} \cdot \text{Aptitude} + w_{\text{int}} \cdot \text{Interview} + w_{\text{cons}} \cdot \text{Consistency}$$

**Default Weights**:
$$w_{\text{dsa}} = 0.25, \quad w_{\text{csf}} = 0.20, \quad w_{\text{coding}} = 0.20, \quad w_{\text{apt}} = 0.15, \quad w_{\text{int}} = 0.10, \quad w_{\text{cons}} = 0.10$$
$$\sum w_i = 1.0$$

#### 4. Sub-Component Formulations
1. **DSA Formula (`dsa_component`)**:
   $$\text{DSA} = 0.70 \cdot \text{DSA\_Mastery} + 0.30 \cdot \left(\frac{\text{DSA\_Coding\_Accepted}}{\text{DSA\_Coding\_Attempted}} \times 100\right)$$
2. **Coding Formula (`coding_component`)**:
   $$\text{Coding} = 70 \cdot \left(\frac{\text{Accepted}}{\text{Attempted}}\right) + 30 \cdot \text{mean}\left(\min\left(1.0, \frac{\text{Expected Time}}{\text{Actual Time}}\right)\right)$$
3. **Consistency Formula (`consistency_component`)**:
   $$\text{Consistency} = 50 \cdot \left(\frac{\min(\text{Streak}, 14)}{14}\right) + 50 \cdot \left(\frac{\text{Active Days in Last 14}}{14}\right)$$

#### 5. Step-by-Step Worked Numerical Example
- **Inputs**:
  - $\text{DSA} = 80.0$
  - $\text{CSF} = 65.0$
  - $\text{Coding} = 75.0$
  - $\text{Aptitude} = 80.0$
  - $\text{Interview} = 70.0$
  - $\text{Consistency} = 60.0$
- **Calculation**:
  $$\text{CRS} = (0.25 \times 80.0) + (0.20 \times 65.0) + (0.20 \times 75.0) + (0.15 \times 80.0) + (0.10 \times 70.0) + (0.10 \times 60.0)$$
  $$\text{CRS} = 20.00 + 13.00 + 15.00 + 12.00 + 7.00 + 6.00 = \mathbf{73.00\%}$$

#### 6. Complexity & Code Path
- **Time Complexity**: $O(N)$ where $N$ is the count of stored submission and mastery records for that user (typically under 500 records; executes in $<7\text{ms}$).
- **Code Path**: `backend/app/services/readiness.py:36-43`, `backend/app/services/readiness_data.py:51-143`.

---

### Algorithm 3: RAG Retrieval, Cosine Similarity & Metadata Re-Ranking (`app/services/rag.py`)

#### 1. Problem It Solves
Identifies the most semantically relevant learning chunks for a student query while prioritizing documents tagged with the student's current topic and target company.

#### 2. Vector Cosine Distance
Given query vector $Q \in \mathbb{R}^{768}$ and document vector $D \in \mathbb{R}^{768}$:
$$\text{sim}(Q, D) = \frac{\sum_{i=1}^{768} Q_i D_i}{\sqrt{\sum_{i=1}^{768} Q_i^2} \sqrt{\sum_{i=1}^{768} D_i^2}}$$
In PostgreSQL with `pgvector`:
$$\text{dist}(Q, D) = 1 - \text{sim}(Q, D) = Q \Leftrightarrow D$$

#### 3. Re-Ranking Formula with Metadata Boosting
$$\text{Final Rank Score}(D) = \text{sim}(Q, D) + \text{boost}_{\text{topic}}(D) + \text{boost}_{\text{company}}(D)$$
Where:
- $\text{boost}_{\text{topic}} = +0.05$ if $D.\text{topic\_id} \in \text{query\_scope}$ else $0.0$.
- $\text{boost}_{\text{company}} = +0.05$ if $D.\text{company\_id} == \text{target\_company}$ else $0.0$.

#### 4. Floor Cutoff & Anti-Hallucination Gate
$$\text{Filtered Chunks} = \{D \mid \text{Final Rank Score}(D) \ge 0.55\}$$
If $\text{Filtered Chunks} == \emptyset$, the LLM is **never invoked**. The system returns an immediate refusal: *"The course knowledge base doesn't cover this yet, so I won't guess."*

#### 5. Complexity
- **Time Complexity**:
  - PostgreSQL with HNSW Index: $O(\log M)$ where $M$ is total chunks.
  - SQLite dev fallback: $O(M \times 768)$ in-memory linear scan.
- **Code Path**: `backend/app/services/rag.py:113-141`.

---

### Algorithm 4: Largest Weighted Gap Recommendation Engine (`app/services/readiness_data.py`)

#### 1. Problem It Solves
When a student finishes an assessment or logs into their dashboard, what should they study next? Rather than picking a random topic, the system identifies the action that will yield the **maximum mathematical increase** in their Company Readiness Score.

#### 2. Formula: Weighted Deficit Minimization
For each component $k \in \{\text{dsa}, \text{csf}, \text{coding}, \text{aptitude}, \text{interview}, \text{consistency}\}$:
$$\text{Deficit}(k) = w_k \times (100.0 - \text{Component Score}_k)$$
$$\text{Worst Component} = \arg\max_{k} \text{Deficit}(k)$$

#### 3. Worked Example
Suppose weights and current scores are:
- $\text{DSA}$: $w=0.25$, score = $80$ $\to \text{Deficit} = 0.25 \times 20 = \mathbf{5.0}$
- $\text{CSF}$: $w=0.20$, score = $50$ $\to \text{Deficit} = 0.20 \times 50 = \mathbf{10.0}$
- $\text{Coding}$: $w=0.20$, score = $70$ $\to \text{Deficit} = 0.20 \times 30 = \mathbf{6.0}$
- $\text{Aptitude}$: $w=0.15$, score = $90$ $\to \text{Deficit} = 0.15 \times 10 = \mathbf{1.5}$
- $\text{Interview}$: $w=0.10$, score = $0$ $\to \text{Deficit} = 0.10 \times 100 = \mathbf{10.0}$
- $\text{Consistency}$: $w=0.10$, score = $60$ $\to \text{Deficit} = 0.10 \times 40 = \mathbf{4.0}$

**Decision**: CSF and Interview tie for the largest weighted gap ($10.0$). The engine recommends:
*"Study Operating Systems: CS Fundamentals is your largest weighted gap; Operating Systems has the lowest topic mastery."*

#### 4. Code Path
- `backend/app/services/readiness_data.py:150-182` (`recommend()`).

---

### Algorithm 5: Deterministic Resume vs Job Description Matcher (`app/services/career.py`)

#### 1. Problem It Solves
Comparing resumes to job descriptions using pure LLM prompts results in subjective, non-reproducible percentages. PrepPath uses LLMs only for text extraction; the skill comparison is 100% deterministic.

#### 2. Canonical Normalization & Aliases
Every extracted skill string is lowercased, stripped of punctuation, and mapped through a canonical alias dictionary (`app/services/career.py:149-160`):
$$\text{norm}(\text{'Postgres'}) = \text{'postgresql'}, \quad \text{norm}(\text{'NodeJS'}) = \text{'node.js'}, \quad \text{norm}(\text{'OOPs'}) = \text{'oop'}$$

#### 3. Weighted Requirement Scoring
- Required skills carry weight $W=2$.
- Preferred technologies carry weight $W=1$.
$$\text{Job Readiness \%} = 100 \times \frac{\sum_{r \in \text{Matched}} W(r)}{\sum_{r \in \text{Total Requirements}} W(r)}$$

#### 4. Worked Example
- Job Description requires:
  - `Python` (Required, $W=2$)
  - `SQL` (Required, $W=2$)
  - `Docker` (Technology, $W=1$)
  - `Redis` (Technology, $W=1$)
  - Total Weight = $2 + 2 + 1 + 1 = 6$.
- Student Resume contains: `Python`, `Postgres` (mapped to `SQL`), and `Git`.
  - Matched: `Python` (2), `SQL` (2). Matched Weight = $4$.
  - Missing: `Docker` (1), `Redis` (1). Missing Weight = $2$.
$$\text{Job Readiness \%} = 100 \times \frac{4}{6} = \mathbf{66.7\%}$$
- Missing skills trigger automatic remediation links to platform topics (e.g. `SQL` $\to$ `/study/sql`).

#### 5. Code Path
- `backend/app/services/career.py:193-229` (`compare()`).

---

## 3. Algorithm Complexity & Performance Summary

| Algorithm | Implementation Function | Measured Mean Latency | Time Complexity | Space Complexity |
|---|---|---|---|---|
| Elo Mastery Update | `mastery.py:update_mastery` | 0.0018 ms | $O(1)$ | $O(1)$ |
| Question Difficulty Stepping | `mastery.py:target_difficulty` | 0.0005 ms | $O(1)$ | $O(1)$ |
| Readiness Equation 3.1 | `readiness_data.py:gather` | 6.26 ms | $O(N)$ (DB query) | $O(N)$ |
| Vector Cosine Search | `rag.py:search` | 15.58 ms | $O(\log M)$ (HNSW) | $O(K)$ |
| Resume Deterministic Match | `career.py:compare` | 0.04 ms | $O(R \times S)$ | $O(R + S)$ |
| Assessment Test Auto-Grading| `grading.py:grade_attempt` | 2.91 ms | $O(Q)$ (Test size) | $O(Q)$ |
