INSERT INTO app.employees(
    first_name, email
)
values
('', 'lol@lol.com');

-- expect: ERROR:  new row for relation "employees" violates check constraint "first_name_not_empty"
