# Document 12: Project Demonstration Script & Presentation Walkthrough

> **Presentation Duration**: 12–15 Minutes  
> **Target Audience**: University Viva Committee, External Examiner, Department Supervisors  
> **Prerequisites**: Frontend running on `http://localhost:3000`, Backend running on `http://localhost:8000` (or `start.bat` executed)  

---

## 1. Demonstration Strategy & Time Allocation

| Phase | Duration | Core Feature Demonstrated | Primary Technical Defense Highlight |
|---|---|---|---|
| **Phase 1** | 1.0 min | Project Introduction & Motivation | Solving preparation fragmentation across LeetCode, GfG, etc. |
| **Phase 2** | 1.5 min | Auth & Student Dashboard | In-memory JWT security + profile intent anchoring |
| **Phase 3** | 1.5 min | Company Intelligence Portal | Skill weight distributions (Amazon 45% DSA) + ethical disclaimer |
| **Phase 4** | 2.5 min | Adaptive Study Mode Loop | 8-step loop + diagnostic test + Bayesian Elo mastery update |
| **Phase 5** | 2.5 min | Monaco Editor & Judge0 Code Sandbox | Asynchronous submission (HTTP 202) + isolated container execution |
| **Phase 6** | 2.0 min | RAG Knowledge Base & AI Tutor | pgvector 768-d vector search + citation guardrail + anti-hallucination |
| **Phase 7** | 1.5 min | Interactive Mock Interview Console | Multi-turn chat + 5-dimension rubric (scale 1–10) $\to$ CRS integration |
| **Phase 8** | 1.5 min | Company Readiness Score & Analytics | Equation 3.1 calculation + Recharts visual trendlines |
| **Phase 9** | 1.0 min | Multi-Agent Dynamic Roadmap Revision| Dynamic adaptation when score $<50\%$ on a topic |
| **Phase 10**| 1.0 min | Conclusion & Examiner Q&A Handoff | Summary of strict deterministic vs generative AI boundary |

---

## 2. Step-by-Step Live Demonstration Script

---

### Step 1: Project Introduction & Problem Framing (1.0 min)
- **What to do**: Stand with the landing page (`http://localhost:3000`) visible on the projector.
- **What to say**:
  > *"Respected committee members, good morning. Today, our team—Palak, Ansh, and Tanmay—presents **PrepPath**, an AI-Powered Adaptive Placement Preparation Platform supervised by Respected Deepti Singh.  
  > 
  > Every final-year computer science student faces the same painful struggle: placement preparation is fragmented across 4 to 5 disconnected websites. Students practice coding on LeetCode, read operating systems theory on GeeksforGeeks, take aptitude quizzes on IndiaBIX, and have no way of knowing how prepared they actually are for their dream company.  
  > 
  > PrepPath solves this. We have built an integrated, company-targeted learning platform that combines sandboxed code execution, deterministic Bayesian skill mastery, and retrieval-augmented generative AI into an auditable preparation lifecycle."*

---

### Step 2: Login & Student Dashboard (1.5 min)
- **What to click**:
  1. Click **"Sign In"** in the top navigation.
  2. Enter credentials: `admin@preppath.dev` / `ChangeMe-Admin1` (or your registered student account).
  3. Land on `/dashboard`.
- **What appears**: The modern dashboard appears, showing current study streak (e.g. 7 days), active target companies (Amazon, TCS), quick-access study links, and readiness radar.
- **What is happening internally**:
  - `POST /api/v1/auth/login` verifies the password using **Argon2id**.
  - A 15-minute access token is issued and stored **strictly in JavaScript memory** (`src/lib/api.ts`).
  - An `httpOnly`, `SameSite=Lax` refresh cookie is set in the browser.
  - The dashboard calls `GET /api/v1/users/me/profile` and `GET /api/v1/progress/readiness/amazon`.
- **What to say to the teacher**:
  > *"Here is the authenticated student dashboard. Notice two important engineering decisions: first, for security, our access token lives strictly in memory, never in `localStorage`, making XSS token theft impossible. Second, everything on this screen is anchored to the student's selected target companies—in this case, Amazon and TCS."*
