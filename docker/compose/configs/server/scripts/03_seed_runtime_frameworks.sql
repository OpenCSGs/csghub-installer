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
-- Seed Data for Name: runtime_frameworks; Type: TABLE DATA; Schema: public; Owner: csghub_server
--

-- Fixed frame_npu_image enforce constraint NOT NULL

DO $$
BEGIN
    IF EXISTS (
        SELECT FROM information_schema.columns
        WHERE table_name = 'runtime_frameworks'
            AND column_name = 'frame_npu_image'
    )
    THEN
        ALTER TABLE IF EXISTS runtime_frameworks
            ALTER COLUMN frame_npu_image DROP NOT NULL;
    END IF;
END
$$;

-- Seed Data
INSERT INTO public.runtime_frameworks (frame_name, frame_version, frame_image, frame_cpu_image, enabled, container_port, type, model_format)
    VALUES
    ('VLLM', 'v0.7.1', 'vllm-local:v0.7.1', 'vllm-cpu:2.4', 1, 8000, 1, ''),
    ('LLaMA-Factory', '1.21', 'llama-factory:1.21-cuda12.1-devel-ubuntu22.04-py310-torch2.1.2', '', 1, 8000, 2, ''),
    ('TGI', '3.0', 'tgi:3.0', '', 1, 8000, 1, ''),
    ('NIM-llama3-8b-instruct', 'latest', 'nvcr.io/nim/meta/llama3-8b-instruct:latest', '', 1, 8000, 1, ''),
    ('NIM-llama3-70b-instruct', 'latest', 'nvcr.io/nim/meta/llama3-70b-instruct:latest', '', 1, 8000, 1, ''),
    ('NIM-llama-3-swallow-70b-instruct-v0.1', 'latest', 'nvcr.io/nim/tokyotech-llm/llama-3-swallow-70b-instruct-v0.1:latest', '', 1, 8000, 1, ''),
    ('NIM-llama-3-taiwan-70b-instruct', 'latest', 'nvcr.io/nim/yentinglin/llama-3-taiwan-70b-instruct:latest', '', 1, 8000, 1, ''),
    ('NIM-llama-2-7b-chat', 'latest', 'nvcr.io/nim/meta/llama-2-7b-chat:latest', '', 1, 8000, 1, ''),
    ('NIM-llama-2-70b-chat', 'latest', 'nvcr.io/nim/meta/llama-2-70b-chat:latest', '', 1, 8000, 1, ''),
    ('NIM-llama-2-13b-chat', 'latest', 'nvcr.io/nim/meta/llama-2-13b-chat:latest', '', 1, 8000, 1, ''),
    ('NIM-llama-3.1-8b-base', 'latest', 'nvcr.io/nim/meta/llama-3.1-8b-base:latest', '', 1, 8000, 1, ''),
    ('NIM-llama-3.1-405b-instruct', 'latest', 'nvcr.io/nim/met/llama-3.1-405b-instruct:latest', '', 1, 8000, 1, ''),
    ('NIM-llama-3.1-8b-instruct', 'latest', 'nvcr.io/nim/meta/llama-3.1-8b-instruct:latest', '', 1, 8000, 1, ''),
    ('NIM-llama-3.1-70b-instruct', 'latest', 'nvcr.io/nim/meta/llama-3.1-70b-instruct:latest', '', 1, 8000, 1, ''),
    ('NIM-mistral-7b-instruct-v0.3', 'latest', 'nvcr.io/nim/mistralai/mistral-7b-instruct-v0.3:latest', '', 1, 8000, 1, ''),
    ('NIM-mixtral-8x7b-instruct-v01', 'latest', 'nvcr.io/nim/mistralai/mixtral-8x7b-instruct-v01:latest', '', 1, 8000, 1, ''),
    ('NIM-mixtral-8x22b-instruct-v01', 'latest', 'nvcr.io/nim/mistralai/mixtral-8x22b-instruct-v01:latest', '', 1, 8000, 1, ''),
    ('MS-Swift', 'v3.1.0', 'ms-swift:v3.1.0', '', 1, 8000, 2, ''),
    ('OpenCompass', '0.3.5', 'opencompass:0.3.5', '', 1, 8000, 4, ''),
    ('SGLang', 'v0.4.1.post3-cu124-srt', 'sglang:v0.4.1.post3-cu124-srt', '', 1, 8000, 1, ''),
    ('HF-Inference-Toolkit', '0.5.3', 'hf-inference-toolkit:0.5.3','', 1, 8000, 1, ''),
    ('TEI', '1.6', 'tei:1.6', 'tei:cpu-1.6', 1, 8000, 1, ''),
    ('Llama.cpp', 'b4689', 'llama.cpp:b4689', 'llama.cpp:b4689-cpu', 1, 8000, 1, 'gguf')
ON CONFLICT (frame_name)
    DO UPDATE SET
        frame_version = EXCLUDED.frame_version,
        frame_image = EXCLUDED.frame_image,
        frame_cpu_image = EXCLUDED.frame_cpu_image,
        enabled = EXCLUDED.enabled,
        container_port = EXCLUDED.container_port,
        type = EXCLUDED.type;
