-- ============================================================================
-- PrepPath: AI-Powered Adaptive Placement Preparation Platform
-- DATABASE SCHEMA DEFINITION (PostgreSQL / Intended Production Dialect)
-- Source: SQLAlchemy 2.0 Declarative Models & Alembic Migration Baseline
-- Features: pgvector Vector Embeddings (768-d), HNSW Cosine Index, Foreign Keys
-- ============================================================================

CREATE EXTENSION IF NOT EXISTS vector;

-- Table: companies
CREATE TABLE companies (
	id SERIAL NOT NULL, 
	name VARCHAR(120) NOT NULL, 
	slug VARCHAR(140) NOT NULL, 
	description TEXT NOT NULL, 
	skill_weights JSON NOT NULL, 
	oa_pattern JSON NOT NULL, 
	readiness_weights JSON, 
	created_at TIMESTAMP WITH TIME ZONE NOT NULL, 
	updated_at TIMESTAMP WITH TIME ZONE NOT NULL, 
	CONSTRAINT pk_companies PRIMARY KEY (id), 
	CONSTRAINT uq_companies_name UNIQUE (name)
);
CREATE UNIQUE INDEX ix_companies_slug ON companies (slug);

-- Table: roles
CREATE TABLE roles (
	id SERIAL NOT NULL, 
	name VARCHAR(32) NOT NULL, 
	description VARCHAR(255) NOT NULL, 
	scopes JSON NOT NULL, 
	CONSTRAINT pk_roles PRIMARY KEY (id), 
	CONSTRAINT uq_roles_name UNIQUE (name)
);

-- Table: topics
CREATE TABLE topics (
	id SERIAL NOT NULL, 
	name VARCHAR(120) NOT NULL, 
	slug VARCHAR(140) NOT NULL, 
	area VARCHAR(32) NOT NULL, 
	description TEXT NOT NULL, 
	parent_id INTEGER, 
	created_at TIMESTAMP WITH TIME ZONE NOT NULL, 
	updated_at TIMESTAMP WITH TIME ZONE NOT NULL, 
	CONSTRAINT pk_topics PRIMARY KEY (id), 
	CONSTRAINT fk_topics_parent_id_topics FOREIGN KEY(parent_id) REFERENCES topics (id) ON DELETE SET NULL
);
CREATE UNIQUE INDEX ix_topics_slug ON topics (slug);
CREATE INDEX ix_topics_area ON topics (area);

-- Table: documents
CREATE TABLE documents (
	id SERIAL NOT NULL, 
	title VARCHAR(255) NOT NULL, 
	kind VARCHAR(32) NOT NULL, 
	source_uri VARCHAR(500) NOT NULL, 
	chunk_index INTEGER NOT NULL, 
	content TEXT NOT NULL, 
	topic_id INTEGER, 
	company_id INTEGER, 
	embedding VECTOR(768), 
	meta JSON NOT NULL, 
	created_at TIMESTAMP WITH TIME ZONE NOT NULL, 
	updated_at TIMESTAMP WITH TIME ZONE NOT NULL, 
	CONSTRAINT pk_documents PRIMARY KEY (id), 
	CONSTRAINT fk_documents_topic_id_topics FOREIGN KEY(topic_id) REFERENCES topics (id) ON DELETE SET NULL, 
	CONSTRAINT fk_documents_company_id_companies FOREIGN KEY(company_id) REFERENCES companies (id) ON DELETE SET NULL
);

-- Table: skills
CREATE TABLE skills (
	id SERIAL NOT NULL, 
	name VARCHAR(120) NOT NULL, 
	slug VARCHAR(140) NOT NULL, 
	area VARCHAR(32) NOT NULL, 
	parent_id INTEGER, 
	topic_id INTEGER, 
	difficulty FLOAT NOT NULL, 
	CONSTRAINT pk_skills PRIMARY KEY (id), 
	CONSTRAINT uq_skills_slug UNIQUE (slug), 
	CONSTRAINT fk_skills_parent_id_skills FOREIGN KEY(parent_id) REFERENCES skills (id) ON DELETE CASCADE, 
	CONSTRAINT fk_skills_topic_id_topics FOREIGN KEY(topic_id) REFERENCES topics (id) ON DELETE SET NULL
);

-- Table: users
CREATE TABLE users (
	id SERIAL NOT NULL, 
	email VARCHAR(320) NOT NULL, 
	password_hash VARCHAR(255), 
	google_sub VARCHAR(255), 
	full_name VARCHAR(120) NOT NULL, 
	role_id INTEGER NOT NULL, 
	is_active BOOLEAN NOT NULL, 
	last_login_at TIMESTAMP WITH TIME ZONE, 
	created_at TIMESTAMP WITH TIME ZONE NOT NULL, 
	updated_at TIMESTAMP WITH TIME ZONE NOT NULL, 
	CONSTRAINT pk_users PRIMARY KEY (id), 
	CONSTRAINT uq_users_google_sub UNIQUE (google_sub), 
	CONSTRAINT fk_users_role_id_roles FOREIGN KEY(role_id) REFERENCES roles (id)
);
CREATE UNIQUE INDEX ix_users_email ON users (email);

-- Table: ai_traces
CREATE TABLE ai_traces (
	id SERIAL NOT NULL, 
	user_id INTEGER, 
	call_type VARCHAR(48) NOT NULL, 
	agent VARCHAR(32), 
	run_id VARCHAR(64), 
	model VARCHAR(64) NOT NULL, 
	prompt_tokens INTEGER NOT NULL, 
	completion_tokens INTEGER NOT NULL, 
	latency_ms INTEGER NOT NULL, 
	cost_usd FLOAT NOT NULL, 
	success BOOLEAN NOT NULL, 
	error TEXT, 
	meta JSON NOT NULL, 
	created_at TIMESTAMP WITH TIME ZONE NOT NULL, 
	CONSTRAINT pk_ai_traces PRIMARY KEY (id), 
	CONSTRAINT fk_ai_traces_user_id_users FOREIGN KEY(user_id) REFERENCES users (id) ON DELETE SET NULL
);
CREATE INDEX ix_ai_traces_run_id ON ai_traces (run_id);
CREATE INDEX ix_ai_traces_call_type ON ai_traces (call_type);

