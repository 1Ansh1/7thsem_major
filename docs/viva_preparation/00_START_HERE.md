# PrepPath — Master Viva Preparation & Technical Defense Guide
## Complete System Understanding, Architectural Traceability, and University Viva Defense

> **Project Title**: PrepPath — AI-Powered Adaptive Placement Preparation Platform  
> **Academic Institution**: Jaypee Institute of Information Technology (JIIT), Noida — Department of Computer Science & Engineering and Information Technology  
> **Authors**: Palak Mathur, Ansh Upadhyay, Tanmay Gupta  
> **Supervisor**: Respected Deepti Singh  
> **Repository Location**: `c:\Users\Asus\Documents\Major project\major1`  
> **Documentation Target Directory**: `docs/viva_preparation/`  

---

## 1. Welcome & Purpose of This Guide

You have built a sophisticated, production-grade, and academically rigorous placement preparation system. Tomorrow, when you present this project to your college professors and external viva examiners, they will not merely ask you to click buttons on a screen. 

They will test whether **you understand the underlying computer science**:
- Did you actually write this system, or did you stitch together random tutorials?
- What happens internally when a student clicks *"Run Code"* or *"Start Study Session"*?
- Why did you use Judge0 CE instead of `exec()` or `subprocess` in Python?
- Where is Generative AI used, where is RAG used, and where is **deterministic engineering** strictly enforced?
- How is the Company Readiness Score calculated? Is it an arbitrary heuristic or an auditable formula?
- How does the system adapt dynamically when a student fails a topic?

This comprehensive guide was generated following a complete, read-only inspection of your actual repository. Every file path, database model, API endpoint, mathematical formula, and algorithm referenced in this document exists in your code.

---

## 2. Quick-Start Viva Study Roadmap (How to Study Tonight)

Depending on how many hours you have before your viva presentation tomorrow, follow one of these three tracks:

```text
Track A: Deep Preparation (4–5 Hours)
├── 1. Read 01_Project_Overview_and_Problem_Statement.md (Understand the "Why")
├── 2. Read 02_System_Architecture.md & view diagrams (Trace the request pipeline)
├── 3. Read 04_Feature_by_Feature_Implementation.md (Master all 20 modules)
├── 4. Read 05_AI_ML_RAG_and_Agentic_AI_Explained.md (Master RAG & 7 Agents)
├── 5. Read 08_Algorithms_Formulas_and_Code_Logic.md (Master Eq. 3.1 & Elo updates)
├── 6. Practice 12_Project_Demonstration_Script.md (Rehearse live 12-min demo)
└── 7. Test yourself with 13_Viva_Questions_and_Answers.md & 14_Cross_Questioning.md

Track B: Express Preparation (2 Hours)
├── 1. Read 01_Project_Overview_and_Problem_Statement.md (Elevator pitches)
├── 2. Read 02_System_Architecture.md (Understand frontend-to-backend flow)
├── 3. Read 08_Algorithms_Formulas_and_Code_Logic.md (Know Eq. 3.1 & Elo cold)
├── 4. Read 12_Project_Demonstration_Script.md (Know exactly what to click and say)
└── 5. Read 14_Cross_Questioning_and_Tricky_Questions.md (Know examiner traps)

Track C: Emergency 15-Minute Revision (Outside the Exam Hall)
└── Read 15_One_Page_Last_Minute_Revision.md (Memorize the cheat sheet)
```

---

## 3. Master Index of the Documentation Suite

The complete viva preparation suite is organized into 16 documents and 9 architecture diagrams:

