-- A write made by a function on the segments must be rolled back together
-- with the statement that called it.
CREATE TABLE seg_write_log (tag text) DISTRIBUTED REPLICATED;
CREATE FUNCTION seg_write(t text) RETURNS SETOF int LANGUAGE plpgsql EXECUTE ON ALL SEGMENTS SET allow_segment_DML TO on AS $$ BEGIN INSERT INTO seg_write_log VALUES (t); RETURN NEXT 1; END $$;

DO $$ BEGIN PERFORM * FROM seg_write('implicit'); RAISE EXCEPTION 'fail after seg_write'; END $$;

BEGIN;
DO $$ BEGIN PERFORM * FROM seg_write('explicit'); END $$;
ROLLBACK;

0U: SELECT tag FROM seg_write_log;
1U: SELECT tag FROM seg_write_log;

DROP FUNCTION seg_write(text);
DROP TABLE seg_write_log;
