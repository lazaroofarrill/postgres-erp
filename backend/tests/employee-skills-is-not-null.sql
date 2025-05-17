INSERT INTO app.employees(
    first_name, email, skills
)
values
('tilin', 'lol@lol.com', null);


-- expect: ERROR:  null value in column "skills" of relation "employees" violates not-null constraint
