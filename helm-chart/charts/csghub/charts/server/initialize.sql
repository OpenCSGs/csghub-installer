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
SELECT pg_catalog.set_config('search_path', 'public', false);

--
-- Truncate Data for Name: space_resources; Type: TABLE DATA; Schema: public; Owner: postgres
--

TRUNCATE TABLE space_resources;

--
-- Seed Data for Name: space_resources; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO space_resources (name, resources, cluster_id)
VALUES
    ('CPU basic · 0.5 vCPU · 1 GB', '{ "cpu": { "type": "Intel", "num": "0.5" }, "memory": "1Gi" }' ,(SELECT cluster_id FROM cluster_infos LIMIT 1))
ON CONFLICT (name)
    DO UPDATE SET
                  resources = EXCLUDED.resources,
                  cluster_id = EXCLUDED.cluster_id;

INSERT INTO space_resources (name, resources, cluster_id)
VALUES
    ('CPU basic · 2 vCPU · 4 GB', '{ "cpu": { "type": "Intel", "num": "2" }, "memory": "4Gi" }', (SELECT cluster_id FROM cluster_infos LIMIT 1))
ON CONFLICT (name)
    DO UPDATE SET
                  resources = EXCLUDED.resources,
                  cluster_id = EXCLUDED.cluster_id;

INSERT INTO space_resources (name, resources, cluster_id)
VALUES
    ('NVIDIA A10G · 4 vCPU · 16 GB', '{"gpu": { "type": "A10", "num": "1", "resource_name": "nvidia.com/gpu", "labels": { "aliyun.accelerator/nvidia_name": "NVIDIA-A10" } }, "cpu": { "type": "Intel", "num": "4" },  "memory": "16Gi" }', (SELECT cluster_id FROM cluster_infos LIMIT 1))
ON CONFLICT (name)
    DO UPDATE SET
                  resources = EXCLUDED.resources,
                  cluster_id = EXCLUDED.cluster_id;

INSERT INTO space_resources (name, resources, cluster_id)
VALUES
    ('NVIDIA A10G · 6 vCPU · 32 GB', '{"gpu": { "type": "A10", "num": "1", "resource_name": "nvidia.com/gpu", "labels": { "aliyun.accelerator/nvidia_name": "NVIDIA-A10" } }, "cpu": { "type": "Intel", "num": "6" },  "memory": "32Gi" }', (SELECT cluster_id FROM public.cluster_infos LIMIT 1))
ON CONFLICT (name)
    DO UPDATE SET
                  resources = EXCLUDED.resources,
                  cluster_id = EXCLUDED.cluster_id;

INSERT INTO space_resources (name, resources, cluster_id)
VALUES
    ('NVIDIA A10G · 2 · 12 vCPU · 48 GB', '{"gpu": { "type": "A10", "num": "2", "resource_name": "nvidia.com/gpu", "labels": { "aliyun.accelerator/nvidia_name": "NVIDIA-A10" } }, "cpu": { "type": "Intel", "num": "12" },  "memory": "48Gi" }', (SELECT cluster_id FROM cluster_infos LIMIT 1))
ON CONFLICT (name)
    DO UPDATE SET
                  resources = EXCLUDED.resources,
                  cluster_id = EXCLUDED.cluster_id;

INSERT INTO space_resources (name, resources, cluster_id)
VALUES
    ('NVIDIA A10G · 4 · 24 vCPU · 96 GB', '{"gpu": { "type": "A10", "num": "4", "resource_name": "nvidia.com/gpu", "labels": { "aliyun.accelerator/nvidia_name": "NVIDIA-A10" } }, "cpu": { "type": "Intel", "num": "24" },  "memory": "96Gi" }', (SELECT cluster_id FROM public.cluster_infos LIMIT 1))
ON CONFLICT (name)
    DO UPDATE SET
                  resources = EXCLUDED.resources,
                  cluster_id = EXCLUDED.cluster_id;
