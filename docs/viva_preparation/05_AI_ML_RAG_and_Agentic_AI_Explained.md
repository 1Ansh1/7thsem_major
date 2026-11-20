# Document 5: AI, Machine Learning, RAG and Agentic Architecture Explained

> **Target Audience**: AI/ML Viva Examiners, External Technical Evaluators, University Faculty  
> **Applicable Project**: PrepPath — AI-Powered Adaptive Placement Preparation Platform  
> **Source Repository Location**: `major1/backend/app/services/`  

---

## 1. Fundamentals of Generative AI & Large Language Models

To defend PrepPath in a university viva, you must understand the exact computer science foundations behind the AI components.

### 1.1 What is Generative AI vs Traditional/Predictive ML?
- **Traditional / Predictive Machine Learning**: Focuses on mapping inputs to categorical labels or continuous values (e.g., classification, regression). It predicts $P(Y \mid X)$ based on historical statistical patterns.
- **Generative AI**: Focuses on learning the joint probability distribution $P(X)$ or conditional probability distribution $P(Y \mid X)$ over high-dimensional token sequences to generate novel, coherent content (text, code, structured JSON).
- **In PrepPath**:
  - Predictive/Deterministic Math: Equation 3.1 Company Readiness Score and Bayesian/Elo Skill Mastery calculations.
  - Generative AI: Socratic conceptual explanations, worked examples, mock interview dialogues, and personalized study schedules.

### 1.2 What is a Large Language Model (LLM)?
An LLM is a deep neural network based on the **Transformer architecture** (specifically the autoregressive decoder stack). It processes text as discrete sub-word units called **tokens** and computes a probability distribution over the vocabulary for the next token:
$$P(w_t \mid w_1, w_2, \dots, w_{t-1})$$

In PrepPath, we use **Google Gemini**:
- **Fast / Lightweight Tasks (`gemini-flash-lite-latest`)**: Used for quick directional hinting, follow-up trivia, and diagnostic parsing.
- **Strong / Complex Tasks (`gemini-flash-latest`)**: Used for 5-dimension mock interview rubric evaluation, AI code reviews, question generation, and multi-agent triage routing.
- **Deterministic Mock Mode (`MockLLMClient`)**: Active when `GEMINI_API_KEY` is not set; generates realistic, reproducible JSON envelopes for offline development and testing.

### 1.3 What is Prompt Engineering & Structured Outputs?
Prompt engineering is the systematic design of inputs to guide an LLM's outputs toward desired behaviors without modifying its weights.

In PrepPath, we implement **Structured Output Contracts** rather than raw text generation:
1. **System Prompt (`SYSTEM_BASE` in `app/services/guardrails.py:17`)**:
   > *"You are an expert computer science tutor and placement preparation mentor for engineering students. Be technically precise, clear, and encouraging. Cite sources when provided. Never invent facts."*
2. **Input Boundary Encapsulation**: Student queries are wrapped inside `<student_input>...</student_input>` tags to prevent prompt injection attacks.
3. **Pydantic JSON Schema Contract**: Every call passes a strict JSON Schema generated from a Pydantic model (`ExplainOut`, `HintOut`, `InterviewEvaluationOut`). Gemini's `response_mime_type="application/json"` and `response_schema` parameters force the model to output valid, structured JSON matching our contract.
4. **Re-Validation**: The raw response is re-parsed through Pydantic. If validation fails, it is caught and handled safely.

---

## 2. Retrieval-Augmented Generation (RAG) Architecture

```text
┌────────────────────────────────────────────────────────────────────────────────────────┐
│                        PHASE 1: DOCUMENT INGESTION PIPELINE                            │
│  Syllabus Notes / Curated CS Documents (DSA, DBMS, OS, CN, OOP)                        │
│                                    │                                                   │
│                                    ▼                                                   │
│  Paragraph-Aware Chunking: size=900 chars, overlap=150 chars (app/services/rag.py)     │
│                                    │                                                   │
│                                    ▼                                                   │
│  Dense Vector Embedding: Gemini gemini-embedding-001 (768 dimensions)                  │
│                                    │                                                   │
│                                    ▼                                                   │
│  Vector Storage: PostgreSQL documents.embedding with HNSW Index (Cosine Distance)      │
└────────────────────────────────────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────────────────────────────────────┐
│                       PHASE 2: GROUNDED RETRIEVAL & GENERATION                         │
│  Student Query: "Explain deadlock prevention vs avoidance"                             │
│                                    │                                                   │
│                                    ▼                                                   │
│  Input Sanitization: check prompt injection, check length (guardrails.py:clean_input)  │
│                                    │                                                   │
│                                    ▼                                                   │
│  Query Embedding: Convert query string to 768-d vector qv                              │
│                                    │                                                   │
│                                    ▼                                                   │
│  Cosine Distance Search: 1 - (embedding <=> qv) with Topic/Company Boost (+0.05)       │
│                                    │                                                   │
│                                    ▼                                                   │
│  Similarity Floor Check: Discard chunks with score < 0.55                              │
│         ├── Chunks Empty ──► Refuse to guess (Anti-Hallucination Refusal)              │
│         └── Chunks Found ──► Format Top Chunks into [S1], [S2] Source Blocks           │
│                                    │                                                   │
│                                    ▼                                                   │
│  Prompt Injection: Grounded context + Student query + Structured Pydantic Schema       │
│                                    │                                                   │
│                                    ▼                                                   │
│  Gemini Structured Call: Returns JSON validated against Pydantic schema               │
│                                    │                                                   │
│                                    ▼                                                   │
│  Citation Guardrail: Verify all cited [S#] exist in retrieved sources                  │
│                                    │                                                   │
│                                    ▼                                                   │
│  Commit Audit Trace: Latency, tokens, cost logged in ai_traces                         │
└────────────────────────────────────────────────────────────────────────────────────────┘
```

