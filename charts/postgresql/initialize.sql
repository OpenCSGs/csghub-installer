--
-- PostgreSQL database dump
--

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

-- Connect to your database server
\c csghub_server_production

--
-- Seed Data for Name: space_resources; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO space_resources (name, resources, cost_per_hour, cluster_id)
VALUES
    ('CPU basic · 1 vCPU · 1 GB', '{ "cpu": { "type": "Intel", "num": "1" }, "memory": "1Gi" }', 0, (SELECT cluster_id FROM cluster_infos LIMIT 1))
ON CONFLICT (name)
    DO UPDATE SET
      resources = EXCLUDED.resources,
      cost_per_hour = EXCLUDED.cost_per_hour,
      cluster_id = EXCLUDED.cluster_id;
INSERT INTO space_resources (name, resources, cost_per_hour, cluster_id)
VALUES
    ('NVIDIA A10G · 4 vCPU · 16 GB', '{"gpu": { "type": "A10", "num": "1", "resource_name": "nvidia.com/gpu", "labels": { "aliyun.accelerator/nvidia_name": "NVIDIA-A10" } }, "cpu": { "type": "Intel", "num": "4" },  "memory": "16Gi" }', 0, (SELECT cluster_id FROM cluster_infos LIMIT 1))
ON CONFLICT (name)
    DO UPDATE SET
      resources = EXCLUDED.resources,
      cost_per_hour = EXCLUDED.cost_per_hour,
      cluster_id = EXCLUDED.cluster_id;

