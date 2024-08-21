--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', 'public', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Seed Data for Name: space_resources; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.space_resources (name, resources, cost_per_hour, cluster_id)
VALUES
    ('CPU basic · 1 vCPU · 1 GB', '{ "cpu": { "type": "Intel", "num": "1" }, "memory": "1Gi" }', 0, (SELECT cluster_id FROM public.cluster_infos LIMIT 1))
ON CONFLICT (name)
    DO UPDATE SET
                  resources = EXCLUDED.resources,
                  cost_per_hour = EXCLUDED.cost_per_hour,
                  cluster_id = EXCLUDED.cluster_id;
INSERT INTO public.space_resources (name, resources, cost_per_hour, cluster_id)
VALUES
    ('NVIDIA A10G · 4 vCPU · 16 GB', '{"gpu": { "type": "A10", "num": "1", "resource_name": "nvidia.com/gpu", "labels": { "aliyun.accelerator/nvidia_name": "NVIDIA-A10" } }, "cpu": { "type": "Intel", "num": "4" },  "memory": "16Gi" }', 0, (SELECT cluster_id FROM public.cluster_infos LIMIT 1))
ON CONFLICT (name)
    DO UPDATE SET
                  resources = EXCLUDED.resources,
                  cost_per_hour = EXCLUDED.cost_per_hour,
                  cluster_id = EXCLUDED.cluster_id;

--
-- Seed Data for Name: runtime_frameworks; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.runtime_frameworks(id, frame_name, frame_version, frame_image, frame_cpu_image, enabled, container_port, type) VALUES (1, 'VLLM', '2.7', 'vllm-local:2.7', 'vllm-cpu:2.3', 1, 8000, 1);
INSERT INTO public.runtime_frameworks(id, frame_name, frame_version, frame_image, frame_cpu_image, enabled, container_port, type) VALUES (2, 'LLaMA-Factory', '1.11', 'llama-factory:1.17-cuda12.1-devel-ubuntu22.04-py310-torch2.1.2', '', 1, 8000, 2);
INSERT INTO public.runtime_frameworks(id, frame_name, frame_version, frame_image, frame_cpu_image, enabled, container_port, type) VALUES (3, 'TGI', '2.1', 'tgi:2.1', '', 1, 8000, 1);
INSERT INTO public.runtime_frameworks(id, frame_name, frame_version, frame_image, frame_cpu_image, enabled, container_port, type) VALUES (4, 'FastChat', '1.2', '', '', 1, 8000, 1);
--
-- Name: runtime_frameworks_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.runtime_frameworks_id_seq', 4, true);

--
-- Define a one-time trigger function and update the root user's permissions to admin
--

CREATE OR REPLACE FUNCTION promote_root_to_admin()
    RETURNS TRIGGER AS $$
BEGIN
    IF NEW.username = 'root' THEN
        UPDATE public.users
        SET role_mask = 'admin'
        WHERE username = 'root';

        -- After update Drop all
        EXECUTE 'DROP TRIGGER IF EXISTS trigger_promote_root_to_admin ON public.users';
        EXECUTE 'DROP FUNCTION IF EXISTS promote_root_to_admin()';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE TRIGGER trigger_promote_root_to_admin
    AFTER INSERT ON public.users
    FOR EACH ROW
EXECUTE FUNCTION promote_root_to_admin();

--
-- Create a trigger function to automatically enable LLaMA-Factory model fine-tuning for the model
-- Types:
-- 	SpaceType     = 0
-- 	InferenceType = 1
-- 	FinetuneType  = 2
--
-- Hint: Only used as a test environment, please choose the enterprise version for production environment
--

CREATE OR REPLACE FUNCTION enable_model_fine_tuning()
    RETURNS trigger AS $$
BEGIN
    INSERT INTO public.repositories_runtime_frameworks (runtime_framework_id, repo_id, type)
    SELECT
        (SELECT id FROM public.runtime_frameworks WHERE frame_name = 'LLaMA-Factory'),
        NEW.repository_id,
        2
    WHERE (SELECT id FROM public.runtime_frameworks WHERE frame_name = 'LLaMA-Factory') IS NOT NULL;

    INSERT INTO public.repositories_runtime_frameworks (runtime_framework_id, repo_id, type)
    SELECT
        (SELECT id FROM public.runtime_frameworks WHERE frame_name = 'LLaMA-Factory'),
        NEW.repository_id,
        1
    WHERE (SELECT id FROM public.runtime_frameworks WHERE frame_name = 'VLLM') IS NOT NULL;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER trigger_enable_model_fine_tuning
    AFTER INSERT ON public.models
    FOR EACH ROW
EXECUTE PROCEDURE enable_model_fine_tuning();