-- Table: feedback
CREATE TABLE feedback (
	id SERIAL NOT NULL, 
	user_id INTEGER NOT NULL, 
	target_type VARCHAR(32) NOT NULL, 
	target_id INTEGER NOT NULL, 
	rating INTEGER, 
	comment TEXT NOT NULL, 
	created_at TIMESTAMP WITH TIME ZONE NOT NULL, 
	CONSTRAINT pk_feedback PRIMARY KEY (id), 
	CONSTRAINT fk_feedback_user_id_users FOREIGN KEY(user_id) REFERENCES users (id) ON DELETE CASCADE
);

-- Table: interviews
CREATE TABLE interviews (
	id SERIAL NOT NULL, 
	user_id INTEGER NOT NULL, 
	company_id INTEGER, 
	role VARCHAR(120) NOT NULL, 
	interview_type VARCHAR(16) NOT NULL, 
	difficulty VARCHAR(16) NOT NULL, 
	status VARCHAR(16) NOT NULL, 
	transcript JSON NOT NULL, 
	scores JSON NOT NULL, 
	report JSON NOT NULL, 
	started_at TIMESTAMP WITH TIME ZONE NOT NULL, 
	ended_at TIMESTAMP WITH TIME ZONE, 
	CONSTRAINT pk_interviews PRIMARY KEY (id), 
	CONSTRAINT fk_interviews_user_id_users FOREIGN KEY(user_id) REFERENCES users (id) ON DELETE CASCADE, 
	CONSTRAINT fk_interviews_company_id_companies FOREIGN KEY(company_id) REFERENCES companies (id) ON DELETE SET NULL
);
CREATE INDEX ix_interviews_user_id ON interviews (user_id);

-- Table: job_descriptions
CREATE TABLE job_descriptions (
	id SERIAL NOT NULL, 
	user_id INTEGER NOT NULL, 
	title VARCHAR(200) NOT NULL, 
	company_name VARCHAR(120) NOT NULL, 
	raw_text TEXT NOT NULL, 
	parsed JSON NOT NULL, 
	created_at TIMESTAMP WITH TIME ZONE NOT NULL, 
	updated_at TIMESTAMP WITH TIME ZONE NOT NULL, 
	CONSTRAINT pk_job_descriptions PRIMARY KEY (id), 
	CONSTRAINT fk_job_descriptions_user_id_users FOREIGN KEY(user_id) REFERENCES users (id) ON DELETE CASCADE
);
CREATE INDEX ix_job_descriptions_user_id ON job_descriptions (user_id);

-- Table: mastery
CREATE TABLE mastery (
	id SERIAL NOT NULL, 
	user_id INTEGER NOT NULL, 
	skill_id INTEGER NOT NULL, 
	mastery_score FLOAT NOT NULL, 
	attempt_count INTEGER NOT NULL, 
	correct_count INTEGER NOT NULL, 
	accuracy FLOAT NOT NULL, 
	average_time_ms FLOAT NOT NULL, 
	difficulty FLOAT NOT NULL, 
	confidence FLOAT, 
	last_attempt TIMESTAMP WITH TIME ZONE, 
	CONSTRAINT pk_mastery PRIMARY KEY (id), 
	CONSTRAINT uq_mastery_user_id UNIQUE (user_id, skill_id), 
	CONSTRAINT fk_mastery_user_id_users FOREIGN KEY(user_id) REFERENCES users (id) ON DELETE CASCADE, 
	CONSTRAINT fk_mastery_skill_id_skills FOREIGN KEY(skill_id) REFERENCES skills (id) ON DELETE CASCADE
);
CREATE INDEX ix_mastery_user_id ON mastery (user_id);

-- Table: notifications
CREATE TABLE notifications (
	id SERIAL NOT NULL, 
	user_id INTEGER NOT NULL, 
	category VARCHAR(32) NOT NULL, 
	title VARCHAR(200) NOT NULL, 
	message TEXT NOT NULL, 
	link VARCHAR(255), 
	is_read BOOLEAN NOT NULL, 
	created_at TIMESTAMP WITH TIME ZONE NOT NULL, 
	CONSTRAINT pk_notifications PRIMARY KEY (id), 
	CONSTRAINT fk_notifications_user_id_users FOREIGN KEY(user_id) REFERENCES users (id) ON DELETE CASCADE
);
CREATE INDEX ix_notifications_user_id ON notifications (user_id);
CREATE INDEX ix_notifications_category ON notifications (category);

-- Table: progress
CREATE TABLE progress (
	id SERIAL NOT NULL, 
	user_id INTEGER NOT NULL, 
	topic_id INTEGER NOT NULL, 
	status VARCHAR(16) NOT NULL, 
	updated_at TIMESTAMP WITH TIME ZONE NOT NULL, 
	CONSTRAINT pk_progress PRIMARY KEY (id), 
	CONSTRAINT uq_progress_user_id UNIQUE (user_id, topic_id), 
	CONSTRAINT fk_progress_user_id_users FOREIGN KEY(user_id) REFERENCES users (id) ON DELETE CASCADE, 
	CONSTRAINT fk_progress_topic_id_topics FOREIGN KEY(topic_id) REFERENCES topics (id) ON DELETE CASCADE
);

