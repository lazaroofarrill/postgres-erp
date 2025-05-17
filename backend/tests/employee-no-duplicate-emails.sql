INSERT INTO app.employees(
    first_name, email
)
values
('tilin', 'lol@lol.com'),
('tilon', 'lol@lol.com');


-- expect: ERROR:  duplicate key value violates unique constraint "unique_email"
-- expect: DETAIL:  Key (email)=(lol@lol.com) already exists.
