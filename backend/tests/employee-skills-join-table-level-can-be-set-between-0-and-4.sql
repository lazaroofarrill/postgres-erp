DO $$
DECLARE
    _skill_id BIGINT;
    _employee_id BIGINT;
BEGIN
    INSERT INTO app.skills(name)
    VALUES
        ('Git')
    RETURNING id INTO _skill_id;

    INSERT INTO app.employees
        (first_name, last_name, email)
    VALUES
        ('tilin', 'tilon', 'tilin.tilon@lol.com')
    RETURNING id INTO _employee_id;

    INSERT INTO app.employee_skills
        (employee_id, skill_id, level)
    VALUES
        (_employee_id, _skill_id, 4);
END;
$$ LANGUAGE plpgsql;

-- expect: DO
