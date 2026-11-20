# Document 11: Project Limitations, Architectural Challenges, and Future Scope

> **Focus**: Honest Engineering Assessment, System Boundaries, Scalability Roadmaps, and Viva Defense Rationale  
> **Source Baseline**: Inspected Implementation in `major1/`  

---

## 1. Honest Appraisal of Current System Limitations

Examiners appreciate maturity and self-awareness. Claiming that your student major project is "flawless and ready for 1,000,000 users" immediately triggers skeptical cross-examination. 

The table below outlines the **genuine technical boundaries** of the current PrepPath implementation:

| ID | Limitation Description | Root Cause / Rationale | Impact on System | Recommended Future Improvement |
|---|---|---|---|---|
| **L01** | **Text-Based Mock Interviews (No Audio/Video)** | Academic timeline & compute constraints; prioritized conversational reasoning over heavy computer vision models. | Communication and Confidence are inferred from written clarity, precision, and tone rather than vocal tone or eye contact. | Integrate WebRTC audio streaming with Whisper STT and open-source prosody/speech acoustics models. |
| **L02** | **External Judge0 Public Tier Latency** | Relies on public HTTP Judge0 CE instance (`https://ce.judge0.com`) or local container profile. | Under heavy network congestion, code compilation can take 1.5–3.0 seconds to return a verdict. | Deploy a dedicated, self-hosted, multi-node Judge0 cluster behind a Redis queue. |
| **L03** | **Heuristic Weights in Equation 3.1** | Default weights (0.25 DSA, 0.20 CSF, etc.) were designed from placement cell experience, not longitudinal cohort regressions. | Score measures competence against intended benchmarks, but cannot guarantee a mathematical probability of selection. | Collect multi-year cohort placement data and use logistic regression to calibrate weights. |
| **L04** | **Cold-Start Sensitivity for New Users** | New students have 0 stored attempts, causing readiness components to initialize to 0.0 (`available: false`). | Initial readiness score is 0.0 until the student completes their first diagnostic test or study session. | Implement an onboarding 10-minute multi-domain baseline diagnostic test upon registration. |
| **L05** | **RAG Single-Hop Retrieval Limitation** | Vector search retrieves top-k chunks independently based on cosine distance. | Fails on complex "multi-hop" questions requiring synthesis across unrelated chapters (e.g. comparing OS virtual memory to DBMS buffer pool management). | Implement Graph RAG or multi-hop retrieval with HyDE (Hypothetical Document Embeddings). |
| **L06** | **Observed vs Official Company Intelligence** | Placement criteria are modeled from student interview archives and campus placement patterns. | Not an official recruiter specification; companies may alter their OA structure without notice. | Partner with corporate campus recruiters or establish automated scraping of verified Glassdoor/LinkedIn debriefs. |
| **L07** | **LLM API Quota & Latency Overhead** | Calls Google Gemini cloud APIs over external HTTPS connections. | External API downtime or rate-limit exhaustion could disrupt live tutoring (mitigated by our local MockLLM fallback). | Host quantized open-source models (e.g. LLaMA-3-8B or Mistral-7B) locally using vLLM on campus GPU servers. |
| **L08** | **Single-File Development Database (SQLite)** | Default development configuration uses `dev.db` via `aiosqlite`. | SQLite file-locking prevents high-concurrency writes during campus-wide simultaneous testing drives. | Enforce production PostgreSQL with PgBouncer connection pooling across all deployments. |

---

## 2. Deep Dive into Major Limitations

### 2.1 Limitation 1: Inferred Written Dimensions in Mock Interviews
- **What is the limitation?**: In `app/services/interview.py`, our 5-dimension rubric includes "Communication" and "Confidence". These are scored by an LLM reading the student's written chat responses.
- **Why does it exist?**: Real-time facial expression tracking (computer vision) and vocal prosody analysis (pitch, hesitation, volume acoustics) require massive client-side GPU computation and raise serious privacy and demographic bias concerns.
- **How we handle it ethically**: The application does not lie to the student. In both the API response and the frontend interface (`src/app/(app)/interview/page.tsx`), we render an explicit disclosure:
  > *"Communication and Confidence dimensions are inferred from written responses (clarity, structure, precision, and decisiveness), not actual voice or behavioural measurements."*
- **Future Scope**: Integrate WebRTC browser audio recording, process speech via OpenAI Whisper (Speech-to-Text), and run open-source pitch/pause duration analyzers (e.g., `pyAudioAnalysis`) to provide objective vocal pacing metrics without invasive video surveillance.

---

