# PrepPath: Final Project Report Appendices & Technical Evidence Master Index

**Project Title:** PrepPath — AI-Powered Adaptive Placement Preparation Platform  
**Academic Submission:** Major Project Final Report (Appendices A, B, and D + Chapter 4 Implementation Evidence)  
**Deliverables Directory:** `major1/docs/report_appendices/` (Mirrored to `docs/report_appendices/`)  
**Generation Timestamp:** November 20, 2026  
**Audit Status:** FULLY VERIFIED (Read-Only Codebase Inspection)  

---

## 1. Directory Tree & Deliverables Overview

```text
docs/report_appendices/
│
├── README.md                                  # Master report asset index & verification record
├── Screenshot_Mapping.md                      # Chapter 4 & Appendix D visual cross-reference
│
├── Appendix_A_Database/
│   ├── ER_Diagram.png                         # High-res (300 DPI) publication ER diagram
│   ├── ER_Diagram.pdf                         # Scalable vector PDF ER diagram
│   ├── Database_Schema.sql                    # Full PostgreSQL (pgvector) & SQLite DDL schema
│   └── Database_Schema_Notes.md               # Technical audit notes & entity specifications
│
├── Appendix_B_Code_Listings/
│   ├── B1_Mastery_Update.py                   # Listing B.1: Student mastery update function
│   ├── B2_Readiness_Score.py                  # Listing B.2: Company Readiness Score (Equation 3.1)
│   ├── B3_RAG_Retrieval.py                    # Listing B.3: Knowledge base RAG vector search
│   ├── B4_AI_Guardrails.py                    # Listing B.4: Multi-tier AI guardrail pipeline
│   └── Code_Listings_Explanation.md           # Rigorous technical & viva documentation
│
└── Appendix_D_Project_Screenshots/
    ├── D1_Landing_Page.png                    # Figure D.1: PrepPath Entry & Authentication Portal
    ├── D2_Student_Dashboard.png               # Figure D.2: Student Learning Dashboard
    ├── D3_Company_Intelligence.png            # Figure D.3 / Fig 4.2: Company Intelligence Interface
    ├── D4_Study_Mode.png                      # Figure D.4 / Fig 4.3: Adaptive Study Mode
    ├── D5_Test_Mode.png                       # Figure D.5 / Fig 4.4: Assessment & Test Engine
    ├── D6_Coding_Evaluation.png               # Figure D.6: Integrated Coding Evaluation Interface
    ├── D7_AI_Tutor.png                        # Figure D.7 / Fig 4.5: AI-Powered Placement Tutor
    ├── D8_Mock_Interview.png                  # Figure D.8 / Fig 4.6: Interactive Mock Interview
    ├── D9_Adaptive_Roadmap.png                # Figure D.9: Personalized Adaptive Learning Roadmap
    └── D10_Analytics_Readiness.png            # Figure D.10: Student Analytics & Company Readiness
```

---

## 2. Deliverable Details & Verification Status

### A. Appendix A — Database Schema & Architecture

| Asset | File Path | Source / Spec | Verification Status |
|---|---|---|---|
| **ER Diagram (PNG)** | `Appendix_A_Database/ER_Diagram.png` | Matplotlib 300 DPI export of 27 tables across 5 subsystems | **GENERATED AND VERIFIED** |
| **ER Diagram (PDF)** | `Appendix_A_Database/ER_Diagram.pdf` | Vector PDF landscape format with full entity detail & legend | **GENERATED AND VERIFIED** |
| **SQL Schema** | `Appendix_A_Database/Database_Schema.sql` | Compiled SQLAlchemy DDL (PostgreSQL pgvector) + live SQLite schema | **GENERATED AND VERIFIED** |
| **Schema Notes** | `Appendix_A_Database/Database_Schema_Notes.md` | Audit of 27 tables, multi-dialect abstraction, and constraints | **GENERATED AND VERIFIED** |

- **Active Runtime Database:** SQLite 3 (`major1/backend/dev.db`, size: 507,904 bytes)
- **Target Production Database:** PostgreSQL 16+ with `pgvector` extension and HNSW cosine index
- **Discrepancy Notes:** Extension tables `notifications` and `user_engagement` defined in ORM `domain.py` (Module 16) are cataloged alongside the 25 baseline tables in `dev.db`.

---

### B. Appendix B — Code Listings

| Listing | File Path | Original Repository Path | Function / Class | Description | Verification Status |
|---|---|---|---|---|---|
| **Listing B.1** | `Appendix_B_Code_Listings/B1_Mastery_Update.py` | `major1/backend/app/services/mastery.py` | `update_mastery` | Deterministic Bayesian error-correction mastery update with speed and confidence weighting. | **GENERATED AND VERIFIED** |
| **Listing B.2** | `Appendix_B_Code_Listings/B2_Readiness_Score.py` | `major1/backend/app/services/readiness.py` & `readiness_data.py` | `readiness`, `gather` | Company Readiness Score engine implementing Equation 3.1 ($0.25\text{DSA} + 0.20\text{CSF} + 0.20\text{Code} + 0.15\text{Apt} + 0.10\text{Int} + 0.10\text{Cons}$). | **GENERATED AND VERIFIED** |
| **Listing B.3** | `Appendix_B_Code_Listings/B3_RAG_Retrieval.py` | `major1/backend/app/services/rag.py` | `search` | Top-k knowledge chunk vector retrieval using pgvector HNSW cosine distance with topic/company metadata boosting. | **GENERATED AND VERIFIED** |
| **Listing B.4** | `Appendix_B_Code_Listings/B4_AI_Guardrails.py` | `major1/backend/app/services/guardrails.py` | `clean_input`, `check_citations`, `strip_verdict_contradictions` | Multi-tier AI safety pipeline: input sanitization, prompt injection XML wrapping, citation verification, hint leakage defense, and verdict consistency. | **GENERATED AND VERIFIED** |
| **Explanation** | `Appendix_B_Code_Listings/Code_Listings_Explanation.md` | Independent Technical Audit | N/A | Comprehensive academic explanation of inputs, outputs, mathematical formulations, and viva discussion notes. | **GENERATED AND VERIFIED** |

