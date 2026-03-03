-- ============================================================
--  COMEX DATABASE SCHEMA
--  Microsoft SQL Server (T-SQL) 2016+
-- ============================================================

-- Create & use database
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'comex_db')
    CREATE DATABASE comex_db;
GO

USE comex_db;
GO

-- ============================================================
-- 1. SERVICES
-- ============================================================
IF OBJECT_ID('dbo.services', 'U') IS NOT NULL DROP TABLE dbo.services;
GO
CREATE TABLE dbo.services (
    id          UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
    title       NVARCHAR(100)    NOT NULL,
    slug        NVARCHAR(100)    NOT NULL,
    short_desc  NVARCHAR(500)    NULL,
    full_desc   NVARCHAR(MAX)    NULL,
    icon_name   NVARCHAR(80)     NULL,
    category    NVARCHAR(60)     NULL,   -- cloud | data | ai | security | database | devops
    is_featured BIT              NOT NULL DEFAULT 0,
    sort_order  SMALLINT         NOT NULL DEFAULT 0,
    created_at  DATETIME2        NOT NULL DEFAULT GETDATE(),
    updated_at  DATETIME2        NOT NULL DEFAULT GETDATE(),
    CONSTRAINT PK_services      PRIMARY KEY (id),
    CONSTRAINT UQ_services_slug UNIQUE      (slug)
);
GO
CREATE INDEX idx_services_category ON dbo.services(category);
CREATE INDEX idx_services_featured ON dbo.services(is_featured);
GO

-- ============================================================
-- 2. TEAM MEMBERS
-- ============================================================
IF OBJECT_ID('dbo.team_members', 'U') IS NOT NULL DROP TABLE dbo.team_members;
GO
CREATE TABLE dbo.team_members (
    id            UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
    full_name     NVARCHAR(100)    NOT NULL,
    role          NVARCHAR(120)    NOT NULL,
    bio           NVARCHAR(MAX)    NULL,
    photo_url     NVARCHAR(500)    NULL,
    linkedin_url  NVARCHAR(500)    NULL,
    email         NVARCHAR(150)    NULL,
    department    NVARCHAR(80)     NULL,
    is_leadership BIT              NOT NULL DEFAULT 0,
    is_active     BIT              NOT NULL DEFAULT 1,
    sort_order    SMALLINT         NOT NULL DEFAULT 0,
    created_at    DATETIME2        NOT NULL DEFAULT GETDATE(),
    CONSTRAINT PK_team_members PRIMARY KEY (id)
);
GO
CREATE INDEX idx_team_leadership ON dbo.team_members(is_leadership);
CREATE INDEX idx_team_active     ON dbo.team_members(is_active);
GO

-- ============================================================
-- 3. CLIENTS / PARTNERS
-- ============================================================
IF OBJECT_ID('dbo.clients', 'U') IS NOT NULL DROP TABLE dbo.clients;
GO
CREATE TABLE dbo.clients (
    id          UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
    name        NVARCHAR(120)    NOT NULL,
    logo_url    NVARCHAR(500)    NULL,
    website_url NVARCHAR(500)    NULL,
    industry    NVARCHAR(100)    NULL,
    country     NVARCHAR(80)     NULL,
    tier        NVARCHAR(30)     NOT NULL DEFAULT 'standard', -- standard | gold | platinum
    is_featured BIT              NOT NULL DEFAULT 0,
    since_year  SMALLINT         NULL,
    created_at  DATETIME2        NOT NULL DEFAULT GETDATE(),
    CONSTRAINT PK_clients PRIMARY KEY (id)
);
GO
CREATE INDEX idx_clients_featured ON dbo.clients(is_featured);
CREATE INDEX idx_clients_industry ON dbo.clients(industry);
GO