- **Likely Follow-Up Question**: *"What happens if the student refreshes the browser page?"*  
  **Your Answer**: *"Our frontend API wrapper detects an empty in-memory token, automatically calls `POST /api/v1/auth/refresh` using the httpOnly cookie, acquires a fresh 15-minute token, and re-renders the dashboard without forcing the student to re-enter their password."*

---

### Step 3: Company Intelligence Portal (1.5 min)
- **What to click**:
  1. Click **"Companies"** in the sidebar navigation (`/companies`).
  2. Click on the **"Amazon"** card (`/companies/amazon`).
- **What appears**: The Amazon Company Intelligence profile renders, displaying skill weight distribution (45% DSA, 15% OOP, 15% DBMS, 10% OS, 10% Aptitude, 5% HR), OA test duration (90 minutes, 2 coding questions), frequently tested topics (Arrays, Trees, Graphs, DP), and the mandatory pattern disclaimer.
- **What is happening internally**:
  - `GET /api/v1/companies/amazon` queries the `companies` table.
  - Returns `skill_weights`, `oa_pattern`, and injects the mandatory disclaimer string from `app/schemas/common.py`.
- **What to say to the teacher**:
  > *"Here is our Company Intelligence layer. We do not treat placement preparation as one-size-fits-all. Amazon's hiring process prioritizes algorithmic problem-solving and object-oriented design, whereas mass recruiters like TCS emphasize quantitative aptitude. Notice our mandatory disclaimer at the top: we explicitly disclose that these weights reflect observed historical preparation patterns, maintaining academic and legal integrity."*

---

### Step 4: Adaptive Study Mode & Socratic Loop (2.5 min)
- **What to click**:
  1. Click **"Study Mode"** in the sidebar.
  2. Select the topic **"Binary Search Trees"** under the DSA domain (`/study/bst`).
  3. The system renders Step 1: A diagnostic question.
  4. Select an answer, set confidence slider to **4 / 5**, and click **"Submit Answer"**.
  5. Click **"Explain Concept"** (renders RAG explanation).
  6. Click **"View Worked Example"** (renders numbered reasoning steps).
  7. Complete the session.
- **What is happening internally**:
  - `POST /api/v1/study/sessions`: Checks `mastery` table. Since current mastery is 40%, `target_difficulty()` selects a "medium" diagnostic question.
  - `POST /study/sessions/{id}/answer`: Records submission.
  - `GET /study/sessions/{id}/teaching?kind=explanation`: RAG search retrieves top 4 chunks from `documents` using 768-d cosine distance; Gemini synthesizes an explanation with verified citation chips `[S12]`.
  - `POST /study/sessions/{id}/complete`: `app/services/mastery.py:update_mastery()` executes the Bayesian Elo update formula, clamping score delta to $\pm 15$ points.
- **What to say to the teacher**:
  > *"This is our 8-step Adaptive Study Mode. Unlike conventional websites that simply display an answer key, PrepPath functions like a human tutor. It tests baseline knowledge, asks the student for their confidence level, serves a RAG-grounded conceptual explanation with verified syllabus citations, walks through a worked example with numbered reasoning, and updates the student's skill mastery using our deterministic Elo formula."*
- **Likely Follow-Up Question**: *"What happens if the student was confident but got the answer wrong?"*  
  **Your Answer**: *"In `app/services/mastery.py`, line 73 applies a 30% misconception penalty: $w = (2.0 - d) \times (1.0 + 0.3 \times \text{confidence})$. An incorrect answer submitted with high confidence penalizes mastery significantly more than an unsure guess, because it indicates a dangerous conceptual misconception."*

---

### Step 5: Monaco Code Editor & Sandboxed Judge0 Pipeline (2.5 min)
- **What to click**:
  1. Click **"Practice Coding"** (`/practice/1` — e.g. "Two Sum" or "Reverse Linked List").
  2. Show the multi-language selector (Python, C++, Java, JavaScript).
  3. In Python, write a working solution.
  4. Click **"Run Code"** (evaluates against visible sample tests).
  5. Click **"Submit Code"** (evaluates against hidden test cases).
  6. Observe real-time status: *"Queued for the sandbox..."* $\to$ *"Accepted — 12 / 12 tests passed (0.041 s, 12.8 MB)"*.
  7. Click **"AI Code Review"** at the bottom of the verdict panel.