--
-- Seed Data for Name: runtime_architectures; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.runtime_architectures VALUES (1, 3, 'AquilaForCausalLM');
INSERT INTO public.runtime_architectures VALUES (2, 3, 'ArcticForCausalLM');
INSERT INTO public.runtime_architectures VALUES (3, 3, 'BaiChuanForCausalLM');
INSERT INTO public.runtime_architectures VALUES (4, 3, 'BloomForCausalLM');
INSERT INTO public.runtime_architectures VALUES (5, 3, 'ChatGLMModel');
INSERT INTO public.runtime_architectures VALUES (6, 3, 'CohereForCausalLM');
INSERT INTO public.runtime_architectures VALUES (7, 3, 'DbrxForCausalLM');
INSERT INTO public.runtime_architectures VALUES (8, 3, 'DeciLMForCausalLM');
INSERT INTO public.runtime_architectures VALUES (9, 3, 'FalconForCausalLM');
INSERT INTO public.runtime_architectures VALUES (10, 3, 'GemmaForCausalLM');
INSERT INTO public.runtime_architectures VALUES (11, 3, 'Gemma2ForCausalLM');
INSERT INTO public.runtime_architectures VALUES (12, 3, 'GPT2LMHeadModel');
INSERT INTO public.runtime_architectures VALUES (13, 3, 'GPTBigCodeForCausalLM');
INSERT INTO public.runtime_architectures VALUES (14, 3, 'GPTJForCausalLM');
INSERT INTO public.runtime_architectures VALUES (15, 3, 'GPTNeoXForCausalLM');
INSERT INTO public.runtime_architectures VALUES (16, 3, 'InternLMForCausalLM');
INSERT INTO public.runtime_architectures VALUES (17, 3, 'InternLM2ForCausalLM');
INSERT INTO public.runtime_architectures VALUES (18, 3, 'JAISLMHeadModel');
INSERT INTO public.runtime_architectures VALUES (19, 3, 'JambaForCausalLM');
INSERT INTO public.runtime_architectures VALUES (20, 3, 'LlamaForCausalLM');
INSERT INTO public.runtime_architectures VALUES (21, 3, 'MiniCPMForCausalLM');
INSERT INTO public.runtime_architectures VALUES (22, 3, 'MistralForCausalLM');
INSERT INTO public.runtime_architectures VALUES (23, 3, 'MixtralForCausalLM');
INSERT INTO public.runtime_architectures VALUES (24, 3, 'MPTForCausalLM');
INSERT INTO public.runtime_architectures VALUES (25, 3, 'OLMoForCausalLM');
INSERT INTO public.runtime_architectures VALUES (26, 3, 'OPTForCausalLM');
INSERT INTO public.runtime_architectures VALUES (27, 3, 'OrionForCausalLM');
INSERT INTO public.runtime_architectures VALUES (28, 3, 'PhiForCausalLM');
INSERT INTO public.runtime_architectures VALUES (29, 3, 'Phi3ForCausalLM');
INSERT INTO public.runtime_architectures VALUES (30, 3, 'Phi3SmallForCausalLM');
INSERT INTO public.runtime_architectures VALUES (31, 3, 'PersimmonForCausalLM');
INSERT INTO public.runtime_architectures VALUES (32, 3, 'QWenLMHeadModel');
INSERT INTO public.runtime_architectures VALUES (33, 3, 'Qwen2ForCausalLM');
INSERT INTO public.runtime_architectures VALUES (34, 3, 'Qwen2MoeForCausalLM');
INSERT INTO public.runtime_architectures VALUES (35, 3, 'StableLmForCausalLM');
INSERT INTO public.runtime_architectures VALUES (36, 3, 'Starcoder2ForCausalLM');
INSERT INTO public.runtime_architectures VALUES (37, 3, 'XverseForCausalLM');
INSERT INTO public.runtime_architectures VALUES (38, 3, 'ChameleonForConditionalGeneration');
INSERT INTO public.runtime_architectures VALUES (39, 3, 'FuyuForCausalLM');
INSERT INTO public.runtime_architectures VALUES (40, 3, 'LlavaForConditionalGeneration');
INSERT INTO public.runtime_architectures VALUES (41, 3, 'LlavaNextForConditionalGeneration');
INSERT INTO public.runtime_architectures VALUES (42, 3, 'PaliGemmaForConditionalGeneration');
INSERT INTO public.runtime_architectures VALUES (43, 3, 'Phi3VForCausalLM');
INSERT INTO public.runtime_architectures VALUES (44, 4, 'BaiChuanForCausalLM');
INSERT INTO public.runtime_architectures VALUES (45, 4, 'BloomForCausalLM');
INSERT INTO public.runtime_architectures VALUES (46, 4, 'ChatGLMModel');
INSERT INTO public.runtime_architectures VALUES (47, 4, 'CohereForCausalLM');
INSERT INTO public.runtime_architectures VALUES (48, 4, 'DeepseekV2ForCausalLM');
INSERT INTO public.runtime_architectures VALUES (49, 4, 'FalconForCausalLM');
INSERT INTO public.runtime_architectures VALUES (50, 4, 'Gemma2ForCausalLM');
INSERT INTO public.runtime_architectures VALUES (51, 4, 'GemmaForCausalLM');
INSERT INTO public.runtime_architectures VALUES (53, 4, 'InternLM2ForCausalLM');
INSERT INTO public.runtime_architectures VALUES (54, 4, 'InternLM2ForRewardModel');
INSERT INTO public.runtime_architectures VALUES (55, 4, 'LlamaForCausalLM');
INSERT INTO public.runtime_architectures VALUES (56, 4, 'LlavaForConditionalGeneration');
INSERT INTO public.runtime_architectures VALUES (57, 4, 'LlavaNextForConditionalGeneration');
INSERT INTO public.runtime_architectures VALUES (58, 4, 'MistralForCausalLM');
INSERT INTO public.runtime_architectures VALUES (59, 4, 'MixtralForCausalLM');
INSERT INTO public.runtime_architectures VALUES (60, 4, 'OlmoForCausalLM');
INSERT INTO public.runtime_architectures VALUES (61, 4, 'PaliGemmaForConditionalGeneration');
INSERT INTO public.runtime_architectures VALUES (62, 4, 'PhiForCausalLM');
INSERT INTO public.runtime_architectures VALUES (63, 4, 'Phi3ForCausalLM');
INSERT INTO public.runtime_architectures VALUES (64, 4, 'Qwen2ForCausalLM');
INSERT INTO public.runtime_architectures VALUES (65, 4, 'QWenLMHeadModel');
INSERT INTO public.runtime_architectures VALUES (66, 4, 'Qwen2MoeForCausalLM');
INSERT INTO public.runtime_architectures VALUES (67, 4, 'Starcoder2ForCausalLM');
INSERT INTO public.runtime_architectures VALUES (68, 4, 'XverseForCausalLM');
INSERT INTO public.runtime_architectures VALUES (69, 4, 'LlavaLlamaForCausalLM');
INSERT INTO public.runtime_architectures VALUES (70, 4, 'YuanForCausalLM');
INSERT INTO public.runtime_architectures VALUES (71, 5, 'DeepseekV2ForCausalLM');
INSERT INTO public.runtime_architectures VALUES (72, 5, 'Idefics2ForConditionalGeneration');
INSERT INTO public.runtime_architectures VALUES (73, 5, 'LlavaNextForConditionalGeneration');
INSERT INTO public.runtime_architectures VALUES (74, 5, 'LlamaForCausalLM');
INSERT INTO public.runtime_architectures VALUES (75, 5, 'Phi3ForCausalLM');
INSERT INTO public.runtime_architectures VALUES (76, 5, 'GemmaForCausalLM');
INSERT INTO public.runtime_architectures VALUES (77, 5, 'PaliGemmaForConditionalGeneration');
INSERT INTO public.runtime_architectures VALUES (78, 5, 'CohereForCausalLM');
INSERT INTO public.runtime_architectures VALUES (79, 5, 'DbrxForCausalLM');
INSERT INTO public.runtime_architectures VALUES (80, 5, 'MistralForCausalLM');
INSERT INTO public.runtime_architectures VALUES (81, 5, 'MixtralForCausalLM');
INSERT INTO public.runtime_architectures VALUES (82, 5, 'GPTBigCodeForCausalLM');
INSERT INTO public.runtime_architectures VALUES (83, 5, 'PhiForCausalLM');
INSERT INTO public.runtime_architectures VALUES (84, 5, 'BaichuanForCausalLM');
INSERT INTO public.runtime_architectures VALUES (85, 5, 'FalconForCausalLM');
INSERT INTO public.runtime_architectures VALUES (86, 5, 'Starcoder2ForCausalLM');
INSERT INTO public.runtime_architectures VALUES (87, 5, 'Qwen2ForCausalLM');
INSERT INTO public.runtime_architectures VALUES (88, 5, 'OPTForCausalLM');
INSERT INTO public.runtime_architectures VALUES (89, 5, 'T5ForConditionalGeneration');
INSERT INTO public.runtime_architectures VALUES (90, 5, 'GPT2LMHeadCustomModel');
INSERT INTO public.runtime_architectures VALUES (91, 5, 'BloomForCausalLM');
INSERT INTO public.runtime_architectures VALUES (92, 5, 'MPTForCausalLM');
INSERT INTO public.runtime_architectures VALUES (93, 5, 'GPT2LMHeadModel');
INSERT INTO public.runtime_architectures VALUES (94, 5, 'GPTNeoXForCausalLM');
INSERT INTO public.runtime_architectures VALUES (95, 5, 'IdeficsForVisionText2Text');
INSERT INTO public.runtime_architectures VALUES (96, 6, 'LlamaForCausalLM');

