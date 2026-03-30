
CREATE TABLE table_to_delete AS
SELECT 'veeeeeeery_long_string' || x AS col
FROM generate_series(1,(10^7)::int) x;

   SELECT *, pg_size_pretty(total_bytes) AS total,
                                    pg_size_pretty(index_bytes) AS INDEX,
                                    pg_size_pretty(toast_bytes) AS toast,
                                    pg_size_pretty(table_bytes) AS TABLE
               FROM ( SELECT *, total_bytes-index_bytes-COALESCE(toast_bytes,0) AS table_bytes
                               FROM (SELECT c.oid,nspname AS table_schema,
                                                               relname AS TABLE_NAME,
                                                              c.reltuples AS row_estimate,
                                                              pg_total_relation_size(c.oid) AS total_bytes,
                                                              pg_indexes_size(c.oid) AS index_bytes,
                                                              pg_total_relation_size(reltoastrelid) AS toast_bytes
                                              FROM pg_class c
                                              LEFT JOIN pg_namespace n ON n.oid = c.relnamespace
                                              WHERE relkind = 'r'
                                              ) a
                                    ) a
               WHERE table_name LIKE '%table_to_delete%';


--table_to_delete takes up 575 MB, 0 bytes index, 8192 bytes toast

DELETE FROM table_to_delete
WHERE REPLACE(col, 'veeeeeeery_long_string','')::int % 3 = 0;

--DELETE took 19 seconds, removed 3,333,333 rows (so 1/3 of 10 million)

-
SELECT *, pg_size_pretty(total_bytes) AS total,
pg_size_pretty(index_bytes) AS INDEX,
pg_size_pretty(toast_bytes) AS toast,
pg_size_pretty(table_bytes) AS TABLE
FROM (SELECT *, total_bytes-index_bytes-COALESCE(toast_bytes,0) AS table_bytes
FROM (SELECT c.oid, nspname AS table_schema, relname AS TABLE_NAME,
c.reltuples AS row_estimate,
pg_total_relation_size(c.oid) AS total_bytes,
pg_indexes_size(c.oid) AS index_bytes,
pg_total_relation_size(reltoastrelid) AS toast_bytes
FROM pg_class c
LEFT JOIN pg_namespace n ON n.oid = c.relnamespace
WHERE relkind = 'r') a) a
WHERE table_name LIKE '%table_to_delete%';

--after DELETE the table still takes 575 MB even though we removed 1/3 of rows
--this is because postgresql doesnt actually free up disk space after DELETE, it just marks rows as no longer existant


VACUUM FULL VERBOSE table_to_delete;

--VACUUM FULL took about 9 seconds (8.9 to be exact)

SELECT *, pg_size_pretty(total_bytes) AS total,
pg_size_pretty(index_bytes) AS INDEX,
pg_size_pretty(toast_bytes) AS toast,
pg_size_pretty(table_bytes) AS TABLE
FROM (SELECT *, total_bytes-index_bytes-COALESCE(toast_bytes,0) AS table_bytes
FROM (SELECT c.oid, nspname AS table_schema, relname AS TABLE_NAME,
c.reltuples AS row_estimate,
pg_total_relation_size(c.oid) AS total_bytes,
pg_indexes_size(c.oid) AS index_bytes,
pg_total_relation_size(reltoastrelid) AS toast_bytes
FROM pg_class c
LEFT JOIN pg_namespace n ON n.oid = c.relnamespace
WHERE relkind = 'r') a) a
WHERE table_name LIKE '%table_to_delete%';

--after VACUUM FULL the table went from 575 MB to 383 MB
--so DELETE alone doesnt free up space, you need VACUUM FULL 

DROP TABLE table_to_delete;

CREATE TABLE table_to_delete AS
SELECT 'veeeeeeery_long_string' || x AS col
FROM generate_series(1,(10^7)::int) x;

TRUNCATE table_to_delete;

--this took 1.112 seconds

SELECT *, pg_size_pretty(total_bytes) AS total,
pg_size_pretty(index_bytes) AS INDEX,
pg_size_pretty(toast_bytes) AS toast,
pg_size_pretty(table_bytes) AS TABLE
FROM (SELECT *, total_bytes-index_bytes-COALESCE(toast_bytes,0) AS table_bytes
FROM (SELECT c.oid, nspname AS table_schema, relname AS TABLE_NAME,
c.reltuples AS row_estimate,
pg_total_relation_size(c.oid) AS total_bytes,
pg_indexes_size(c.oid) AS index_bytes,
pg_total_relation_size(reltoastrelid) AS toast_bytes
FROM pg_class c
LEFT JOIN pg_namespace n ON n.oid = c.relnamespace
WHERE relkind = 'r') a) a
WHERE table_name LIKE '%table_to_delete%';

--TRUNCATE took only 1 second vs DELETE which took 19 seconds
--plus TRUNCATE immediately freed all space (table went from 575 MB to 0 bytes)
--but TRUNCATE removes all rows, you cant filter with WHERE like DELETE, also TRUNCATE cant be rolled back inside a transaction



