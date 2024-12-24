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
-- Seed Data for Name: users; Type: TABLE DATA; Schema: public; Owner: csghub_server
--

-- Create Trigger Function
CREATE OR REPLACE FUNCTION promote_root_to_admin ()
    RETURNS TRIGGER
    AS $$
BEGIN
    IF NEW.username = 'root' THEN
        UPDATE
            public.users
        SET
            role_mask = 'admin'
        WHERE
            username = 'root';

        -- After update Drop all
        EXECUTE 'DROP TRIGGER IF EXISTS trigger_promote_root_to_admin ON public.users';
        EXECUTE 'DROP FUNCTION IF EXISTS promote_root_to_admin()';
    END IF;
    RETURN NEW;
END;
$$
LANGUAGE plpgsql
VOLATILE;

-- Create Trigger
CREATE OR REPLACE TRIGGER trigger_promote_root_to_admin
    AFTER INSERT ON public.users
    FOR EACH ROW
    EXECUTE FUNCTION promote_root_to_admin ();

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
INSERT INTO public.runtime_frameworks (id, frame_name, frame_version, frame_image, frame_cpu_image, enabled, container_port, type)
    VALUES
    (1, 'VLLM', '3.1', 'vllm-local:3.1', 'vllm-cpu:2.4', 1, 8000, 1),
    (2, 'LLaMA-Factory', '1.21', 'llama-factory:1.21-cuda12.1-devel-ubuntu22.04-py310-torch2.1.2', '', 1, 8000, 2),
    (3, 'TGI', '3.0', 'tgi:3.0', '', 1, 8000, 1),
    (4, 'NIM-llama3-8b-instruct', 'latest', 'nvcr.io/nim/meta/llama3-8b-instruct:latest', '', 1, 8000, 1),
    (5, 'NIM-llama3-70b-instruct', 'latest', 'nvcr.io/nim/meta/llama3-70b-instruct:latest', '', 1, 8000, 1),
    (6, 'NIM-llama-3-swallow-70b-instruct-v0.1', 'latest', 'nvcr.io/nim/tokyotech-llm/llama-3-swallow-70b-instruct-v0.1:latest', '', 1, 8000, 1),
    (7, 'NIM-llama-3-taiwan-70b-instruct', 'latest', 'nvcr.io/nim/yentinglin/llama-3-taiwan-70b-instruct:latest', '', 1, 8000, 1),
    (8, 'NIM-llama-2-7b-chat', 'latest', 'nvcr.io/nim/meta/llama-2-7b-chat:latest', '', 1, 8000, 1),
    (9, 'NIM-llama-2-70b-chat', 'latest', 'nvcr.io/nim/meta/llama-2-70b-chat:latest', '', 1, 8000, 1),
    (10, 'NIM-llama-2-13b-chat', 'latest', 'nvcr.io/nim/meta/llama-2-13b-chat:latest', '', 1, 8000, 1),
    (11, 'NIM-llama-3.1-8b-base', 'latest', 'nvcr.io/nim/meta/llama-3.1-8b-base:latest', '', 1, 8000, 1),
    (12, 'NIM-llama-3.1-405b-instruct', 'latest', 'nvcr.io/nim/meta/llama-3.1-405b-instruct:latest', '', 1, 8000, 1),
    (13, 'NIM-llama-3.1-8b-instruct', 'latest', 'nvcr.io/nim/meta/llama-3.1-8b-instruct:latest', '', 1, 8000, 1),
    (14, 'NIM-llama-3.1-70b-instruct', 'latest', 'nvcr.io/nim/meta/llama-3.1-70b-instruct:latest', '', 1, 8000, 1),
    (15, 'NIM-mistral-7b-instruct-v0.3', 'latest', 'nvcr.io/nim/mistralai/mistral-7b-instruct-v0.3:latest', '', 1, 8000, 1),
    (16, 'NIM-mixtral-8x7b-instruct-v01', 'latest', 'nvcr.io/nim/mistralai/mixtral-8x7b-instruct-v01:latest', '', 1, 8000, 1),
    (17, 'NIM-mixtral-8x22b-instruct-v01', 'latest', 'nvcr.io/nim/mistralai/mixtral-8x22b-instruct-v01:latest', '', 1, 8000, 1),
    (18, 'MS-Swift', '1.0', 'ms-swift:1.0-cuda12.1-devel-ubuntu22.04-py310-torch2.4.0', '', 1, 8000, 2),
    (19, 'OpenCompass', '0.3.5', 'opencompass:0.3.5', '', 1, 8000, 4)
