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

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE OR REPLACE FUNCTION generate_uuid(input_string TEXT)
    RETURNS UUID AS $$
DECLARE
    base_uuid TEXT;
BEGIN
    base_uuid := md5(input_string);
    RETURN uuid_generate_v5(uuid_nil(), base_uuid);
END;
$$ LANGUAGE plpgsql;

-- Create Trigger Function
CREATE OR REPLACE FUNCTION promote_root_to_admin ()
    RETURNS TRIGGER
    AS $$
BEGIN
    IF NEW.username = 'root' THEN
        UPDATE
            public.users
        SET
            role_mask = 'admin',
            uuid = generate_uuid({{ .Release.Name | squote }})
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
        (2, 'CPU basic · 2 vCPU · 4 GB', '{ "cpu": { "type": "Intel", "num": "2" }, "memory": "4Gi" }', ( SELECT cluster_id FROM selected_cluster))
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
INSERT INTO public.runtime_frameworks (frame_name, frame_version, frame_image, frame_cpu_image, enabled, container_port, type)
    VALUES
    ('VLLM', 'v0.7.1', 'vllm-local:v0.7.1', 'vllm-cpu:2.4', 1, 8000, 1),
    ('LLaMA-Factory', '1.21', 'llama-factory:1.21-cuda12.1-devel-ubuntu22.04-py310-torch2.1.2', '', 1, 8000, 2),
    ('TGI', '3.0', 'tgi:3.0', '', 1, 8000, 1),
    ('NIM-llama3-8b-instruct', 'latest', 'nvcr.io/nim/meta/llama3-8b-instruct:latest', '', 1, 8000, 1),
    ('NIM-llama3-70b-instruct', 'latest', 'nvcr.io/nim/meta/llama3-70b-instruct:latest', '', 1, 8000, 1),
    ('NIM-llama-3-swallow-70b-instruct-v0.1', 'latest', 'nvcr.io/nim/tokyotech-llm/llama-3-swallow-70b-instruct-v0.1:latest', '', 1, 8000, 1),
    ('NIM-llama-3-taiwan-70b-instruct', 'latest', 'nvcr.io/nim/yentinglin/llama-3-taiwan-70b-instruct:latest', '', 1, 8000, 1),
    ('NIM-llama-2-7b-chat', 'latest', 'nvcr.io/nim/meta/llama-2-7b-chat:latest', '', 1, 8000, 1),
    ('NIM-llama-2-70b-chat', 'latest', 'nvcr.io/nim/meta/llama-2-70b-chat:latest', '', 1, 8000, 1),
    ('NIM-llama-2-13b-chat', 'latest', 'nvcr.io/nim/meta/llama-2-13b-chat:latest', '', 1, 8000, 1),
    ('NIM-llama-3.1-8b-base', 'latest', 'nvcr.io/nim/meta/llama-3.1-8b-base:latest', '', 1, 8000, 1),
    ('NIM-llama-3.1-405b-instruct', 'latest', 'nvcr.io/nim/met/llama-3.1-405b-instruct:latest', '', 1, 8000, 1),
    ('NIM-llama-3.1-8b-instruct', 'latest', 'nvcr.io/nim/meta/llama-3.1-8b-instruct:latest', '', 1, 8000, 1),
    ('NIM-llama-3.1-70b-instruct', 'latest', 'nvcr.io/nim/meta/llama-3.1-70b-instruct:latest', '', 1, 8000, 1),
    ('NIM-mistral-7b-instruct-v0.3', 'latest', 'nvcr.io/nim/mistralai/mistral-7b-instruct-v0.3:latest', '', 1, 8000, 1),
    ('NIM-mixtral-8x7b-instruct-v01', 'latest', 'nvcr.io/nim/mistralai/mixtral-8x7b-instruct-v01:latest', '', 1, 8000, 1),
    ('NIM-mixtral-8x22b-instruct-v01', 'latest', 'nvcr.io/nim/mistralai/mixtral-8x22b-instruct-v01:latest', '', 1, 8000, 1),
    ('MS-Swift', 'v3.1.0', 'ms-swift:v3.1.0', '', 1, 8000, 2),
    ('OpenCompass', '0.3.5', 'opencompass:0.3.5', '', 1, 8000, 4),
    ('SGLang', 'v0.4.1.post3-cu124-srt', 'sglang:v0.4.1.post3-cu124-srt', '', 1, 8000, 1),
    ('HF-Inference-Toolkit', '0.5.3', 'hf-inference-toolkit:0.5.3','', 1, 8000, 1)
