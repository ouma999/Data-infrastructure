USE comex_db;

-- Create a SQL Server login
CREATE LOGIN comex_user WITH PASSWORD = 'Comex@2026!';

-- Give it access to comex_db
CREATE USER comex_user FOR LOGIN comex_user;

-- Give it full permissions
ALTER ROLE db_owner ADD MEMBER comex_user;
```

---
USE comex_db;

SELECT 
    first_name,
    last_name,
    email,
    company,
    phone,
    message,
    status,
    source,
    created_at
FROM dbo.leads
ORDER BY created_at DESC;


SELECT * FROM dbo.services ORDER BY sort_order;

SELECT * FROM dbo.team_members ORDER BY sort_order;

SELECT * FROM dbo.clients ORDER BY name;
SELECT * FROM dbo.jobs ORDER BY posted_at DESC;