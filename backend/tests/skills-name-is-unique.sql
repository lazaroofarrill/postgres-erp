INSERT INTO app.skills (name)
VALUES ('Git'), ('Git');

-- expect: ERROR:  duplicate key value violates unique constraint "skills_name_key"
-- expect: DETAIL:  Key (name)=(Git) already exists.