-- ============================================================
-- 4. CASE STUDIES
-- ============================================================
IF OBJECT_ID('dbo.case_studies', 'U') IS NOT NULL DROP TABLE dbo.case_studies;
GO
CREATE TABLE dbo.case_studies (
    id              UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
    client_id       UNIQUEIDENTIFIER NULL,
    service_id      UNIQUEIDENTIFIER NULL,
    title           NVARCHAR(220)    NOT NULL,
    slug            NVARCHAR(220)    NOT NULL,
    industry        NVARCHAR(100)    NULL,
    country         NVARCHAR(80)     NULL,
    challenge       NVARCHAR(MAX)    NULL,
    solution        NVARCHAR(MAX)    NULL,
    results         NVARCHAR(MAX)    NULL,
    key_metric      NVARCHAR(200)    NULL,   -- e.g. 60% cost reduction
    cover_image_url NVARCHAR(500)    NULL,
    banner_emoji    NVARCHAR(10)     NULL,
    is_featured     BIT              NOT NULL DEFAULT 0,
    published_at    DATETIME2        NULL,
    created_at      DATETIME2        NOT NULL DEFAULT GETDATE(),
    updated_at      DATETIME2        NOT NULL DEFAULT GETDATE(),
    CONSTRAINT PK_case_studies      PRIMARY KEY (id),
    CONSTRAINT UQ_cases_slug        UNIQUE      (slug),
    CONSTRAINT FK_cases_client      FOREIGN KEY (client_id)  REFERENCES dbo.clients(id),
    CONSTRAINT FK_cases_service     FOREIGN KEY (service_id) REFERENCES dbo.services(id)
);
GO
CREATE INDEX idx_cases_featured ON dbo.case_studies(is_featured);
CREATE INDEX idx_cases_industry ON dbo.case_studies(industry);
GO

-- ============================================================
-- 5. BLOG POSTS / INSIGHTS
-- ============================================================
IF OBJECT_ID('dbo.posts', 'U') IS NOT NULL DROP TABLE dbo.posts;
GO
CREATE TABLE dbo.posts (
    id              UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
    author_id       UNIQUEIDENTIFIER NULL,
    title           NVARCHAR(250)    NOT NULL,
    slug            NVARCHAR(250)    NOT NULL,
    excerpt         NVARCHAR(MAX)    NULL,
    content         NVARCHAR(MAX)    NULL,
    cover_image_url NVARCHAR(500)    NULL,
    category        NVARCHAR(100)    NULL,
    read_time_mins  SMALLINT         NULL,
    is_published    BIT              NOT NULL DEFAULT 0,
    is_featured     BIT              NOT NULL DEFAULT 0,
    views           INT              NOT NULL DEFAULT 0,
    published_at    DATETIME2        NULL,
    created_at      DATETIME2        NOT NULL DEFAULT GETDATE(),
    updated_at      DATETIME2        NOT NULL DEFAULT GETDATE(),
    CONSTRAINT PK_posts      PRIMARY KEY (id),
    CONSTRAINT UQ_posts_slug UNIQUE      (slug),
    CONSTRAINT FK_posts_author FOREIGN KEY (author_id) REFERENCES dbo.team_members(id)
);
GO
CREATE INDEX idx_posts_published ON dbo.posts(is_published, published_at);
GO

-- Post Tags (normalized - no array type in SQL Server)
IF OBJECT_ID('dbo.post_tags', 'U') IS NOT NULL DROP TABLE dbo.post_tags;
GO
CREATE TABLE dbo.post_tags (
    post_id UNIQUEIDENTIFIER NOT NULL,
    tag     NVARCHAR(80)     NOT NULL,
    CONSTRAINT PK_post_tags      PRIMARY KEY (post_id, tag),
    CONSTRAINT FK_post_tags_post FOREIGN KEY (post_id) REFERENCES dbo.posts(id) ON DELETE CASCADE
);
GO

-- ============================================================
-- 6. TESTIMONIALS
-- ============================================================
IF OBJECT_ID('dbo.testimonials', 'U') IS NOT NULL DROP TABLE dbo.testimonials;
GO
CREATE TABLE dbo.testimonials (
    id            UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
    client_id     UNIQUEIDENTIFIER NULL,
    case_study_id UNIQUEIDENTIFIER NULL,
    author_name   NVARCHAR(120)    NOT NULL,
    author_role   NVARCHAR(120)    NULL,
    author_photo  NVARCHAR(500)    NULL,
    quote         NVARCHAR(MAX)    NOT NULL,
    rating        TINYINT          NULL CHECK (rating BETWEEN 1 AND 5),
    is_featured   BIT              NOT NULL DEFAULT 0,
    created_at    DATETIME2        NOT NULL DEFAULT GETDATE(),
    CONSTRAINT PK_testimonials       PRIMARY KEY (id),
    CONSTRAINT FK_test_client        FOREIGN KEY (client_id)     REFERENCES dbo.clients(id),
    CONSTRAINT FK_test_case_study    FOREIGN KEY (case_study_id) REFERENCES dbo.case_studies(id)
);
GO
CREATE INDEX idx_testimonials_featured ON dbo.testimonials(is_featured);
GO

