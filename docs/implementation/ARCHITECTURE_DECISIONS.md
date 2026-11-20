# PrepPath: Architectural Decision Records (ADRs)

This document records the foundational architectural decisions governing the design, implementation, and boundaries of the PrepPath platform.

---

## ADR 01: Modular Monolith vs Microservices

### Context
The platform comprises several distinct functional subsystems: learning (Study Mode), assessment (Test Mode), code judging (Judge0 integration), AI tutoring (RAG), career analytics, and user management.

### Decision
Adopt a **modular monolith** with internal service boundaries, supplemented by an asynchronous worker tier (Redis + Celery), rather than a distributed microservices architecture.

### Rationale
- **Academic and Team Scope**: At this development stage and throughput requirement, network boundaries, distributed transactions, cross-service schema synchronization, and independent CI/CD pipelines introduce high operational friction without scaling benefits.
- **Transactional Consistency**: Relational database joins between student attempt records, questions, topics, and skill graphs preserve ACID properties cleanly.
- **Evolutionary Path**: Clear internal service packages (`app/services/{study, assessment, judge, rag, interview, roadmap}`) preserve the option to extract microservices if scaling demands dictate.

---

## ADR 02: Strict Boundary Between Deterministic Logic & Generative AI

### Context
A recurring flaw in naive AI education systems is delegating correctness decisions, test verdicts, or numerical grades to large language models, leading to non-reproducible grades, hallucinations, and unverified pass/fail status.

### Decision
Enforce a hard, unbreachable boundary in code:
1. **Code Execution & Correctness**: Only Judge0 executing inside an isolated sandbox against hidden test cases determines pass/fail and test verdicts. The language model never determines code correctness.
2. **AI Code Review**: Runs strictly AFTER the Judge0 verdict is recorded. A post-processor strips any generative sentences that contradict the judge verdict (e.g., claiming code has a bug when it passed all tests, or claiming code is correct when it failed).
3. **Company Readiness Score**: Computed deterministically by Equation 3.1:
   $$\text{Readiness} = 0.25 \cdot \text{DSA} + 0.20 \cdot \text{CSF} + 0.20 \cdot \text{Coding} + 0.15 \cdot \text{Aptitude} + 0.10 \cdot \text{Interview} + 0.10 \cdot \text{Consistency}$$
   The language model may explain or summarize this score, but cannot calculate or override it.

---

## ADR 03: Unified Relational + Vector Storage via PostgreSQL & pgvector

### Context
The platform requires traditional relational tables for user identities, assessments, submissions, and skill mastery, alongside vector embeddings (768-d) for semantic search over curated preparation documents.

### Decision
Use PostgreSQL with the `pgvector` extension (using HNSW indexing) as the single primary datastore, with an in-Python cosine distance fallback for SQLite during local lightweight testing.

### Rationale
- Avoids the operational overhead, cost, and synchronization issues of introducing a separate specialized vector database (e.g., Pinecone, Qdrant, Milvus).
- Enables relational joins between vector chunks and topic/company metadata in a single SQL query.
- HNSW (Hierarchical Navigable Small World) indexes provide sub-10ms retrieval latency over institutional-scale document corpuses.

---

## ADR 04: Six Bounded AI Tutor Modes vs Free-Form Chatbot

### Context
Free-form chat interfaces in tutoring platforms often fail pedagogically by prematurely revealing complete solutions when students only ask for a hint, or drifting off-topic.

### Decision
Structure the AI Tutor into six bounded modes, each with strict system instructions and Pydantic output schemas:
1. **EXPLAIN**: Beginner-friendly explanation grounded in retrieved sources with mandatory citations.
2. **HINT**: Directional, progressive guidance that strictly withholds the final code/answer.
3. **INTERVIEWER**: Realistic technical and behavioral questions matched to company and difficulty.
4. **EVALUATE**: Structured rubric scoring of student written answers against expected concepts.
5. **FOLLOW-UP**: Conditioned follow-up probing deeper on previous student answers.
6. **REVISION**: Remedial questions targeting previously failed assessment items.

---

## ADR 05: Human-in-the-Loop AI Question Guardrails

### Context
AI-generated questions can hallucinate incorrect options, invalid test cases, or flawed explanations.

### Decision
Implement a multi-stage guardrail pipeline:
$$\text{Generation} \longrightarrow \text{Pydantic Schema Validation} \longrightarrow \text{Judge0 Reference Validation (Coding)} \longrightarrow \text{Admin Review Queue} \longrightarrow \text{Publication}$$
No AI-generated question is ever visible to students until an authorized Content Manager or Administrator reviews and approves it in the Admin Review Queue (`/admin/review`).
