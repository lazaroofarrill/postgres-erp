INSERT INTO app.employees(
    first_name, email, skills
)
values
('tilin', 'lol@lol.com', '[{"level": 5, "skill": "climbing" }]');


-- expect: ERROR:  new row for relation "employees" violates check constraint "skills_json_format_check"
