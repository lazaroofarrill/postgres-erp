CREATE OR REPLACE FUNCTION is_valid_skills_format(skills JSONB)
RETURNS BOOLEAN
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
  item JSONB;
  lvl INTEGER;
BEGIN
  IF jsonb_typeof(skills) <> 'array' THEN
    RETURN FALSE;
  END IF;

  FOR item IN SELECT * FROM jsonb_array_elements(skills)
  LOOP
    IF jsonb_typeof(item) <> 'object' THEN
      RETURN FALSE;
    END IF;

    IF NOT (item ? 'skill') OR NOT (item ? 'level') THEN
      RETURN FALSE;
    END IF;

    IF jsonb_typeof(item->'skill') <> 'string' THEN
      RETURN FALSE;
    END IF;

    IF jsonb_typeof(item->'level') <> 'number' THEN
      RETURN FALSE;
    END IF;

    lvl := (item->>'level')::int;
    IF lvl < 0 OR lvl > 4 THEN
      RETURN FALSE;
    END IF;
  END LOOP;

  RETURN TRUE;
END;
$$;


ALTER TABLE app.employees
ADD CONSTRAINT skills_json_format_check
CHECK(is_valid_skills_format(skills));
