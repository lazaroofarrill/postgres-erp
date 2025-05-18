DROP VIEW IF EXISTS public.available_employees;
DROP VIEW IF EXISTS public.employees;

CREATE VIEW public.employees AS
SELECT emp.id,
       emp.first_name,
       emp.last_name,
       emp.email,
       emp.skills,
       json_agg(
               json_build_object(
                       'id', prj.id,
                       'name', prj.name
               )
       ) projects
FROM app.employees emp
         LEFT JOIN app.employee_projects emp_j_prj ON emp_j_prj.employee_id = emp.id
         LEFT JOIN app.projects prj ON emp_j_prj.project_id = prj.id
GROUP BY emp.id, emp.first_name, emp.last_name, emp.email, emp.skills
ORDER BY emp.id;


CREATE VIEW public.available_employees AS
SELECT emp.* FROM app.employees emp
LEFT JOIN app.employee_projects emp_prj on emp_prj.employee_id = emp.id
LEFT JOIN app.projects prj on prj.id = emp_prj.project_id
WHERE emp_prj.project_id IS NULL OR prj.end_date IS NOT NULL;