-- Table: questions
CREATE TABLE questions (
	id SERIAL NOT NULL, 
	type VARCHAR(32) NOT NULL, 
	title VARCHAR(200) NOT NULL, 
	body TEXT NOT NULL, 
	difficulty VARCHAR(16) NOT NULL, 
	topic_id INTEGER, 
	options JSON NOT NULL, 
	answer JSON NOT NULL, 
	explanation TEXT NOT NULL, 
	meta JSON NOT NULL, 
	status VARCHAR(16) NOT NULL, 
	source VARCHAR(16) NOT NULL, 
	created_by INTEGER, 
	created_at TIMESTAMP WITH TIME ZONE NOT NULL, 
	updated_at TIMESTAMP WITH TIME ZONE NOT NULL, 
	CONSTRAINT pk_questions PRIMARY KEY (id), 
	CONSTRAINT fk_questions_topic_id_topics FOREIGN KEY(topic_id) REFERENCES topics (id) ON DELETE SET NULL, 
	CONSTRAINT fk_questions_created_by_users FOREIGN KEY(created_by) REFERENCES users (id) ON DELETE SET NULL
);
CREATE INDEX ix_questions_difficulty ON questions (difficulty);
CREATE INDEX ix_questions_topic_id ON questions (topic_id);
CREATE INDEX ix_questions_status ON questions (status);
CREATE INDEX ix_questions_type ON questions (type);

-- Table: readiness_scores
CREATE TABLE readiness_scores (
	id SERIAL NOT NULL, 
	user_id INTEGER NOT NULL, 
	company_id INTEGER, 
	overall FLOAT NOT NULL, 
	components JSON NOT NULL, 
	weights JSON NOT NULL, 
	computed_at TIMESTAMP WITH TIME ZONE NOT NULL, 
	CONSTRAINT pk_readiness_scores PRIMARY KEY (id), 
	CONSTRAINT fk_readiness_scores_user_id_users FOREIGN KEY(user_id) REFERENCES users (id) ON DELETE CASCADE, 
	CONSTRAINT fk_readiness_scores_company_id_companies FOREIGN KEY(company_id) REFERENCES companies (id) ON DELETE CASCADE
);
CREATE INDEX ix_readiness_scores_user_id ON readiness_scores (user_id);

-- Table: recommendations
CREATE TABLE recommendations (
	id SERIAL NOT NULL, 
	user_id INTEGER NOT NULL, 
	kind VARCHAR(32) NOT NULL, 
	payload JSON NOT NULL, 
	reason TEXT NOT NULL, 
	created_at TIMESTAMP WITH TIME ZONE NOT NULL, 
	acted_at TIMESTAMP WITH TIME ZONE, 
	CONSTRAINT pk_recommendations PRIMARY KEY (id), 
	CONSTRAINT fk_recommendations_user_id_users FOREIGN KEY(user_id) REFERENCES users (id) ON DELETE CASCADE
);
CREATE INDEX ix_recommendations_user_id ON recommendations (user_id);

-- Table: resumes
CREATE TABLE resumes (
	id SERIAL NOT NULL, 
	user_id INTEGER NOT NULL, 
	filename VARCHAR(255) NOT NULL, 
	content_type VARCHAR(100) NOT NULL, 
	storage_path VARCHAR(500) NOT NULL, 
	status VARCHAR(16) NOT NULL, 
	parsed JSON NOT NULL, 
	created_at TIMESTAMP WITH TIME ZONE NOT NULL, 
	updated_at TIMESTAMP WITH TIME ZONE NOT NULL, 
	CONSTRAINT pk_resumes PRIMARY KEY (id), 
	CONSTRAINT fk_resumes_user_id_users FOREIGN KEY(user_id) REFERENCES users (id) ON DELETE CASCADE
);
CREATE INDEX ix_resumes_user_id ON resumes (user_id);

-- Table: roadmaps
CREATE TABLE roadmaps (
	id SERIAL NOT NULL, 
	user_id INTEGER NOT NULL, 
	company_id INTEGER, 
	title VARCHAR(200) NOT NULL, 
	plan JSON NOT NULL, 
	version INTEGER NOT NULL, 
	status VARCHAR(16) NOT NULL, 
	created_at TIMESTAMP WITH TIME ZONE NOT NULL, 
	updated_at TIMESTAMP WITH TIME ZONE NOT NULL, 
	CONSTRAINT pk_roadmaps PRIMARY KEY (id), 
	CONSTRAINT fk_roadmaps_user_id_users FOREIGN KEY(user_id) REFERENCES users (id) ON DELETE CASCADE, 
	CONSTRAINT fk_roadmaps_company_id_companies FOREIGN KEY(company_id) REFERENCES companies (id) ON DELETE SET NULL
);
CREATE INDEX ix_roadmaps_user_id ON roadmaps (user_id);

-- Table: sessions
CREATE TABLE sessions (
	id SERIAL NOT NULL, 
	user_id INTEGER NOT NULL, 
	family_id VARCHAR(64) NOT NULL, 
	token_hash VARCHAR(64) NOT NULL, 
	expires_at TIMESTAMP WITH TIME ZONE NOT NULL, 
	revoked_at TIMESTAMP WITH TIME ZONE, 
	replaced_by_id INTEGER, 
	user_agent VARCHAR(255) NOT NULL, 
	created_at TIMESTAMP WITH TIME ZONE NOT NULL, 
	CONSTRAINT pk_sessions PRIMARY KEY (id), 
	CONSTRAINT fk_sessions_user_id_users FOREIGN KEY(user_id) REFERENCES users (id) ON DELETE CASCADE, 
	CONSTRAINT uq_sessions_token_hash UNIQUE (token_hash)
);
CREATE INDEX ix_sessions_family_id ON sessions (family_id);
CREATE INDEX ix_sessions_user_id ON sessions (user_id);