-- for A40
INSERT INTO space_resources (name, resources, cluster_id)
VALUES
    ('NVIDIA A40G · 4 vCPU · 16 GB', '{"gpu": { "type": "A40", "num": "1", "resource_name": "nvidia.com/gpu", "labels": { "nvidia.com/nvidia_name": "NVIDIA-A40" } }, "cpu": { "type": "Intel", "num": "4" },  "memory": "16Gi" }', (SELECT cluster_id FROM cluster_infos LIMIT 1))
ON CONFLICT (name)
    DO UPDATE SET
                  resources = EXCLUDED.resources,
                  cluster_id = EXCLUDED.cluster_id;

INSERT INTO space_resources (name, resources,  cluster_id)
VALUES
('NVIDIA A40G · 8 vCPU · 32 GB', '{"gpu": { "type": "A40", "num": "1", "resource_name": "nvidia.com/gpu", "labels": { "nvidia.com/nvidia_name": "NVIDIA-A40" } }, "cpu": { "type": "Intel", "num": "8" },  "memory": "32Gi" }', (SELECT cluster_id FROM cluster_infos LIMIT 1))
ON CONFLICT (name)
    DO UPDATE SET
                  resources = EXCLUDED.resources,
                  cluster_id = EXCLUDED.cluster_id;


INSERT INTO space_resources (name, resources, cluster_id)
VALUES
    ('NVIDIA A40G · 2 · 12 vCPU · 48 GB', '{"gpu": { "type": "A40", "num": "2", "resource_name": "nvidia.com/gpu", "labels": { "nvidia.com/nvidia_name": "NVIDIA-A40" } }, "cpu": { "type": "Intel", "num": "12" },  "memory": "48Gi" }', (SELECT cluster_id FROM cluster_infos LIMIT 1))
ON CONFLICT (name)
    DO UPDATE SET
                  resources = EXCLUDED.resources,
                  cluster_id = EXCLUDED.cluster_id;

--
-- Truncate Data for Name: runtime_frameworks; Type: TABLE DATA; Schema: public; Owner: postgres
--

TRUNCATE TABLE runtime_frameworks;

