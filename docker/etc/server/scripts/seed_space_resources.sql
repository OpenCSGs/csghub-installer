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
-- Seed Data for Name: space_resources; Type: TABLE DATA; Schema: public; Owner: csghub_server
--

WITH selected_cluster AS (
    SELECT
        cluster_id
    FROM
        public.cluster_infos
    LIMIT 1)
    INSERT INTO public.space_resources (id, name, resources, cluster_id)
        VALUES
        (1, 'CPU basic · 0.5 vCPU · 1 GB', '{ "cpu": { "type": "Intel", "num": "0.5" }, "memory": "1Gi" }', ( SELECT cluster_id FROM selected_cluster)),
        (2, 'CPU basic · 2 vCPU · 4 GB', '{ "cpu": { "type": "Intel", "num": "2" }, "memory": "4Gi" }', ( SELECT cluster_id FROM selected_cluster)),
        (3, 'NVIDIA A10G · 4 vCPU · 16 GB', '{"gpu": { "type": "A10", "num": "1", "resource_name": "nvidia.com/gpu", "labels": { "aliyun.accelerator/nvidia_name": "NVIDIA-A10" } }, "cpu": { "type": "Intel", "num": "4" }, "memory": "16Gi" }', ( SELECT cluster_id FROM selected_cluster)),
        (4, 'NVIDIA A10G · 6 vCPU · 32 GB', '{"gpu": { "type": "A10", "num": "1", "resource_name": "nvidia.com/gpu", "labels": { "aliyun.accelerator/nvidia_name": "NVIDIA-A10" } }, "cpu": { "type": "Intel", "num": "6" }, "memory": "32Gi" }', ( SELECT cluster_id FROM selected_cluster)),
        (5, 'NVIDIA A10G · 2 · 12 vCPU · 48 GB', '{"gpu": { "type": "A10", "num": "2", "resource_name": "nvidia.com/gpu", "labels": { "aliyun.accelerator/nvidia_name": "NVIDIA-A10" } }, "cpu": { "type": "Intel", "num": "12" }, "memory": "48Gi" }', ( SELECT cluster_id FROM selected_cluster)),
        (6, 'NVIDIA A10G · 4 · 24 vCPU · 96 GB', '{"gpu": { "type": "A10", "num": "4", "resource_name": "nvidia.com/gpu", "labels": { "aliyun.accelerator/nvidia_name": "NVIDIA-A10" } }, "cpu": { "type": "Intel", "num": "24" }, "memory": "96Gi" }', ( SELECT cluster_id FROM selected_cluster)),
        (7, 'NVIDIA A40G · 4 vCPU · 16 GB', '{"gpu": { "type": "A40", "num": "1", "resource_name": "nvidia.com/gpu", "labels": { "nvidia.com/nvidia_name": "NVIDIA-A40" } }, "cpu": { "type": "Intel", "num": "4" }, "memory": "16Gi" }', ( SELECT cluster_id FROM selected_cluster)),
        (8, 'NVIDIA A40G · 8 vCPU · 32 GB', '{"gpu": { "type": "A40", "num": "1", "resource_name": "nvidia.com/gpu", "labels": { "nvidia.com/nvidia_name": "NVIDIA-A40" } }, "cpu": { "type": "Intel", "num": "8" }, "memory": "32Gi" }', ( SELECT cluster_id FROM selected_cluster)),
        (9, 'NVIDIA A40G · 2 · 12 vCPU · 48 GB', '{"gpu": { "type": "A40", "num": "2", "resource_name": "nvidia.com/gpu", "labels": { "nvidia.com/nvidia_name": "NVIDIA-A40" } }, "cpu": { "type": "Intel", "num": "12" }, "memory": "48Gi" }', ( SELECT cluster_id FROM selected_cluster))
ON CONFLICT (id)
    DO UPDATE SET
        name = EXCLUDED.name,
        resources = EXCLUDED.resources,
        cluster_id = EXCLUDED.cluster_id;

--
-- Name: space_resources_id_seq; Type: SEQUENCE SET; Schema: public; Owner: csghub_server
--

SELECT
    pg_catalog.setval('public.space_resources_id_seq', (
            SELECT
                MAX(id)
            FROM public.space_resources), TRUE);
