--
-- Record Timestamp
--
SELECT now() as "Execute Timestamp";

--
-- PostgreSQL database dump
--
SET exit_on_error = on;
SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Set Default Schema for All Tables
--

SELECT pg_catalog.set_config('search_path', 'public', false);

--
-- Seed Data for Name: tag_categories; Type: TABLE DATA; Schema: public; Owner: csghub_server
--

INSERT INTO public.tag_categories(name, scope, show_name, enabled)
    VALUES
    ('task', 'model', '任务','t'),
    ('license', 'model', '许可证','t'),
    ('framework', 'model', '框架','t'),
    ('task', 'dataset', '任务','t'),
    ('license', 'dataset', '许可证','t'),
    ('size', 'dataset', '大小','f'),
    ('license', 'code', '许可证','t'),
    ('language', 'model', '语言','t'),
    ('language', 'dataset', '语言','t'),
    ('language', 'code', ' ','f'),
    ('language', 'space', ' ','f'),
    ('license', 'space', ' ','f'),
    ('industry', 'model', '行业','f'),
    ('industry', 'dataset', ' ','f'),
    ('industry', 'code', ' ','f'),
    ('industry', 'space', ' ','f'),
    ('resource', 'model', ' ','f'),
    ('runtime_framework', 'model', ' ','f'),
    ('evaluation', 'dataset', ' ','f')
ON CONFLICT (name, scope)
    DO UPDATE SET
        show_name = EXCLUDED.show_name,
        enabled = EXCLUDED.enabled;