---

### C. Appendix D & Chapter 4 — Application Screenshots

All screenshots were captured from the active application running on `http://localhost:3000` via Chrome DevTools Protocol at native $1920 \times 1080$ desktop resolution:

| Figure | Image Path | Chapter 4 Reuse | Active Route | Feature Demonstrated | Verification Status |
|---|---|---|---|---|---|
| **Figure D.1** | `Appendix_D_Project_Screenshots/D1_Landing_Page.png` | N/A | `/login` | Entry landing portal, Google OAuth2 integration, security notice. | **GENERATED AND VERIFIED** |
| **Figure D.2** | `Appendix_D_Project_Screenshots/D2_Student_Dashboard.png` | N/A | `/dashboard` | Student dashboard, study streak counter, readiness summary. | **GENERATED AND VERIFIED** |
| **Figure D.3** | `Appendix_D_Project_Screenshots/D3_Company_Intelligence.png` | **Figure 4.2** | `/companies/amazon` | Amazon corporate hiring pattern, OA breakdown, syllabus weights. | **GENERATED AND VERIFIED** |
| **Figure D.4** | `Appendix_D_Project_Screenshots/D4_Study_Mode.png` | **Figure 4.3** | `/study` | Adaptive curriculum tree across DSA, DBMS, OS, CN, OOP. | **GENERATED AND VERIFIED** |
| **Figure D.5** | `Appendix_D_Project_Screenshots/D5_Test_Mode.png` | **Figure 4.4** | `/tests` | Timed mock assessment catalog, marking rules, attempt history. | **GENERATED AND VERIFIED** |
| **Figure D.6** | `Appendix_D_Project_Screenshots/D6_Coding_Evaluation.png` | N/A | `/practice/5` | CodeWorkbench split-pane IDE, language selector, Judge0 execution. | **GENERATED AND VERIFIED** |
| **Figure D.7** | `Appendix_D_Project_Screenshots/D7_AI_Tutor.png` | **Figure 4.5** | `/tutor` | Conversational tutor with RAG context grounding and citations. | **GENERATED AND VERIFIED** |
| **Figure D.8** | `Appendix_D_Project_Screenshots/D8_Mock_Interview.png` | **Figure 4.6** | `/interview` | Multi-turn speech/text mock interview interface with rubrics. | **GENERATED AND VERIFIED** |
| **Figure D.9** | `Appendix_D_Project_Screenshots/D9_Adaptive_Roadmap.png` | N/A | `/roadmap` | Personalized adaptive preparation roadmap with milestone tracking. | **GENERATED AND VERIFIED** |
| **Figure D.10** | `Appendix_D_Project_Screenshots/D10_Analytics_Readiness.png` | N/A | `/readiness` | Full Equation 3.1 Company Readiness Score dashboard & breakdown. | **GENERATED AND VERIFIED** |

---

## 3. Strict Safety & Read-Only Audit Record

To guarantee total non-interference with the existing major project codebase, the following safety constraints were adhered to:

- **Source Code Alteration:** `NONE` (Zero application logic, models, controllers, or frontend components were modified).
- **Database Mutation:** `NONE` (Zero records inserted, updated, deleted; zero migrations executed).
- **Dependency Modification:** `NONE` (Zero packages installed or upgraded; `package.json` and `requirements.txt` untouched).
- **Environment & Config:** `NONE` (No `.env` or configuration parameters altered).
- **Git State:** `PRESERVED` (No commits, pushes, stashes, or branch adjustments executed).

---

## 4. Manual Steps Remaining for Final Report Assembly

Before binding these materials into your final project report document (LaTeX / Word):

1. **Chapter 4 Implementation Figures:**
   - Copy or reference `Appendix_D_Project_Screenshots/D3_Company_Intelligence.png` for **Figure 4.2**.
   - Copy or reference `Appendix_D_Project_Screenshots/D4_Study_Mode.png` for **Figure 4.3**.
   - Copy or reference `Appendix_D_Project_Screenshots/D5_Test_Mode.png` for **Figure 4.4**.
   - Copy or reference `Appendix_D_Project_Screenshots/D7_AI_Tutor.png` for **Figure 4.5**.
   - Copy or reference `Appendix_D_Project_Screenshots/D8_Mock_Interview.png` for **Figure 4.6**.
   - Use the captions and route descriptions documented in `Screenshot_Mapping.md`.

2. **Appendix A (Database Schema):**
   - Insert `ER_Diagram.pdf` (or `ER_Diagram.png` for Word) in landscape orientation.
   - Insert `Database_Schema.sql` in a formatted verbatim code environment.
   - Integrate `Database_Schema_Notes.md` into the explanatory text.

3. **Appendix B (Code Listings):**
   - Insert `B1_Mastery_Update.py`, `B2_Readiness_Score.py`, `B3_RAG_Retrieval.py`, and `B4_AI_Guardrails.py` under Listings B.1 through B.4.
   - Incorporate the mathematical formulations and explanations from `Code_Listings_Explanation.md`.

4. **Appendix D (Project Outcome):**
   - Insert all ten figures (D.1 through D.10) in sequential order accompanied by the captions provided in `Screenshot_Mapping.md`.