### 2.1 Why Ordinary LLM Prompting Is Insufficient
If you simply ask an ungrounded LLM: *"Explain B-Tree node splitting rules for our DBMS course"*, several risks emerge:
1. **Hallucination**: LLMs generate plausible-sounding but factually incorrect assertions (e.g. inventing non-existent database parameters or syntax).
2. **Lack of Syllabus Alignment**: The LLM may explain an advanced academic variant rather than the standard textbook definition expected in university campus placements.
3. **No Provenance**: The student cannot verify where the answer came from or check source course materials.

### 2.2 What Are Embeddings and Vector Search?
- **Embedding**: A mapping of high-dimensional discrete tokens into a continuous low-dimensional vector space ($\mathbb{R}^{768}$). Words and sentences with similar semantic meanings are mapped to vectors that lie close to each other in geometric space.
- **Cosine Similarity Formula**: Measures the cosine of the angle between two non-zero vectors $A$ and $B$:
  $$\text{Cosine Similarity}(A, B) = \frac{A \cdot B}{\|A\|_2 \|B\|_2} = \frac{\sum_{i=1}^{n} A_i B_i}{\sqrt{\sum_{i=1}^{n} A_i^2} \sqrt{\sum_{i=1}^{n} B_i^2}}$$
- **Cosine Distance**: In pgvector, distance is defined as:
  $$\text{Cosine Distance}(A, B) = 1 - \text{Cosine Similarity}(A, B)$$
  A distance of $0.0$ means identical orientation; a distance near $1.0$ means orthogonal (unrelated).

### 2.3 Document Ingestion & Chunking Strategy
Implemented in `backend/app/services/rag.py`:
- **Paragraph-Aware Splitting**: `chunk_text(text, size=900, overlap=150)` splits text on double newlines (`\n\n`) to preserve semantic thought boundaries.
- **Giant Paragraph Handling**: If a single paragraph exceeds 900 characters, it finds the nearest sentence boundary (`. `) to avoid cutting words in half.
- **Overlap**: A 150-character overlap between consecutive chunks ensures that concepts spanning a boundary are not lost.
- **Storage**: Chunks are stored in the `documents` table with `chunk_index`, `topic_id`, and `company_id`.

### 2.4 Indexing & Retrieval
- **PostgreSQL / pgvector**: Uses an **HNSW (Hierarchical Navigable Small World)** index. HNSW creates a multi-layered geometric graph that allows approximate nearest neighbor (ANN) search in $O(\log N)$ time rather than scanning every document in $O(N)$.
- **SQLite Fallback**: In local development (`app/core/config.py:database_url` with SQLite), `rag.py:_cos()` computes the exact dot product and Euclidean norm across all stored chunks in Python memory.
- **Metadata Boosting (`rag.py:127-133`)**:
  $$\text{Rank Score} = \text{Cosine Similarity} + \text{Topic Boost} (0.05) + \text{Company Boost} (0.05)$$
  Prioritizes chunks tagged with the student's current topic or target company.
- **Similarity Floor (`rag.py:21-22`)**: Enforces a minimum cosine similarity floor ($\ge 0.55$ for real Gemini embeddings). Chunks below this floor are discarded as irrelevant.

### 2.5 Citation Verification Guardrail
In `backend/app/services/guardrails.py:check_citations()`:
- The system parses all citation references emitted by the LLM (e.g. `[S12]`, `[S15]`).
- Every citation is matched against the list of chunks actually retrieved for that turn.
- If the LLM invents a phantom citation (e.g., citing `[S99]` when only `S1` and `S2` were passed), the hallucinated citation is stripped before returning the payload to the frontend.