| File Name | Primary Topic & Content | Key Viva Takeaway |
|---|---|---|
| [`00_START_HERE.md`](file:///c:/Users/Asus/Documents/Major%20project/major1/docs/viva_preparation/00_START_HERE.md) | Navigation guide, study roadmaps, exam strategy | Orientation and study plan |
| [`01_Project_Overview_and_Problem_Statement.md`](file:///c:/Users/Asus/Documents/Major%20project/major1/docs/viva_preparation/01_Project_Overview_and_Problem_Statement.md) | 30s/1m/2m project pitches, core motivation, problem statement | How to introduce your project |
| [`02_System_Architecture.md`](file:///c:/Users/Asus/Documents/Major%20project/major1/docs/viva_preparation/02_System_Architecture.md) | Ground-up architecture, modular monolith, layers, execution tracing | High-level engineering defense |
| [`03_Technology_Stack_Explained.md`](file:///c:/Users/Asus/Documents/Major%20project/major1/docs/viva_preparation/03_Technology_Stack_Explained.md) | Why Next.js 15, FastAPI, SQLAlchemy, pgvector, Judge0, Celery, Redis | Justifying every tech decision |
| [`04_Feature_by_Feature_Implementation.md`](file:///c:/Users/Asus/Documents/Major%20project/major1/docs/viva_preparation/04_Feature_by_Feature_Implementation.md) | Deep breakdown of all 20 modules with 3-level explanations | The master feature bible |
| [`05_AI_ML_RAG_and_Agentic_AI_Explained.md`](file:///c:/Users/Asus/Documents/Major%20project/major1/docs/viva_preparation/05_AI_ML_RAG_and_Agentic_AI_Explained.md) | Generative AI, Gemini, RAG HNSW search, 7 Bounded Agents, Guardrails | Defending the AI implementation |
| [`06_Database_and_Data_Flow.md`](file:///c:/Users/Asus/Documents/Major%20project/major1/docs/viva_preparation/06_Database_and_Data_Flow.md) | Complete schema, 17 tables, foreign keys, lifecycle tracing | Database viva questions |
| [`07_API_and_Backend_Workflow.md`](file:///c:/Users/Asus/Documents/Major%20project/major1/docs/viva_preparation/07_API_and_Backend_Workflow.md) | All 45+ REST endpoints, Pydantic contracts, middleware | Backend & API defense |
| [`08_Algorithms_Formulas_and_Code_Logic.md`](file:///c:/Users/Asus/Documents/Major%20project/major1/docs/viva_preparation/08_Algorithms_Formulas_and_Code_Logic.md) | Equation 3.1, Bayesian Elo mastery, Cosine search, Rank weakness | Mathematical rigor & worked examples |
| [`09_Security_Testing_and_DevOps.md`](file:///c:/Users/Asus/Documents/Major%20project/major1/docs/viva_preparation/09_Security_Testing_and_DevOps.md) | Argon2id, JWT rotation, Judge0 isolation, Docker Compose, 90 tests | Security & infrastructure defense |
| [`10_Comparison_with_Existing_Platforms.md`](file:///c:/Users/Asus/Documents/Major%20project/major1/docs/viva_preparation/10_Comparison_with_Existing_Platforms.md) | PrepPath vs LeetCode, GfG, HackerRank, PrepInsta, InterviewBit | Proving unique academic value |
| [`11_Project_Limitations_and_Future_Scope.md`](file:///c:/Users/Asus/Documents/Major%20project/major1/docs/viva_preparation/11_Project_Limitations_and_Future_Scope.md) | Honest assessment of limits, scalability challenges, roadmap | Humility and maturity in viva |
| [`12_Project_Demonstration_Script.md`](file:///c:/Users/Asus/Documents/Major%20project/major1/docs/viva_preparation/12_Project_Demonstration_Script.md) | Step-by-step 12-minute presentation and live demo walkthrough | What to click, show, and say |
| [`13_Viva_Questions_and_Answers.md`](file:///c:/Users/Asus/Documents/Major%20project/major1/docs/viva_preparation/13_Viva_Questions_and_Answers.md) | 125 curated Q&As across Sections A through I | Comprehensive exam question bank |
| [`14_Cross_Questioning_and_Tricky_Questions.md`](file:///c:/Users/Asus/Documents/Major%20project/major1/docs/viva_preparation/14_Cross_Questioning_and_Tricky_Questions.md) | 45 high-pressure, skeptical external examiner questions | Handling aggressive cross-examination |
| [`15_One_Page_Last_Minute_Revision.md`](file:///c:/Users/Asus/Documents/Major%20project/major1/docs/viva_preparation/15_One_Page_Last_Minute_Revision.md) | The ultra-compact cheat sheet of formulas, ports, and facts | 10-minute pre-viva memory refresher |

### Dedicated Architecture Diagrams (`docs/viva_preparation/diagrams/`)
1. [`System_Architecture.mmd`](file:///c:/Users/Asus/Documents/Major%20project/major1/docs/viva_preparation/diagrams/System_Architecture.mmd): Overall multi-tier system topology.
2. [`Authentication_Flow.mmd`](file:///c:/Users/Asus/Documents/Major%20project/major1/docs/viva_preparation/diagrams/Authentication_Flow.mmd): Argon2id, 15m in-memory JWT, httpOnly cookie rotation, and reuse revocation.
3. [`Study_Mode_Flow.mmd`](file:///c:/Users/Asus/Documents/Major%20project/major1/docs/viva_preparation/diagrams/Study_Mode_Flow.mmd): 8-step adaptive diagnostic, explanation, and worked-example loop.
4. [`Assessment_Flow.mmd`](file:///c:/Users/Asus/Documents/Major%20project/major1/docs/viva_preparation/diagrams/Assessment_Flow.mmd): Timed company test, server deadline, Monaco/Judge0 execution, and grading.
5. [`RAG_AI_Tutor_Flow.mmd`](file:///c:/Users/Asus/Documents/Major%20project/major1/docs/viva_preparation/diagrams/RAG_AI_Tutor_Flow.mmd): Paragraph chunking, Gemini 768-d vector search, prompt encapsulation, and citation verification.
6. [`Agent_Orchestration_Flow.mmd`](file:///c:/Users/Asus/Documents/Major%20project/major1/docs/viva_preparation/diagrams/Agent_Orchestration_Flow.mmd): Triage dispatching across 7 bounded agents and dynamic roadmap revision.
7. [`Mock_Interview_Flow.mmd`](file:///c:/Users/Asus/Documents/Major%20project/major1/docs/viva_preparation/diagrams/Mock_Interview_Flow.mmd): Conversational multi-turn interview and 5-dimension rubric evaluation.
8. [`Readiness_Score_Flow.mmd`](file:///c:/Users/Asus/Documents/Major%20project/major1/docs/viva_preparation/diagrams/Readiness_Score_Flow.mmd): Gathering components for Equation 3.1 and weight overrides.
9. [`Data_Flow.mmd`](file:///c:/Users/Asus/Documents/Major%20project/major1/docs/viva_preparation/diagrams/Data_Flow.mmd): End-to-end data lifecycle from attempt to mastery to readiness.

---

## 4. The Three Golden Rules of Your Viva Defense

Examiners respect honest engineering far more than inflated marketing claims. Keep these three principles in mind during your viva:

### Rule 1: Always Defend the Strict Boundary Between Deterministic Logic and Generative AI
- **What is Deterministic**: Code judging (Judge0 CE), test grading, Equation 3.1 Company Readiness Score, Bayesian/Elo skill mastery updates, resume skill matching (alias normalizer), and student data export.
- **What is Generative AI**: Concept explanations (RAG AI Tutor), directional hints, interview questions, interview rubric scoring, roadmap schedule synthesis, and code review suggestions.
- **Why this impresses examiners**: If an examiner asks, *"What if your LLM hallucinates an answer or awards 100 marks to wrong code?"*, you can immediately answer:  
  *"Sir/Ma'am, that is architecturally impossible in PrepPath. The LLM has zero authority over code execution or scoring. Code is executed inside an isolated Judge0 sandbox that returns authoritative verdicts. The Company Readiness Score is computed by pure, auditable Python functions from stored attempt records. The LLM is strictly confined to explanatory tutoring and conversational coaching under Pydantic schema validation and citation guardrails."*

### Rule 2: Acknowledge Real Boundaries Transparently
- If asked about Mock Interviews: *"Communication and Confidence dimensions are inferred from the structure, precision, and decisiveness of the student's written technical responses. We do not perform video facial tracking or speech acoustics, and our UI explicitly discloses this ethical boundary."*
- If asked about Company Intelligence: *"Company profiles reflect observed historical preparation patterns and publicly shared syllabus distributions, not an official recruiter endorsement. We enforce a mandatory pattern disclaimer on all company endpoints."*

### Rule 3: Use the 3-Level Explanation Technique
Whenever asked about any feature:
1. **Level 1 (Concept/Analogy)**: Explain what it achieves in plain English using a simple metaphor.
2. **Level 2 (Technical Details)**: Name the exact file, class, database table, HTTP endpoint, and algorithm.
3. **Level 3 (Viva Defense)**: State the design trade-off and explain why alternative approaches were rejected.

---

## 5. Verified Codebase Facts (Zero Guesswork)

When teachers question whether this project is tested, you have verified empirical facts:
- **Backend Test Suite**: 90/90 tests passing (`pytest` with SQLite in-memory, covering auth, judging, study, tests, readiness, interview, roadmap, notifications, and privacy).
- **Frontend Quality**: TypeScript compile check (`tsc --noEmit`) passes with 0 errors across all 28 Next.js App Router pages.
- **Benchmark Suite**: Assessment pipeline benchmark (`benchmark_pipeline.py`) measured mean latencies (e.g., MCQ scoring: 0.0018ms, Judge0 verdict: 0.003s mock / ~1.5s live, Vector retrieval: 15.58ms).
- **RAG Evaluation Harness**: RAG retrieval evaluation (`rag_eval_harness.py`) measured Faithfulness (0.857), Answer Relevance (0.885), Context Recall (1.0), Citation Accuracy (0.988), and Out-of-Corpus Refusal Correctness (1.0).

Proceed now to [`01_Project_Overview_and_Problem_Statement.md`](file:///c:/Users/Asus/Documents/Major%20project/major1/docs/viva_preparation/01_Project_Overview_and_Problem_Statement.md) to begin your preparation.