-- Table: tests
CREATE TABLE tests (
	id SERIAL NOT NULL, 
	title VARCHAR(200) NOT NULL, 
	description TEXT NOT NULL, 
	company_id INTEGER, 
	duration_seconds INTEGER NOT NULL, 
	sections JSON NOT NULL, 
	negative_marking BOOLEAN NOT NULL, 
	randomize BOOLEAN NOT NULL, 
	is_published BOOLEAN NOT NULL, 
	created_by INTEGER, 
	created_at TIMESTAMP WITH TIME ZONE NOT NULL, 
	updated_at TIMESTAMP WITH TIME ZONE NOT NULL, 
	CONSTRAINT pk_tests PRIMARY KEY (id), 
	CONSTRAINT fk_tests_company_id_companies FOREIGN KEY(company_id) REFERENCES companies (id) ON DELETE SET NULL, 
	CONSTRAINT fk_tests_created_by_users FOREIGN KEY(created_by) REFERENCES users (id) ON DELETE SET NULL
);

-- Table: user_engagement
CREATE TABLE user_engagement (
	id SERIAL NOT NULL, 
	user_id INTEGER NOT NULL, 
	xp INTEGER NOT NULL, 
	badges JSON NOT NULL, 
	leaderboard_opt_in BOOLEAN NOT NULL, 
	preferences JSON NOT NULL, 
	CONSTRAINT pk_user_engagement PRIMARY KEY (id), 
	CONSTRAINT fk_user_engagement_user_id_users FOREIGN KEY(user_id) REFERENCES users (id) ON DELETE CASCADE
);
CREATE UNIQUE INDEX ix_user_engagement_user_id ON user_engagement (user_id);

-- Table: attempts
CREATE TABLE attempts (
	id SERIAL NOT NULL, 
	user_id INTEGER NOT NULL, 
	test_id INTEGER, 
	mode VARCHAR(16) NOT NULL, 
	status VARCHAR(16) NOT NULL, 
	score FLOAT, 
	max_score FLOAT, 
	state JSON NOT NULL, 
	started_at TIMESTAMP WITH TIME ZONE NOT NULL, 
	submitted_at TIMESTAMP WITH TIME ZONE, 
	CONSTRAINT pk_attempts PRIMARY KEY (id), 
	CONSTRAINT fk_attempts_user_id_users FOREIGN KEY(user_id) REFERENCES users (id) ON DELETE CASCADE, 
	CONSTRAINT fk_attempts_test_id_tests FOREIGN KEY(test_id) REFERENCES tests (id) ON DELETE SET NULL
);
CREATE INDEX ix_attempts_user_id ON attempts (user_id);

-- Table: profiles
CREATE TABLE profiles (
	id SERIAL NOT NULL, 
	user_id INTEGER NOT NULL, 
	college VARCHAR(200) NOT NULL, 
	branch VARCHAR(120) NOT NULL, 
	graduation_year INTEGER, 
	target_role VARCHAR(120) NOT NULL, 
	target_company_ids JSON NOT NULL, 
	dsa_score FLOAT, 
	csf_score FLOAT, 
	aptitude_score FLOAT, 
	coding_score FLOAT, 
	study_streak INTEGER NOT NULL, 
	last_active_on DATE, 
	topics_completed INTEGER NOT NULL, 
	weak_topics JSON NOT NULL, 
	preferred_language VARCHAR(32) NOT NULL, 
	resume_id INTEGER, 
	created_at TIMESTAMP WITH TIME ZONE NOT NULL, 
	updated_at TIMESTAMP WITH TIME ZONE NOT NULL, 
	CONSTRAINT pk_profiles PRIMARY KEY (id), 
	CONSTRAINT uq_profiles_user_id UNIQUE (user_id), 
	CONSTRAINT fk_profiles_user_id_users FOREIGN KEY(user_id) REFERENCES users (id) ON DELETE CASCADE, 
	CONSTRAINT fk_profiles_resume_id_resumes FOREIGN KEY(resume_id) REFERENCES resumes (id) ON DELETE SET NULL
);

-- Table: question_companies
CREATE TABLE question_companies (
	question_id INTEGER NOT NULL, 
	company_id INTEGER NOT NULL, 
	CONSTRAINT pk_question_companies PRIMARY KEY (question_id, company_id), 
	CONSTRAINT fk_question_companies_question_id_questions FOREIGN KEY(question_id) REFERENCES questions (id) ON DELETE CASCADE, 
	CONSTRAINT fk_question_companies_company_id_companies FOREIGN KEY(company_id) REFERENCES companies (id) ON DELETE CASCADE
);

-- Table: test_questions
CREATE TABLE test_questions (
	id SERIAL NOT NULL, 
	test_id INTEGER NOT NULL, 
	question_id INTEGER NOT NULL, 
	section VARCHAR(64) NOT NULL, 
	position INTEGER NOT NULL, 
	marks FLOAT NOT NULL, 
	negative_marks FLOAT NOT NULL, 
	CONSTRAINT pk_test_questions PRIMARY KEY (id), 
	CONSTRAINT fk_test_questions_test_id_tests FOREIGN KEY(test_id) REFERENCES tests (id) ON DELETE CASCADE, 
	CONSTRAINT fk_test_questions_question_id_questions FOREIGN KEY(question_id) REFERENCES questions (id) ON DELETE CASCADE
);
CREATE INDEX ix_test_questions_test_id ON test_questions (test_id);