-- ============================================================
-- 7. LEADS (Contact Form Submissions)
-- ============================================================
IF OBJECT_ID('dbo.leads', 'U') IS NOT NULL DROP TABLE dbo.leads;
GO
CREATE TABLE dbo.leads (
    id           UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
    first_name   NVARCHAR(60)     NOT NULL,
    last_name    NVARCHAR(60)     NOT NULL,
    email        NVARCHAR(150)    NOT NULL,
    company      NVARCHAR(150)    NULL,
    phone        NVARCHAR(30)     NULL,
    country      NVARCHAR(80)     NULL,
    service_id   UNIQUEIDENTIFIER NULL,
    message      NVARCHAR(MAX)    NULL,
    source       NVARCHAR(60)     NOT NULL DEFAULT 'contact_form', -- contact_form | newsletter | event | referral
    utm_source   NVARCHAR(100)    NULL,
    utm_medium   NVARCHAR(100)    NULL,
    utm_campaign NVARCHAR(100)    NULL,
    status       NVARCHAR(30)     NOT NULL DEFAULT 'new',          -- new | contacted | qualified | proposal | closed_won | closed_lost
    assigned_to  UNIQUEIDENTIFIER NULL,
    notes        NVARCHAR(MAX)    NULL,
    created_at   DATETIME2        NOT NULL DEFAULT GETDATE(),
    updated_at   DATETIME2        NOT NULL DEFAULT GETDATE(),
    CONSTRAINT PK_leads             PRIMARY KEY (id),
    CONSTRAINT FK_leads_service     FOREIGN KEY (service_id)  REFERENCES dbo.services(id),
    CONSTRAINT FK_leads_assigned_to FOREIGN KEY (assigned_to) REFERENCES dbo.team_members(id)
);
GO
CREATE INDEX idx_leads_email   ON dbo.leads(email);
CREATE INDEX idx_leads_status  ON dbo.leads(status);
CREATE INDEX idx_leads_created ON dbo.leads(created_at DESC);
GO

-- ============================================================
-- 8. NEWSLETTER SUBSCRIBERS
-- ============================================================
IF OBJECT_ID('dbo.subscribers', 'U') IS NOT NULL DROP TABLE dbo.subscribers;
GO
CREATE TABLE dbo.subscribers (
    id              UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
    email           NVARCHAR(150)    NOT NULL,
    first_name      NVARCHAR(60)     NULL,
    source          NVARCHAR(60)     NULL,
    is_active       BIT              NOT NULL DEFAULT 1,
    confirmed_at    DATETIME2        NULL,
    unsubscribed_at DATETIME2        NULL,
    subscribed_at   DATETIME2        NOT NULL DEFAULT GETDATE(),
    CONSTRAINT PK_subscribers       PRIMARY KEY (id),
    CONSTRAINT UQ_subscribers_email UNIQUE      (email)
);
GO
CREATE INDEX idx_subscribers_active ON dbo.subscribers(is_active);
GO

-- Subscriber Interests (normalized)
IF OBJECT_ID('dbo.subscriber_interests', 'U') IS NOT NULL DROP TABLE dbo.subscriber_interests;
GO
CREATE TABLE dbo.subscriber_interests (
    subscriber_id UNIQUEIDENTIFIER NOT NULL,
    interest      NVARCHAR(80)     NOT NULL,
    CONSTRAINT PK_subscriber_interests PRIMARY KEY (subscriber_id, interest),
    CONSTRAINT FK_sub_interests         FOREIGN KEY (subscriber_id) REFERENCES dbo.subscribers(id) ON DELETE CASCADE
);
GO

-- ============================================================
-- 9. SERVICE FEATURES
-- ============================================================
IF OBJECT_ID('dbo.service_features', 'U') IS NOT NULL DROP TABLE dbo.service_features;
GO
CREATE TABLE dbo.service_features (
    id          UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
    service_id  UNIQUEIDENTIFIER NOT NULL,
    title       NVARCHAR(120)    NOT NULL,
    description NVARCHAR(MAX)    NULL,
    sort_order  SMALLINT         NOT NULL DEFAULT 0,
    CONSTRAINT PK_service_features    PRIMARY KEY (id),
    CONSTRAINT FK_service_features_svc FOREIGN KEY (service_id) REFERENCES dbo.services(id) ON DELETE CASCADE
);
GO