---

## 3. The Seven Bounded Agents & Multi-Agent Orchestration

### 3.1 What Makes an Agent Different from a Simple Chatbot?
| Dimension | Traditional Chatbot | PrepPath Bounded Agent |
|---|---|---|
| **Interaction Model** | Reactive text generator | Proactive, goal-oriented specialist |
| **State Awareness** | Limited to current chat session | Accesses skill graph, attempt history, and deadlines |
| **Output Format** | Unstructured markdown / prose | Strict Pydantic typed data contracts |
| **Tool Execution** | None (cannot trigger backend changes)| Modifies roadmaps, schedules revisions, queries DB |
| **Decision Authority**| None | Enforces pedagogical and difficulty rules |

### 3.2 The Seven Bounded Agents in Detail

```text
                                  ┌────────────────────────┐
                                  │     Student Query /    │
                                  │   Assessment Evidence  │
                                  └───────────┬────────────┘
                                              │
                                              ▼
                                 ┌──────────────────────────┐
                                 │     1. TRIAGE AGENT      │
                                 │ (Classifies Intent 0..1) │
                                 └────────────┬─────────────┘
                                              │
         ┌───────────────┬────────────────────┼───────────────────┬────────────────┐
         ▼               ▼                    ▼                   ▼                ▼
┌─────────────────┐ ┌───────────────┐ ┌───────────────┐ ┌───────────────────┐ ┌────────────────────┐
│ 2. TUTOR AGENT  │ │3. ASSESSMENT  │ │4. INTERVIEW   │ │5. PLACEMENT AGENT │ │6. ANALYTICS AGENT  │
│ (RAG Socratic   │ │   AGENT       │ │   AGENT       │ │(Synthesizes Daily │ │(Audits Mastery,    │
│  Explanations)  │ │(Stepped Quizzes││(5-Dim Rubric) │ │  20-Day Roadmap)  │ │ CRS Trends, Gaps)  │
└─────────────────┘ └───────────────┘ └───────────────┘ └─────────┬─────────┘ └────────────────────┘
                                                                  │
                                                                  ▼
                                                      ┌─────────────────────────┐
                                                      │ 7. RECOMMENDATION AGENT │
                                                      │ (Dynamic Plan Revision  │
                                                      │  on Assessment Failure) │
                                                      └─────────────────────────┘
```

#### Agent 1: Triage Agent
- **Purpose**: Acts as the central traffic controller, classifying free-form student input into one of six domain intents.
- **Input**: User raw text query.
- **Output**: `TriageDecisionOut` (intent: `tutor | assessment | interview | placement_roadmap | analytics | recommendation`, confidence: float 0–1, reasoning: string).
- **Implementation**: `app/services/agents/orchestrator.py:triage_student_intent()`.
- **Model**: Calls `gemini-flash-latest` with `TriageDecisionOut` schema.

#### Agent 2: Tutor Agent
- **Purpose**: Delivers pedagogical instruction across 6 bounded modes (Explain, Hint, Worked Example, Interviewer, Evaluate, Follow-up, Revision).
- **Input**: Question text, topic context, student draft attempt.
- **Output**: Typed envelope (`ExplainOut`, `HintOut`, `WorkedExampleOut`) with verified citations.
- **Implementation**: `app/services/tutor.py`.
- **Model**: RAG search + Gemini Flash + Guardrails.

#### Agent 3: Assessment Agent
- **Purpose**: Selects diagnostic questions matching the student's target difficulty.
- **Input**: Topic ID, student current skill mastery score.
- **Output**: Filtered question records with answers stripped.
- **Implementation**: `app/services/mastery.py:target_difficulty()`, `app/routers/study.py`.
- **Decision Logic**: **Deterministic**: $<35 \to \text{easy}$, $35\text{--}70 \to \text{medium}$, $\ge 70 \to \text{hard}$.

#### Agent 4: Interview Agent
- **Purpose**: Conducts multi-turn technical/HR mock interviews and evaluates performance across a 5-dimension rubric.
- **Input**: Target company, target role, previous turn transcript, student written answer.
- **Output**: Probing follow-up questions (`TurnFollowUpOut`) and final evaluation (`InterviewEvaluationOut`).
- **Implementation**: `app/services/interview.py`.
- **Model**: Gemini Strong (`gemini-flash-latest`).

#### Agent 5: Placement Agent
- **Purpose**: Constructs a customized, daily preparation schedule targeting a specific company's hiring pattern.
- **Input**: Company name, preparation days (e.g. 20), daily study hours, student skill summary, weak topics.
- **Output**: `GeneratedRoadmapPlanOut` (daily schedules with topics, minutes, problem counts, and mini-assessments).
- **Implementation**: `app/services/agents/orchestrator.py:placement_agent_build_roadmap()`.
- **Model**: Gemini Strong (`gemini-flash-latest`).

