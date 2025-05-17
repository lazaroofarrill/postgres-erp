
ALTER TABLE IF EXISTS app.employees
ADD skills jsonb default '[]',
ADD CONSTRAINT unique_email UNIQUE (email);

