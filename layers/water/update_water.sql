-- Recreate ocean layer by union regular squares into larger polygons
-- etldoc: osm_ocean_polygon -> osm_ocean_polygon_union
CREATE TABLE IF NOT EXISTS osm_ocean_polygon_union AS
    (
    SELECT (ST_Dump(ST_Union(ST_MakeValid(geometry)))).geom::geometry(Polygon, 3857) AS geometry 
    FROM osm_ocean_polygon
    --for union select just full square (not big triangles)
    WHERE ST_Area(geometry) > 100000000 AND 
          ST_NPoints(geometry) = 5
    UNION ALL
    SELECT geometry 
    FROM osm_ocean_polygon
    -- as 321 records have less then 5 coordinates (triangle)
    -- bigger then 5 coordinates have squares with holes from island and coastline
    WHERE ST_NPoints(geometry) <> 5
    );

CREATE INDEX IF NOT EXISTS osm_ocean_polygon_union_geom_idx
  ON osm_ocean_polygon_union
  USING GIST (geometry);

--Drop data from original table but keep table as `CREATE TABLE IF NOT EXISTS` still test if query is valid
TRUNCATE TABLE osm_ocean_polygon;

-- This statement can be deleted after the water importer image stops creating this object as a table
DO
$$
    BEGIN
        DROP TABLE IF EXISTS osm_ocean_polygon_gen_z11 CASCADE;
    EXCEPTION
        WHEN wrong_object_type THEN
    END;
$$ LANGUAGE plpgsql;

-- etldoc: osm_ocean_polygon_union -> osm_ocean_polygon_gen_z11
DROP MATERIALIZED VIEW IF EXISTS osm_ocean_polygon_gen_z11 CASCADE;
CREATE MATERIALIZED VIEW osm_ocean_polygon_gen_z11 AS
(
SELECT ST_Simplify(geometry, ZRes(13)) AS geometry
FROM osm_ocean_polygon_union
    ) /* DELAY_MATERIALIZED_VIEW_CREATION */ ;
CREATE INDEX IF NOT EXISTS osm_ocean_polygon_gen_z11_idx ON osm_ocean_polygon_gen_z11 USING gist (geometry);


-- This statement can be deleted after the water importer image stops creating this object as a table
DO
$$
    BEGIN
        DROP TABLE IF EXISTS osm_ocean_polygon_gen_z10 CASCADE;
    EXCEPTION
        WHEN wrong_object_type THEN
    END;
$$ LANGUAGE plpgsql;

-- etldoc: osm_ocean_polygon_gen_z11 -> osm_ocean_polygon_gen_z10
DROP MATERIALIZED VIEW IF EXISTS osm_ocean_polygon_gen_z10 CASCADE;
CREATE MATERIALIZED VIEW osm_ocean_polygon_gen_z10 AS
(
SELECT ST_Simplify(geometry, ZRes(12)) AS geometry
FROM osm_ocean_polygon_gen_z11
    ) /* DELAY_MATERIALIZED_VIEW_CREATION */ ;
CREATE INDEX IF NOT EXISTS osm_ocean_polygon_gen_z10_idx ON osm_ocean_polygon_gen_z10 USING gist (geometry);


-- This statement can be deleted after the water importer image stops creating this object as a table
DO
$$
    BEGIN
        DROP TABLE IF EXISTS osm_ocean_polygon_gen_z9 CASCADE;
    EXCEPTION
        WHEN wrong_object_type THEN
    END;
$$ LANGUAGE plpgsql;

-- etldoc: osm_ocean_polygon_gen_z10 -> osm_ocean_polygon_gen_z9
DROP MATERIALIZED VIEW IF EXISTS osm_ocean_polygon_gen_z9 CASCADE;
CREATE MATERIALIZED VIEW osm_ocean_polygon_gen_z9 AS
(
SELECT ST_Simplify(geometry, ZRes(11)) AS geometry
FROM osm_ocean_polygon_gen_z10
    ) /* DELAY_MATERIALIZED_VIEW_CREATION */ ;
CREATE INDEX IF NOT EXISTS osm_ocean_polygon_gen_z9_idx ON osm_ocean_polygon_gen_z9 USING gist (geometry);


-- This statement can be deleted after the water importer image stops creating this object as a table
DO
$$
    BEGIN
        DROP TABLE IF EXISTS osm_ocean_polygon_gen_z8 CASCADE;
    EXCEPTION
        WHEN wrong_object_type THEN
    END;
