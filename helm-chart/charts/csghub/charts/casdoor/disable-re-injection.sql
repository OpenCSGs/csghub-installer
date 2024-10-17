-- This code is used to solve the problem that \
-- casdoor will constantly reinitialize data \
-- every time the pod is restarted when the init_data.json file exists.
-- ref: https://github.com/casdoor/casdoor/issues/3292

CREATE OR REPLACE FUNCTION restore_root_id()
    RETURNS TRIGGER AS $$
BEGIN
    -- Check whether the modified record is name='root'
    IF NEW.name = 'root' THEN
        -- Change id back to its previous value OLD.id
        NEW.id := OLD.id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_restore_root_id
    BEFORE UPDATE ON public.user
    FOR EACH ROW
EXECUTE FUNCTION restore_root_id();