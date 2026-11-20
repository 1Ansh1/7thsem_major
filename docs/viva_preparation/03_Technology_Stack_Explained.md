# Document 3: Technology Stack Explained & Technical Distinctions

> **Target Audience**: Viva Examiners, Architecture Reviewers, Technical Panel  
> **Applicable Project**: PrepPath — AI-Powered Adaptive Placement Preparation Platform  
> **Source Repository Location**: `major1/`  

---

## 1. Complete Technology Inventory

Every technology in PrepPath was selected to solve a concrete engineering requirement. The table below outlines each primary technology in the repository:

### 1.1 Frontend Technologies

#### Next.js 15.1 (App Router)
| Question | Technical Explanation |
|---|---|
| **What is it?** | A production React framework providing server-side rendering, hybrid static rendering, file-based routing, and asset optimization. |
| **Why did we use it?** | Placement dashboards require fast initial page loads (SSR) combined with responsive client-side state for code editors and real-time timers. Next.js App Router provides nested layouts, route grouping `(app)`, and optimized bundle splitting. |
| **Where is it used?** | `frontend/package.json`, `frontend/src/app/` (all 28 routes, nested layouts, and page entrypoints). |
| **How does it work here?** | Root layout provides fonts and theme tokens; `(app)/layout.tsx` enforces client-side authentication checks; subpages render dynamic components. |
| **What alternatives existed?** | Vite + React SPA, Remix, Create React App. |
| **Why is our selection reasonable?** | Vite requires separate routing and client-only rendering, leading to blank loading screens. Next.js App Router handles server-rendered shells and client interactivity seamlessly. |
| **What could a teacher ask?** | *"Why not use plain React with Vite?"* $\to$ **Viva Answer**: *"Vite builds purely client-side Single Page Applications. The initial HTML is an empty `<div>`, meaning the browser must download and execute the entire JavaScript bundle before rendering anything. Next.js pre-renders the HTML shell on the server, improving perceived performance and SEO, while providing built-in route layouts and middleware."* |

---

#### TypeScript 5.7
| Question | Technical Explanation |
|---|---|
| **What is it?** | A statically typed superset of JavaScript that compiles to plain JavaScript. |
| **Why did we use it?** | Complex placement platforms handle diverse data shapes: submission verdicts, interview transcripts, readiness breakdowns, and mastery trees. TypeScript catches type mismatches at compile time rather than during live runtime. |
| **Where is it used?** | Throughout `frontend/src/`, specifically `src/lib/types.ts` and `src/lib/judge.ts`. |
| **How does it work here?** | TypeScript interfaces (`SubmissionView`, `VerdictView`, `Profile`, `InterviewView`) mirror FastAPI Pydantic schemas, guaranteeing frontend-backend contract harmony. `tsc --noEmit` verifies 0 errors across the codebase. |
| **What alternatives existed?** | Plain JavaScript (ES6+), JSDoc. |
| **Why is our selection reasonable?** | In a project with 28 routes and 45+ API endpoints, JavaScript's dynamic typing leads to subtle runtime `TypeError: undefined is not a function` bugs. TypeScript prevents this entirely. |
| **What could a teacher ask?** | *"Does TypeScript run in the browser?"* $\to$ **Viva Answer**: *"No, browsers only execute JavaScript. TypeScript is stripped during the build step (`next build`) by the SWC compiler, leaving clean, optimized JavaScript while giving developers compile-time type safety."* |

---

#### Monaco Editor (`@monaco-editor/react` v4.7)
| Question | Technical Explanation |
|---|---|
| **What is it?** | The browser-based code editor that powers Microsoft Visual Studio Code. |
| **Why did we use it?** | Placement exams require realistic code editor features: syntax highlighting, auto-indentation, bracket matching, line numbers, and multi-language support (Python, C++, Java, JS, SQL). |
| **Where is it used?** | `frontend/src/components/CodeEditor.tsx` and `CodeWorkbench.tsx`. |
| **How does it work here?** | Loaded dynamically with SSR disabled (`next/dynamic` with `ssr: false`). Synchronizes theme with the platform's dark/light mode token and provides draft caching to browser `localStorage`. |
| **What alternatives existed?** | CodeMirror, Ace Editor, plain `<textarea>`. |
| **Why is our selection reasonable?** | CodeMirror is lightweight but requires extensive manual plugin configuration to match modern IDE feel. Monaco gives students the exact interface used in real company assessment platforms like HackerRank and Mercer Mettl. |
| **What could a teacher ask?** | *"Why did you set `ssr: false` when loading Monaco?"* $\to$ **Viva Answer**: *"Monaco directly accesses browser window APIs (`window`, `document`) that do not exist during Next.js Node.js server-side rendering. Disabling SSR avoids hydration mismatch errors."* |

