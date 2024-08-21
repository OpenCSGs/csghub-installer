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
-- Seed Data for Name: runtime_architectures; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.runtime_architectures(id, runtime_framework_id, architecture_name) VALUES (1, 3, 'AquilaForCausalLM');
INSERT INTO public.runtime_architectures(id, runtime_framework_id, architecture_name) VALUES (2, 3, 'ArcticForCausalLM');
INSERT INTO public.runtime_architectures(id, runtime_framework_id, architecture_name) VALUES (3, 3, 'BaiChuanForCausalLM');
INSERT INTO public.runtime_architectures(id, runtime_framework_id, architecture_name) VALUES (4, 3, 'BloomForCausalLM');
INSERT INTO public.runtime_architectures(id, runtime_framework_id, architecture_name) VALUES (5, 3, 'ChatGLMModel');
INSERT INTO public.runtime_architectures(id, runtime_framework_id, architecture_name) VALUES (6, 3, 'CohereForCausalLM');
INSERT INTO public.runtime_architectures(id, runtime_framework_id, architecture_name) VALUES (7, 3, 'DbrxForCausalLM');
INSERT INTO public.runtime_architectures(id, runtime_framework_id, architecture_name) VALUES (8, 3, 'DeciLMForCausalLM');
INSERT INTO public.runtime_architectures(id, runtime_framework_id, architecture_name) VALUES (9, 3, 'FalconForCausalLM');
INSERT INTO public.runtime_architectures(id, runtime_framework_id, architecture_name) VALUES (10, 3, 'GemmaForCausalLM');
INSERT INTO public.runtime_architectures(id, runtime_framework_id, architecture_name) VALUES (11, 3, 'Gemma2ForCausalLM');
INSERT INTO public.runtime_architectures(id, runtime_framework_id, architecture_name) VALUES (12, 3, 'GPT2LMHeadModel');
INSERT INTO public.runtime_architectures(id, runtime_framework_id, architecture_name) VALUES (13, 3, 'GPTBigCodeForCausalLM');
INSERT INTO public.runtime_architectures(id, runtime_framework_id, architecture_name) VALUES (14, 3, 'GPTJForCausalLM');
INSERT INTO public.runtime_architectures(id, runtime_framework_id, architecture_name) VALUES (15, 3, 'GPTNeoXForCausalLM');
INSERT INTO public.runtime_architectures(id, runtime_framework_id, architecture_name) VALUES (16, 3, 'InternLMForCausalLM');
INSERT INTO public.runtime_architectures(id, runtime_framework_id, architecture_name) VALUES (17, 3, 'InternLM2ForCausalLM');
INSERT INTO public.runtime_architectures(id, runtime_framework_id, architecture_name) VALUES (18, 3, 'JAISLMHeadModel');
INSERT INTO public.runtime_architectures(id, runtime_framework_id, architecture_name) VALUES (19, 3, 'JambaForCausalLM');
INSERT INTO public.runtime_architectures(id, runtime_framework_id, architecture_name) VALUES (20, 3, 'LlamaForCausalLM');
INSERT INTO public.runtime_architectures(id, runtime_framework_id, architecture_name) VALUES (21, 3, 'MiniCPMForCausalLM');
INSERT INTO public.runtime_architectures(id, runtime_framework_id, architecture_name) VALUES (22, 3, 'MistralForCausalLM');
INSERT INTO public.runtime_architectures(id, runtime_framework_id, architecture_name) VALUES (23, 3, 'MixtralForCausalLM');
INSERT INTO public.runtime_architectures(id, runtime_framework_id, architecture_name) VALUES (24, 3, 'MPTForCausalLM');
INSERT INTO public.runtime_architectures(id, runtime_framework_id, architecture_name) VALUES (25, 3, 'OLMoForCausalLM');
INSERT INTO public.runtime_architectures(id, runtime_framework_id, architecture_name) VALUES (26, 3, 'OPTForCausalLM');
INSERT INTO public.runtime_architectures(id, runtime_framework_id, architecture_name) VALUES (27, 3, 'OrionForCausalLM');
INSERT INTO public.runtime_architectures(id, runtime_framework_id, architecture_name) VALUES (28, 3, 'PhiForCausalLM');
INSERT INTO public.runtime_architectures(id, runtime_framework_id, architecture_name) VALUES (29, 3, 'Phi3ForCausalLM');
INSERT INTO public.runtime_architectures(id, runtime_framework_id, architecture_name) VALUES (30, 3, 'Phi3SmallForCausalLM');
INSERT INTO public.runtime_architectures(id, runtime_framework_id, architecture_name) VALUES (31, 3, 'PersimmonForCausalLM');
INSERT INTO public.runtime_architectures(id, runtime_framework_id, architecture_name) VALUES (32, 3, 'QWenLMHeadModel');
INSERT INTO public.runtime_architectures(id, runtime_framework_id, architecture_name) VALUES (33, 3, 'Qwen2ForCausalLM');
INSERT INTO public.runtime_architectures(id, runtime_framework_id, architecture_name) VALUES (34, 3, 'Qwen2MoeForCausalLM');
INSERT INTO public.runtime_architectures(id, runtime_framework_id, architecture_name) VALUES (35, 3, 'StableLmForCausalLM');
INSERT INTO public.runtime_architectures(id, runtime_framework_id, architecture_name) VALUES (36, 3, 'Starcoder2ForCausalLM');
INSERT INTO public.runtime_architectures(id, runtime_framework_id, architecture_name) VALUES (37, 3, 'XverseForCausalLM');
INSERT INTO public.runtime_architectures(id, runtime_framework_id, architecture_name) VALUES (38, 3, 'ChameleonForConditionalGeneration');
INSERT INTO public.runtime_architectures(id, runtime_framework_id, architecture_name) VALUES (39, 3, 'FuyuForCausalLM');
INSERT INTO public.runtime_architectures(id, runtime_framework_id, architecture_name) VALUES (40, 3, 'LlavaForConditionalGeneration');
INSERT INTO public.runtime_architectures(id, runtime_framework_id, architecture_name) VALUES (41, 3, 'LlavaNextForConditionalGeneration');
INSERT INTO public.runtime_architectures(id, runtime_framework_id, architecture_name) VALUES (42, 3, 'PaliGemmaForConditionalGeneration');
INSERT INTO public.runtime_architectures(id, runtime_framework_id, architecture_name) VALUES (43, 3, 'Phi3VForCausalLM');
INSERT INTO public.runtime_architectures(id, runtime_framework_id, architecture_name) VALUES (44, 4, 'BaiChuanForCausalLM');
INSERT INTO public.runtime_architectures(id, runtime_framework_id, architecture_name) VALUES (45, 4, 'BloomForCausalLM');
INSERT INTO public.runtime_architectures(id, runtime_framework_id, architecture_name) VALUES (46, 4, 'ChatGLMModel');
INSERT INTO public.runtime_architectures(id, runtime_framework_id, architecture_name) VALUES (47, 4, 'CohereForCausalLM');
INSERT INTO public.runtime_architectures(id, runtime_framework_id, architecture_name) VALUES (48, 4, 'DeepseekV2ForCausalLM');
INSERT INTO public.runtime_architectures(id, runtime_framework_id, architecture_name) VALUES (49, 4, 'FalconForCausalLM');
INSERT INTO public.runtime_architectures(id, runtime_framework_id, architecture_name) VALUES (50, 4, 'Gemma2ForCausalLM');
INSERT INTO public.runtime_architectures(id, runtime_framework_id, architecture_name) VALUES (51, 4, 'GemmaForCausalLM');
INSERT INTO public.runtime_architectures(id, runtime_framework_id, architecture_name) VALUES (53, 4, 'InternLM2ForCausalLM');
INSERT INTO public.runtime_architectures(id, runtime_framework_id, architecture_name) VALUES (54, 4, 'InternLM2ForRewardModel');
INSERT INTO public.runtime_architectures(id, runtime_framework_id, architecture_name) VALUES (55, 4, 'LlamaForCausalLM');
INSERT INTO public.runtime_architectures(id, runtime_framework_id, architecture_name) VALUES (56, 4, 'LlavaForConditionalGeneration');
INSERT INTO public.runtime_architectures(id, runtime_framework_id, architecture_name) VALUES (57, 4, 'LlavaNextForConditionalGeneration');
INSERT INTO public.runtime_architectures(id, runtime_framework_id, architecture_name) VALUES (58, 4, 'MistralForCausalLM');
INSERT INTO public.runtime_architectures(id, runtime_framework_id, architecture_name) VALUES (59, 4, 'MixtralForCausalLM');
INSERT INTO public.runtime_architectures(id, runtime_framework_id, architecture_name) VALUES (60, 4, 'OlmoForCausalLM');
INSERT INTO public.runtime_architectures(id, runtime_framework_id, architecture_name) VALUES (61, 4, 'PaliGemmaForConditionalGeneration');
INSERT INTO public.runtime_architectures(id, runtime_framework_id, architecture_name) VALUES (62, 4, 'PhiForCausalLM');
INSERT INTO public.runtime_architectures(id, runtime_framework_id, architecture_name) VALUES (63, 4, 'Phi3ForCausalLM');
INSERT INTO public.runtime_architectures(id, runtime_framework_id, architecture_name) VALUES (64, 4, 'Qwen2ForCausalLM');
INSERT INTO public.runtime_architectures(id, runtime_framework_id, architecture_name) VALUES (65, 4, 'QWenLMHeadModel');
INSERT INTO public.runtime_architectures(id, runtime_framework_id, architecture_name) VALUES (66, 4, 'Qwen2MoeForCausalLM');
INSERT INTO public.runtime_architectures(id, runtime_framework_id, architecture_name) VALUES (67, 4, 'Starcoder2ForCausalLM');
INSERT INTO public.runtime_architectures(id, runtime_framework_id, architecture_name) VALUES (68, 4, 'XverseForCausalLM');
INSERT INTO public.runtime_architectures(id, runtime_framework_id, architecture_name) VALUES (69, 4, 'LlavaLlamaForCausalLM');
INSERT INTO public.runtime_architectures(id, runtime_framework_id, architecture_name) VALUES (70, 4, 'YuanForCausalLM');
INSERT INTO public.runtime_architectures(id, runtime_framework_id, architecture_name) VALUES (71, 5, 'DeepseekV2ForCausalLM');
INSERT INTO public.runtime_architectures(id, runtime_framework_id, architecture_name) VALUES (72, 5, 'Idefics2ForConditionalGeneration');
INSERT INTO public.runtime_architectures(id, runtime_framework_id, architecture_name) VALUES (73, 5, 'LlavaNextForConditionalGeneration');
INSERT INTO public.runtime_architectures(id, runtime_framework_id, architecture_name) VALUES (74, 5, 'LlamaForCausalLM');
INSERT INTO public.runtime_architectures(id, runtime_framework_id, architecture_name) VALUES (75, 5, 'Phi3ForCausalLM');
INSERT INTO public.runtime_architectures(id, runtime_framework_id, architecture_name) VALUES (76, 5, 'GemmaForCausalLM');
INSERT INTO public.runtime_architectures(id, runtime_framework_id, architecture_name) VALUES (77, 5, 'PaliGemmaForConditionalGeneration');
INSERT INTO public.runtime_architectures(id, runtime_framework_id, architecture_name) VALUES (78, 5, 'CohereForCausalLM');
INSERT INTO public.runtime_architectures(id, runtime_framework_id, architecture_name) VALUES (79, 5, 'DbrxForCausalLM');
INSERT INTO public.runtime_architectures(id, runtime_framework_id, architecture_name) VALUES (80, 5, 'MistralForCausalLM');
INSERT INTO public.runtime_architectures(id, runtime_framework_id, architecture_name) VALUES (81, 5, 'MixtralForCausalLM');
INSERT INTO public.runtime_architectures(id, runtime_framework_id, architecture_name) VALUES (82, 5, 'GPTBigCodeForCausalLM');
INSERT INTO public.runtime_architectures(id, runtime_framework_id, architecture_name) VALUES (83, 5, 'PhiForCausalLM');
INSERT INTO public.runtime_architectures(id, runtime_framework_id, architecture_name) VALUES (84, 5, 'BaichuanForCausalLM');
INSERT INTO public.runtime_architectures(id, runtime_framework_id, architecture_name) VALUES (85, 5, 'FalconForCausalLM');
INSERT INTO public.runtime_architectures(id, runtime_framework_id, architecture_name) VALUES (86, 5, 'Starcoder2ForCausalLM');
INSERT INTO public.runtime_architectures(id, runtime_framework_id, architecture_name) VALUES (87, 5, 'Qwen2ForCausalLM');
INSERT INTO public.runtime_architectures(id, runtime_framework_id, architecture_name) VALUES (88, 5, 'OPTForCausalLM');
INSERT INTO public.runtime_architectures(id, runtime_framework_id, architecture_name) VALUES (89, 5, 'T5ForConditionalGeneration');
INSERT INTO public.runtime_architectures(id, runtime_framework_id, architecture_name) VALUES (90, 5, 'GPT2LMHeadCustomModel');
INSERT INTO public.runtime_architectures(id, runtime_framework_id, architecture_name) VALUES (91, 5, 'BloomForCausalLM');
INSERT INTO public.runtime_architectures(id, runtime_framework_id, architecture_name) VALUES (92, 5, 'MPTForCausalLM');
INSERT INTO public.runtime_architectures(id, runtime_framework_id, architecture_name) VALUES (93, 5, 'GPT2LMHeadModel');
INSERT INTO public.runtime_architectures(id, runtime_framework_id, architecture_name) VALUES (94, 5, 'GPTNeoXForCausalLM');
INSERT INTO public.runtime_architectures(id, runtime_framework_id, architecture_name) VALUES (95, 5, 'IdeficsForVisionText2Text');
INSERT INTO public.runtime_architectures(id, runtime_framework_id, architecture_name) VALUES (96, 6, 'LlamaForCausalLM');