-- Table: submissions
CREATE TABLE submissions (
	id SERIAL NOT NULL, 
	user_id INTEGER NOT NULL, 
	attempt_id INTEGER, 
	question_id INTEGER NOT NULL, 
	answer JSON NOT NULL, 
	mode VARCHAR(16) NOT NULL, 
	language VARCHAR(32), 
	code TEXT, 
	time_taken_ms INTEGER, 
	confidence INTEGER, 
	created_at TIMESTAMP WITH TIME ZONE NOT NULL, 
	CONSTRAINT pk_submissions PRIMARY KEY (id), 
	CONSTRAINT fk_submissions_user_id_users FOREIGN KEY(user_id) REFERENCES users (id) ON DELETE CASCADE, 
	CONSTRAINT fk_submissions_attempt_id_attempts FOREIGN KEY(attempt_id) REFERENCES attempts (id) ON DELETE CASCADE, 
	CONSTRAINT fk_submissions_question_id_questions FOREIGN KEY(question_id) REFERENCES questions (id) ON DELETE CASCADE
);
CREATE INDEX ix_submissions_user_id ON submissions (user_id);
CREATE INDEX ix_submissions_mode ON submissions (mode);

-- Table: verdicts
CREATE TABLE verdicts (
	id SERIAL NOT NULL, 
	submission_id INTEGER NOT NULL, 
	status VARCHAR(32) NOT NULL, 
	is_correct BOOLEAN NOT NULL, 
	score FLOAT NOT NULL, 
	judged_by VARCHAR(16) NOT NULL, 
	details JSON NOT NULL, 
	created_at TIMESTAMP WITH TIME ZONE NOT NULL, 
	CONSTRAINT pk_verdicts PRIMARY KEY (id), 
	CONSTRAINT uq_verdicts_submission_id UNIQUE (submission_id), 
	CONSTRAINT fk_verdicts_submission_id_submissions FOREIGN KEY(submission_id) REFERENCES submissions (id) ON DELETE CASCADE
);

-- pgvector HNSW Approximate Nearest Neighbor Index for RAG Retrieval
CREATE INDEX IF NOT EXISTS ix_documents_embedding_hnsw ON documents 
USING hnsw (embedding vector_cosine_ops) WITH (m = 16, ef_construction = 64);

-- ============================================================================
-- PrepPath: ACTIVE LOCAL DEVELOPMENT DATABASE SCHEMA (SQLite 3 Dialect)
-- Source: Live backend/dev.db schema snapshot
-- Note: Embeddings are stored as JSON list fallback; vector cosine operations
--       are evaluated in-memory via numpy/math cosine similarity in Python.
-- ============================================================================

-- SQLite Table: ai_traces
CREATE TABLE ai_traces (
	id INTEGER NOT NULL, 
	user_id INTEGER, 
	call_type VARCHAR(48) NOT NULL, 
	agent VARCHAR(32), 
	run_id VARCHAR(64), 
	model VARCHAR(64) NOT NULL, 
	prompt_tokens INTEGER NOT NULL, 
	completion_tokens INTEGER NOT NULL, 
	latency_ms INTEGER NOT NULL, 
	cost_usd FLOAT NOT NULL, 
	success BOOLEAN NOT NULL, 
	error TEXT, 
	meta JSON NOT NULL, 
	created_at DATETIME NOT NULL, 
	CONSTRAINT pk_ai_traces PRIMARY KEY (id), 
	CONSTRAINT fk_ai_traces_user_id_users FOREIGN KEY(user_id) REFERENCES users (id) ON DELETE SET NULL
);

-- SQLite Table: alembic_version
CREATE TABLE alembic_version (
	version_num VARCHAR(32) NOT NULL, 
	CONSTRAINT alembic_version_pkc PRIMARY KEY (version_num)
);

-- SQLite Table: attempts
CREATE TABLE attempts (
	id INTEGER NOT NULL, 
	user_id INTEGER NOT NULL, 
	test_id INTEGER, 
	mode VARCHAR(16) NOT NULL, 
	status VARCHAR(16) NOT NULL, 
	score FLOAT, 
	max_score FLOAT, 
	state JSON NOT NULL, 
	started_at DATETIME NOT NULL, 
	submitted_at DATETIME, 
	CONSTRAINT pk_attempts PRIMARY KEY (id), 
	CONSTRAINT fk_attempts_user_id_users FOREIGN KEY(user_id) REFERENCES users (id) ON DELETE CASCADE, 
	CONSTRAINT fk_attempts_test_id_tests FOREIGN KEY(test_id) REFERENCES tests (id) ON DELETE SET NULL
);

-- SQLite Table: companies
CREATE TABLE companies (
	id INTEGER NOT NULL, 
	name VARCHAR(120) NOT NULL, 
	slug VARCHAR(140) NOT NULL, 
	description TEXT NOT NULL, 
	skill_weights JSON NOT NULL, 
	oa_pattern JSON NOT NULL, 
	readiness_weights JSON, 
	created_at DATETIME NOT NULL, 
	updated_at DATETIME NOT NULL, 
	CONSTRAINT pk_companies PRIMARY KEY (id), 
	CONSTRAINT uq_companies_name UNIQUE (name)
);

-- SQLite Table: documents
CREATE TABLE documents (
	id INTEGER NOT NULL, 
	title VARCHAR(255) NOT NULL, 
	kind VARCHAR(32) NOT NULL, 
	source_uri VARCHAR(500) NOT NULL, 
	chunk_index INTEGER NOT NULL, 
	content TEXT NOT NULL, 
	topic_id INTEGER, 
	company_id INTEGER, 
	embedding JSON, 
	meta JSON NOT NULL, 
	created_at DATETIME NOT NULL, 
	updated_at DATETIME NOT NULL, 
	CONSTRAINT pk_documents PRIMARY KEY (id), 
	CONSTRAINT fk_documents_topic_id_topics FOREIGN KEY(topic_id) REFERENCES topics (id) ON DELETE SET NULL, 
	CONSTRAINT fk_documents_company_id_companies FOREIGN KEY(company_id) REFERENCES companies (id) ON DELETE SET NULL
);

