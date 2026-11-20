# Document 1: Project Overview and Problem Statement

> **Target Audience**: University Viva Examiners, Project Review Committee, Academic Supervisors  
> **Applicable Project**: PrepPath — AI-Powered Adaptive Placement Preparation Platform  
> **Source Repository Location**: `major1/`  

---

## 1. What is PrepPath?

### 1.1 One-Sentence Explanation
> **PrepPath** is an integrated, company-targeted engineering placement preparation platform that combines sandboxed code execution, deterministic skill-mastery tracking, and retrieval-augmented generative AI into a unified, adaptive learning workflow.

### 1.2 30-Second Elevator Pitch
"Good morning, esteemed committee members. Most computer science students prepare for campus placements using disconnected websites—practicing DSA on LeetCode, reading core CS theory on GeeksforGeeks, and taking general aptitude quizzes elsewhere. They receive no company-specific feedback or unified readiness metric. **PrepPath** solves this fragmentation. It unites company-specific intelligence, an adaptive study loop with deterministic Elo-based skill tracking, sandboxed Judge0 coding evaluations, an ethical RAG-grounded AI Tutor, interactive mock interviews, and an auditable Company Readiness Score (Equation 3.1) that dynamically adapts daily study roadmaps when students struggle."

### 1.3 One-Minute Academic Pitch
"PrepPath is an adaptive placement preparation platform designed to bridge the gap between academic learning and corporate technical recruitment. Current students face two major hurdles: preparation fragmentation and generic learning paths that fail to align with specific company evaluation patterns. 

PrepPath addresses this through a modular, dual-engine architecture:
1. **The Deterministic Foundation**: Code is compiled and evaluated inside a sandboxed Judge0 environment across C++, Java, Python, and JavaScript. Student topic mastery is calculated using a deterministic Bayesian/Elo update formula with learning rate decay, speed adjustments, and confidence penalties. Company readiness is quantified through Equation 3.1—a 6-component weighted metric that is 100% auditable and never hallucinated.
2. **The Bounded Generative AI Layer**: Using Google Gemini and RAG over vector embeddings with pgvector HNSW indexing, PrepPath provides Socratic explanations, directional hints, interactive mock interviews across a 5-dimension rubric, and dynamic roadmap revision. Crucially, the AI is bounded by strict Pydantic contracts and safety guardrails, ensuring that generative models never evaluate code or assign marks."

### 1.4 Detailed Two-Minute Comprehensive Explanation
"In undergraduate engineering, campus recruitment represents the single most critical transition point for computer science students. However, the preparation ecosystem is broken into silos:
- Students solve hundreds of algorithmic puzzles on competitive programming platforms without knowing if those problems reflect their target company's online assessment (OA) patterns.
- Core Computer Science Fundamentals (DBMS, Operating Systems, Computer Networks, and OOP) are studied passively from static notes without active diagnostic recall.
- Mock interviews are either non-existent or arranged informally with no objective rubric scoring.
- Students have no single, reliable metric that tells them: *'Based on your actual practice data, how prepared are you for Amazon vs TCS vs Microsoft?'*

PrepPath was engineered to replace this fragmented experience with an end-to-end, personalized preparation pipeline. A student selects their target company and target role. The platform automatically maps company-specific skill weights and frequently tested topics. 

The student enters **Adaptive Study Mode**, which uses an 8-step interactive loop: diagnostic question, measured accuracy, self-reported confidence, RAG-grounded conceptual explanation, worked examples with numbered reasoning, and follow-up mini-quizzes.

When practicing coding, code is evaluated by an asynchronous **Judge0 CE** pipeline executing multi-test batches in an isolated container. The authoritative Judge0 verdict then feeds into an AI Code Review service that analyzes time and space complexity while strictly prohibiting the LLM from contradicting the judge's verdict.

Student competence across DSA, CS Fundamentals, Coding Speed, Aptitude, Mock Interviews, and Daily Consistency is continuously aggregated into the **Company Readiness Score (CRS)**. If an assessment reveals a critical learning gap—for instance, scoring below 50% on Graph algorithms—the **Recommendation Agent** dynamically revises the student's active roadmap, inserting remedial BFS/DFS practice and postponing advanced topics. Every number displayed to the student is mathematically grounded in stored database records, establishing a trustworthy, transparent learning environment."

---

## 2. Problem Statement: The Reality of Placement Preparation

