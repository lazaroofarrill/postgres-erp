INSERT INTO app.employees(
    first_name, last_name, email
)
values
('recesion', '' ,'lol@lol.com');

-- expect: ERROR:  new row for relation "employees" violates check constraint "last_name_not_empty"