-- ============================================================
-- 10. TECHNOLOGIES
-- ============================================================
IF OBJECT_ID('dbo.technologies', 'U') IS NOT NULL DROP TABLE dbo.technologies;
GO
CREATE TABLE dbo.technologies (
    id          UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
    name        NVARCHAR(80)     NOT NULL,
    logo_url    NVARCHAR(500)    NULL,
    category    NVARCHAR(60)     NULL,   -- cloud | database | ai | devops | data
    website_url NVARCHAR(500)    NULL,
    CONSTRAINT PK_technologies      PRIMARY KEY (id),
    CONSTRAINT UQ_technologies_name UNIQUE      (name)
);
GO

IF OBJECT_ID('dbo.service_technologies', 'U') IS NOT NULL DROP TABLE dbo.service_technologies;
GO
CREATE TABLE dbo.service_technologies (
    service_id UNIQUEIDENTIFIER NOT NULL,
    tech_id    UNIQUEIDENTIFIER NOT NULL,
    CONSTRAINT PK_service_technologies PRIMARY KEY (service_id, tech_id),
    CONSTRAINT FK_svc_tech_service     FOREIGN KEY (service_id) REFERENCES dbo.services(id)     ON DELETE CASCADE,
    CONSTRAINT FK_svc_tech_tech        FOREIGN KEY (tech_id)    REFERENCES dbo.technologies(id) ON DELETE CASCADE
);
GO

IF OBJECT_ID('dbo.case_study_technologies', 'U') IS NOT NULL DROP TABLE dbo.case_study_technologies;
GO
CREATE TABLE dbo.case_study_technologies (
    case_study_id UNIQUEIDENTIFIER NOT NULL,
    tech_id       UNIQUEIDENTIFIER NOT NULL,
    CONSTRAINT PK_case_study_technologies PRIMARY KEY (case_study_id, tech_id),
    CONSTRAINT FK_cs_tech_case            FOREIGN KEY (case_study_id) REFERENCES dbo.case_studies(id) ON DELETE CASCADE,
    CONSTRAINT FK_cs_tech_tech            FOREIGN KEY (tech_id)       REFERENCES dbo.technologies(id) ON DELETE CASCADE
);
GO

-- ============================================================
-- 11. CAREERS / JOB OPENINGS
-- ============================================================
IF OBJECT_ID('dbo.jobs', 'U') IS NOT NULL DROP TABLE dbo.jobs;
GO
CREATE TABLE dbo.jobs (
    id           UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
    title        NVARCHAR(150)    NOT NULL,
    department   NVARCHAR(80)     NULL,
    location     NVARCHAR(100)    NULL,
    type         NVARCHAR(40)     NULL,   -- full-time | part-time | contract | remote
    description  NVARCHAR(MAX)    NULL,
    requirements NVARCHAR(MAX)    NULL,
    is_open      BIT              NOT NULL DEFAULT 1,
    posted_at    DATETIME2        NOT NULL DEFAULT GETDATE(),
    closes_at    DATETIME2        NULL,
    CONSTRAINT PK_jobs PRIMARY KEY (id)
);
GO
CREATE INDEX idx_jobs_open ON dbo.jobs(is_open);
GO

-- ============================================================
-- TRIGGERS — auto-update updated_at
-- ============================================================
GO
CREATE OR ALTER TRIGGER trg_services_updated
ON dbo.services AFTER UPDATE AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.services SET updated_at = GETDATE()
    WHERE id IN (SELECT id FROM inserted);
END;
GO

CREATE OR ALTER TRIGGER trg_cases_updated
ON dbo.case_studies AFTER UPDATE AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.case_studies SET updated_at = GETDATE()
    WHERE id IN (SELECT id FROM inserted);
END;
GO

CREATE OR ALTER TRIGGER trg_posts_updated
ON dbo.posts AFTER UPDATE AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.posts SET updated_at = GETDATE()
    WHERE id IN (SELECT id FROM inserted);
END;
GO

CREATE OR ALTER TRIGGER trg_leads_updated
ON dbo.leads AFTER UPDATE AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.leads SET updated_at = GETDATE()
    WHERE id IN (SELECT id FROM inserted);
END;
GO