---

#### Recharts (v2.15)
| Question | Technical Explanation |
|---|---|
| **What is it?** | A composable charting library built on React components and SVG. |
| **Why did we use it?** | To render interactive performance visualizations: daily accuracy curves, company readiness horizontal bars, topic mastery distributions, and solve-time histograms. |
| **Where is it used?** | `frontend/src/components/charts.tsx`, `src/app/(app)/analytics/page.tsx`, `readiness/[slug]/page.tsx`. |
| **How does it work here?** | Receives structured analytics data from `GET /api/v1/me/analytics` and renders animated SVG paths with tooltips, legend indicators, and responsive container wrapping. |
| **What alternatives existed?** | Chart.js, D3.js, Plotly. |
| **Why is our selection reasonable?** | D3 requires imperative DOM manipulation that conflicts with React's virtual DOM. Recharts is purely declarative and React-native. |
| **What could a teacher ask?** | *"What happens if the student has no practice data?"* $\to$ **Viva Answer**: *"The component renders a clean, accessible `<EmptyState>` placeholder with an invitation to take a practice test, avoiding broken or zeroed-out SVG axes."* |

---

### 1.2 Backend & Core Services

#### FastAPI (0.115) & Python 3.12
| Question | Technical Explanation |
|---|---|
| **What is it?** | A modern, high-performance, asynchronous web framework for building APIs with Python based on standard type hints. |
| **Why did we use it?** | Our backend handles asynchronous operations: Judge0 polling, vector searches, and LLM streaming. FastAPI runs on ASGI (Uvicorn), providing high concurrency with non-blocking I/O. |
| **Where is it used?** | `backend/app/main.py` and all 15 routers in `backend/app/routers/`. |
| **How does it work here?** | Every endpoint is declared as an `async def`. FastAPI automatically validates inputs against Pydantic schemas, generates interactive Swagger docs (`/api/docs`), and handles dependency injection. |
| **What alternatives existed?** | Flask, Django, Express.js. |
| **Why is our selection reasonable?** | Flask is synchronous by default (WSGI) and requires third-party extensions for validation and Swagger. Django is overly heavyweight for a REST-only API. FastAPI offers speed comparable to Node/Go with native Python AI integration. |
| **What could a teacher ask?** | *"How is FastAPI faster than Flask?"* $\to$ **Viva Answer**: *"Flask uses WSGI which handles requests synchronously—one thread per request. FastAPI runs on Starlette and Uvicorn using ASGI (Asynchronous Server Gateway Interface), leveraging Python's `asyncio` event loop. It can handle thousands of concurrent I/O-bound requests on a single worker without thread blocking."* |

---

#### Pydantic v2
| Question | Technical Explanation |
|---|---|
| **What is it?** | Data validation and settings management library using Python type annotations. |
| **Why did we use it?** | To enforce strict contracts on API requests, responses, database serialization, and crucially, **LLM structured output validation**. |
| **Where is it used?** | `backend/app/schemas/`, `app/core/config.py`, and inside all AI services (`ExplainOut`, `HintOut`, `InterviewEvaluationOut`). |
| **How does it work here?** | Validates incoming JSON before endpoint execution. When calling Gemini LLM, Pydantic generates the JSON Schema passed to the model, and parses the returned JSON string back into a verified object. |
| **What alternatives existed?** | Marshmallow, Cerberus, manual dictionary checks. |
| **Why is our selection reasonable?** | Pydantic v2 core is rewritten in Rust, making it up to 20x faster than traditional Python validation libraries. |
| **What could a teacher ask?** | *"What happens if the LLM returns an invalid JSON string?"* $\to$ **Viva Answer**: *"Pydantic raises a `ValidationError`. Our guardrail layer catches this, logs the failure in `ai_traces`, and either retries or triggers a safe deterministic fallback rather than crashing the API."* |

---

