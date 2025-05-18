ALTER TABLE app.projects
ADD CONSTRAINT name_not_empty
CHECK (char_length(trim(name)) > 0);