-- ============================================================
-- SEED DATA — Services
-- ============================================================
INSERT INTO dbo.services (id, title, slug, short_desc, icon_name, category, is_featured, sort_order) VALUES
    (NEWID(), 'Cloud Infrastructure',  'cloud-infrastructure', 'Architect, migrate, and manage multi-cloud environments.',        'cloud',    'cloud',    1, 1),
    (NEWID(), 'Data Analytics',        'data-analytics',       'End-to-end analytics, BI dashboards, and reporting platforms.',  'chart',    'data',     1, 2),
    (NEWID(), 'AI & Machine Learning', 'ai-ml',                'Intelligent models that automate decisions and predict outcomes.','robot',    'ai',       1, 3),
    (NEWID(), 'Cybersecurity',         'cybersecurity',        'Enterprise-grade security audits, compliance, and monitoring.',  'shield',   'security', 0, 4),
    (NEWID(), 'Database Management',   'database-management',  'Expert DBA services and performance tuning, 24/7.',              'database', 'database', 0, 5),
    (NEWID(), 'DevOps & Automation',   'devops-automation',    'CI/CD pipelines, IaC, and intelligent automation.',              'gear',     'devops',   0, 6);
GO

-- ============================================================
-- SEED DATA — Technologies
-- ============================================================
INSERT INTO dbo.technologies (id, name, category) VALUES
    (NEWID(), 'AWS',             'cloud'),
    (NEWID(), 'Microsoft Azure', 'cloud'),
    (NEWID(), 'Google Cloud',    'cloud'),
    (NEWID(), 'SQL Server',      'database'),
    (NEWID(), 'MySQL',           'database'),
    (NEWID(), 'Oracle',          'database'),
    (NEWID(), 'MongoDB',         'database'),
    (NEWID(), 'Kubernetes',      'devops'),
    (NEWID(), 'Terraform',       'devops'),
    (NEWID(), 'Apache Spark',    'data'),
    (NEWID(), 'dbt',             'data'),
    (NEWID(), 'TensorFlow',      'ai'),
    (NEWID(), 'PyTorch',         'ai');
GO

-- ============================================================
-- SEED DATA — Team Members
-- ============================================================
INSERT INTO dbo.team_members (id, full_name, role, department, is_leadership, sort_order) VALUES
    (NEWID(), 'Alex Comex',    'Chief Executive Officer',  'Executive', 1, 1),
    (NEWID(), 'Sara Ndungu',   'Chief Technology Officer', 'Executive', 1, 2),
    (NEWID(), 'David Osei',    'Head of Cloud Services',   'Cloud',     0, 3),
    (NEWID(), 'Linda Mutua',   'Lead Data Engineer',        'Data',      0, 4),
    (NEWID(), 'James Kariuki', 'AI & ML Architect',         'AI',        0, 5);
GO

-- ============================================================
-- USEFUL VIEWS
-- ============================================================

CREATE OR ALTER VIEW dbo.v_featured_services AS
    SELECT id, title, slug, short_desc, icon_name, category, sort_order
    FROM dbo.services
    WHERE is_featured = 1;
GO

CREATE OR ALTER VIEW dbo.v_featured_cases AS
    SELECT
        cs.id, cs.title, cs.slug, cs.industry,
        cs.key_metric, cs.banner_emoji, cs.published_at,
        c.name  AS client_name,
        s.title AS service_title
    FROM dbo.case_studies cs
    LEFT JOIN dbo.clients  c ON c.id = cs.client_id
    LEFT JOIN dbo.services s ON s.id = cs.service_id
    WHERE cs.is_featured = 1;
GO

CREATE OR ALTER VIEW dbo.v_open_leads AS
    SELECT
        l.id, l.first_name, l.last_name, l.email,
        l.company, l.status, l.created_at,
        s.title     AS service_interest,
        tm.full_name AS assigned_to_name
    FROM dbo.leads l
    LEFT JOIN dbo.services     s  ON s.id  = l.service_id
    LEFT JOIN dbo.team_members tm ON tm.id = l.assigned_to
    WHERE l.status NOT IN ('closed_won', 'closed_lost');
GO

CREATE OR ALTER VIEW dbo.v_subscriber_interests AS
    SELECT si.interest, COUNT(*) AS total
    FROM dbo.subscriber_interests si
    JOIN dbo.subscribers s ON s.id = si.subscriber_id
    WHERE s.is_active = 1
    GROUP BY si.interest;
GO

-- ============================================================
-- END OF COMEX SQL SERVER SCHEMA
-- =============