```text
The Traditional Placement Preparation Reality: Fragmented & Generic
┌─────────────────┐   ┌─────────────────┐   ┌─────────────────┐   ┌─────────────────┐
│  LeetCode / CF  │   │ GeeksforGeeks   │   │ IndiaBIX / Prep │   │ Static PDF JDs  │
│  (DSA Only)     │   │ (Static Notes)  │   │ (Aptitude Only) │   │ (No Feedback)   │
└────────┬────────┘   └────────┬────────┘   └────────┬────────┘   └────────┬────────┘
         │                     │                     │                     │
         └───────────────┬─────┴─────────────────────┴─────────────────────┘
                         ▼
             NO Unified Readiness Metric
             NO Company-Specific Skill Weighting
             NO Adaptive Feedback Loop
             NO Socratic AI Tutoring
                         │
                         ▼
┌───────────────────────────────────────────────────────────────────────────────────┐
│ PrepPath: Unified, Adaptive, Company-Oriented & Mathematically Grounded Platform │
└───────────────────────────────────────────────────────────────────────────────────┘
```

### 2.1 Difficulties with Traditional Preparation
1. **Tool and Context Fragmentation**: A candidate must juggle 4–5 browser tabs: one for coding puzzles, one for CS theory articles, one for quantitative aptitude, one for resume formatting, and unstructured chat prompts for doubts. No single system correlates performance across these domains.
2. **Generic vs Company-Specific Preparation**: The hiring criteria of a product company (e.g., Amazon focusing 45% on DSA, graph algorithms, and OOP) differ fundamentally from a mass-recruitment service firm (e.g., TCS focusing 30% on quantitative aptitude, CS fundamentals, and basic coding). Generic preparation forces students to over-prepare in irrelevant areas while neglecting essential company requirements.
3. **Passive Reading vs Active Diagnostic Recall**: Students read dense articles on Operating Systems (e.g., virtual memory or process synchronization) without being tested on edge cases or common placement traps.
4. **Lack of Objective Readiness Feedback**: Students enter recruitment drives guessing their readiness. Without a unified scoring model, anxiety increases and preparation remains disorganized.
5. **Generic Chatbot Hallucinations**: When students consult general LLMs (ChatGPT, Claude) for placement doubts, the models often provide overly verbose, ungrounded code, hallucinate library features, or reveal solutions prematurely instead of providing pedagogical Socratic guidance.

---

## 3. Implemented Project Objectives

PrepPath implements the following tangible engineering objectives:

- **Objective 1: Multi-Tenant Identity & Scoped Authorization**: Secure authentication with Argon2id password hashing, 15-minute in-memory JWTs, rotating httpOnly refresh cookies with session reuse detection, and 3-tier Role-Based Access Control (`student`, `content_manager`, `admin`).
- **Objective 2: Company Intelligence Modeling**: Structured schema modeling target companies (e.g., Amazon, TCS, Microsoft) with skill weighting distributions, OA pattern durations, frequent topics, and mandatory disclaimer enforcement.
- **Objective 3: Hierarchical Skill Graph & Elo-Based Mastery**: Tree-structured taxonomy (DSA, DBMS, OS, CN, OOP, Aptitude) tracking student competence through a deterministic Bayesian/Elo update formula with learning rate decay and confidence penalties.
- **Objective 4: Sandboxed Multi-Language Code Evaluation**: Integration with Judge0 CE via asynchronous job queues, isolating execution of C++, Java, Python, JavaScript, and SQL with memory/time limit enforcement and hidden test cases.
- **Objective 5: RAG-Grounded AI Tutoring**: Retrieval-Augmented Generation using 768-dimensional Gemini embeddings, paragraph-aware chunking, pgvector HNSW search (with SQLite fallback), and 6 bounded tutoring modes with citation validation.
- **Objective 6: Auditable Company Readiness Score (Equation 3.1)**: Pure mathematical calculation combining DSA, CSF, Coding, Aptitude, Mock Interview, and Consistency into a single 0–100 score with company weight overrides.
- **Objective 7: Conversational Mock Interviews**: Multi-turn technical and HR mock interview console with a 5-dimension rubric (Technical Knowledge, Problem Solving, Communication, Confidence, Concept Accuracy) on a 1–10 scale.
- **Objective 8: Multi-Agent Dynamic Roadmap Revision**: Seven bounded agents (Triage, Tutor, Assessment, Interview, Placement, Analytics, Recommendation) that synthesize and adapt daily preparation roadmaps when students fail topic thresholds.
- **Objective 9: Student Data Privacy & GDPR/DPDP Portability**: Full JSON export (`/api/v1/users/me/export`) and complete cascading account deletion (`/api/v1/users/me`) with file unlinking.

