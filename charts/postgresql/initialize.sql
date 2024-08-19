-- Seed resource table
\c csghub_server_production

-- Insert first record
INSERT INTO space_resources (name, resources, cost_per_hour, cluster_id)
VALUES
    ('CPU basic · 1 vCPU · 1 GB', '{ "cpu": { "type": "Intel", "num": "1" }, "memory": "1Gi" }', 0, (SELECT cluster_id FROM cluster_infos LIMIT 1))
ON CONFLICT (name)
    DO UPDATE SET
      resources = EXCLUDED.resources,
      cost_per_hour = EXCLUDED.cost_per_hour,
      cluster_id = EXCLUDED.cluster_id;

-- Insert second record
INSERT INTO space_resources (name, resources, cost_per_hour, cluster_id)
VALUES
    ('NVIDIA A10G · 4 vCPU · 16 GB', '{"gpu": { "type": "A10", "num": "1", "resource_name": "nvidia.com/gpu", "labels": { "aliyun.accelerator/nvidia_name": "NVIDIA-A10" } }, "cpu": { "type": "Intel", "num": "4" },  "memory": "16Gi" }', 0, (SELECT cluster_id FROM cluster_infos LIMIT 1))
ON CONFLICT (name)
    DO UPDATE SET
      resources = EXCLUDED.resources,
      cost_per_hour = EXCLUDED.cost_per_hour,
      cluster_id = EXCLUDED.cluster_id;