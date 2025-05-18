create schema if not exists "app";

create schema if not exists "extensions";

create extension if not exists citext with schema "extensions" version '1.6';

create sequence "app"."departments_id_seq";

create sequence "app"."projects_id_seq";

create sequence "app"."skills_id_seq";

create table "app"."departments" (
    "id" integer not null default nextval('app.departments_id_seq'::regclass),
    "name" character varying(1000) not null
);


create table "app"."employee_departments" (
    "department_id" bigint not null,
    "employee_id" bigint not null
);


create table "app"."employee_projects" (
    "project_id" bigint not null,
    "employee_id" bigint not null
);


create table "app"."employee_skills" (
    "employee_id" bigint not null,
    "skill_id" bigint not null,
    "level" integer not null
);


create table "app"."employees" (
    "id" bigint generated always as identity not null,
    "first_name" text not null,
    "last_name" text,
    "email" citext not null,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now(),
    "skills" jsonb not null default '[]'::jsonb
);


create table "app"."projects" (
    "id" integer not null default nextval('app.projects_id_seq'::regclass),
    "name" character varying(1000) not null,
    "start" timestamp with time zone not null,
    "end_date" timestamp with time zone
);


create table "app"."skills" (
    "id" integer not null default nextval('app.skills_id_seq'::regclass),
    "name" character varying(1000) not null
);


alter sequence "app"."departments_id_seq" owned by "app"."departments"."id";

alter sequence "app"."projects_id_seq" owned by "app"."projects"."id";

alter sequence "app"."skills_id_seq" owned by "app"."skills"."id";

CREATE UNIQUE INDEX departments_pkey ON app.departments USING btree (id);

CREATE UNIQUE INDEX employee_departments_pkey ON app.employee_departments USING btree (department_id, employee_id);

CREATE UNIQUE INDEX employee_projects_pkey ON app.employee_projects USING btree (project_id, employee_id);

CREATE UNIQUE INDEX employee_skills_pkey ON app.employee_skills USING btree (employee_id, skill_id);

CREATE UNIQUE INDEX employees_pkey ON app.employees USING btree (id);

CREATE UNIQUE INDEX projects_pkey ON app.projects USING btree (id);

CREATE UNIQUE INDEX skills_name_key ON app.skills USING btree (name);

CREATE UNIQUE INDEX skills_pkey ON app.skills USING btree (id);

CREATE UNIQUE INDEX unique_email ON app.employees USING btree (email);

alter table "app"."departments" add constraint "departments_pkey" PRIMARY KEY using index "departments_pkey";

alter table "app"."employee_departments" add constraint "employee_departments_pkey" PRIMARY KEY using index "employee_departments_pkey";

alter table "app"."employee_projects" add constraint "employee_projects_pkey" PRIMARY KEY using index "employee_projects_pkey";

alter table "app"."employee_skills" add constraint "employee_skills_pkey" PRIMARY KEY using index "employee_skills_pkey";

alter table "app"."employees" add constraint "employees_pkey" PRIMARY KEY using index "employees_pkey";

alter table "app"."projects" add constraint "projects_pkey" PRIMARY KEY using index "projects_pkey";

alter table "app"."skills" add constraint "skills_pkey" PRIMARY KEY using index "skills_pkey";

alter table "app"."employee_departments" add constraint "employee_departments_department_id_fkey" FOREIGN KEY (department_id) REFERENCES app.departments(id) not valid;

alter table "app"."employee_departments" validate constraint "employee_departments_department_id_fkey";

alter table "app"."employee_departments" add constraint "employee_departments_employee_id_fkey" FOREIGN KEY (employee_id) REFERENCES app.employees(id) not valid;

alter table "app"."employee_departments" validate constraint "employee_departments_employee_id_fkey";

alter table "app"."employee_projects" add constraint "employee_projects_employee_id_fkey" FOREIGN KEY (employee_id) REFERENCES app.employees(id) not valid;

alter table "app"."employee_projects" validate constraint "employee_projects_employee_id_fkey";

alter table "app"."employee_projects" add constraint "employee_projects_project_id_fkey" FOREIGN KEY (project_id) REFERENCES app.projects(id) not valid;

alter table "app"."employee_projects" validate constraint "employee_projects_project_id_fkey";

alter table "app"."employee_skills" add constraint "employee_skills_employee_id_fkey" FOREIGN KEY (employee_id) REFERENCES app.employees(id) not valid;

alter table "app"."employee_skills" validate constraint "employee_skills_employee_id_fkey";