-- SQLite Table: feedback
CREATE TABLE feedback (
	id INTEGER NOT NULL, 
	user_id INTEGER NOT NULL, 
	target_type VARCHAR(32) NOT NULL, 
	target_id INTEGER NOT NULL, 
	rating INTEGER, 
	comment TEXT NOT NULL, 
	created_at DATETIME NOT NULL, 
	CONSTRAINT pk_feedback PRIMARY KEY (id), 
	CONSTRAINT fk_feedback_user_id_users FOREIGN KEY(user_id) REFERENCES users (id) ON DELETE CASCADE
);

-- SQLite Table: interviews
CREATE TABLE interviews (
	id INTEGER NOT NULL, 
	user_id INTEGER NOT NULL, 
	company_id INTEGER, 
	role VARCHAR(120) NOT NULL, 
	interview_type VARCHAR(16) NOT NULL, 
	difficulty VARCHAR(16) NOT NULL, 
	status VARCHAR(16) NOT NULL, 
	transcript JSON NOT NULL, 
	scores JSON NOT NULL, 
	report JSON NOT NULL, 
	started_at DATETIME NOT NULL, 
	ended_at DATETIME, 
	CONSTRAINT pk_interviews PRIMARY KEY (id), 
	CONSTRAINT fk_interviews_user_id_users FOREIGN KEY(user_id) REFERENCES users (id) ON DELETE CASCADE, 
	CONSTRAINT fk_interviews_company_id_companies FOREIGN KEY(company_id) REFERENCES companies (id) ON DELETE SET NULL
);

-- SQLite Table: job_descriptions
CREATE TABLE job_descriptions (
	id INTEGER NOT NULL, 
	user_id INTEGER NOT NULL, 
	title VARCHAR(200) NOT NULL, 
	company_name VARCHAR(120) NOT NULL, 
	raw_text TEXT NOT NULL, 
	parsed JSON NOT NULL, 
	created_at DATETIME NOT NULL, 
	updated_at DATETIME NOT NULL, 
	CONSTRAINT pk_job_descriptions PRIMARY KEY (id), 
	CONSTRAINT fk_job_descriptions_user_id_users FOREIGN KEY(user_id) REFERENCES users (id) ON DELETE CASCADE
);

-- SQLite Table: mastery
CREATE TABLE mastery (
	id INTEGER NOT NULL, 
	user_id INTEGER NOT NULL, 
	skill_id INTEGER NOT NULL, 
	mastery_score FLOAT NOT NULL, 
	attempt_count INTEGER NOT NULL, 
	correct_count INTEGER NOT NULL, 
	accuracy FLOAT NOT NULL, 
	average_time_ms FLOAT NOT NULL, 
	difficulty FLOAT NOT NULL, 
	confidence FLOAT, 
	last_attempt DATETIME, 
	CONSTRAINT pk_mastery PRIMARY KEY (id), 
	CONSTRAINT uq_mastery_user_id UNIQUE (user_id, skill_id), 
	CONSTRAINT fk_mastery_user_id_users FOREIGN KEY(user_id) REFERENCES users (id) ON DELETE CASCADE, 
	CONSTRAINT fk_mastery_skill_id_skills FOREIGN KEY(skill_id) REFERENCES skills (id) ON DELETE CASCADE
);

-- SQLite Table: profiles
CREATE TABLE profiles (
	id INTEGER NOT NULL, 
	user_id INTEGER NOT NULL, 
	college VARCHAR(200) NOT NULL, 
	branch VARCHAR(120) NOT NULL, 
	graduation_year INTEGER, 
	target_role VARCHAR(120) NOT NULL, 
	target_company_ids JSON NOT NULL, 
	dsa_score FLOAT, 
	csf_score FLOAT, 
	aptitude_score FLOAT, 
	coding_score FLOAT, 
	study_streak INTEGER NOT NULL, 
	last_active_on DATE, 
	topics_completed INTEGER NOT NULL, 
	weak_topics JSON NOT NULL, 
	preferred_language VARCHAR(32) NOT NULL, 
	resume_id INTEGER, 
	created_at DATETIME NOT NULL, 
	updated_at DATETIME NOT NULL, 
	CONSTRAINT pk_profiles PRIMARY KEY (id), 
	CONSTRAINT uq_profiles_user_id UNIQUE (user_id), 
	CONSTRAINT fk_profiles_user_id_users FOREIGN KEY(user_id) REFERENCES users (id) ON DELETE CASCADE, 
	CONSTRAINT fk_profiles_resume_id_resumes FOREIGN KEY(resume_id) REFERENCES resumes (id) ON DELETE SET NULL
);

-- SQLite Table: progress
CREATE TABLE progress (
	id INTEGER NOT NULL, 
	user_id INTEGER NOT NULL, 
	topic_id INTEGER NOT NULL, 
	status VARCHAR(16) NOT NULL, 
	updated_at DATETIME NOT NULL, 
	CONSTRAINT pk_progress PRIMARY KEY (id), 
	CONSTRAINT uq_progress_user_id UNIQUE (user_id, topic_id), 
	CONSTRAINT fk_progress_user_id_users FOREIGN KEY(user_id) REFERENCES users (id) ON DELETE CASCADE, 
	CONSTRAINT fk_progress_topic_id_topics FOREIGN KEY(topic_id) REFERENCES topics (id) ON DELETE CASCADE
);