#### Agent 6: Analytics Agent
- **Purpose**: Aggregates stored attempt records to compute domain mastery, consistency streaks, and Company Readiness Score.
- **Input**: Stored records in `attempts`, `submissions`, `mastery`, `interviews`.
- **Output**: Performance trendlines, readiness radar, and ranked weakest topics.
- **Implementation**: `app/services/readiness_data.py`, `app/routers/progress.py`.
- **Decision Logic**: **Deterministic** mathematical execution (Equation 3.1).

#### Agent 7: Recommendation Agent
- **Purpose**: Dynamically adapts the active roadmap when assessment evidence indicates a critical learning gap.
- **Input**: Original roadmap plan, struggled topic name (e.g. "Graphs"), assessment score ($<50\%$), target company.
- **Output**: `RoadmapRevisionOut` (revision reason, modified day numbers, extended topics, postponed topics, updated schedule).
- **Implementation**: `app/services/agents/orchestrator.py:recommendation_agent_revise_roadmap()`.
- **Model**: Gemini Strong + DB transaction updating `roadmaps` version and logging `recommendations`.

---

## 4. Deterministic vs Probabilistic Architecture Boundary

Examiners frequently scrutinize whether students understand which parts of their system are deterministic and which parts are probabilistic:

```text
THE STRICT ARCHITECTURAL SEPARATION:
┌──────────────────────────────────────────────────────────────────────────────────┐
│                           DETERMINISTIC SUBSYSTEMS                               │
│ • Code Compilation & Test Case Verdicts (Judge0 CE Isolated Sandbox)             │
│ • Skill Mastery Score Updates (Bayesian Elo Differential Formula)               │
│ • Company Readiness Score (Equation 3.1 Weighted Multi-Criteria Metric)          │
│ • Test Grading & Score Deductions (Negative Marking Arithmetic)                 │
│ • Resume Skill Gap Matching (Canonical Alias Normalization & Weighted Match %)  │
│ • Student Data Export & Account Erasure (Relational Cascades & Disk Unlinking)  │
└──────────────────────────────────────────────────────────────────────────────────┘
                                         ▲
                           STRICT ARCHITECTURAL BOUNDARY
                  (LLM has ZERO authority over these subsystems)
                                         ▼
┌──────────────────────────────────────────────────────────────────────────────────┐
│                           PROBABILISTIC / AI SUBSYSTEMS                          │
│ • RAG-Grounded Socratic Tutoring & Explanations (Gemini Flash + Context Chunks)  │
│ • Directional Hints (Bounded by Answer Leakage Guardrails)                       │
│ • Mock Interview Turn Generation & Probing Follow-Up Queries                    │
│ • 5-Dimension Interview Rubric Scoring (Technical, Problem Solving, Comm, etc.) │
│ • Company Preparation Schedule Synthesis (Placement Agent Roadmap Plan)         │
│ • Code Complexity & Style Annotation (AI Code Review Post-Judge0 Execution)      │
└──────────────────────────────────────────────────────────────────────────────────┘
```

---

## 5. Cost Control, Rate Limiting & Observability

To prevent runaway API bills and protect backend availability, PrepPath enforces multi-tiered cost and reliability controls (`app/services/llm.py`):

1. **Per-User Rate Limiting**: Maximum 12 AI requests per minute per authenticated user (`app/core/config.py:ai_requests_per_minute`). Exceeding this returns an HTTP 429 Too Many Requests error.
2. **Daily Token Budget**: Maximum 150,000 tokens per user per day (prompt tokens + completion tokens). Enforced by querying the sum of tokens in `ai_traces` for the last 24 hours. If exceeded, raises `BudgetExceeded`.
3. **Response Caching**: Responses for identical inputs (e.g. explaining a standard syllabus topic with the same retrieved chunks) are cached for 6 hours (`ai_cache_ttl_seconds = 21600`) in Redis or memory.
4. **Comprehensive Auditing (`ai_traces` table)**: Every single LLM or embedding call writes a record:
   - `call_type`: `explain`, `hint`, `interview_turn`, `parse_resume`, etc.
   - `model`: `gemini-flash-latest`, `gemini-flash-lite-latest`, or `gemini-embedding-001`.
   - `prompt_tokens`, `completion_tokens`, `latency_ms`.
   - `cost_usd`: Estimated using published Google Cloud token pricing ($0.10/1M prompt for flash-lite, $0.30/1M prompt for flash).
   - `success`: Boolean flag; records full stack trace in `error` text column if failed.