--
-- Seed Data for Name: runtime_frameworks; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO runtime_frameworks (id, frame_name, frame_version, frame_image, frame_cpu_image, enabled, container_port, type) VALUES (1, 'VLLM', '2.8', 'vllm-local:2.8', 'vllm-cpu:2.4', 1, 8000, 1);
INSERT INTO runtime_frameworks (id, frame_name, frame_version, frame_image, frame_cpu_image, enabled, container_port, type) VALUES (2, 'LLaMA-Factory', '1.21', 'llama-factory:1.21-cuda12.1-devel-ubuntu22.04-py310-torch2.1.2', '', 1, 8000, 2);
INSERT INTO runtime_frameworks (id, frame_name, frame_version, frame_image, frame_cpu_image, enabled, container_port, type) VALUES (3, 'TGI', '2.1', 'tgi:2.1', '', 1, 8000, 1);
INSERT INTO runtime_frameworks (id, frame_name, frame_version, frame_image, frame_cpu_image, enabled, container_port, type) VALUES (4, 'NIM-llama3-8b-instruct', 'latest', 'nvcr.io/nim/meta/llama3-8b-instruct:latest', '', 1, 8000, 1);
INSERT INTO runtime_frameworks (id, frame_name, frame_version, frame_image, frame_cpu_image, enabled, container_port, type) VALUES (5, 'NIM-llama3-70b-instruct', 'latest', 'nvcr.io/nim/meta/llama3-70b-instruct:latest', '', 1, 8000, 1);
INSERT INTO runtime_frameworks (id, frame_name, frame_version, frame_image, frame_cpu_image, enabled, container_port, type) VALUES (6, 'NIM-llama-3-swallow-70b-instruct-v0.1', 'latest', 'nvcr.io/nim/tokyotech-llm/llama-3-swallow-70b-instruct-v0.1:latest', '', 1, 8000, 1);
INSERT INTO runtime_frameworks (id, frame_name, frame_version, frame_image, frame_cpu_image, enabled, container_port, type) VALUES (7, 'NIM-llama-3-taiwan-70b-instruct', 'latest', 'nvcr.io/nim/yentinglin/llama-3-taiwan-70b-instruct:latest', '', 1, 8000, 1);
INSERT INTO runtime_frameworks (id, frame_name, frame_version, frame_image, frame_cpu_image, enabled, container_port, type) VALUES (8, 'NIM-llama-2-7b-chat', 'latest', 'nvcr.io/nim/meta/llama-2-7b-chat:latest', '', 1, 8000, 1);
INSERT INTO runtime_frameworks (id, frame_name, frame_version, frame_image, frame_cpu_image, enabled, container_port, type) VALUES (9, 'NIM-llama-2-70b-chat', 'latest', 'nvcr.io/nim/meta/llama-2-70b-chat:latest', '', 1, 8000, 1);
INSERT INTO runtime_frameworks (id, frame_name, frame_version, frame_image, frame_cpu_image, enabled, container_port, type) VALUES (10, 'NIM-llama-2-13b-chat', 'latest', 'nvcr.io/nim/meta/llama-2-13b-chat:latest', '', 1, 8000, 1);
INSERT INTO runtime_frameworks (id, frame_name, frame_version, frame_image, frame_cpu_image, enabled, container_port, type) VALUES (11, 'NIM-llama-3.1-8b-base', 'latest', 'nvcr.io/nim/meta/llama-3.1-8b-base:latest', '', 1, 8000, 1);
INSERT INTO runtime_frameworks (id, frame_name, frame_version, frame_image, frame_cpu_image, enabled, container_port, type) VALUES (12, 'NIM-llama-3.1-405b-instruct', 'latest', 'nvcr.io/nim/meta/llama-3.1-405b-instruct:latest', '', 1, 8000, 1);
INSERT INTO runtime_frameworks (id, frame_name, frame_version, frame_image, frame_cpu_image, enabled, container_port, type) VALUES (13, 'NIM-llama-3.1-8b-instruct', 'latest', 'nvcr.io/nim/meta/llama-3.1-8b-instruct:latest', '', 1, 8000, 1);
INSERT INTO runtime_frameworks (id, frame_name, frame_version, frame_image, frame_cpu_image, enabled, container_port, type) VALUES (14, 'NIM-llama-3.1-70b-instruct', 'latest', 'nvcr.io/nim/meta/llama-3.1-70b-instruct:latest', '', 1, 8000, 1);
INSERT INTO runtime_frameworks (id, frame_name, frame_version, frame_image, frame_cpu_image, enabled, container_port, type) VALUES (15, 'NIM-mistral-7b-instruct-v0.3', 'latest', 'nvcr.io/nim/mistralai/mistral-7b-instruct-v0.3:latest', '', 1, 8000, 1);
INSERT INTO runtime_frameworks (id, frame_name, frame_version, frame_image, frame_cpu_image, enabled, container_port, type) VALUES (16, 'NIM-mixtral-8x7b-instruct-v01', 'latest', 'nvcr.io/nim/mistralai/mixtral-8x7b-instruct-v01:latest', '', 1, 8000, 1);
INSERT INTO runtime_frameworks (id, frame_name, frame_version, frame_image, frame_cpu_image, enabled, container_port, type) VALUES (17, 'NIM-mixtral-8x22b-instruct-v01', 'latest', 'nvcr.io/nim/mistralai/mixtral-8x22b-instruct-v01:latest', '', 1, 8000, 1);

--
-- Truncate Data for Name: runtime_architectures; Type: TABLE DATA; Schema: public; Owner: postgres
--

TRUNCATE TABLE runtime_architectures;

--
-- Seed Data for Name: runtime_architectures; Type: TABLE DATA; Schema: public; Owner: postgres
--