--
-- Seed Data for Name: runtime_frameworks; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.runtime_frameworks VALUES (1, 'VLLM', '2.7', 'vllm-local:2.7', '', 'vllm-cpu:2.3', 1, 8000, 1, '2024-05-20 13:40:11.817976+00', '2024-07-11 04:50:37.622677+00');
INSERT INTO public.runtime_frameworks VALUES (2, 'LLaMA-Factory', '1.11', 'llama-factory:1.17-cuda12.1-devel-ubuntu22.04-py310-torch2.1.2', 'llama-factory:1.9-8.0.rc2.alpha003-910b-ubuntu22.04-py3.8', '', 1, 8000, 2, '2024-06-12 06:57:32.820586+00', '2024-06-18 14:25:42.087066+00');
INSERT INTO public.runtime_frameworks VALUES (3, 'TGI', '2.1', 'tgi:2.1', '', '', 1, 8000, 1, '2024-07-09 01:14:20.018472+00', '2024-07-11 04:51:31.710133+00');
INSERT INTO public.runtime_frameworks VALUES (4, 'FastChat', '1.2', '', 'fastchat:1.2', '', 1, 8000, 1, '2024-08-11 07:58:17.101281+00', '2024-08-11 07:58:17.101281+00');

--
-- Name: runtime_architectures_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.runtime_architectures_id_seq', 96, true);


--
-- Name: runtime_frameworks_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.runtime_frameworks_id_seq', 4, true);


--
-- PostgreSQL database dump complete
--