--
-- Seed Data for Name: runtime_frameworks; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.runtime_frameworks(id, frame_name, frame_version, frame_image, frame_cpu_image, frame_npu_image, enabled, container_port, type) VALUES (1, 'VLLM', '2.7', 'vllm-local:2.7', 'vllm-cpu:2.3', '', 1, 8000, 1);
INSERT INTO public.runtime_frameworks(id, frame_name, frame_version, frame_image, frame_cpu_image, frame_npu_image, enabled, container_port, type) VALUES (2, 'LLaMA-Factory', '1.11', 'llama-factory:1.17-cuda12.1-devel-ubuntu22.04-py310-torch2.1.2', '', 'llama-factory:1.9-8.0.rc2.alpha003-910b-ubuntu22.04-py3.8', 1, 8000, 2);
INSERT INTO public.runtime_frameworks(id, frame_name, frame_version, frame_image, frame_cpu_image, frame_npu_image, enabled, container_port, type) VALUES (3, 'TGI', '2.1', 'tgi:2.1', '', '', 1, 8000, 1);
INSERT INTO public.runtime_frameworks(id, frame_name, frame_version, frame_image, frame_cpu_image, frame_npu_image, enabled, container_port, type) VALUES (4, 'FastChat', '1.2', '', '', 'fastchat:1.2', 1, 8000, 1);

--
-- Name: runtime_architectures_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.runtime_architectures_id_seq', 96, true);


--
-- Name: runtime_frameworks_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.runtime_frameworks_id_seq', 4, true);

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