-- SQLite Table: question_companies
CREATE TABLE question_companies (
	question_id INTEGER NOT NULL, 
	company_id INTEGER NOT NULL, 
	CONSTRAINT pk_question_companies PRIMARY KEY (question_id, company_id), 
	CONSTRAINT fk_question_companies_question_id_questions FOREIGN KEY(question_id) REFERENCES questions (id) ON DELETE CASCADE, 
	CONSTRAINT fk_question_companies_company_id_companies FOREIGN KEY(company_id) REFERENCES companies (id) ON DELETE CASCADE
);

-- SQLite Table: questions
CREATE TABLE questions (
	id INTEGER NOT NULL, 
	type VARCHAR(32) NOT NULL, 
	title VARCHAR(200) NOT NULL, 
	body TEXT NOT NULL, 
	difficulty VARCHAR(16) NOT NULL, 
	topic_id INTEGER, 
	options JSON NOT NULL, 
	answer JSON NOT NULL, 
	explanation TEXT NOT NULL, 
	meta JSON NOT NULL, 
	status VARCHAR(16) NOT NULL, 
	source VARCHAR(16) NOT NULL, 
	created_by INTEGER, 
	created_at DATETIME NOT NULL, 
	updated_at DATETIME NOT NULL, 
	CONSTRAINT pk_questions PRIMARY KEY (id), 
	CONSTRAINT fk_questions_topic_id_topics FOREIGN KEY(topic_id) REFERENCES topics (id) ON DELETE SET NULL, 
	CONSTRAINT fk_questions_created_by_users FOREIGN KEY(created_by) REFERENCES users (id) ON DELETE SET NULL
);

-- SQLite Table: readiness_scores
CREATE TABLE readiness_scores (
	id INTEGER NOT NULL, 
	user_id INTEGER NOT NULL, 
	company_id INTEGER, 
	overall FLOAT NOT NULL, 
	components JSON NOT NULL, 
	weights JSON NOT NULL, 
	computed_at DATETIME NOT NULL, 
	CONSTRAINT pk_readiness_scores PRIMARY KEY (id), 
	CONSTRAINT fk_readiness_scores_user_id_users FOREIGN KEY(user_id) REFERENCES users (id) ON DELETE CASCADE, 
	CONSTRAINT fk_readiness_scores_company_id_companies FOREIGN KEY(company_id) REFERENCES companies (id) ON DELETE CASCADE
);

-- SQLite Table: recommendations
CREATE TABLE recommendations (
	id INTEGER NOT NULL, 
	user_id INTEGER NOT NULL, 
	kind VARCHAR(32) NOT NULL, 
	payload JSON NOT NULL, 
	reason TEXT NOT NULL, 
	created_at DATETIME NOT NULL, 
	acted_at DATETIME, 
	CONSTRAINT pk_recommendations PRIMARY KEY (id), 
	CONSTRAINT fk_recommendations_user_id_users FOREIGN KEY(user_id) REFERENCES users (id) ON DELETE CASCADE
);

-- SQLite Table: resumes
CREATE TABLE resumes (
	id INTEGER NOT NULL, 
	user_id INTEGER NOT NULL, 
	filename VARCHAR(255) NOT NULL, 
	content_type VARCHAR(100) NOT NULL, 
	storage_path VARCHAR(500) NOT NULL, 
	status VARCHAR(16) NOT NULL, 
	parsed JSON NOT NULL, 
	created_at DATETIME NOT NULL, 
	updated_at DATETIME NOT NULL, 
	CONSTRAINT pk_resumes PRIMARY KEY (id), 
	CONSTRAINT fk_resumes_user_id_users FOREIGN KEY(user_id) REFERENCES users (id) ON DELETE CASCADE
);

-- SQLite Table: roadmaps
CREATE TABLE roadmaps (
	id INTEGER NOT NULL, 
	user_id INTEGER NOT NULL, 
	company_id INTEGER, 
	title VARCHAR(200) NOT NULL, 
	"plan" JSON NOT NULL, 
	version INTEGER NOT NULL, 
	status VARCHAR(16) NOT NULL, 
	created_at DATETIME NOT NULL, 
	updated_at DATETIME NOT NULL, 
	CONSTRAINT pk_roadmaps PRIMARY KEY (id), 
	CONSTRAINT fk_roadmaps_user_id_users FOREIGN KEY(user_id) REFERENCES users (id) ON DELETE CASCADE, 
	CONSTRAINT fk_roadmaps_company_id_companies FOREIGN KEY(company_id) REFERENCES companies (id) ON DELETE SET NULL
);

-- SQLite Table: roles
CREATE TABLE roles (
	id INTEGER NOT NULL, 
	name VARCHAR(32) NOT NULL, 
	description VARCHAR(255) NOT NULL, 
	scopes JSON NOT NULL, 
	CONSTRAINT pk_roles PRIMARY KEY (id), 
	CONSTRAINT uq_roles_name UNIQUE (name)
);

-- SQLite Table: sessions
CREATE TABLE sessions (
	id INTEGER NOT NULL, 
	user_id INTEGER NOT NULL, 
	family_id VARCHAR(64) NOT NULL, 
	token_hash VARCHAR(64) NOT NULL, 
	expires_at DATETIME NOT NULL, 
	revoked_at DATETIME, 
	replaced_by_id INTEGER, 
	user_agent VARCHAR(255) NOT NULL, 
	created_at DATETIME NOT NULL, 
	CONSTRAINT pk_sessions PRIMARY KEY (id), 
	CONSTRAINT fk_sessions_user_id_users FOREIGN KEY(user_id) REFERENCES users (id) ON DELETE CASCADE, 
	CONSTRAINT uq_sessions_token_hash UNIQUE (token_hash)
);