$$ LANGUAGE plpgsql;

-- etldoc: osm_ocean_polygon_gen_z9 -> osm_ocean_polygon_gen_z8
DROP MATERIALIZED VIEW IF EXISTS osm_ocean_polygon_gen_z8 CASCADE;
CREATE MATERIALIZED VIEW osm_ocean_polygon_gen_z8 AS
(
SELECT ST_Simplify(geometry, ZRes(10)) AS geometry
FROM osm_ocean_polygon_gen_z9
    ) /* DELAY_MATERIALIZED_VIEW_CREATION */ ;
CREATE INDEX IF NOT EXISTS osm_ocean_polygon_gen_z8_idx ON osm_ocean_polygon_gen_z8 USING gist (geometry);


-- This statement can be deleted after the water importer image stops creating this object as a table
DO
$$
    BEGIN
        DROP TABLE IF EXISTS osm_ocean_polygon_gen_z7 CASCADE;
    EXCEPTION
        WHEN wrong_object_type THEN
    END;
$$ LANGUAGE plpgsql;

-- etldoc: osm_ocean_polygon_gen_z8 -> osm_ocean_polygon_gen_z7
DROP MATERIALIZED VIEW IF EXISTS osm_ocean_polygon_gen_z7 CASCADE;
CREATE MATERIALIZED VIEW osm_ocean_polygon_gen_z7 AS
(
SELECT ST_Simplify(geometry, ZRes(9)) AS geometry
FROM osm_ocean_polygon_gen_z8
    ) /* DELAY_MATERIALIZED_VIEW_CREATION */ ;
CREATE INDEX IF NOT EXISTS osm_ocean_polygon_gen_z7_idx ON osm_ocean_polygon_gen_z7 USING gist (geometry);


-- This statement can be deleted after the water importer image stops creating this object as a table
DO
$$
    BEGIN
        DROP TABLE IF EXISTS osm_ocean_polygon_gen_z6 CASCADE;
    EXCEPTION
        WHEN wrong_object_type THEN
    END;
$$ LANGUAGE plpgsql;

-- etldoc: osm_ocean_polygon_gen_z7 -> osm_ocean_polygon_gen_z6
DROP MATERIALIZED VIEW IF EXISTS osm_ocean_polygon_gen_z6 CASCADE;
CREATE MATERIALIZED VIEW osm_ocean_polygon_gen_z6 AS
(
SELECT ST_Simplify(geometry, ZRes(8)) AS geometry
FROM osm_ocean_polygon_gen_z7
    ) /* DELAY_MATERIALIZED_VIEW_CREATION */ ;
CREATE INDEX IF NOT EXISTS osm_ocean_polygon_gen_z6_idx ON osm_ocean_polygon_gen_z6 USING gist (geometry);


-- This statement can be deleted after the water importer image stops creating this object as a table
DO
$$
    BEGIN
        DROP TABLE IF EXISTS osm_ocean_polygon_gen_z5 CASCADE;
    EXCEPTION
        WHEN wrong_object_type THEN
    END;
$$ LANGUAGE plpgsql;

-- etldoc: osm_ocean_polygon_gen_z6 -> osm_ocean_polygon_gen_z5
DROP MATERIALIZED VIEW IF EXISTS osm_ocean_polygon_gen_z5 CASCADE;
CREATE MATERIALIZED VIEW osm_ocean_polygon_gen_z5 AS
(
SELECT ST_Simplify(geometry, ZRes(7)) AS geometry
FROM osm_ocean_polygon_gen_z6
    ) /* DELAY_MATERIALIZED_VIEW_CREATION */ ;
CREATE INDEX IF NOT EXISTS osm_ocean_polygon_gen_z5_idx ON osm_ocean_polygon_gen_z5 USING gist (geometry);


-- This statement can be deleted after the water importer image stops creating this object as a table
DO
$$
    BEGIN
        DROP TABLE IF EXISTS osm_ocean_polygon_gen_z4 CASCADE;
    EXCEPTION
        WHEN wrong_object_type THEN
    END;
$$ LANGUAGE plpgsql;

-- etldoc: osm_ocean_polygon_gen_z5 -> osm_ocean_polygon_gen_z4
DROP MATERIALIZED VIEW IF EXISTS osm_ocean_polygon_gen_z4 CASCADE;
CREATE MATERIALIZED VIEW osm_ocean_polygon_gen_z4 AS
(
SELECT ST_Simplify(geometry, ZRes(6)) AS geometry
FROM osm_ocean_polygon_gen_z5
    ) /* DELAY_MATERIALIZED_VIEW_CREATION */ ;