### 2.2 Limitation 2: Cold-Start Estimation
- **What is the limitation?**: When a new student registers, their profile competence scores are `null`. Equation 3.1 calculates components as `0.0` with `available: False`.
- **Why does it exist?**: PrepPath refuses to fabricate synthetic baseline competence without measured evidence.
- **How we handle it**: The UI displays clean empty states and badges ("Not measured yet"). The Recommendation Agent immediately prompts the student to take their first diagnostic assessment.
- **Future Scope**: Introduce a mandatory 15-minute "Adaptive Diagnostic Placement Baseline Test" during user registration (2 DSA, 2 CSF, 2 Aptitude questions) that establishes an initial Elo mastery baseline for all six domains before unlocking the main dashboard.

---

### 2.3 Limitation 3: Heuristic Nature of Equation 3.1
- **What is the limitation?**:
  $$\text{CRS} = 0.25 \cdot \text{DSA} + 0.20 \cdot \text{CSF} + 0.20 \cdot \text{Coding} + 0.15 \cdot \text{Aptitude} + 0.10 \cdot \text{Interview} + 0.10 \cdot \text{Consistency}$$
  While these weights reflect established placement hiring emphasis, they were chosen heuristically.
- **Why does it exist?**: An academic undergraduate project does not possess a 10-year historical dataset linking student preparation scores to actual corporate offer letters across thousands of students.
- **Future Scope**: Partner with the university placement cell (JIIT Training & Placement Cell) to collect anonymized historical placement outcomes. Train a **Logistic Regression or Gradient Boosted Decision Tree (XGBoost)** where independent variables are the 6 component scores and the dependent variable is binary placement success ($Y \in \{0, 1\}$). The regression coefficients would provide empirically calibrated, statistically proven component weights.

---

## 3. High-Scoring Viva Answers for Examiner Challenges

### Question 1: "What is the single biggest limitation of your project?"
> **Your Spoken Viva Answer**:  
> *"Sir, the single biggest limitation is that our Mock Interview subsystem evaluates communication and confidence based on written text structure rather than real-time speech acoustics and facial video analysis. While our LLM can effectively assess whether an answer is logically structured and technically articulate, real interviews involve vocal modulation, pacing, and body language. We made an intentional architectural decision to prioritize technical reasoning and ethical privacy over invasive video tracking, and we prominently disclose this limitation in our UI."*

### Question 2: "What would you improve if given another month to work on this?"
> **Your Spoken Viva Answer**:  
> *"If given another month, I would focus on three specific engineering enhancements:  
> 1. **Automated Onboarding Diagnostic**: Build a 15-minute adaptive placement diagnostic during registration to eliminate the cold-start problem.  
> 2. **Local LLM Serving**: Deploy a quantized open-source model (such as LLaMA-3-8B) using vLLM on a local GPU server, eliminating external Google Gemini API latency and token costs.  
> 3. **Graph RAG**: Upgrade our vector search to a knowledge-graph-enhanced RAG system, allowing the AI Tutor to perform multi-hop reasoning across interconnected computer science domains."*

### Question 3: "How would you scale this platform to 10,000 concurrent engineering students taking a test simultaneously?"
> **Your Spoken Viva Answer**:  
> *"To scale PrepPath to 10,000 concurrent students, I would introduce three architectural adjustments:  
> 1. **Database Tier**: Migrate from our single PostgreSQL instance to a master-replica cluster with PgBouncer connection pooling. Read-heavy traffic (fetching questions, viewing roadmaps) would be routed to read-replicas, while write operations (submitting answers) hit the primary node.  
> 2. **Distributed Judge0 Worker Pool**: During a 10,000-student test, code execution would overwhelm a single sandbox. I would deploy a horizontally scaled cluster of 20+ Judge0 worker nodes managed by Kubernetes, with Redis handling queue partitioning.  
> 3. **Edge Caching & Test State**: Test question assets and static learning content would be cached at the Cloudflare CDN edge, while student in-progress draft answers would be buffered in a distributed Redis cluster and written to PostgreSQL in batched background transactions."*

### Question 4: "How could you mathematically validate that the Company Readiness Score is actually accurate?"
> **Your Spoken Viva Answer**:  
> *"We would conduct a formal longitudinal validation study. In collaboration with our college Training & Placement cell, we would track a cohort of 500 final-year students throughout placement season. We would record their PrepPath readiness scores prior to on-campus drives and correlate those scores with actual hiring outcomes (clearing the Online Assessment round and receiving job offers).  
> 
> We would evaluate the score's predictive power using **Receiver Operating Characteristic (ROC) analysis and Area Under the Curve (AUC)**. An AUC above 0.80 would statistically validate that the score reliably distinguishes students who clear company selection hurdles from those who do not."*
