INSERT INTO app.employees (first_name, last_name, email, skills)
VALUES
  ('Alice', 'Nguyen', 'alice.nguyen@example.com', '[{"skill": "Python", "level": 4}, {"skill": "Django", "level": 3}, {"skill": "PostgreSQL", "level": 3}]'),
  ('Bob', 'Martinez', 'bob.martinez@example.com', '[{"skill": "JavaScript", "level": 4}, {"skill": "React", "level": 3}, {"skill": "Node.js", "level": 3}]'),
  ('Carol', 'Singh', 'carol.singh@example.com', '[{"skill": "Java", "level": 4}, {"skill": "Spring Boot", "level": 3}, {"skill": "MySQL", "level": 3}]'),
  ('David', 'Chen', 'david.chen@example.com', '[{"skill": "Go", "level": 4}, {"skill": "Docker", "level": 3}, {"skill": "Kubernetes", "level": 2}]'),
  ('Eva', 'Sanchez', 'eva.sanchez@example.com', '[{"skill": "Ruby", "level": 3}, {"skill": "Rails", "level": 3}, {"skill": "PostgreSQL", "level": 2}]'),
  ('Frank', 'Kim', 'frank.kim@example.com', '[{"skill": "C#", "level": 4}, {"skill": ".NET", "level": 3}, {"skill": "SQL Server", "level": 2}]'),
  ('Grace', 'Patel', 'grace.patel@example.com', '[{"skill": "TypeScript", "level": 3}, {"skill": "Angular", "level": 3}, {"skill": "MongoDB", "level": 2}]'),
  ('Hank', 'Brown', 'hank.brown@example.com', '[{"skill": "PHP", "level": 3}, {"skill": "Laravel", "level": 2}, {"skill": "MariaDB", "level": 2}]'),
  ('Isabel', 'Wright', 'isabel.wright@example.com', '[{"skill": "C++", "level": 4}, {"skill": "Qt", "level": 3}, {"skill": "SQLite", "level": 2}]'),
  ('Jake', 'Baker', 'jake.baker@example.com', '[{"skill": "Rust", "level": 3}, {"skill": "Actix", "level": 2}, {"skill": "PostgreSQL", "level": 3}]'),
  ('Kira', 'Lopez', 'kira.lopez@example.com', '[{"skill": "Swift", "level": 4}, {"skill": "iOS", "level": 3}, {"skill": "CoreData", "level": 2}]'),
  ('Leo', 'Morgan', 'leo.morgan@example.com', '[{"skill": "Kotlin", "level": 4}, {"skill": "Android", "level": 3}, {"skill": "Firebase", "level": 3}]'),
  ('Maya', 'Ali', 'maya.ali@example.com', '[{"skill": "Scala", "level": 3}, {"skill": "Play", "level": 2}, {"skill": "Cassandra", "level": 2}]'),
  ('Noah', 'Foster', 'noah.foster@example.com', '[{"skill": "Perl", "level": 3}, {"skill": "Mojolicious", "level": 2}, {"skill": "Oracle", "level": 2}]'),
  ('Olivia', 'Turner', 'olivia.turner@example.com', '[{"skill": "Elixir", "level": 3}, {"skill": "Phoenix", "level": 2}, {"skill": "PostgreSQL", "level": 3}]'),
  ('Paul', 'Diaz', 'paul.diaz@example.com', '[{"skill": "Shell", "level": 4}, {"skill": "Ansible", "level": 3}, {"skill": "Terraform", "level": 2}]'),
  ('Quinn', 'Jenkins', 'quinn.jenkins@example.com', '[{"skill": "Haskell", "level": 3}, {"skill": "Servant", "level": 2}, {"skill": "PostgreSQL", "level": 3}]'),
  ('Rosa', 'White', 'rosa.white@example.com', '[{"skill": "Dart", "level": 3}, {"skill": "Flutter", "level": 3}, {"skill": "Firebase", "level": 2}]'),
  ('Sam', 'Lee', 'sam.lee@example.com', '[{"skill": "MATLAB", "level": 4}, {"skill": "Simulink", "level": 3}, {"skill": "Python", "level": 2}]'),
  ('Tina', 'Hughes', 'tina.hughes@example.com', '[{"skill": "R", "level": 3}, {"skill": "Shiny", "level": 3}, {"skill": "SQL", "level": 2}]');

INSERT INTO app.projects
(name, start)
VALUES
('Engineering', now()),
('Human Resources', now()),
('Design', now());