ON CONFLICT (id)
    DO UPDATE SET
        frame_name = EXCLUDED.frame_name,
        frame_version = EXCLUDED.frame_version,
        frame_image = EXCLUDED.frame_image,
        frame_cpu_image = EXCLUDED.frame_cpu_image,
        enabled = EXCLUDED.enabled,
        container_port = EXCLUDED.container_port,
        type = EXCLUDED.type;

--
-- Name: runtime_frameworks_id_seq; Type: SEQUENCE SET; Schema: public; Owner: csghub_server
--

SELECT
    pg_catalog.setval('public.runtime_frameworks_id_seq', (
            SELECT
                MAX(id)
            FROM public.runtime_frameworks), TRUE);

--
-- Seed Data for Name: runtime_architectures; Type: TABLE DATA; Schema: public; Owner: csghub_server
--

INSERT INTO public.runtime_architectures (id, runtime_framework_id, architecture_name)
    VALUES
    -- For VLLM
    (1, 1, 'AquilaForCausalLM'),
    (2, 1, 'ArcticForCausalLM'),
    (3, 1, 'BaiChuanForCausalLM'),
    (4, 1, 'BloomForCausalLM'),
    (5, 1, 'ChatGLMModel'),
    (6, 1, 'CohereForCausalLM'),
    (7, 1, 'DbrxForCausalLM'),
    (8, 1, 'DeciLMForCausalLM'),
    (9, 1, 'FalconForCausalLM'),
    (10, 1, 'GemmaForCausalLM'),
    (11, 1, 'Gemma2ForCausalLM'),
    (12, 1, 'GPT2LMHeadModel'),
    (13, 1, 'GPTBigCodeForCausalLM'),
    (14, 1, 'GPTJForCausalLM'),
    (15, 1, 'GPTNeoXForCausalLM'),
    (16, 1, 'InternLMForCausalLM'),
    (17, 1, 'InternLM2ForCausalLM'),
    (18, 1, 'JAISLMHeadModel'),
    (19, 1, 'JambaForCausalLM'),
    (20, 1, 'LlamaForCausalLM'),
    (21, 1, 'MiniCPMForCausalLM'),
    (22, 1, 'MistralForCausalLM'),
    (23, 1, 'MixtralForCausalLM'),
    (24, 1, 'MPTForCausalLM'),
    (25, 1, 'OLMoForCausalLM'),
    (26, 1, 'OPTForCausalLM'),
    (27, 1, 'OrionForCausalLM'),
    (28, 1, 'PhiForCausalLM'),
    (29, 1, 'Phi3ForCausalLM'),
    (30, 1, 'Phi3SmallForCausalLM'),
    (31, 1, 'PersimmonForCausalLM'),
    (32, 1, 'QWenLMHeadModel'),
    (33, 1, 'Qwen2ForCausalLM'),
    (34, 1, 'Qwen2MoeForCausalLM'),
    (35, 1, 'StableLmForCausalLM'),
    (36, 1, 'Starcoder2ForCausalLM'),
    (37, 1, 'XverseForCausalLM'),
    (38, 1, 'ChameleonForConditionalGeneration'),
    (39, 1, 'FuyuForCausalLM'),
    (40, 1, 'LlavaForConditionalGeneration'),
    (41, 1, 'LlavaNextForConditionalGeneration'),
    (42, 1, 'PaliGemmaForConditionalGeneration'),
    (43, 1, 'Phi3VForCausalLM'),
    -- For LLaMA-Factory
    (44, 2, 'BaiChuanForCausalLM'),
    (45, 2, 'BloomForCausalLM'),
    (46, 2, 'ChatGLMModel'),
    (47, 2, 'CohereForCausalLM'),
    (48, 2, 'DeepseekV2ForCausalLM'),
    (49, 2, 'FalconForCausalLM'),
    (50, 2, 'Gemma2ForCausalLM'),
    (51, 2, 'GemmaForCausalLM'),
    (52, 2, 'InternLM2ForCausalLM'),
    (53, 2, 'InternLM2ForRewardModel'),
    (54, 2, 'LlamaForCausalLM'),
    (55, 2, 'LlavaForConditionalGeneration'),
    (56, 2, 'LlavaNextForConditionalGeneration'),
    (57, 2, 'MistralForCausalLM'),
    (58, 2, 'MixtralForCausalLM'),
    (59, 2, 'OlmoForCausalLM'),
    (60, 2, 'PaliGemmaForConditionalGeneration'),
    (61, 2, 'PhiForCausalLM'),
    (62, 2, 'Phi3ForCausalLM'),
    (63, 2, 'Qwen2ForCausalLM'),
    (64, 2, 'QWenLMHeadModel'),
    (65, 2, 'Qwen2MoeForCausalLM'),
    (66, 2, 'Starcoder2ForCausalLM'),
    (67, 2, 'XverseForCausalLM'),
    (68, 2, 'LlavaLlamaForCausalLM'),
    (69, 2, 'YuanForCausalLM'),
    -- For TGI
    (70, 3, 'DeepseekV2ForCausalLM'),
    (71, 3, 'Idefics2ForConditionalGeneration'),
    (72, 3, 'LlavaNextForConditionalGeneration'),
    (73, 3, 'LlamaForCausalLM'),
    (74, 3, 'Phi3ForCausalLM'),
    (75, 3, 'GemmaForCausalLM'),
    (76, 3, 'PaliGemmaForConditionalGeneration'),
    (77, 3, 'CohereForCausalLM'),
    (78, 3, 'DbrxForCausalLM'),
    (79, 3, 'MistralForCausalLM'),
    (80, 3, 'MixtralForCausalLM'),
    (81, 3, 'GPTBigCodeForCausalLM'),
    (82, 3, 'PhiForCausalLM'),
    (83, 3, 'BaichuanForCausalLM'),
    (84, 3, 'FalconForCausalLM'),
    (85, 3, 'Starcoder2ForCausalLM'),
    (86, 3, 'Qwen2ForCausalLM'),
    (87, 3, 'OPTForCausalLM'),
    (88, 3, 'T5ForConditionalGeneration'),
    (89, 3, 'GPT2LMHeadCustomModel'),
    (90, 3, 'BloomForCausalLM'),
    (91, 3, 'MPTForCausalLM'),
    (92, 3, 'GPT2LMHeadModel'),
    (93, 3, 'GPTNeoXForCausalLM'),
    (94, 3, 'IdeficsForVisionText2Text'),
    -- For OpenCompass
    (95, 19, 'AquilaForCausalLM'),
    (96, 19, 'ArcticForCausalLM'),
    (97, 19, 'BaiChuanForCausalLM'),
    (98, 19, 'BloomForCausalLM'),
    (99, 19, 'ChatGLMModel'),
    (100, 19, 'CohereForCausalLM'),
    (101, 19, 'DbrxForCausalLM'),
    (102, 19, 'DeciLMForCausalLM'),
    (103, 19, 'FalconForCausalLM'),
    (104, 19, 'GemmaForCausalLM'),
    (105, 19, 'Gemma2ForCausalLM'),
    (106, 19, 'GPT2LMHeadModel'),
    (107, 19, 'GPTBigCodeForCausalLM'),
    (108, 19, 'GPTJForCausalLM'),
    (109, 19, 'GPTNeoXForCausalLM'),
    (110, 19, 'InternLMForCausalLM'),
    (111, 19, 'InternLM2ForCausalLM'),
    (112, 19, 'JAISLMHeadModel'),
    (113, 19, 'JambaForCausalLM'),
    (114, 19, 'LlamaForCausalLM'),
    (115, 19, 'MiniCPMForCausalLM'),
    (116, 19, 'MistralForCausalLM'),
    (117, 19, 'MixtralForCausalLM'),
    (118, 19, 'MPTForCausalLM'),
    (119, 19, 'OLMoForCausalLM'),
    (120, 19, 'OPTForCausalLM'),
    (121, 19, 'OrionForCausalLM'),
    (122, 19, 'PhiForCausalLM'),
    (123, 19, 'Phi3ForCausalLM'),
    (124, 19, 'Phi3SmallForCausalLM'),
    (125, 19, 'PersimmonForCausalLM'),
    (126, 19, 'QWenLMHeadModel'),
    (127, 19, 'Qwen2ForCausalLM'),
    (128, 19, 'Qwen2MoeForCausalLM'),
    (129, 19, 'StableLmForCausalLM'),
    (130, 19, 'Starcoder2ForCausalLM'),
    (131, 19, 'XverseForCausalLM'),
    (132, 19, 'ChameleonForConditionalGeneration'),
    (133, 19, 'FuyuForCausalLM'),
    (134, 19, 'LlavaForConditionalGeneration'),
    (135, 19, 'LlavaNextForConditionalGeneration'),
    (136, 19, 'PaliGemmaForConditionalGeneration'),
    (137, 19, 'Phi3VForCausalLM')
ON CONFLICT (id)
    DO UPDATE SET
        runtime_framework_id = EXCLUDED.runtime_framework_id,
        architecture_name = EXCLUDED.architecture_name;

--
-- Name: runtime_frameworks_id_seq; Type: SEQUENCE SET; Schema: public; Owner: csghub_server
--

SELECT
    pg_catalog.setval('public.runtime_architectures_id_seq', (
            SELECT
                MAX(id)
            FROM public.runtime_architectures), TRUE);