alter table "app"."employee_skills" add constraint "employee_skills_level_check" CHECK (((level >= 0) AND (level <= 4))) not valid;

alter table "app"."employee_skills" validate constraint "employee_skills_level_check";

alter table "app"."employee_skills" add constraint "employee_skills_skill_id_fkey" FOREIGN KEY (skill_id) REFERENCES app.skills(id) not valid;

alter table "app"."employee_skills" validate constraint "employee_skills_skill_id_fkey";

alter table "app"."employees" add constraint "first_name_not_empty" CHECK ((char_length(TRIM(BOTH FROM first_name)) > 0)) not valid;

alter table "app"."employees" validate constraint "first_name_not_empty";

alter table "app"."employees" add constraint "last_name_not_empty" CHECK (((last_name IS NULL) OR (char_length(TRIM(BOTH FROM last_name)) > 0))) not valid;

alter table "app"."employees" validate constraint "last_name_not_empty";



alter table "app"."employees" add constraint "unique_email" UNIQUE using index "unique_email";

alter table "app"."projects" add constraint "name_not_empty" CHECK ((char_length(TRIM(BOTH FROM name)) > 0)) not valid;

alter table "app"."projects" validate constraint "name_not_empty";

alter table "app"."skills" add constraint "skills_name_check" CHECK ((char_length(TRIM(BOTH FROM name)) > 0)) not valid;

alter table "app"."skills" validate constraint "skills_name_check";

alter table "app"."skills" add constraint "skills_name_key" UNIQUE using index "skills_name_key";

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION app.set_updated_at()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$function$
;

CREATE TRIGGER trigger_set_updated_at BEFORE UPDATE ON app.employees FOR EACH ROW EXECUTE FUNCTION app.set_updated_at();


set check_function_bodies = off;

create or replace view "public"."available_employees" as  SELECT emp.id,
    emp.first_name,
    emp.last_name,
    emp.email,
    emp.created_at,
    emp.updated_at,
    emp.skills
   FROM ((app.employees emp
     LEFT JOIN app.employee_projects emp_prj ON ((emp_prj.employee_id = emp.id)))
     LEFT JOIN app.projects prj ON ((prj.id = emp_prj.project_id)))
  WHERE ((emp_prj.project_id IS NULL) OR (prj.end_date IS NOT NULL));


create or replace view "public"."departments" as  SELECT id,
    name
   FROM app.departments;


create or replace view "public"."employees" as  SELECT emp.id,
    emp.first_name,
    emp.last_name,
    emp.email,
    emp.skills,
    json_agg(json_build_object('id', prj.id, 'name', prj.name)) AS projects
   FROM ((app.employees emp
     LEFT JOIN app.employee_projects emp_j_prj ON ((emp_j_prj.employee_id = emp.id)))
     LEFT JOIN app.projects prj ON ((emp_j_prj.project_id = prj.id)))
  GROUP BY emp.id, emp.first_name, emp.last_name, emp.email, emp.skills
  ORDER BY emp.id;


create or replace view "public"."employees_with_normalized_skills" as  SELECT emp.id,
    emp.first_name,
    emp.last_name,
    emp.email,
    COALESCE(json_agg(DISTINCT jsonb_build_object('id', prj.id, 'name', prj.name)) FILTER (WHERE (prj.id IS NOT NULL)), '[]'::json) AS projects,
    COALESCE(json_agg(DISTINCT jsonb_build_object('id', sk.id, 'name', sk.name, 'level', es.level)) FILTER (WHERE (sk.id IS NOT NULL)), '[]'::json) AS skills
   FROM ((((app.employees emp
     LEFT JOIN app.employee_projects emp_j_prj ON ((emp_j_prj.employee_id = emp.id)))
     LEFT JOIN app.projects prj ON ((emp_j_prj.project_id = prj.id)))
     LEFT JOIN app.employee_skills es ON ((es.employee_id = emp.id)))
     LEFT JOIN app.skills sk ON ((es.skill_id = sk.id)))
  GROUP BY emp.id, emp.first_name, emp.last_name, emp.email;


CREATE OR REPLACE FUNCTION public.is_valid_skills_format(skills jsonb)
 RETURNS boolean
 LANGUAGE plpgsql
 STABLE
AS $function$
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
$function$
;


alter table "app"."employees" add constraint "skills_json_format_check" CHECK (is_valid_skills_format(skills)) not valid;


alter table "app"."employees" validate constraint "skills_json_format_check";

create or replace view "public"."projects" as  SELECT id,
    name
   FROM app.projects;