#### SQLAlchemy 2.0 (Async) & Alembic
| Question | Technical Explanation |
|---|---|
| **What is it?** | The premier Object-Relational Mapper (ORM) for Python, providing asynchronous database access, combined with Alembic for versioned schema migrations. |
| **Why did we use it?** | To abstract SQL interactions into Python classes while preserving full support for complex joins, transactions, JSON columns, and vector similarity operators. |
| **Where is it used?** | `backend/app/models/`, `backend/app/core/db.py`, `backend/alembic/versions/`. |
| **How does it work here?** | Uses `AsyncSession` with `asyncpg` (PostgreSQL) or `aiosqlite` (SQLite). Migration `0001_initial.py` creates all 17 tables, foreign key constraints, and HNSW indexes. |
| **What alternatives existed?** | Raw SQL, Tortoise ORM, Peewee, Django ORM. |
| **Why is our selection reasonable?** | SQLAlchemy 2.0 provides mature type-hinted mapped columns (`Mapped[int]`), supports async natively, and works across PostgreSQL and SQLite without changing model code. |
| **What could a teacher ask?** | *"What is the difference between SQLAlchemy and PostgreSQL?"* $\to$ **Viva Answer**: *"PostgreSQL is the database management system (the engine running on disk/port 5432). SQLAlchemy is an application-level library (ORM) that translates Python objects and queries into SQL statements executed by PostgreSQL."* |

---

### 1.3 Database & Infrastructure Technologies

#### PostgreSQL 16 & pgvector
| Question | Technical Explanation |
|---|---|
| **What is it?** | An enterprise-grade ACID relational database combined with the `pgvector` open-source extension for vector similarity search. |
| **Why did we use it?** | To avoid the architectural complexity and cost of running a separate dedicated vector database (e.g. Pinecone). Storing both relational records (users, submissions) and vector embeddings (course notes) in one database enables unified transactions. |
| **Where is it used?** | Configured in `major1/docker-compose.yml`, mapped in `app/models/base.py` and `app/models/content.py`. |
| **How does it work here?** | Document chunks store 768-dimensional float arrays (`vector(768)`). An HNSW (Hierarchical Navigable Small World) index accelerates cosine distance queries (`<=>`). |
| **What alternatives existed?** | Pinecone, Milvus, Weaviate, ChromaDB. |
| **Why is our selection reasonable?** | Dedicated vector databases introduce distributed state, separate billing, and foreign-key disconnects. `pgvector` allows querying vector similarity and relational filters (`WHERE topic_id = 5`) in a single SQL query. |
| **What could a teacher ask?** | *"How does pgvector perform similarity search?"* $\to$ **Viva Answer**: *"It builds an HNSW graph index over the vector space. During a query, it traverses this graph using approximate nearest neighbor (ANN) search to find chunks with the minimum cosine distance (`1 - cos_sim`)."* |

---

#### SQLite (`dev.db`)
| Question | Technical Explanation |
|---|---|
| **What is it?** | A self-contained, serverless, zero-configuration SQL database engine. |
| **Why did we use it?** | To enable instant local development, offline developer workflows, and rapid unit testing without requiring a live Docker or PostgreSQL daemon. |
| **Where is it used?** | Default `DATABASE_URL` in `app/core/config.py` (`sqlite+aiosqlite:///./dev.db`). |
| **How does it work here?** | When SQLite is detected, vector columns degrade gracefully to JSON arrays, and cosine similarity is calculated in-memory via pure Python (`app/services/rag.py:_cos`). |
| **What alternatives existed?** | Forcing PostgreSQL for all environments. |
| **Why is our selection reasonable?** | Allows a student or teacher to clone the repository and run `pytest` or `start.bat` immediately without configuring database servers. |
| **What could a teacher ask?** | *"Can SQLite be used in production for this platform?"* $\to$ **Viva Answer**: *"No. SQLite locks the entire database file on write transactions, which creates a bottleneck under concurrent user load. In production, we deploy PostgreSQL with connection pooling via Docker Compose."* |

---

