INSERT into app.projects(
    name, start
)
VALUES (null, now());


-- expect: ERROR:  null value in column "name" of relation "projects" violates not-null constraint
