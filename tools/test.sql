--
-- PostgreSQL database dump
--

-- Dumped from database version 14.6 (Debian 14.6-1.pgdg110+1)
-- Dumped by pg_dump version 14.6 (Debian 14.6-1.pgdg110+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: hr; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA hr;


ALTER SCHEMA hr OWNER TO postgres;

--
-- Name: dblink; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS dblink WITH SCHEMA hr;


--
-- Name: EXTENSION dblink; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION dblink IS 'connect to other PostgreSQL databases from within a database';


--
-- Name: add_job_history(integer, timestamp without time zone, timestamp without time zone, character varying, smallint); Type: PROCEDURE; Schema: hr; Owner: postgres
--

CREATE PROCEDURE hr.add_job_history(IN p_emp_id integer, IN p_start_date timestamp without time zone, IN p_end_date timestamp without time zone, IN p_job_id character varying, IN p_department_id smallint)
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
  INSERT INTO job_history(employee_id, start_date, end_date,
                           job_id, department_id)
    VALUES (p_emp_id, p_start_date, p_end_date, p_job_id, p_department_id);
END;
$$;


ALTER PROCEDURE hr.add_job_history(IN p_emp_id integer, IN p_start_date timestamp without time zone, IN p_end_date timestamp without time zone, IN p_job_id character varying, IN p_department_id smallint) OWNER TO postgres;

--
-- Name: secure_dml(); Type: PROCEDURE; Schema: hr; Owner: postgres
--

CREATE PROCEDURE hr.secure_dml()
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
  IF TO_CHAR(clock_timestamp(), 'HH24:MI') NOT BETWEEN '08:00' AND '18:00'
        OR TO_CHAR(clock_timestamp(), 'DY') IN ('SAT', 'SUN') THEN
	RAISE EXCEPTION '%', 'You may only make changes during normal office hours' USING ERRCODE = '45205';
  END IF;
END;
$$;


ALTER PROCEDURE hr.secure_dml() OWNER TO postgres;

--
-- Name: trigger_fct_update_job_history(); Type: FUNCTION; Schema: hr; Owner: postgres
--

CREATE FUNCTION hr.trigger_fct_update_job_history() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
  CALL add_job_history(OLD.employee_id, OLD.hire_date, LOCALTIMESTAMP,
                  OLD.job_id, OLD.department_id);
RETURN NEW;
END
$$;


ALTER FUNCTION hr.trigger_fct_update_job_history() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: countries; Type: TABLE; Schema: hr; Owner: postgres
--

CREATE TABLE hr.countries (
    country_id character(2) NOT NULL,
    country_name character varying(40),
    region_id bigint
);


ALTER TABLE hr.countries OWNER TO postgres;

--
-- Name: TABLE countries; Type: COMMENT; Schema: hr; Owner: postgres
--

COMMENT ON TABLE hr.countries IS 'country table. Contains 25 rows. References with locations table.';


--
-- Name: COLUMN countries.country_id; Type: COMMENT; Schema: hr; Owner: postgres
--

COMMENT ON COLUMN hr.countries.country_id IS 'Primary key of countries table.';


--
-- Name: COLUMN countries.country_name; Type: COMMENT; Schema: hr; Owner: postgres
--

COMMENT ON COLUMN hr.countries.country_name IS 'Country name';


--
-- Name: COLUMN countries.region_id; Type: COMMENT; Schema: hr; Owner: postgres
--

COMMENT ON COLUMN hr.countries.region_id IS 'Region ID for the country. Foreign key to region_id column in the departments table.';


--
-- Name: departments; Type: TABLE; Schema: hr; Owner: postgres
--

CREATE TABLE hr.departments (
    department_id smallint NOT NULL,
    department_name character varying(30) NOT NULL,
    manager_id integer,
    location_id smallint
);


ALTER TABLE hr.departments OWNER TO postgres;

--
-- Name: TABLE departments; Type: COMMENT; Schema: hr; Owner: postgres
--

COMMENT ON TABLE hr.departments IS 'Departments table that shows details of departments where employees
work. Contains 27 rows; references with locations, employees, and job_history tables.';


--
-- Name: COLUMN departments.department_id; Type: COMMENT; Schema: hr; Owner: postgres
--

COMMENT ON COLUMN hr.departments.department_id IS 'Primary key column of departments table.';


--
-- Name: COLUMN departments.department_name; Type: COMMENT; Schema: hr; Owner: postgres
--

COMMENT ON COLUMN hr.departments.department_name IS 'A not null column that shows name of a department. Administration,
Marketing, Purchasing, Human Resources, Shipping, IT, Executive, Public
Relations, Sales, Finance, and Accounting. ';


--
-- Name: COLUMN departments.manager_id; Type: COMMENT; Schema: hr; Owner: postgres
--

COMMENT ON COLUMN hr.departments.manager_id IS 'Manager_id of a department. Foreign key to employee_id column of employees table. The manager_id column of the employee table references this column.';


--
-- Name: COLUMN departments.location_id; Type: COMMENT; Schema: hr; Owner: postgres
--

COMMENT ON COLUMN hr.departments.location_id IS 'Location id where a department is located. Foreign key to location_id column of locations table.';


--
-- Name: employees; Type: TABLE; Schema: hr; Owner: postgres
--

CREATE TABLE hr.employees (
    employee_id integer NOT NULL,
    first_name character varying(20),
    last_name character varying(25) NOT NULL,
    email character varying(25) NOT NULL,
    phone_number character varying(20),
    hire_date timestamp without time zone NOT NULL,
    job_id character varying(10) NOT NULL,
    salary double precision,
    commission_pct real,
    manager_id integer,
    department_id smallint,
    CONSTRAINT emp_salary_min CHECK ((salary > (0)::double precision))
);


ALTER TABLE hr.employees OWNER TO postgres;

--
-- Name: TABLE employees; Type: COMMENT; Schema: hr; Owner: postgres
--

COMMENT ON TABLE hr.employees IS 'employees table. Contains 107 rows. References with departments,
jobs, job_history tables. Contains a self reference.';


--
-- Name: COLUMN employees.employee_id; Type: COMMENT; Schema: hr; Owner: postgres
--

COMMENT ON COLUMN hr.employees.employee_id IS 'Primary key of employees table.';


--
-- Name: COLUMN employees.first_name; Type: COMMENT; Schema: hr; Owner: postgres
--

COMMENT ON COLUMN hr.employees.first_name IS 'First name of the employee. A not null column.';


--
-- Name: COLUMN employees.last_name; Type: COMMENT; Schema: hr; Owner: postgres
--

COMMENT ON COLUMN hr.employees.last_name IS 'Last name of the employee. A not null column.';


--
-- Name: COLUMN employees.email; Type: COMMENT; Schema: hr; Owner: postgres
--

COMMENT ON COLUMN hr.employees.email IS 'Email id of the employee';


--
-- Name: COLUMN employees.phone_number; Type: COMMENT; Schema: hr; Owner: postgres
--

COMMENT ON COLUMN hr.employees.phone_number IS 'Phone number of the employee; includes country code and area code';


--
-- Name: COLUMN employees.hire_date; Type: COMMENT; Schema: hr; Owner: postgres
--

COMMENT ON COLUMN hr.employees.hire_date IS 'Date when the employee started on this job. A not null column.';


--
-- Name: COLUMN employees.job_id; Type: COMMENT; Schema: hr; Owner: postgres
--

COMMENT ON COLUMN hr.employees.job_id IS 'Current job of the employee; foreign key to job_id column of the
jobs table. A not null column.';


--
-- Name: COLUMN employees.salary; Type: COMMENT; Schema: hr; Owner: postgres
--

COMMENT ON COLUMN hr.employees.salary IS 'Monthly salary of the employee. Must be greater
than zero (enforced by constraint emp_salary_min)';


--
-- Name: COLUMN employees.commission_pct; Type: COMMENT; Schema: hr; Owner: postgres
--

COMMENT ON COLUMN hr.employees.commission_pct IS 'Commission percentage of the employee; Only employees in sales
department elgible for commission percentage';


--
-- Name: COLUMN employees.manager_id; Type: COMMENT; Schema: hr; Owner: postgres
--

COMMENT ON COLUMN hr.employees.manager_id IS 'Manager id of the employee; has same domain as manager_id in
departments table. Foreign key to employee_id column of employees table.
(useful for reflexive joins and CONNECT BY query)';


--
-- Name: COLUMN employees.department_id; Type: COMMENT; Schema: hr; Owner: postgres
--

COMMENT ON COLUMN hr.employees.department_id IS 'Department id where employee works; foreign key to department_id
column of the departments table';


--
-- Name: jobs; Type: TABLE; Schema: hr; Owner: postgres
--

CREATE TABLE hr.jobs (
    job_id character varying(10) NOT NULL,
    job_title character varying(35) NOT NULL,
    min_salary integer,
    max_salary integer
);


ALTER TABLE hr.jobs OWNER TO postgres;

--
-- Name: TABLE jobs; Type: COMMENT; Schema: hr; Owner: postgres
--

COMMENT ON TABLE hr.jobs IS 'jobs table with job titles and salary ranges. Contains 19 rows.
References with employees and job_history table.';


--
-- Name: COLUMN jobs.job_id; Type: COMMENT; Schema: hr; Owner: postgres
--

COMMENT ON COLUMN hr.jobs.job_id IS 'Primary key of jobs table.';


--
-- Name: COLUMN jobs.job_title; Type: COMMENT; Schema: hr; Owner: postgres
--

COMMENT ON COLUMN hr.jobs.job_title IS 'A not null column that shows job title, e.g. AD_VP, FI_ACCOUNTANT';


--
-- Name: COLUMN jobs.min_salary; Type: COMMENT; Schema: hr; Owner: postgres
--

COMMENT ON COLUMN hr.jobs.min_salary IS 'Minimum salary for a job title.';


--
-- Name: COLUMN jobs.max_salary; Type: COMMENT; Schema: hr; Owner: postgres
--

COMMENT ON COLUMN hr.jobs.max_salary IS 'Maximum salary for a job title';


--
-- Name: locations; Type: TABLE; Schema: hr; Owner: postgres
--

CREATE TABLE hr.locations (
    location_id smallint NOT NULL,
    street_address character varying(40),
    postal_code character varying(12),
    city character varying(30) NOT NULL,
    state_province character varying(25),
    country_id character(2)
);


ALTER TABLE hr.locations OWNER TO postgres;

--
-- Name: TABLE locations; Type: COMMENT; Schema: hr; Owner: postgres
--

COMMENT ON TABLE hr.locations IS 'Locations table that contains specific address of a specific office,
warehouse, and/or production site of a company. Does not store addresses /
locations of customers. Contains 23 rows; references with the
departments and countries tables. ';


--
-- Name: COLUMN locations.location_id; Type: COMMENT; Schema: hr; Owner: postgres
--

COMMENT ON COLUMN hr.locations.location_id IS 'Primary key of locations table';


--
-- Name: COLUMN locations.street_address; Type: COMMENT; Schema: hr; Owner: postgres
--

COMMENT ON COLUMN hr.locations.street_address IS 'Street address of an office, warehouse, or production site of a company.
Contains building number and street name';


--
-- Name: COLUMN locations.postal_code; Type: COMMENT; Schema: hr; Owner: postgres
--

COMMENT ON COLUMN hr.locations.postal_code IS 'Postal code of the location of an office, warehouse, or production site
of a company. ';


--
-- Name: COLUMN locations.city; Type: COMMENT; Schema: hr; Owner: postgres
--

COMMENT ON COLUMN hr.locations.city IS 'A not null column that shows city where an office, warehouse, or
production site of a company is located. ';


--
-- Name: COLUMN locations.state_province; Type: COMMENT; Schema: hr; Owner: postgres
--

COMMENT ON COLUMN hr.locations.state_province IS 'State or Province where an office, warehouse, or production site of a
company is located.';


--
-- Name: COLUMN locations.country_id; Type: COMMENT; Schema: hr; Owner: postgres
--

COMMENT ON COLUMN hr.locations.country_id IS 'Country where an office, warehouse, or production site of a company is
located. Foreign key to country_id column of the countries table.';


--
-- Name: regions; Type: TABLE; Schema: hr; Owner: postgres
--

CREATE TABLE hr.regions (
    region_id bigint NOT NULL,
    region_name character varying(25)
);


ALTER TABLE hr.regions OWNER TO postgres;

--
-- Name: TABLE regions; Type: COMMENT; Schema: hr; Owner: postgres
--

COMMENT ON TABLE hr.regions IS 'Regions table that contains region numbers and names. Contains 4 rows; references with the Countries table.';


--
-- Name: COLUMN regions.region_id; Type: COMMENT; Schema: hr; Owner: postgres
--

COMMENT ON COLUMN hr.regions.region_id IS 'Primary key of regions table.';


--
-- Name: COLUMN regions.region_name; Type: COMMENT; Schema: hr; Owner: postgres
--

COMMENT ON COLUMN hr.regions.region_name IS 'Names of regions. Locations are in the countries of these regions.';


--
-- Name: emp_details_view; Type: VIEW; Schema: hr; Owner: postgres
--

CREATE VIEW hr.emp_details_view AS
 SELECT e.employee_id,
    e.job_id,
    e.manager_id,
    e.department_id,
    d.location_id,
    l.country_id,
    e.first_name,
    e.last_name,
    e.salary,
    e.commission_pct,
    d.department_name,
    j.job_title,
    l.city,
    l.state_province,
    c.country_name,
    r.region_name
   FROM (((((hr.employees e
     JOIN hr.departments d ON ((e.department_id = d.department_id)))
     JOIN hr.jobs j ON (((j.job_id)::text = (e.job_id)::text)))
     JOIN hr.locations l ON ((d.location_id = l.location_id)))
     JOIN hr.countries c ON ((l.country_id = c.country_id)))
     JOIN hr.regions r ON ((c.region_id = r.region_id)));


ALTER TABLE hr.emp_details_view OWNER TO postgres;

--
-- Name: job_history; Type: TABLE; Schema: hr; Owner: postgres
--

CREATE TABLE hr.job_history (
    employee_id integer NOT NULL,
    start_date timestamp without time zone NOT NULL,
    end_date timestamp without time zone NOT NULL,
    job_id character varying(10) NOT NULL,
    department_id smallint,
    CONSTRAINT jhist_date_interval CHECK ((end_date > start_date))
);


ALTER TABLE hr.job_history OWNER TO postgres;

--
-- Name: TABLE job_history; Type: COMMENT; Schema: hr; Owner: postgres
--

COMMENT ON TABLE hr.job_history IS 'Table that stores job history of the employees. If an employee
changes departments within the job or changes jobs within the department,
new rows get inserted into this table with old job information of the
employee. Contains a complex primary key: employee_id+start_date.
Contains 25 rows. References with jobs, employees, and departments tables.';


--
-- Name: COLUMN job_history.employee_id; Type: COMMENT; Schema: hr; Owner: postgres
--

COMMENT ON COLUMN hr.job_history.employee_id IS 'A not null column in the complex primary key employee_id+start_date.
Foreign key to employee_id column of the employee table';


--
-- Name: COLUMN job_history.start_date; Type: COMMENT; Schema: hr; Owner: postgres
--

COMMENT ON COLUMN hr.job_history.start_date IS 'A not null column in the complex primary key employee_id+start_date.
Must be less than the end_date of the job_history table. (enforced by
constraint jhist_date_interval)';


--
-- Name: COLUMN job_history.end_date; Type: COMMENT; Schema: hr; Owner: postgres
--

COMMENT ON COLUMN hr.job_history.end_date IS 'Last day of the employee in this job role. A not null column. Must be
greater than the start_date of the job_history table.
(enforced by constraint jhist_date_interval)';


--
-- Name: COLUMN job_history.job_id; Type: COMMENT; Schema: hr; Owner: postgres
--

COMMENT ON COLUMN hr.job_history.job_id IS 'Job role in which the employee worked in the past; foreign key to
job_id column in the jobs table. A not null column.';


--
-- Name: COLUMN job_history.department_id; Type: COMMENT; Schema: hr; Owner: postgres
--

COMMENT ON COLUMN hr.job_history.department_id IS 'Department id in which the employee worked in the past; foreign key to deparment_id column in the departments table';


--
-- Data for Name: countries; Type: TABLE DATA; Schema: hr; Owner: postgres
--

COPY hr.countries (country_id, country_name, region_id) FROM stdin;
AR	Argentina	2
AU	Australia	3
BE	Belgium	1
BR	Brazil	2
CA	Canada	2
CH	Switzerland	1
CN	China	3
DE	Germany	1
DK	Denmark	1
EG	Egypt	4
FR	France	1
IL	Israel	4
IN	India	3
IT	Italy	1
JP	Japan	3
KW	Kuwait	4
ML	Malaysia	3
MX	Mexico	2
NG	Nigeria	4
NL	Netherlands	1
SG	Singapore	3
UK	United Kingdom	1
US	United States of America	2
ZM	Zambia	4
ZW	Zimbabwe	4
\.


--
-- Data for Name: departments; Type: TABLE DATA; Schema: hr; Owner: postgres
--

COPY hr.departments (department_id, department_name, manager_id, location_id) FROM stdin;
10	Administration	200	1700
20	Marketing	201	1800
30	Purchasing	114	1700
40	Human Resources	203	2400
50	Shipping	121	1500
60	IT	103	1400
70	Public Relations	204	2700
80	Sales	145	2500
90	Executive	100	1700
100	Finance	108	1700
110	Accounting	205	1700
120	Treasury	\N	1700
130	Corporate Tax	\N	1700
140	Control And Credit	\N	1700
150	Shareholder Services	\N	1700
160	Benefits	\N	1700
170	Manufacturing	\N	1700
180	Construction	\N	1700
190	Contracting	\N	1700
200	Operations	\N	1700
210	IT Support	\N	1700
220	NOC	\N	1700
230	IT Helpdesk	\N	1700
240	Government Sales	\N	1700
250	Retail Sales	\N	1700
260	Recruiting	\N	1700
270	Payroll	\N	1700
\.


--
-- Data for Name: employees; Type: TABLE DATA; Schema: hr; Owner: postgres
--

COPY hr.employees (employee_id, first_name, last_name, email, phone_number, hire_date, job_id, salary, commission_pct, manager_id, department_id) FROM stdin;
101	Neena	Kochhar	NKOCHHAR	515.123.4568	2005-09-21 00:00:00	AD_VP	17000	\N	100	90
102	Lex	De Haan	LDEHAAN	515.123.4569	2001-01-13 00:00:00	AD_VP	17000	\N	100	90
103	Alexander	Hunold	AHUNOLD	590.423.4567	2006-01-03 00:00:00	IT_PROG	9000	\N	102	60
104	Bruce	Ernst	BERNST	590.423.4568	2007-05-21 00:00:00	IT_PROG	6000	\N	103	60
105	David	Austin	DAUSTIN	590.423.4569	2005-06-25 00:00:00	IT_PROG	4800	\N	103	60
106	Valli	Pataballa	VPATABAL	590.423.4560	2006-02-05 00:00:00	IT_PROG	4800	\N	103	60
107	Diana	Lorentz	DLORENTZ	590.423.5567	2007-02-07 00:00:00	IT_PROG	4200	\N	103	60
108	Nancy	Greenberg	NGREENBE	515.124.4569	2002-08-17 00:00:00	FI_MGR	12008	\N	101	100
109	Daniel	Faviet	DFAVIET	515.124.4169	2002-08-16 00:00:00	FI_ACCOUNT	9000	\N	108	100
110	John	Chen	JCHEN	515.124.4269	2005-09-28 00:00:00	FI_ACCOUNT	8200	\N	108	100
111	Ismael	Sciarra	ISCIARRA	515.124.4369	2005-09-30 00:00:00	FI_ACCOUNT	7700	\N	108	100
112	Jose Manuel	Urman	JMURMAN	515.124.4469	2006-03-07 00:00:00	FI_ACCOUNT	7800	\N	108	100
113	Luis	Popp	LPOPP	515.124.4567	2007-12-07 00:00:00	FI_ACCOUNT	6900	\N	108	100
114	Den	Raphaely	DRAPHEAL	515.127.4561	2002-12-07 00:00:00	PU_MAN	11000	\N	100	30
115	Alexander	Khoo	AKHOO	515.127.4562	2003-05-18 00:00:00	PU_CLERK	3100	\N	114	30
116	Shelli	Baida	SBAIDA	515.127.4563	2005-12-24 00:00:00	PU_CLERK	2900	\N	114	30
117	Sigal	Tobias	STOBIAS	515.127.4564	2005-07-24 00:00:00	PU_CLERK	2800	\N	114	30
118	Guy	Himuro	GHIMURO	515.127.4565	2006-11-15 00:00:00	PU_CLERK	2600	\N	114	30
119	Karen	Colmenares	KCOLMENA	515.127.4566	2007-08-10 00:00:00	PU_CLERK	2500	\N	114	30
120	Matthew	Weiss	MWEISS	650.123.1234	2004-07-18 00:00:00	ST_MAN	8000	\N	100	50
121	Adam	Fripp	AFRIPP	650.123.2234	2005-04-10 00:00:00	ST_MAN	8200	\N	100	50
122	Payam	Kaufling	PKAUFLIN	650.123.3234	2003-05-01 00:00:00	ST_MAN	7900	\N	100	50
123	Shanta	Vollman	SVOLLMAN	650.123.4234	2005-10-10 00:00:00	ST_MAN	6500	\N	100	50
124	Kevin	Mourgos	KMOURGOS	650.123.5234	2007-11-16 00:00:00	ST_MAN	5800	\N	100	50
125	Julia	Nayer	JNAYER	650.124.1214	2005-07-16 00:00:00	ST_CLERK	3200	\N	120	50
126	Irene	Mikkilineni	IMIKKILI	650.124.1224	2006-09-28 00:00:00	ST_CLERK	2700	\N	120	50
127	James	Landry	JLANDRY	650.124.1334	2007-01-14 00:00:00	ST_CLERK	2400	\N	120	50
128	Steven	Markle	SMARKLE	650.124.1434	2008-03-08 00:00:00	ST_CLERK	2200	\N	120	50
129	Laura	Bissot	LBISSOT	650.124.5234	2005-08-20 00:00:00	ST_CLERK	3300	\N	121	50
130	Mozhe	Atkinson	MATKINSO	650.124.6234	2005-10-30 00:00:00	ST_CLERK	2800	\N	121	50
131	James	Marlow	JAMRLOW	650.124.7234	2005-02-16 00:00:00	ST_CLERK	2500	\N	121	50
132	TJ	Olson	TJOLSON	650.124.8234	2007-04-10 00:00:00	ST_CLERK	2100	\N	121	50
133	Jason	Mallin	JMALLIN	650.127.1934	2004-06-14 00:00:00	ST_CLERK	3300	\N	122	50
134	Michael	Rogers	MROGERS	650.127.1834	2006-08-26 00:00:00	ST_CLERK	2900	\N	122	50
135	Ki	Gee	KGEE	650.127.1734	2007-12-12 00:00:00	ST_CLERK	2400	\N	122	50
136	Hazel	Philtanker	HPHILTAN	650.127.1634	2008-02-06 00:00:00	ST_CLERK	2200	\N	122	50
137	Renske	Ladwig	RLADWIG	650.121.1234	2003-07-14 00:00:00	ST_CLERK	3600	\N	123	50
138	Stephen	Stiles	SSTILES	650.121.2034	2005-10-26 00:00:00	ST_CLERK	3200	\N	123	50
139	John	Seo	JSEO	650.121.2019	2006-02-12 00:00:00	ST_CLERK	2700	\N	123	50
140	Joshua	Patel	JPATEL	650.121.1834	2006-04-06 00:00:00	ST_CLERK	2500	\N	123	50
141	Trenna	Rajs	TRAJS	650.121.8009	2003-10-17 00:00:00	ST_CLERK	3500	\N	124	50
142	Curtis	Davies	CDAVIES	650.121.2994	2005-01-29 00:00:00	ST_CLERK	3100	\N	124	50
143	Randall	Matos	RMATOS	650.121.2874	2006-03-15 00:00:00	ST_CLERK	2600	\N	124	50
144	Peter	Vargas	PVARGAS	650.121.2004	2006-07-09 00:00:00	ST_CLERK	2500	\N	124	50
145	John	Russell	JRUSSEL	011.44.1344.429268	2004-10-01 00:00:00	SA_MAN	14000	0.4	100	80
146	Karen	Partners	KPARTNER	011.44.1344.467268	2005-01-05 00:00:00	SA_MAN	13500	0.3	100	80
147	Alberto	Errazuriz	AERRAZUR	011.44.1344.429278	2005-03-10 00:00:00	SA_MAN	12000	0.3	100	80
148	Gerald	Cambrault	GCAMBRAU	011.44.1344.619268	2007-10-15 00:00:00	SA_MAN	11000	0.3	100	80
149	Eleni	Zlotkey	EZLOTKEY	011.44.1344.429018	2008-01-29 00:00:00	SA_MAN	10500	0.2	100	80
150	Peter	Tucker	PTUCKER	011.44.1344.129268	2005-01-30 00:00:00	SA_REP	10000	0.3	145	80
151	David	Bernstein	DBERNSTE	011.44.1344.345268	2005-03-24 00:00:00	SA_REP	9500	0.25	145	80
152	Peter	Hall	PHALL	011.44.1344.478968	2005-08-20 00:00:00	SA_REP	9000	0.25	145	80
153	Christopher	Olsen	COLSEN	011.44.1344.498718	2006-03-30 00:00:00	SA_REP	8000	0.2	145	80
154	Nanette	Cambrault	NCAMBRAU	011.44.1344.987668	2006-12-09 00:00:00	SA_REP	7500	0.2	145	80
155	Oliver	Tuvault	OTUVAULT	011.44.1344.486508	2007-11-23 00:00:00	SA_REP	7000	0.15	145	80
156	Janette	King	JKING	011.44.1345.429268	2004-01-30 00:00:00	SA_REP	10000	0.35	146	80
157	Patrick	Sully	PSULLY	011.44.1345.929268	2004-03-04 00:00:00	SA_REP	9500	0.35	146	80
158	Allan	McEwen	AMCEWEN	011.44.1345.829268	2004-08-01 00:00:00	SA_REP	9000	0.35	146	80
159	Lindsey	Smith	LSMITH	011.44.1345.729268	2005-03-10 00:00:00	SA_REP	8000	0.3	146	80
160	Louise	Doran	LDORAN	011.44.1345.629268	2005-12-15 00:00:00	SA_REP	7500	0.3	146	80
161	Sarath	Sewall	SSEWALL	011.44.1345.529268	2006-11-03 00:00:00	SA_REP	7000	0.25	146	80
162	Clara	Vishney	CVISHNEY	011.44.1346.129268	2005-11-11 00:00:00	SA_REP	10500	0.25	147	80
163	Danielle	Greene	DGREENE	011.44.1346.229268	2007-03-19 00:00:00	SA_REP	9500	0.15	147	80
164	Mattea	Marvins	MMARVINS	011.44.1346.329268	2008-01-24 00:00:00	SA_REP	7200	0.1	147	80
165	David	Lee	DLEE	011.44.1346.529268	2008-02-23 00:00:00	SA_REP	6800	0.1	147	80
166	Sundar	Ande	SANDE	011.44.1346.629268	2008-03-24 00:00:00	SA_REP	6400	0.1	147	80
167	Amit	Banda	ABANDA	011.44.1346.729268	2008-04-21 00:00:00	SA_REP	6200	0.1	147	80
168	Lisa	Ozer	LOZER	011.44.1343.929268	2005-03-11 00:00:00	SA_REP	11500	0.25	148	80
169	Harrison	Bloom	HBLOOM	011.44.1343.829268	2006-03-23 00:00:00	SA_REP	10000	0.2	148	80
170	Tayler	Fox	TFOX	011.44.1343.729268	2006-01-24 00:00:00	SA_REP	9600	0.2	148	80
171	William	Smith	WSMITH	011.44.1343.629268	2007-02-23 00:00:00	SA_REP	7400	0.15	148	80
172	Elizabeth	Bates	EBATES	011.44.1343.529268	2007-03-24 00:00:00	SA_REP	7300	0.15	148	80
173	Sundita	Kumar	SKUMAR	011.44.1343.329268	2008-04-21 00:00:00	SA_REP	6100	0.1	148	80
174	Ellen	Abel	EABEL	011.44.1644.429267	2004-05-11 00:00:00	SA_REP	11000	0.3	149	80
175	Alyssa	Hutton	AHUTTON	011.44.1644.429266	2005-03-19 00:00:00	SA_REP	8800	0.25	149	80
176	Jonathon	Taylor	JTAYLOR	011.44.1644.429265	2006-03-24 00:00:00	SA_REP	8600	0.2	149	80
177	Jack	Livingston	JLIVINGS	011.44.1644.429264	2006-04-23 00:00:00	SA_REP	8400	0.2	149	80
178	Kimberely	Grant	KGRANT	011.44.1644.429263	2007-05-24 00:00:00	SA_REP	7000	0.15	149	\N
179	Charles	Johnson	CJOHNSON	011.44.1644.429262	2008-01-04 00:00:00	SA_REP	6200	0.1	149	80
180	Winston	Taylor	WTAYLOR	650.507.9876	2006-01-24 00:00:00	SH_CLERK	3200	\N	120	50
181	Jean	Fleaur	JFLEAUR	650.507.9877	2006-02-23 00:00:00	SH_CLERK	3100	\N	120	50
182	Martha	Sullivan	MSULLIVA	650.507.9878	2007-06-21 00:00:00	SH_CLERK	2500	\N	120	50
183	Girard	Geoni	GGEONI	650.507.9879	2008-02-03 00:00:00	SH_CLERK	2800	\N	120	50
184	Nandita	Sarchand	NSARCHAN	650.509.1876	2004-01-27 00:00:00	SH_CLERK	4200	\N	121	50
185	Alexis	Bull	ABULL	650.509.2876	2005-02-20 00:00:00	SH_CLERK	4100	\N	121	50
186	Julia	Dellinger	JDELLING	650.509.3876	2006-06-24 00:00:00	SH_CLERK	3400	\N	121	50
187	Anthony	Cabrio	ACABRIO	650.509.4876	2007-02-07 00:00:00	SH_CLERK	3000	\N	121	50
188	Kelly	Chung	KCHUNG	650.505.1876	2005-06-14 00:00:00	SH_CLERK	3800	\N	122	50
189	Jennifer	Dilly	JDILLY	650.505.2876	2005-08-13 00:00:00	SH_CLERK	3600	\N	122	50
190	Timothy	Gates	TGATES	650.505.3876	2006-07-11 00:00:00	SH_CLERK	2900	\N	122	50
191	Randall	Perkins	RPERKINS	650.505.4876	2007-12-19 00:00:00	SH_CLERK	2500	\N	122	50
192	Sarah	Bell	SBELL	650.501.1876	2004-02-04 00:00:00	SH_CLERK	4000	\N	123	50
193	Britney	Everett	BEVERETT	650.501.2876	2005-03-03 00:00:00	SH_CLERK	3900	\N	123	50
194	Samuel	McCain	SMCCAIN	650.501.3876	2006-07-01 00:00:00	SH_CLERK	3200	\N	123	50
195	Vance	Jones	VJONES	650.501.4876	2007-03-17 00:00:00	SH_CLERK	2800	\N	123	50
196	Alana	Walsh	AWALSH	650.507.9811	2006-04-24 00:00:00	SH_CLERK	3100	\N	124	50
197	Kevin	Feeney	KFEENEY	650.507.9822	2006-05-23 00:00:00	SH_CLERK	3000	\N	124	50
198	Donald	OConnell	DOCONNEL	650.507.9833	2007-06-21 00:00:00	SH_CLERK	2600	\N	124	50
199	Douglas	Grant	DGRANT	650.507.9844	2008-01-13 00:00:00	SH_CLERK	2600	\N	124	50
200	Jennifer	Whalen	JWHALEN	515.123.4444	2003-09-17 00:00:00	AD_ASST	4400	\N	101	10
201	Michael	Hartstein	MHARTSTE	515.123.5555	2004-02-17 00:00:00	MK_MAN	13000	\N	100	20
202	Pat	Fay	PFAY	603.123.6666	2005-08-17 00:00:00	MK_REP	6000	\N	201	20
203	Susan	Mavris	SMAVRIS	515.123.7777	2002-06-07 00:00:00	HR_REP	6500	\N	101	40
204	Hermann	Baer	HBAER	515.123.8888	2002-06-07 00:00:00	PR_REP	10000	\N	101	70
205	Shelley	Higgins	SHIGGINS	515.123.8080	2002-06-07 00:00:00	AC_MGR	12008	\N	101	110
206	William	Gietz	WGIETZ	515.123.8181	2002-06-07 00:00:00	AC_ACCOUNT	8300	\N	205	110
100	Steven	King	SKING	515.123.4567	2003-06-17 00:00:00	AD_VP	24000	\N	\N	90
\.


--
-- Data for Name: job_history; Type: TABLE DATA; Schema: hr; Owner: postgres
--

COPY hr.job_history (employee_id, start_date, end_date, job_id, department_id) FROM stdin;
102	2001-01-13 00:00:00	2006-07-24 00:00:00	IT_PROG	60
101	1997-09-21 00:00:00	2001-10-27 00:00:00	AC_ACCOUNT	110
101	2001-10-28 00:00:00	2005-03-15 00:00:00	AC_MGR	110
201	2004-02-17 00:00:00	2007-12-19 00:00:00	MK_REP	20
114	2006-03-24 00:00:00	2007-12-31 00:00:00	ST_CLERK	50
122	2007-01-01 00:00:00	2007-12-31 00:00:00	ST_CLERK	50
200	1995-09-17 00:00:00	2001-06-17 00:00:00	AD_ASST	90
176	2006-03-24 00:00:00	2006-12-31 00:00:00	SA_REP	80
176	2007-01-01 00:00:00	2007-12-31 00:00:00	SA_MAN	80
200	2002-07-01 00:00:00	2006-12-31 00:00:00	AC_ACCOUNT	90
100	2003-06-17 00:00:00	2022-11-21 16:44:32.273603	AD_PRES	90
\.


--
-- Data for Name: jobs; Type: TABLE DATA; Schema: hr; Owner: postgres
--

COPY hr.jobs (job_id, job_title, min_salary, max_salary) FROM stdin;
AD_PRES	President	20080	40000
AD_VP	Administration Vice President	15000	30000
AD_ASST	Administration Assistant	3000	6000
FI_MGR	Finance Manager	8200	16000
FI_ACCOUNT	Accountant	4200	9000
AC_MGR	Accounting Manager	8200	16000
AC_ACCOUNT	Public Accountant	4200	9000
SA_MAN	Sales Manager	10000	20080
SA_REP	Sales Representative	6000	12008
PU_MAN	Purchasing Manager	8000	15000
PU_CLERK	Purchasing Clerk	2500	5500
ST_MAN	Stock Manager	5500	8500
ST_CLERK	Stock Clerk	2008	5000
SH_CLERK	Shipping Clerk	2500	5500
IT_PROG	Programmer	4000	10000
MK_MAN	Marketing Manager	9000	15000
MK_REP	Marketing Representative	4000	9000
HR_REP	Human Resources Representative	4000	9000
PR_REP	Public Relations Representative	4500	10500
\.


--
-- Data for Name: locations; Type: TABLE DATA; Schema: hr; Owner: postgres
--

COPY hr.locations (location_id, street_address, postal_code, city, state_province, country_id) FROM stdin;
1000	1297 Via Cola di Rie	00989	Roma	\N	IT
1100	93091 Calle della Testa	10934	Venice	\N	IT
1200	2017 Shinjuku-ku	1689	Tokyo	Tokyo Prefecture	JP
1300	9450 Kamiya-cho	6823	Hiroshima	\N	JP
1400	2014 Jabberwocky Rd	26192	Southlake	Texas	US
1500	2011 Interiors Blvd	99236	South San Francisco	California	US
1600	2007 Zagora St	50090	South Brunswick	New Jersey	US
1700	2004 Charade Rd	98199	Seattle	Washington	US
1800	147 Spadina Ave	M5V 2L7	Toronto	Ontario	CA
1900	6092 Boxwood St	YSW 9T2	Whitehorse	Yukon	CA
2000	40-5-12 Laogianggen	190518	Beijing	\N	CN
2100	1298 Vileparle (E)	490231	Bombay	Maharashtra	IN
2200	12-98 Victoria Street	2901	Sydney	New South Wales	AU
2300	198 Clementi North	540198	Singapore	\N	SG
2400	8204 Arthur St	\N	London	\N	UK
2500	Magdalen Centre, The Oxford Science Park	OX9 9ZB	Oxford	Oxford	UK
2600	9702 Chester Road	09629850293	Stretford	Manchester	UK
2700	Schwanthalerstr. 7031	80925	Munich	Bavaria	DE
2800	Rua Frei Caneca 1360 	01307-002	Sao Paulo	Sao Paulo	BR
2900	20 Rue des Corps-Saints	1730	Geneva	Geneve	CH
3000	Murtenstrasse 921	3095	Bern	BE	CH
3100	Pieter Breughelstraat 837	3029SK	Utrecht	Utrecht	NL
3200	Mariano Escobedo 9991	11932	Mexico City	Distrito Federal,	MX
\.


--
-- Data for Name: regions; Type: TABLE DATA; Schema: hr; Owner: postgres
--

COPY hr.regions (region_id, region_name) FROM stdin;
1	Europe
2	Americas
3	Asia
4	Middle East and Africa
\.


--
-- Name: countries countries_pkey; Type: CONSTRAINT; Schema: hr; Owner: postgres
--

ALTER TABLE ONLY hr.countries
    ADD CONSTRAINT countries_pkey PRIMARY KEY (country_id);


--
-- Name: departments departments_pkey; Type: CONSTRAINT; Schema: hr; Owner: postgres
--

ALTER TABLE ONLY hr.departments
    ADD CONSTRAINT departments_pkey PRIMARY KEY (department_id);


--
-- Name: employees employees_email_key; Type: CONSTRAINT; Schema: hr; Owner: postgres
--

ALTER TABLE ONLY hr.employees
    ADD CONSTRAINT employees_email_key UNIQUE (email);


--
-- Name: employees employees_pkey; Type: CONSTRAINT; Schema: hr; Owner: postgres
--

ALTER TABLE ONLY hr.employees
    ADD CONSTRAINT employees_pkey PRIMARY KEY (employee_id);


--
-- Name: job_history job_history_pkey; Type: CONSTRAINT; Schema: hr; Owner: postgres
--

ALTER TABLE ONLY hr.job_history
    ADD CONSTRAINT job_history_pkey PRIMARY KEY (employee_id, start_date);


--
-- Name: jobs jobs_pkey; Type: CONSTRAINT; Schema: hr; Owner: postgres
--

ALTER TABLE ONLY hr.jobs
    ADD CONSTRAINT jobs_pkey PRIMARY KEY (job_id);


--
-- Name: locations locations_pkey; Type: CONSTRAINT; Schema: hr; Owner: postgres
--

ALTER TABLE ONLY hr.locations
    ADD CONSTRAINT locations_pkey PRIMARY KEY (location_id);


--
-- Name: regions regions_pkey; Type: CONSTRAINT; Schema: hr; Owner: postgres
--

ALTER TABLE ONLY hr.regions
    ADD CONSTRAINT regions_pkey PRIMARY KEY (region_id);


--
-- Name: dept_location_ix; Type: INDEX; Schema: hr; Owner: postgres
--

CREATE INDEX dept_location_ix ON hr.departments USING btree (location_id);


--
-- Name: emp_department_ix; Type: INDEX; Schema: hr; Owner: postgres
--

CREATE INDEX emp_department_ix ON hr.employees USING btree (department_id);


--
-- Name: emp_job_ix; Type: INDEX; Schema: hr; Owner: postgres
--

CREATE INDEX emp_job_ix ON hr.employees USING btree (job_id);


--
-- Name: emp_manager_ix; Type: INDEX; Schema: hr; Owner: postgres
--

CREATE INDEX emp_manager_ix ON hr.employees USING btree (manager_id);


--
-- Name: emp_name_ix; Type: INDEX; Schema: hr; Owner: postgres
--

CREATE INDEX emp_name_ix ON hr.employees USING btree (last_name, first_name);


--
-- Name: jhist_department_ix; Type: INDEX; Schema: hr; Owner: postgres
--

CREATE INDEX jhist_department_ix ON hr.job_history USING btree (department_id);


--
-- Name: jhist_employee_ix; Type: INDEX; Schema: hr; Owner: postgres
--

CREATE INDEX jhist_employee_ix ON hr.job_history USING btree (employee_id);


--
-- Name: jhist_job_ix; Type: INDEX; Schema: hr; Owner: postgres
--

CREATE INDEX jhist_job_ix ON hr.job_history USING btree (job_id);


--
-- Name: loc_city_ix; Type: INDEX; Schema: hr; Owner: postgres
--

CREATE INDEX loc_city_ix ON hr.locations USING btree (city);


--
-- Name: loc_country_ix; Type: INDEX; Schema: hr; Owner: postgres
--

CREATE INDEX loc_country_ix ON hr.locations USING btree (country_id);


--
-- Name: loc_state_province_ix; Type: INDEX; Schema: hr; Owner: postgres
--

CREATE INDEX loc_state_province_ix ON hr.locations USING btree (state_province);


--
-- Name: employees update_job_history; Type: TRIGGER; Schema: hr; Owner: postgres
--

CREATE TRIGGER update_job_history AFTER UPDATE OF job_id, department_id ON hr.employees FOR EACH ROW EXECUTE FUNCTION hr.trigger_fct_update_job_history();


--
-- PostgreSQL database dump complete
--