#### Redis 7 & Celery
| Question | Technical Explanation |
|---|---|
| **What is it?** | Redis is an in-memory key-value data store used as a message broker and cache; Celery is an asynchronous distributed task queue. |
| **Why did we use it?** | To handle asynchronous background jobs: dispatching code batches to Judge0, embedding uploaded documents, parsing PDF resumes, and caching AI responses. |
| **Where is it used?** | `backend/app/worker.py`, `backend/app/services/jobs.py`, and `docker-compose.yml`. |
| **How does it work here?** | When `REDIS_URL` is set, `jobs.enqueue()` sends Celery tasks to the Redis broker. A Celery worker processes them concurrently. If Redis is absent, `jobs.py` gracefully falls back to in-process `asyncio.create_task`. |
| **What alternatives existed?** | RabbitMQ, Apache Kafka, synchronous request execution. |
| **Why is our selection reasonable?** | RabbitMQ is complex to configure; Kafka is designed for high-throughput stream processing. Redis is lightweight, fast, and doubles as an LRU response cache for AI queries. |
| **What could a teacher ask?** | *"Why not run Celery tasks directly inside the FastAPI thread?"* $\to$ **Viva Answer**: *"FastAPI's event loop must stay responsive to incoming web requests. CPU-intensive operations (like PDF parsing) or high-latency network operations (polling Judge0) would block the event loop, degrading the response time for all active users."* |

---

### 1.4 Code Execution & Artificial Intelligence

#### Judge0 CE (Community Edition)
| Question | Technical Explanation |
|---|---|
| **What is it?** | An open-source, robust, and sandboxed code execution system. |
| **Why did we use it?** | Running untrusted student code directly on the application server (e.g. via `exec()` or `subprocess.run()`) is a catastrophic security vulnerability (remote code execution, fork bombs, server takeover). |
| **Where is it used?** | `backend/app/services/judge.py`, `backend/app/services/judging.py`. |
| **How does it work here?** | Code submissions are packaged into JSON batches with base64-encoded `source_code`, `stdin`, `expected_output`, `cpu_time_limit`, and `memory_limit`. Dispatched over HTTP to `https://ce.judge0.com` or local Judge0 container. |
| **What alternatives existed?** | Docker-in-Docker subprocess execution, PyPypy sandbox, direct Python `exec()`. |
| **Why is our selection reasonable?** | Judge0 isolates execution inside secure Linux cgroups and seccomp filters, automatically enforcing CPU limits, RAM limits, and capturing isolated compilation and runtime error streams. |
| **What could a teacher ask?** | *"Why can't we just compare the student's code text with a reference answer using AI?"* $\to$ **Viva Answer**: *"Code correctness cannot be verified by string matching or LLM reading. A correct solution can be written in infinite syntactic variations, and an LLM cannot reliably detect off-by-one errors or $O(N^2)$ time-limit violations. Code must be compiled and executed against edge-case test vectors in a sandbox."* |

---

#### Google Gemini API (`gemini-flash-latest`, `gemini-embedding-001`)
| Question | Technical Explanation |
|---|---|
| **What is it?** | Google's multimodal large language model family, offering high speed, large context windows, and native structured JSON outputs. |
| **Why did we use it?** | To power the AI Tutor, interactive mock interviews, resume parsing, and adaptive roadmap synthesis with high semantic accuracy and low latency. |
| **Where is it used?** | `backend/app/services/llm.py`, `app/services/rag.py`, `app/services/tutor.py`. |
| **How does it work here?** | Cheap model (`gemini-flash-lite-latest`) handles fast tasks (hinting, trivia); strong model (`gemini-flash-latest`) handles evaluations and mock interviews. `gemini-embedding-001` outputs 768-dimensional dense vectors. |
| **What alternatives existed?** | OpenAI GPT-4o, Anthropic Claude 3.5, Local Ollama / LLaMA-3. |
| **Why is our selection reasonable?** | Gemini provides a generous free tier for academic projects, natively enforces JSON schema contracts, and produces compact 768-d embeddings well-suited for pgvector indexing. |
| **What could a teacher ask?** | *"What happens if the Gemini API key runs out of quota during your presentation?"* $\to$ **Viva Answer**: *"Our application features an automated, deterministic `MockLLMClient` fallback. If no key is set or quota is exhausted, the system seamlessly returns realistic, clearly labeled mock responses, ensuring zero presentation downtime."* |

---

## 2. Key Technical Distinctions (Examiner Favorites)

Examiners love asking comparative questions to verify fundamental engineering concepts:

```text
Summary of Key Architectural Distinctions:
1. React (Library) ───────► Next.js (Full-Stack Framework with SSR & Routing)
2. JavaScript (Dynamic) ──► TypeScript (Static Types & Compile-Time Contracts)
3. SQLAlchemy (ORM) ──────► PostgreSQL (Relational Database Engine)
4. SQLite (Single-File) ──► PostgreSQL (Enterprise Client-Server ACID Cluster)
5. Redis (In-Memory Key) ─► Relational DB (On-Disk Persistent Tabular Data)
6. Celery (Async Worker) ─► FastAPI Thread (Synchronous Event Loop)
7. pgvector (Vector HNSW) ─► Traditional SQL (B-Tree Exact Matches)
8. RAG (External Grounding)► Raw Prompting (Ungrounded Parametric Memory)
9. Agentic AI (Goal-Driven)► Simple Chatbot (Single-Turn Reactive Text)
10. Monaco Editor (UI) ────► Judge0 (Sandboxed Execution Engine)
```

