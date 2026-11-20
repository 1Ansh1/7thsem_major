# Chapter 4 & Appendix D — Application Screenshot Evidence Mapping

**Project:** PrepPath — AI-Powered Adaptive Placement Preparation Platform  
**Document:** Visual Implementation Evidence & Chapter Figure Cross-Reference  
**Output Location:** `docs/report_appendices/Screenshot_Mapping.md`  
**Generated On:** November 20, 2026  

---

## 1. Executive Summary

This document specifies the exact correlation between the live running PrepPath web application screens, their corresponding figure assignments in **Chapter 4: System Implementation**, and the complete visual outcome record in **Appendix D: Project Outcome**.

All screenshots were captured from the genuine active application runtime:
- **Frontend Environment:** Next.js 15 (React 19, Tailwind CSS) running on `http://localhost:3000`
- **Backend API:** FastAPI REST service running on `http://localhost:8000`
- **Session Authentication:** Authenticated using documented demo student account (`student@preppath.dev`)
- **Viewport Specification:** Full desktop 16:9 aspect ratio ($1920 \times 1080$ pixels) with browser chrome and developer inspection tools omitted for publication purity.

---

## 2. Chapter 4 Implementation Screenshots (Figures 4.2 – 4.6)

As defined in the project report structure, Chapter 4 integrates five key implementation interfaces demonstrating core architectural modules:

| Report Figure | Appendix D Asset | Screenshot Filename | Active Route | Subsystem / Technical Capability Demonstrated |
|---|---|---|---|---|
| **Figure 4.2** | Figure D.3 | `D3_Company_Intelligence.png` | `/companies/amazon` | **Company Intelligence:** Historical Online Assessment (OA) patterns, question distribution, syllabus weighting bars, and linked corporate questions. |
| **Figure 4.3** | Figure D.4 | `D4_Study_Mode.png` | `/study` | **Adaptive Study Mode:** Hierarchical topic/skill curriculum navigation across DSA, DBMS, OS, CN, and OOP with live Bayesian mastery progress bars. |
| **Figure 4.4** | Figure D.5 | `D5_Test_Mode.png` | `/tests` | **Test & Assessment Engine:** Timed, sectioned mock assessments with configurable negative marking, question quotas, and past attempt history table. |
| **Figure 4.5** | Figure D.7 | `D7_AI_Tutor.png` | `/tutor` | **AI-Powered Placement Tutor:** Conversational technical tutor grounded with RAG knowledge chunks, prompt injection defenses, and strict source citations. |
| **Figure 4.6** | Figure D.8 | `D8_Mock_Interview.png` | `/interview` | **Interactive Mock Interview:** Speech/text technical and HR mock interview sessions with real-time feedback rubrics, rubric evaluation, and report synthesis. |

---

## 3. Appendix D Master Screenshot Catalogue (Figures D.1 – D.10)

The table below catalogs the complete set of ten production screenshots captured for Appendix D:

| Appendix D Figure | Filename | Application Route | Page Header / Title | Description of Technical Evidence | File Size |
|---|---|---|---|---|---|
| **Figure D.1** | `D1_Landing_Page.png` | `/login` | PrepPath — Sign in | Entry authentication portal displaying email/password fields, Google OAuth link, and security branding. | 63.0 KB |
| **Figure D.2** | `D2_Student_Dashboard.png` | `/dashboard` | Welcome back, Demo | Central student dashboard highlighting current study streak, Company Readiness Score card, and immediate next-step recommendations. | 123.1 KB |
| **Figure D.3** | `D3_Company_Intelligence.png` | `/companies/amazon` | Amazon | Company profile detailing observed OA duration, MCQ vs. coding breakdown, skill distribution bars, and frequent topics. | 106.4 KB |
| **Figure D.4** | `D4_Study_Mode.png` | `/study` | Study mode | Interactive curriculum tree organized by area (DSA, DBMS, OS, CN, OOP) showing individual topic mastery bars and session launcher buttons. | 124.1 KB |
| **Figure D.5** | `D5_Test_Mode.png` | `/tests` | Tests | Timed mock test assessment cards showing duration, question count, maximum marks, company tags, and past test attempt log. | 84.2 KB |
| **Figure D.6** | `D6_Coding_Evaluation.png` | `/practice/5` | Two Sum (sorted input) | Split-screen coding evaluation workbench featuring problem description, multi-language editor, sample testcase execution, and Judge0 submission. | 104.8 KB |
| **Figure D.7** | `D7_AI_Tutor.png` | `/tutor` | AI tutor | Intelligent technical tutor interface supporting conceptual explanations, Socratic hints, and citation verification against course knowledge chunks. | 74.9 KB |
| **Figure D.8** | `D8_Mock_Interview.png` | `/interview` | Mock Interviews | Comprehensive mock interview setup interface supporting technical and HR interview rounds with company-specific behavioral rubrics. | 95.3 KB |
| **Figure D.9** | `D9_Adaptive_Roadmap.png` | `/roadmap` | Adaptive Preparation Roadmap | Personalized placement preparation roadmap showing dynamic milestones, target company alignment, and sequenced learning modules. | 87.0 KB |
| **Figure D.10** | `D10_Analytics_Readiness.png` | `/readiness` | Readiness | Full Company Readiness Score (Equation 3.1) visualization displaying overall score (0–100), 6 component breakdowns, and corporate comparisons. | 150.2 KB |

---

## 4. Screenshot Authenticity & Quality Statement

All ten visual assets were generated through direct headless Chrome DevTools Protocol automation against the running production build of PrepPath. None of the images have been cropped, artificially edited, or synthesized with mock UI elements. Every metric, chart, and component displayed reflects real data processed by the backend and frontend engines.
