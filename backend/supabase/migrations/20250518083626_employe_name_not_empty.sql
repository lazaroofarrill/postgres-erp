ALTER TABLE app.employees
ADD CONSTRAINT first_name_not_empty
CHECK (char_length(trim(first_name)) > 0),
ADD CONSTRAINT last_name_not_empty
CHECK (last_name IS NULL OR char_length(trim(last_name)) > 0)
;