---

## 4. Target Users

| User Persona | Typical Scenario | PrepPath Value Proposition |
|---|---|---|
| **Final-Year B.Tech Student** | Preparing for on-campus drives 4 weeks away. | Selects company (e.g. Amazon), receives tailored 20-day roadmap, practices OA-style tests, and monitors readiness score. |
| **Pre-Final Year Aspirant** | Building fundamental computer science and coding skills. | Uses Study Mode for Socratic learning, builds topic mastery from Easy to Hard, and tracks streak consistency. |
| **Placement Cell & Content Manager** | Curating high-yield placement questions. | Creates and reviews questions, sets hidden test cases, and tags questions to specific company hiring patterns. |
| **System Administrator** | Auditing system health and AI safety. | Monitors AI token usage, costs, latencies, cache hit rates, and reviews AI-generated question queues. |

---

## 5. Complete Platform Workflow: From Registration to Readiness

```text
1. Student Registration & Profile Setup
   ├── Enters target companies (e.g. Amazon, TCS) & target role (SDE)
   └── Selects preferred programming language (Python, C++, Java, JS)
                   │
                   ▼
2. Baseline Diagnostic & Active Roadmap
   ├── Multi-Agent Orchestrator generates a customized daily preparation plan
   └── Initial diagnostic checks establish starting skill graph mastery
                   │
                   ▼
3. Adaptive Study Loop
   ├── Diagnostic question -> Student submits answer + confidence rating
   ├── RAG AI Tutor serves grounded explanation & worked example
   └── Deterministic mastery algorithm updates skill node score
                   │
                   ▼
4. Practical Application: Coding & Timed OA Tests
   ├── Writes code in Monaco Editor -> Dispatched to Judge0 Sandbox
   ├── Timed assessment engine simulates actual company test environment
   └── Post-test AI code review analyzes complexity & potential defects
                   │
                   ▼
5. Interactive Mock Interview
   ├── Multi-turn conversational interview tailored to company & role
   └── Graded across 5 rubric dimensions -> Scaled to 0–100 score
                   │
                   ▼
6. Company Readiness Score & Adaptive Plan Revision
   ├── Equation 3.1 recalculates overall company readiness
   ├── If weak areas detected (<50%), Recommendation Agent adapts roadmap
   └── Student downloads complete learning record or reviews analytics
```

---

## 6. What Makes PrepPath Different?

| Architectural Dimension | Traditional Prep Sites (LeetCode, GfG, etc.) | PrepPath Platform |
|---|---|---|
| **Preparation Scope** | Siloed (DSA only or Theory articles only) | Unified (DSA + Core CS + Aptitude + Mock Interview + Roadmaps) |
| **Company Targeting** | Tagged question lists without weighting | Formal company skill weights (e.g., 45% DSA, 20% CSF) driving score calculation |
| **Skill Mastery** | Binary solved count (e.g., "150 Solved") | Continuous Bayesian/Elo mastery score incorporating speed, difficulty, and confidence |
| **Code Evaluation** | Monolithic server execution | Sandboxed Judge0 CE container execution with strict isolation |
| **AI Tutoring** | Generic ungrounded chat prompts | RAG with pgvector HNSW search, citation checking, and refusal on ungrounded queries |
| **Score Trustworthiness** | Opaque ranking numbers | Auditable Equation 3.1 grounded in database records |
| **Roadmap Dynamism** | Static lists of problems | Dynamically revised schedule responding to student assessment failures |

---

## 7. Expected Academic & Practical Outcomes

### Genuine Implemented Outcomes
- **Elimination of Context Switching**: Students can practice coding, revise CS core subjects, take company-specific timed tests, and participate in mock interviews within a single authenticated session.
- **Transparent Preparation Visibility**: Students see exactly why their readiness is 68.5% (e.g., "DSA is 75%, but CSF is only 42% because DBMS and OS haven't been practiced").
- **Pedagogical Integrity**: The AI Tutor gives hints and worked examples without leaking answers or allowing code review to override judge verdicts.

### What PrepPath Honestly Does NOT Claim
- **No Guaranteed Placement**: PrepPath does not claim that using the platform guarantees a job offer. Hiring depends on recruiter evaluations, economic conditions, and communication dynamics.
- **No Official Recruiter Data**: Company profiles represent observed preparation patterns, not secret recruitment rubrics.
- **No Video Emotion Recognition**: Mock interviews evaluate written technical responses, not facial expressions or voice acoustics.