ON CONFLICT (frame_name)
    DO UPDATE SET
        frame_version = EXCLUDED.frame_version,
        frame_image = EXCLUDED.frame_image,
        frame_cpu_image = EXCLUDED.frame_cpu_image,
        enabled = EXCLUDED.enabled,
        container_port = EXCLUDED.container_port,
        type = EXCLUDED.type;

--
-- Seed Data for Name: runtime_architectures; Type: TABLE DATA; Schema: public; Owner: csghub_server
--
WITH framework_architecture AS (
    SELECT *
    FROM (
        VALUES
            ('VLLM', 'ArcticForCausalLM'),
            ('VLLM', 'BaiChuanForCausalLM'),
            ('VLLM', 'BloomForCausalLM'),
            ('VLLM', 'ChatGLMModel'),
            ('VLLM', 'CohereForCausalLM'),
            ('VLLM', 'DbrxForCausalLM'),
            ('VLLM', 'DeciLMForCausalLM'),
            ('VLLM', 'Phi3VForCausalLM'),
            ('VLLM', 'PaliGemmaForConditionalGeneration'),
            ('VLLM', 'LlavaNextForConditionalGeneration'),
            ('VLLM', 'LlavaForConditionalGeneration'),
            ('VLLM', 'FuyuForCausalLM'),
            ('VLLM', 'ChameleonForConditionalGeneration'),
            ('VLLM', 'XverseForCausalLM'),
            ('VLLM', 'Starcoder2ForCausalLM'),
            ('VLLM', 'StableLmForCausalLM'),
            ('VLLM', 'Qwen2MoeForCausalLM'),
            ('VLLM', 'Qwen2ForCausalLM'),
            ('VLLM', 'QWenLMHeadModel'),
            ('VLLM', 'PersimmonForCausalLM'),
            ('VLLM', 'Phi3SmallForCausalLM'),
            ('VLLM', 'Phi3ForCausalLM'),
            ('VLLM', 'PhiForCausalLM'),
            ('VLLM', 'OrionForCausalLM'),
            ('VLLM', 'OPTForCausalLM'),
            ('VLLM', 'OLMoForCausalLM'),
            ('VLLM', 'MPTForCausalLM'),
            ('VLLM', 'MixtralForCausalLM'),
            ('VLLM', 'MistralForCausalLM'),
            ('VLLM', 'MiniCPMForCausalLM'),
            ('VLLM', 'LlamaForCausalLM'),
            ('VLLM', 'JambaForCausalLM'),
            ('VLLM', 'JAISLMHeadModel'),
            ('VLLM', 'InternLM2ForCausalLM'),
            ('VLLM', 'InternLMForCausalLM'),
            ('VLLM', 'GPTNeoXForCausalLM'),
            ('VLLM', 'GPTJForCausalLM'),
            ('VLLM', 'GPTBigCodeForCausalLM'),
            ('VLLM', 'GPT2LMHeadModel'),
            ('VLLM', 'Gemma2ForCausalLM'),
            ('VLLM', 'GemmaForCausalLM'),
            ('VLLM', 'FalconForCausalLM'),
            ('VLLM', 'AquilaForCausalLM'),
            ('LLaMA-Factory', 'MistralForCausalLM'),
            ('LLaMA-Factory', 'MixtralForCausalLM'),
            ('LLaMA-Factory', 'OlmoForCausalLM'),
            ('LLaMA-Factory', 'PaliGemmaForConditionalGeneration'),
            ('LLaMA-Factory', 'PhiForCausalLM'),
            ('LLaMA-Factory', 'LlavaLlamaForCausalLM'),
            ('LLaMA-Factory', 'YuanForCausalLM'),
            ('LLaMA-Factory', 'BaiChuanForCausalLM'),
            ('LLaMA-Factory', 'BloomForCausalLM'),
            ('LLaMA-Factory', 'ChatGLMModel'),
            ('LLaMA-Factory', 'CohereForCausalLM'),
            ('LLaMA-Factory', 'DeepseekV2ForCausalLM'),
            ('LLaMA-Factory', 'FalconForCausalLM'),
            ('LLaMA-Factory', 'Gemma2ForCausalLM'),
            ('LLaMA-Factory', 'GemmaForCausalLM'),
            ('LLaMA-Factory', 'InternLM2ForCausalLM'),
            ('LLaMA-Factory', 'InternLM2ForRewardModel'),
            ('LLaMA-Factory', 'LlamaForCausalLM'),
            ('LLaMA-Factory', 'LlavaForConditionalGeneration'),
            ('LLaMA-Factory', 'LlavaNextForConditionalGeneration'),
            ('LLaMA-Factory', 'Phi3ForCausalLM'),
            ('LLaMA-Factory', 'Qwen2ForCausalLM'),
            ('LLaMA-Factory', 'QWenLMHeadModel'),
            ('LLaMA-Factory', 'Qwen2MoeForCausalLM'),
            ('LLaMA-Factory', 'Starcoder2ForCausalLM'),
            ('LLaMA-Factory', 'XverseForCausalLM'),
            ('TGI', 'GemmaForCausalLM'),
            ('TGI', 'Phi3ForCausalLM'),
            ('TGI', 'IdeficsForVisionText2Text'),
            ('TGI', 'GPTNeoXForCausalLM'),
            ('TGI', 'GPT2LMHeadModel'),
            ('TGI', 'MPTForCausalLM'),
            ('TGI', 'Starcoder2ForCausalLM'),
            ('TGI', 'FalconForCausalLM'),
            ('TGI', 'BaichuanForCausalLM'),
            ('TGI', 'PhiForCausalLM'),
            ('TGI', 'GPTBigCodeForCausalLM'),
            ('TGI', 'MixtralForCausalLM'),
            ('TGI', 'LlamaForCausalLM'),
            ('TGI', 'LlavaNextForConditionalGeneration'),
            ('TGI', 'Idefics2ForConditionalGeneration'),
            ('TGI', 'DeepseekV2ForCausalLM'),
            ('TGI', 'BloomForCausalLM'),
            ('TGI', 'GPT2LMHeadCustomModel'),
            ('TGI', 'T5ForConditionalGeneration'),
            ('TGI', 'OPTForCausalLM'),
            ('TGI', 'Qwen2ForCausalLM'),
            ('TGI', 'MistralForCausalLM'),
            ('TGI', 'DbrxForCausalLM'),
            ('TGI', 'CohereForCausalLM'),
            ('TGI', 'PaliGemmaForConditionalGeneration'),
            ('OpenCompass', 'DeciLMForCausalLM'),
            ('OpenCompass', 'ChatGLMModel'),
            ('OpenCompass', 'DbrxForCausalLM'),
            ('OpenCompass', 'AquilaForCausalLM'),
            ('OpenCompass', 'ArcticForCausalLM'),
            ('OpenCompass', 'BaiChuanForCausalLM'),
            ('OpenCompass', 'BloomForCausalLM'),
            ('OpenCompass', 'FalconForCausalLM'),
            ('OpenCompass', 'GemmaForCausalLM'),
            ('OpenCompass', 'Gemma2ForCausalLM'),
            ('OpenCompass', 'GPTNeoXForCausalLM'),
            ('OpenCompass', 'InternLMForCausalLM'),
            ('OpenCompass', 'InternLM2ForCausalLM'),
            ('OpenCompass', 'MiniCPMForCausalLM'),
            ('OpenCompass', 'MistralForCausalLM'),
            ('OpenCompass', 'MixtralForCausalLM'),
            ('OpenCompass', 'PhiForCausalLM'),
            ('OpenCompass', 'Phi3ForCausalLM'),
            ('OpenCompass', 'Phi3SmallForCausalLM'),
            ('OpenCompass', 'Qwen2ForCausalLM'),
            ('OpenCompass', 'Qwen2MoeForCausalLM'),
            ('OpenCompass', 'XverseForCausalLM'),
            ('OpenCompass', 'ChameleonForConditionalGeneration'),
            ('OpenCompass', 'LlavaNextForConditionalGeneration'),
            ('OpenCompass', 'Phi3VForCausalLM'),
            ('OpenCompass', 'PaliGemmaForConditionalGeneration'),
            ('OpenCompass', 'LlavaForConditionalGeneration'),
            ('OpenCompass', 'FuyuForCausalLM'),
            ('OpenCompass', 'Starcoder2ForCausalLM'),
            ('OpenCompass', 'StableLmForCausalLM'),
            ('OpenCompass', 'QWenLMHeadModel'),
            ('OpenCompass', 'PersimmonForCausalLM'),
            ('OpenCompass', 'OrionForCausalLM'),
            ('OpenCompass', 'OPTForCausalLM'),
            ('OpenCompass', 'OLMoForCausalLM'),
            ('OpenCompass', 'MPTForCausalLM'),
            ('OpenCompass', 'LlamaForCausalLM'),
            ('OpenCompass', 'JambaForCausalLM'),
            ('OpenCompass', 'JAISLMHeadModel'),
            ('OpenCompass', 'GPTJForCausalLM'),
            ('OpenCompass', 'GPTBigCodeForCausalLM'),
            ('OpenCompass', 'GPT2LMHeadModel'),
            ('OpenCompass', 'CohereForCausalLM'),
            ('SGLang', 'MiniCPM3ForCausalLM'),
            ('SGLang', 'XverseMoeForCausalLM'),
            ('SGLang', 'BaichuanForCausalLM'),
            ('SGLang', 'InternLM2ForRewardModel'),
            ('SGLang', 'DbrxForCausalLM'),
            ('SGLang', 'Qwen2VLForConditionalGeneration'),
            ('SGLang', 'Olmo2ForCausalLM'),
            ('SGLang', 'DeepseekV2ForCausalLM'),
            ('SGLang', 'DeepseekV3ForCausalLM'),
            ('SGLang', 'LlavaVidForCausalLM'),
            ('SGLang', 'LlamaForClassification'),
            ('SGLang', 'MistralForCausalLM'),
            ('SGLang', 'GPT2LMHeadModel'),
            ('SGLang', 'OlmoForCausalLM'),
            ('SGLang', 'MixtralForCausalLM'),
            ('SGLang', 'Qwen2MoeForCausalLM'),
            ('SGLang', 'YiVLForCausalLM'),
            ('SGLang', 'LlamaEmbeddingModel'),
            ('SGLang', 'MistralModel'),
            ('SGLang', 'Qwen2ForCausalLM'),
            ('SGLang', 'LlamaForCausalLMEagle'),
            ('SGLang', 'GraniteForCausalLM'),
            ('SGLang', 'ExaoneForCausalLM'),
            ('SGLang', 'CohereForCausalLM'),
            ('SGLang', 'GPTBigCodeForCausalLM'),
            ('SGLang', 'GemmaForCausalLM'),
            ('SGLang', 'Gemma2ForSequenceClassification'),
            ('SGLang', 'QuantMixtralForCausalLM'),
            ('SGLang', 'TorchNativePhi3ForCausalLM'),
            ('SGLang', 'TorchNativeLlamaForCausalLM'),
            ('SGLang', 'OlmoeForCausalLM'),
            ('SGLang', 'ChatGLMModel'),
            ('SGLang', 'Grok1ForCausalLM'),
            ('SGLang', 'Grok1ModelForCausalLM'),
            ('SGLang', 'InternLM2ForCausalLM'),
            ('SGLang', 'Phi3SmallForCausalLM'),
            ('SGLang', 'StableLmForCausalLM'),
            ('SGLang', 'MiniCPMForCausalLM'),
            ('SGLang', 'LlavaLlamaForCausalLM'),
            ('SGLang', 'LlavaQwenForCausalLM'),
            ('SGLang', 'LlavaMistralForCausalLM'),
            ('SGLang', 'MllamaForConditionalGeneration'),
            ('SGLang', 'LlamaForCausalLM'),
            ('SGLang', 'Phi3ForCausalLM'),
            ('SGLang', 'Gemma2ForCausalLM'),
            ('SGLang', 'XverseForCausalLM'),
            ('SGLang', 'QWenLMHeadModel'),
            ('SGLang', 'DeepseekForCausalLM'),
            ('HF-Inference-Toolkit', 'StableDiffusionPipeline'),
            ('HF-Inference-Toolkit', 'LatentConsistencyModelPipeline'),
            ('HF-Inference-Toolkit', 'StableDiffusionXLPipeline'),
            ('HF-Inference-Toolkit', 'StableDiffusion3Pipeline'),
            ('HF-Inference-Toolkit', 'FluxPipeline')
    ) AS data(frame_name, architecture_name)
)
INSERT INTO public.runtime_architectures (runtime_framework_id, architecture_name)
    SELECT r.id, f.architecture_name
    FROM framework_architecture f, public.runtime_frameworks r
    WHERE f.frame_name = r.frame_name
ON CONFLICT (runtime_framework_id, architecture_name)
    DO NOTHING;