-- SQLite Table: skills
CREATE TABLE skills (
	id INTEGER NOT NULL, 
	name VARCHAR(120) NOT NULL, 
	slug VARCHAR(140) NOT NULL, 
	area VARCHAR(32) NOT NULL, 
	parent_id INTEGER, 
	topic_id INTEGER, 
	difficulty FLOAT NOT NULL, 
	CONSTRAINT pk_skills PRIMARY KEY (id), 
	CONSTRAINT uq_skills_slug UNIQUE (slug), 
	CONSTRAINT fk_skills_parent_id_skills FOREIGN KEY(parent_id) REFERENCES skills (id) ON DELETE CASCADE, 
	CONSTRAINT fk_skills_topic_id_topics FOREIGN KEY(topic_id) REFERENCES topics (id) ON DELETE SET NULL
);

-- SQLite Table: submissions
CREATE TABLE submissions (
	id INTEGER NOT NULL, 
	user_id INTEGER NOT NULL, 
	attempt_id INTEGER, 
	question_id INTEGER NOT NULL, 
	answer JSON NOT NULL, 
	mode VARCHAR(16) NOT NULL, 
	language VARCHAR(32), 
	code TEXT, 
	time_taken_ms INTEGER, 
	confidence INTEGER, 
	created_at DATETIME NOT NULL, 
	CONSTRAINT pk_submissions PRIMARY KEY (id), 
	CONSTRAINT fk_submissions_user_id_users FOREIGN KEY(user_id) REFERENCES users (id) ON DELETE CASCADE, 
	CONSTRAINT fk_submissions_attempt_id_attempts FOREIGN KEY(attempt_id) REFERENCES attempts (id) ON DELETE CASCADE, 
	CONSTRAINT fk_submissions_question_id_questions FOREIGN KEY(question_id) REFERENCES questions (id) ON DELETE CASCADE
);

-- SQLite Table: test_questions
CREATE TABLE test_questions (
	id INTEGER NOT NULL, 
	test_id INTEGER NOT NULL, 
	question_id INTEGER NOT NULL, 
	section VARCHAR(64) NOT NULL, 
	position INTEGER NOT NULL, 
	marks FLOAT NOT NULL, 
	negative_marks FLOAT NOT NULL, 
	CONSTRAINT pk_test_questions PRIMARY KEY (id), 
	CONSTRAINT fk_test_questions_test_id_tests FOREIGN KEY(test_id) REFERENCES tests (id) ON DELETE CASCADE, 
	CONSTRAINT fk_test_questions_question_id_questions FOREIGN KEY(question_id) REFERENCES questions (id) ON DELETE CASCADE
);

-- SQLite Table: tests
CREATE TABLE tests (
	id INTEGER NOT NULL, 
	title VARCHAR(200) NOT NULL, 
	description TEXT NOT NULL, 
	company_id INTEGER, 
	duration_seconds INTEGER NOT NULL, 
	sections JSON NOT NULL, 
	negative_marking BOOLEAN NOT NULL, 
	randomize BOOLEAN NOT NULL, 
	is_published BOOLEAN NOT NULL, 
	created_by INTEGER, 
	created_at DATETIME NOT NULL, 
	updated_at DATETIME NOT NULL, 
	CONSTRAINT pk_tests PRIMARY KEY (id), 
	CONSTRAINT fk_tests_company_id_companies FOREIGN KEY(company_id) REFERENCES companies (id) ON DELETE SET NULL, 
	CONSTRAINT fk_tests_created_by_users FOREIGN KEY(created_by) REFERENCES users (id) ON DELETE SET NULL
);

-- SQLite Table: topics
CREATE TABLE topics (
	id INTEGER NOT NULL, 
	name VARCHAR(120) NOT NULL, 
	slug VARCHAR(140) NOT NULL, 
	area VARCHAR(32) NOT NULL, 
	description TEXT NOT NULL, 
	parent_id INTEGER, 
	created_at DATETIME NOT NULL, 
	updated_at DATETIME NOT NULL, 
	CONSTRAINT pk_topics PRIMARY KEY (id), 
	CONSTRAINT fk_topics_parent_id_topics FOREIGN KEY(parent_id) REFERENCES topics (id) ON DELETE SET NULL
);

-- SQLite Table: users
CREATE TABLE users (
	id INTEGER NOT NULL, 
	email VARCHAR(320) NOT NULL, 
	password_hash VARCHAR(255), 
	google_sub VARCHAR(255), 
	full_name VARCHAR(120) NOT NULL, 
	role_id INTEGER NOT NULL, 
	is_active BOOLEAN NOT NULL, 
	last_login_at DATETIME, 
	created_at DATETIME NOT NULL, 
	updated_at DATETIME NOT NULL, 
	CONSTRAINT pk_users PRIMARY KEY (id), 
	CONSTRAINT uq_users_google_sub UNIQUE (google_sub), 
	CONSTRAINT fk_users_role_id_roles FOREIGN KEY(role_id) REFERENCES roles (id)
);

-- SQLite Table: verdicts
CREATE TABLE verdicts (
	id INTEGER NOT NULL, 
	submission_id INTEGER NOT NULL, 
	status VARCHAR(32) NOT NULL, 
	is_correct BOOLEAN NOT NULL, 
	score FLOAT NOT NULL, 
	judged_by VARCHAR(16) NOT NULL, 
	details JSON NOT NULL, 
	created_at DATETIME NOT NULL, 
	CONSTRAINT pk_verdicts PRIMARY KEY (id), 
	CONSTRAINT uq_verdicts_submission_id UNIQUE (submission_id), 
	CONSTRAINT fk_verdicts_submission_id_submissions FOREIGN KEY(submission_id) REFERENCES submissions (id) ON DELETE CASCADE
);