-- For VLLM
INSERT INTO runtime_architectures (runtime_framework_id, architecture_name) VALUES(1, 'AquilaForCausalLM');
INSERT INTO runtime_architectures (runtime_framework_id, architecture_name) VALUES(1, 'ArcticForCausalLM');
INSERT INTO runtime_architectures (runtime_framework_id, architecture_name) VALUES(1, 'BaiChuanForCausalLM');
INSERT INTO runtime_architectures (runtime_framework_id, architecture_name) VALUES(1, 'BloomForCausalLM');
INSERT INTO runtime_architectures (runtime_framework_id, architecture_name) VALUES(1, 'ChatGLMModel');
INSERT INTO runtime_architectures (runtime_framework_id, architecture_name) VALUES(1, 'CohereForCausalLM');
INSERT INTO runtime_architectures (runtime_framework_id, architecture_name) VALUES(1, 'DbrxForCausalLM');
INSERT INTO runtime_architectures (runtime_framework_id, architecture_name) VALUES(1, 'DeciLMForCausalLM');
INSERT INTO runtime_architectures (runtime_framework_id, architecture_name) VALUES(1, 'FalconForCausalLM');
INSERT INTO runtime_architectures (runtime_framework_id, architecture_name) VALUES(1, 'GemmaForCausalLM');
INSERT INTO runtime_architectures (runtime_framework_id, architecture_name) VALUES(1, 'Gemma2ForCausalLM');
INSERT INTO runtime_architectures (runtime_framework_id, architecture_name) VALUES(1, 'GPT2LMHeadModel');
INSERT INTO runtime_architectures (runtime_framework_id, architecture_name) VALUES(1, 'GPTBigCodeForCausalLM');
INSERT INTO runtime_architectures (runtime_framework_id, architecture_name) VALUES(1, 'GPTJForCausalLM');
INSERT INTO runtime_architectures (runtime_framework_id, architecture_name) VALUES(1, 'GPTNeoXForCausalLM');
INSERT INTO runtime_architectures (runtime_framework_id, architecture_name) VALUES(1, 'InternLMForCausalLM');
INSERT INTO runtime_architectures (runtime_framework_id, architecture_name) VALUES(1, 'InternLM2ForCausalLM');
INSERT INTO runtime_architectures (runtime_framework_id, architecture_name) VALUES(1, 'JAISLMHeadModel');
INSERT INTO runtime_architectures (runtime_framework_id, architecture_name) VALUES(1, 'JambaForCausalLM');
INSERT INTO runtime_architectures (runtime_framework_id, architecture_name) VALUES(1, 'LlamaForCausalLM');
INSERT INTO runtime_architectures (runtime_framework_id, architecture_name) VALUES(1, 'MiniCPMForCausalLM');
INSERT INTO runtime_architectures (runtime_framework_id, architecture_name) VALUES(1, 'MistralForCausalLM');
INSERT INTO runtime_architectures (runtime_framework_id, architecture_name) VALUES(1, 'MixtralForCausalLM');
INSERT INTO runtime_architectures (runtime_framework_id, architecture_name) VALUES(1, 'MPTForCausalLM');
INSERT INTO runtime_architectures (runtime_framework_id, architecture_name) VALUES(1, 'OLMoForCausalLM');
INSERT INTO runtime_architectures (runtime_framework_id, architecture_name) VALUES(1, 'OPTForCausalLM');
INSERT INTO runtime_architectures (runtime_framework_id, architecture_name) VALUES(1, 'OrionForCausalLM');
INSERT INTO runtime_architectures (runtime_framework_id, architecture_name) VALUES(1, 'PhiForCausalLM');
INSERT INTO runtime_architectures (runtime_framework_id, architecture_name) VALUES(1, 'Phi3ForCausalLM');
INSERT INTO runtime_architectures (runtime_framework_id, architecture_name) VALUES(1, 'Phi3SmallForCausalLM');
INSERT INTO runtime_architectures (runtime_framework_id, architecture_name) VALUES(1, 'PersimmonForCausalLM');
INSERT INTO runtime_architectures (runtime_framework_id, architecture_name) VALUES(1, 'QWenLMHeadModel');
INSERT INTO runtime_architectures (runtime_framework_id, architecture_name) VALUES(1, 'Qwen2ForCausalLM');
INSERT INTO runtime_architectures (runtime_framework_id, architecture_name) VALUES(1, 'Qwen2MoeForCausalLM');
INSERT INTO runtime_architectures (runtime_framework_id, architecture_name) VALUES(1, 'StableLmForCausalLM');
INSERT INTO runtime_architectures (runtime_framework_id, architecture_name) VALUES(1, 'Starcoder2ForCausalLM');
INSERT INTO runtime_architectures (runtime_framework_id, architecture_name) VALUES(1, 'XverseForCausalLM');
INSERT INTO runtime_architectures (runtime_framework_id, architecture_name) VALUES(1, 'ChameleonForConditionalGeneration');
INSERT INTO runtime_architectures (runtime_framework_id, architecture_name) VALUES(1, 'FuyuForCausalLM');
INSERT INTO runtime_architectures (runtime_framework_id, architecture_name) VALUES(1, 'LlavaForConditionalGeneration');
INSERT INTO runtime_architectures (runtime_framework_id, architecture_name) VALUES(1, 'LlavaNextForConditionalGeneration');
INSERT INTO runtime_architectures (runtime_framework_id, architecture_name) VALUES(1, 'PaliGemmaForConditionalGeneration');
INSERT INTO runtime_architectures (runtime_framework_id, architecture_name) VALUES(1, 'Phi3VForCausalLM');
-- For LLaMA-Factory
INSERT INTO runtime_architectures (runtime_framework_id, architecture_name) VALUES(2, 'BaiChuanForCausalLM');
INSERT INTO runtime_architectures (runtime_framework_id, architecture_name) VALUES(2, 'BloomForCausalLM');
INSERT INTO runtime_architectures (runtime_framework_id, architecture_name) VALUES(2, 'ChatGLMModel');
INSERT INTO runtime_architectures (runtime_framework_id, architecture_name) VALUES(2, 'CohereForCausalLM');
INSERT INTO runtime_architectures (runtime_framework_id, architecture_name) VALUES(2, 'DeepseekV2ForCausalLM');
INSERT INTO runtime_architectures (runtime_framework_id, architecture_name) VALUES(2, 'FalconForCausalLM');
INSERT INTO runtime_architectures (runtime_framework_id, architecture_name) VALUES(2, 'Gemma2ForCausalLM');
INSERT INTO runtime_architectures (runtime_framework_id, architecture_name) VALUES(2, 'GemmaForCausalLM');
INSERT INTO runtime_architectures (runtime_framework_id, architecture_name) VALUES(2, 'InternLM2ForCausalLM');
INSERT INTO runtime_architectures (runtime_framework_id, architecture_name) VALUES(2, 'InternLM2ForRewardModel');
INSERT INTO runtime_architectures (runtime_framework_id, architecture_name) VALUES(2, 'LlamaForCausalLM');
INSERT INTO runtime_architectures (runtime_framework_id, architecture_name) VALUES(2, 'LlavaForConditionalGeneration');
INSERT INTO runtime_architectures (runtime_framework_id, architecture_name) VALUES(2, 'LlavaNextForConditionalGeneration');
INSERT INTO runtime_architectures (runtime_framework_id, architecture_name) VALUES(2, 'MistralForCausalLM');
INSERT INTO runtime_architectures (runtime_framework_id, architecture_name) VALUES(2, 'MixtralForCausalLM');
INSERT INTO runtime_architectures (runtime_framework_id, architecture_name) VALUES(2, 'OlmoForCausalLM');
INSERT INTO runtime_architectures (runtime_framework_id, architecture_name) VALUES(2, 'PaliGemmaForConditionalGeneration');
INSERT INTO runtime_architectures (runtime_framework_id, architecture_name) VALUES(2, 'PhiForCausalLM');
INSERT INTO runtime_architectures (runtime_framework_id, architecture_name) VALUES(2, 'Phi3ForCausalLM');
INSERT INTO runtime_architectures (runtime_framework_id, architecture_name) VALUES(2, 'Qwen2ForCausalLM');
INSERT INTO runtime_architectures (runtime_framework_id, architecture_name) VALUES(2, 'QWenLMHeadModel');
INSERT INTO runtime_architectures (runtime_framework_id, architecture_name) VALUES(2, 'Qwen2MoeForCausalLM');
INSERT INTO runtime_architectures (runtime_framework_id, architecture_name) VALUES(2, 'Starcoder2ForCausalLM');
INSERT INTO runtime_architectures (runtime_framework_id, architecture_name) VALUES(2, 'XverseForCausalLM');
INSERT INTO runtime_architectures (runtime_framework_id, architecture_name) VALUES(2, 'LlavaLlamaForCausalLM');
INSERT INTO runtime_architectures (runtime_framework_id, architecture_name) VALUES(2, 'YuanForCausalLM');
-- For TGI
INSERT INTO runtime_architectures (runtime_framework_id, architecture_name) VALUES(3, 'DeepseekV2ForCausalLM');
INSERT INTO runtime_architectures (runtime_framework_id, architecture_name) VALUES(3, 'Idefics2ForConditionalGeneration');
INSERT INTO runtime_architectures (runtime_framework_id, architecture_name) VALUES(3, 'LlavaNextForConditionalGeneration');
INSERT INTO runtime_architectures (runtime_framework_id, architecture_name) VALUES(3, 'LlamaForCausalLM');
INSERT INTO runtime_architectures (runtime_framework_id, architecture_name) VALUES(3, 'Phi3ForCausalLM');
INSERT INTO runtime_architectures (runtime_framework_id, architecture_name) VALUES(3, 'GemmaForCausalLM');
INSERT INTO runtime_architectures (runtime_framework_id, architecture_name) VALUES(3, 'PaliGemmaForConditionalGeneration');
INSERT INTO runtime_architectures (runtime_framework_id, architecture_name) VALUES(3, 'CohereForCausalLM');
INSERT INTO runtime_architectures (runtime_framework_id, architecture_name) VALUES(3, 'DbrxForCausalLM');
INSERT INTO runtime_architectures (runtime_framework_id, architecture_name) VALUES(3, 'MistralForCausalLM');
INSERT INTO runtime_architectures (runtime_framework_id, architecture_name) VALUES(3, 'MixtralForCausalLM');
INSERT INTO runtime_architectures (runtime_framework_id, architecture_name) VALUES(3, 'GPTBigCodeForCausalLM');
INSERT INTO runtime_architectures (runtime_framework_id, architecture_name) VALUES(3, 'PhiForCausalLM');
INSERT INTO runtime_architectures (runtime_framework_id, architecture_name) VALUES(3, 'BaichuanForCausalLM');
INSERT INTO runtime_architectures (runtime_framework_id, architecture_name) VALUES(3, 'FalconForCausalLM');
INSERT INTO runtime_architectures (runtime_framework_id, architecture_name) VALUES(3, 'Starcoder2ForCausalLM');
INSERT INTO runtime_architectures (runtime_framework_id, architecture_name) VALUES(3, 'Qwen2ForCausalLM');
INSERT INTO runtime_architectures (runtime_framework_id, architecture_name) VALUES(3, 'OPTForCausalLM');
INSERT INTO runtime_architectures (runtime_framework_id, architecture_name) VALUES(3, 'T5ForConditionalGeneration');
INSERT INTO runtime_architectures (runtime_framework_id, architecture_name) VALUES(3, 'GPT2LMHeadCustomModel');
INSERT INTO runtime_architectures (runtime_framework_id, architecture_name) VALUES(3, 'BloomForCausalLM');
INSERT INTO runtime_architectures (runtime_framework_id, architecture_name) VALUES(3, 'MPTForCausalLM');
INSERT INTO runtime_architectures (runtime_framework_id, architecture_name) VALUES(3, 'GPT2LMHeadModel');
INSERT INTO runtime_architectures (runtime_framework_id, architecture_name) VALUES(3, 'GPTNeoXForCausalLM');
INSERT INTO runtime_architectures (runtime_framework_id, architecture_name) VALUES(3, 'IdeficsForVisionText2Text');

--
-- Name: runtime_frameworks_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval(
               'public.runtime_frameworks_id_seq',
               (SELECT MAX(id) FROM runtime_frameworks),
               true
       );

--
-- Seed Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
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