- **What is happening internally**:
  - Monaco Editor captures code.
  - `POST /api/v1/submissions`: Inserts submission with status `queued` and immediately returns HTTP `202 Accepted`.
  - Background worker dispatches batch to Judge0 container: `POST /submissions/batch`.
  - Judge0 compiles and executes code inside isolated cgroups with 2.0s time limit and 128MB RAM limit.
  - Hidden test inputs are never transmitted to the browser.
  - AI Code Review runs strictly **after** Judge0 returns `Accepted`, analyzing time/space complexity without touching the verdict.
- **What to say to the teacher**:
  > *"Here is our coding environment. We use Monaco Editor—the engine behind VS Code. When I click 'Submit', our server does NOT execute this code. Executing untrusted student code directly on a web server is a fatal security flaw.  
  > 
  > Instead, our FastAPI backend dispatches the code asynchronously to an isolated Judge0 CE sandbox running inside Linux cgroups. Judge0 evaluates the code against hidden test cases and returns status code 3: Accepted. Notice that when I click 'AI Code Review', the LLM is only permitted to analyze time and space complexity. The LLM has zero authority to overturn the judge's verdict."*

---

### Step 6: RAG Knowledge Base & AI Tutor (2.0 min)
- **What to click**:
  1. Click **"AI Tutor"** in the sidebar (`/tutor`).
  2. Select the mode tab: **"Explain"**.
  3. Type the query: *"Explain LRU Cache eviction policy and how to implement it with a Doubly Linked List"*.
  4. Click **"Ask Tutor"**.
  5. Show the generated markdown response with blue citation chips (e.g. `[S14] Operating Systems - Virtual Memory`).
  6. Click a citation chip to view the verified snippet.
- **What is happening internally**:
  - `clean_input()` sanitizes the prompt and encapsulates it in `<student_input>`.
  - `rag.search()` converts the query into a 768-d vector via `gemini-embedding-001`.
  - `pgvector` executes an HNSW cosine distance search (`1 - cos_sim`) with similarity floor $\ge 0.55$.
  - Gemini outputs JSON matching `ExplainOut`.
  - `check_citations()` verifies that citation tags match retrieved chunk IDs.
  - Latency and token costs are logged in `ai_traces`.
- **What to say to the teacher**:
  > *"This is our RAG-grounded AI Tutor. Notice that this is not an ordinary ChatGPT wrapper. If you look at the bottom of the response, every technical claim is accompanied by a verified citation chip linking back to our curated knowledge base. If I were to ask an out-of-syllabus question like 'What is the capital of France?', our similarity floor drops below 0.55 and the tutor politely refuses to answer, eliminating hallucinations."*

---

### Step 7: Interactive Mock Interview Console (1.5 min)
- **What to click**:
  1. Click **"Mock Interview"** in the sidebar (`/interview`).
  2. Form: Select Company **"Amazon"**, Role **"Software Development Engineer"**, Difficulty **"Medium"**.
  3. Click **"Start Interview Session"**.
  4. Read the opening question generated by the AI interviewer.
  5. Type a realistic technical approach in the input box and click **"Send Answer"**.
  6. Observe the interviewer's adaptive follow-up question.
  7. Click **"Finish Interview & Generate Report"**.
  8. View the 5-dimension rubric breakdown and radar chart.
- **What is happening internally**:
  - `POST /api/v1/interviews`: Searches RAG for Amazon interview topics; generates opening question via `OpeningQuestionOut`.
  - `POST /turn`: Evaluates turn transcript, probes constraints.
  - `POST /finish`: Evaluates the full transcript across the 5 standard rubric dimensions on a 1–10 scale: Technical Knowledge, Problem Solving, Communication, Confidence, and Concept Accuracy.
  - Scaled overall score ($0–100$) commits to the database and feeds Equation 3.1.
- **What to say to the teacher**:
  > *"Our Mock Interview subsystem simulates a live campus technical interview. It conducts multi-turn probing exchanges. When finished, it grades the student across five objective rubric dimensions on a 1-to-10 scale. Notice our ethical disclosure: we explicitly state that Communication and Confidence are inferred from written clarity, structure, and precision, without claiming video facial tracking."*

---