### Distinction 1: React vs Next.js
- **React**: A client-side JavaScript UI library for building component trees. It does not provide routing, build optimization, or server rendering out of the box.
- **Next.js**: A full-stack framework built on top of React. It provides the **App Router**, automatic server-side rendering (SSR), static site generation (SSG), asset optimization, and API route proxying.

### Distinction 2: JavaScript vs TypeScript
- **JavaScript**: Dynamically typed; types are resolved at runtime in the browser. Type mismatches produce silent bugs or runtime crashes.
- **TypeScript**: Statically typed; enforces strict type annotations and interfaces during development. All types are validated at compile time, eliminating an entire class of runtime errors before deployment.

### Distinction 3: SQLAlchemy vs PostgreSQL
- **PostgreSQL**: The relational database management system running on port 5432 that manages storage, indexing, transactions, and ACID compliance.
- **SQLAlchemy**: The Python Object-Relational Mapping (ORM) library that translates Python classes (`User`, `Question`) into SQL queries, managing connection pooling and transaction lifecycles.

### Distinction 4: SQLite vs PostgreSQL
- **SQLite**: A serverless, in-process database that writes to a single local file (`dev.db`). Perfect for tests and local zero-setup development, but cannot support high-concurrency writes.
- **PostgreSQL**: A dedicated client-server database engine designed for enterprise production workloads, supporting connection pooling, row-level locking, and extensions like `pgvector`.

### Distinction 5: Redis vs Relational Database
- **Relational DB (Postgres)**: Persists data to disk in structured tables with foreign keys and ACID transactions. Optimized for complex queries and durability.
- **Redis**: Stores data entirely in RAM as key-value data structures (strings, hashes, lists). Optimized for sub-millisecond lookups, rate limiting, and pub/sub queues.

### Distinction 6: Celery vs Synchronous API Execution
- **Synchronous Execution**: The HTTP request handler runs the entire task while the user waits. If a task takes 3 seconds (e.g. compiling code on Judge0), the user's browser hangs and the server worker is blocked.
- **Celery**: The HTTP request handler pushes a message into Redis and immediately returns an HTTP `202 Accepted` response. A separate Celery worker process picks up the job and executes it in the background.

### Distinction 7: Vector Databases (pgvector) vs Traditional Databases
- **Traditional Relational Queries**: Compare exact values or ranges using B-Tree indexes (`WHERE topic_id = 5` or `WHERE email = 'user@example.com'`).
- **Vector Search (`pgvector`)**: Compares high-dimensional mathematical embeddings using geometric distance formulas (Cosine Distance or Euclidean Distance) via HNSW graphs to find conceptually similar text even when keywords do not match.

### Distinction 8: RAG vs Ordinary LLM Prompting
- **Ordinary Prompting**: The LLM relies solely on parameters learned during training. It has no access to your syllabus, frequently hallucinates outdated or incorrect facts, and cannot cite sources.
- **RAG (Retrieval-Augmented Generation)**: The system first searches a private, curated knowledge base for relevant document chunks, injects those chunks into the prompt as verified context, and instructs the LLM to synthesize an answer grounded strictly in those sources with citations.

### Distinction 9: Agentic AI vs Simple Chatbot
- **Simple Chatbot**: Reacts to single-turn user prompts by outputting next-token text. It has no goal awareness, cannot call external tools, and cannot adapt over time.
- **Agentic AI**: Possesses defined goals, tools, and memory. In PrepPath, 7 bounded agents classify intents, check skill graph mastery, synthesize personalized 20-day schedules, and dynamically adapt roadmaps when assessment failures occur.

### Distinction 10: Monaco Editor vs Judge0
- **Monaco Editor**: A purely client-side browser component. It formats code, highlights syntax, and captures keystrokes. It does **not** compile or execute code.
- **Judge0**: A server-side sandboxed execution container. It receives code, compiles it with a real GCC/Java/Python compiler inside isolated cgroups, executes it against test cases, and returns structured execution metrics.
