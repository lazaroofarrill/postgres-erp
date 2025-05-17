CREATE TABLE app.departments(
    id SERIAL PRIMARY KEY,
    name VARCHAR(1000) NOT NULL
);

CREATE VIEW public.departments AS
SELECT id, name
FROM app.departments;

CREATE TABLE app.projects(
    id SERIAL PRIMARY KEY,
    name VARCHAR(1000) NOT NULL,
    start TIMESTAMPTZ NOT NULL,
    end_date TIMESTAMPTZ NULL
);

CREATE VIEW public.projects AS
SELECT id, name
FROM app.projects;

CREATE TABLE app.employee_projects(
    project_id BIGINT REFERENCES app.projects,
    employee_id BIGINT REFERENCES app.employees,
    PRIMARY KEY (project_id, employee_id)
);

CREATE TABLE app.employee_departments(
    department_id BIGINT REFERENCES app.departments,
    employee_id BIGINT REFERENCES app.employees,
    PRIMARY KEY (department_id, employee_id)
);

CREATE VIEW public.available_employees AS
SELECT emp.* FROM public.employees emp
LEFT JOIN app.employee_projects emp_prj on emp_prj.employee_id = emp.id
LEFT JOIN app.projects prj on prj.id = emp_prj.project_id
WHERE emp_prj.project_id IS NULL OR prj.end_date IS NOT NULL;