### Step 8: Company Readiness Score & Analytics Dashboard (1.5 min)
- **What to click**:
  1. Click **"Readiness"** (`/readiness/amazon`).
  2. Show the overall score (e.g. **74.2%**) and the six individual component bars.
  3. Show the recommendation card at the top: *"Practice a mock interview: Interview performance has a large weighted gap in your target readiness."*
  4. Click **"Analytics"** (`/analytics`) to show the Recharts daily accuracy line and weakest topics list.
- **What is happening internally**:
  - `GET /api/v1/progress/readiness/amazon` executes `readiness_data.py:report()`.
  - Gathers DSA mastery, CS fundamentals rollup, Judge0 accepted solve ratios, aptitude accuracy, interview scores, and consistency streaks.
  - Evaluates Equation 3.1:
    $$\text{CRS} = 0.25(\text{DSA}) + 0.20(\text{CSF}) + 0.20(\text{Coding}) + 0.15(\text{Aptitude}) + 0.10(\text{Interview}) + 0.10(\text{Consistency})$$
  - Identifies the largest weighted gap via `recommend()`.
- **What to say to the teacher**:
  > *"This is the centerpiece of our platform: the Company Readiness Score, defined by Equation 3.1. It is a 100% auditable weighted metric. Notice that every number is traceable: my DSA score is 80%, my Coding solve score is 75%, but my overall readiness is held back because my Mock Interview score is low. The system automatically highlights this deficit and recommends the exact action needed to maximize my score."*

---

### Step 9: Multi-Agent Dynamic Roadmap Revision (1.0 min)
- **What to click**:
  1. Click **"Roadmap"** in the sidebar (`/roadmap`).
  2. Show the active 20-day Amazon preparation plan.
  3. Click the demonstration button: **"Simulate Assessment Struggle"** (Select topic "Graphs", score "35%").
  4. Click **"Trigger Dynamic Plan Revision"**.
  5. The roadmap immediately updates to **Version 2**. A notification banner appears:
     *"Plan Dynamically Revised: Extended Graphs revision by 2 days; postponed Dynamic Programming to Day 14."*
- **What is happening internally**:
  - Calls `POST /api/v1/roadmaps/revise`.
  - Multi-Agent Orchestrator triggers the **Recommendation Agent** (`orchestrator.py:recommendation_agent_revise_roadmap()`).
  - Synthesizes an adapted daily schedule, increments `roadmap.version`, and commits modification reasons to `recommendations` and `roadmaps` tables.
- **What to say to the teacher**:
  > *"Finally, here is our 7-agent dynamic roadmap engine. Traditional study roadmaps are static checklists that break the moment a student falls behind. Here, when our assessment engine detects that I scored only 35% on Graphs, our Recommendation Agent dynamically adapts the remaining roadmap—inserting remedial graph traversal practice and postponing advanced topics to keep the preparation timeline realistic."*

---

### Step 10: Conclusion & Examiner Handoff (1.0 min)
- **What to say**:
  > *"To conclude, PrepPath transforms placement preparation from a fragmented, anxious guessing game into an integrated, mathematically grounded learning journey. We have verified 90 passing backend unit tests, 0 frontend TypeScript compile errors, and verified empirical RAG faithfulness of 85.7%.  
  > 
  > We are now ready and excited to take your questions. Thank you."*

---

## 3. Emergency Presentation Fallback Plan

If an unexpected technical issue occurs during your viva (e.g. college Wi-Fi disconnects or Gemini API quota is reached):

1. **If Internet Disconnects**:
   - The application automatically switches to **Mock Mode**:
     - Gemini LLM falls back to `MockLLMClient` in `app/services/llm.py:MockLLMClient`.
     - Code evaluation falls back to `MockJudgeClient`.
     - Vector search operates locally via SQLite in-memory cosine math (`app/services/rag.py:_cos`).
   - **What to tell the examiner**: *"Sir/Ma'am, our architecture includes a zero-dependency offline fallback. Even without internet access, our in-memory SQLite vector engine and deterministic mock service allow the complete user workflow to be demonstrated seamlessly."*
2. **Never Trigger Destructive Actions Live**:
   - Do **NOT** click "Delete Account & Purge Records" during the live demonstration. If an examiner asks about data deletion, show them the code in `app/routers/users.py:delete_my_account()` and point to the passing automated test in `tests/test_privacy.py`.