CREATE INDEX IF NOT EXISTS osm_ocean_polygon_gen_z4_idx ON osm_ocean_polygon_gen_z4 USING gist (geometry);


-- This statement can be deleted after the water importer image stops creating this object as a table
DO
$$
    BEGIN
        DROP TABLE IF EXISTS osm_ocean_polygon_gen_z3 CASCADE;
    EXCEPTION
        WHEN wrong_object_type THEN
    END;
$$ LANGUAGE plpgsql;

-- etldoc: osm_ocean_polygon_gen_z4 -> osm_ocean_polygon_gen_z3
DROP MATERIALIZED VIEW IF EXISTS osm_ocean_polygon_gen_z3 CASCADE;
CREATE MATERIALIZED VIEW osm_ocean_polygon_gen_z3 AS
(
SELECT ST_Simplify(geometry, ZRes(5)) AS geometry
FROM osm_ocean_polygon_gen_z4
    ) /* DELAY_MATERIALIZED_VIEW_CREATION */ ;
CREATE INDEX IF NOT EXISTS osm_ocean_polygon_gen_z3_idx ON osm_ocean_polygon_gen_z3 USING gist (geometry);


-- This statement can be deleted after the water importer image stops creating this object as a table
DO
$$
    BEGIN
        DROP TABLE IF EXISTS osm_ocean_polygon_gen_z2 CASCADE;
    EXCEPTION
        WHEN wrong_object_type THEN
    END;
$$ LANGUAGE plpgsql;

-- etldoc: osm_ocean_polygon_gen_z3 -> osm_ocean_polygon_gen_z2
DROP MATERIALIZED VIEW IF EXISTS osm_ocean_polygon_gen_z2 CASCADE;
CREATE MATERIALIZED VIEW osm_ocean_polygon_gen_z2 AS
(
SELECT ST_Simplify(geometry, ZRes(4)) AS geometry
FROM osm_ocean_polygon_gen_z3
    ) /* DELAY_MATERIALIZED_VIEW_CREATION */ ;
CREATE INDEX IF NOT EXISTS osm_ocean_polygon_gen_z2_idx ON osm_ocean_polygon_gen_z2 USING gist (geometry);


-- This statement can be deleted after the water importer image stops creating this object as a table
DO
$$
    BEGIN
        DROP TABLE IF EXISTS osm_ocean_polygon_gen_z1 CASCADE;
    EXCEPTION
        WHEN wrong_object_type THEN
    END;
$$ LANGUAGE plpgsql;

-- etldoc: osm_ocean_polygon_gen_z2 -> osm_ocean_polygon_gen_z1
DROP MATERIALIZED VIEW IF EXISTS osm_ocean_polygon_gen_z1 CASCADE;
CREATE MATERIALIZED VIEW osm_ocean_polygon_gen_z1 AS
(
SELECT ST_Simplify(geometry, ZRes(3)) AS geometry
FROM osm_ocean_polygon_gen_z2
    ) /* DELAY_MATERIALIZED_VIEW_CREATION */ ;
CREATE INDEX IF NOT EXISTS osm_ocean_polygon_gen_z1_idx ON osm_ocean_polygon_gen_z1 USING gist (geometry);


-- This statement can be deleted after the water importer image stops creating this object as a table
DO
$$
    BEGIN
        DROP TABLE IF EXISTS osm_ocean_polygon_gen_z0 CASCADE;
    EXCEPTION
        WHEN wrong_object_type THEN
    END;
$$ LANGUAGE plpgsql;

-- etldoc: osm_ocean_polygon_gen_z1 -> osm_ocean_polygon_gen_z0
DROP MATERIALIZED VIEW IF EXISTS osm_ocean_polygon_gen_z0 CASCADE;
CREATE MATERIALIZED VIEW osm_ocean_polygon_gen_z0 AS
(
SELECT ST_Simplify(geometry, ZRes(2)) AS geometry
FROM osm_ocean_polygon_gen_z1
    ) /* DELAY_MATERIALIZED_VIEW_CREATION */ ;
CREATE INDEX IF NOT EXISTS osm_ocean_polygon_gen_z0_idx ON osm_ocean_polygon_gen_z0 USING gist (geometry);

