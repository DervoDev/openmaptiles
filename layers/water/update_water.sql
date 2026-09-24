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
    WHERE ST_NPoints(geometry) <> 5 -- <> betyr != 
    );

CREATE INDEX IF NOT EXISTS osm_ocean_polygon_union_geom_idx
  ON osm_ocean_polygon_union
  USING GIST (geometry);

--Drop data from original table but keep table as `CREATE TABLE IF NOT EXISTS` still test if query is valid
TRUNCATE TABLE osm_ocean_polygon;

-- ============================================================================
-- ZOOM 11
-- ============================================================================
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
WITH buffered_polygons AS (
    SELECT 
        ST_MakeValid(
            (ST_Dump(
                ST_Buffer(
                    ST_Union(
                        ST_Buffer(
                            ST_SimplifyPreserveTopology(geometry, ZRes(12.5)), 
                            -ZRes(11+3),
                            'join=round quad_segs=1'
                        )
                    ),
                    ZRes(11+3),
                    'join=round quad_segs=1'
                )
            )).geom
        ) AS geometry
    FROM osm_ocean_polygon_union
),
filtered_polygons AS (
    SELECT geometry 
    FROM buffered_polygons
    WHERE ST_Area(geometry) > power(ZRes(11+1) * 3, 2)
),
cleaned_polygons AS (
    SELECT 
        ST_MakePolygon(
            ST_ExteriorRing(poly.geometry),
            ARRAY(
                SELECT ST_ExteriorRing(rings.geom)
                FROM ST_DumpRings(poly.geometry) AS rings
                WHERE rings.path[1] > 0 
                  AND ST_Area(rings.geom) > power(ZRes(11+1) * 3, 2)
            )
        ) AS geometry
    FROM filtered_polygons AS poly
),
simplified_polygons AS (
    SELECT 
        ST_SimplifyVW(geometry, power(ZRes(12.5), 2)) AS geometry
    FROM cleaned_polygons
)
SELECT ST_MakeValid(ST_ForcePolygonCW(geometry)) AS geometry 
FROM simplified_polygons;
CREATE INDEX IF NOT EXISTS osm_ocean_polygon_gen_z11_idx ON osm_ocean_polygon_gen_z11 USING gist (geometry);


-- ============================================================================
-- ZOOM 10
-- ============================================================================
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
WITH buffered_polygons AS (
    SELECT 
        ST_MakeValid((ST_Dump(
            ST_Buffer(
                ST_Union(
                    ST_Buffer(
                        ST_SimplifyPreserveTopology(geometry, ZRes(11.6)), 
                        -ZRes(10+3),
                        'join=round quad_segs=1'
                    )
                ),
                ZRes(10+3),
                'join=round quad_segs=1'
            )
        )).geom) AS geometry
    FROM osm_ocean_polygon_gen_z11
),
filtered_polygons AS (
    SELECT geometry 
    FROM buffered_polygons
    WHERE ST_Area(geometry) > power(ZRes(10+1) * 3, 2)
),
cleaned_polygons AS (
    SELECT 
        ST_MakePolygon(
            ST_ExteriorRing(poly.geometry),
            ARRAY(
                SELECT ST_ExteriorRing(rings.geom)
                FROM ST_DumpRings(poly.geometry) AS rings
                WHERE rings.path[1] > 0 
                  AND ST_Area(rings.geom) > power(ZRes(10+2.4) * 3, 2)
            )
        ) AS geometry
    FROM filtered_polygons AS poly
),
simplified_polygons AS (
    SELECT 
        ST_SimplifyVW(geometry, power(ZRes(11.6), 2)) AS geometry
    FROM cleaned_polygons
)
SELECT ST_MakeValid(ST_ForcePolygonCW(geometry)) AS geometry 
FROM simplified_polygons;
CREATE INDEX IF NOT EXISTS osm_ocean_polygon_gen_z10_idx ON osm_ocean_polygon_gen_z10 USING gist (geometry);


-- ============================================================================
-- ZOOM 9
-- ============================================================================
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
WITH buffered_polygons AS (
    SELECT 
        ST_MakeValid((ST_Dump(
            ST_Buffer(
                ST_Union(
                    ST_Buffer(
                        ST_SimplifyPreserveTopology(geometry, ZRes(10.7)), 
                        -ZRes(9+3),
                        'join=round quad_segs=1'
                    )
                ),
                ZRes(9+3),
                'join=round quad_segs=1'
            )
        )).geom) AS geometry
    FROM osm_ocean_polygon_gen_z10
),
filtered_polygons AS (
    SELECT geometry 
    FROM buffered_polygons
    WHERE ST_Area(geometry) > power(ZRes(9+1) * 3, 2)
),
cleaned_polygons AS (
    SELECT 
        ST_MakePolygon(
            ST_ExteriorRing(poly.geometry),
            ARRAY(
                SELECT ST_ExteriorRing(rings.geom)
                FROM ST_DumpRings(poly.geometry) AS rings
                WHERE rings.path[1] > 0 
                  AND ST_Area(rings.geom) > power(ZRes(9+1) * 3, 2)
            )
        ) AS geometry
    FROM filtered_polygons AS poly
),
simplified_polygons AS (
    SELECT 
        ST_SimplifyVW(geometry, power(ZRes(10.7), 2)) AS geometry
    FROM cleaned_polygons
)
SELECT ST_MakeValid(ST_ForcePolygonCW(geometry)) AS geometry 
FROM simplified_polygons;
CREATE INDEX IF NOT EXISTS osm_ocean_polygon_gen_z9_idx ON osm_ocean_polygon_gen_z9 USING gist (geometry);


-- ============================================================================
-- ZOOM 8
-- ============================================================================
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
WITH buffered_polygons AS (
    SELECT 
        ST_MakeValid((ST_Dump(
            ST_Buffer(
                ST_Union(
                    ST_Buffer(
                        ST_SimplifyPreserveTopology(geometry, ZRes(9.8)), 
                        -ZRes(8+3),
                        'join=round quad_segs=1'
                    )
                ),
                ZRes(8+3),
                'join=round quad_segs=1'
            )
        )).geom) AS geometry
    FROM osm_ocean_polygon_gen_z9
),
filtered_polygons AS (
    SELECT geometry 
    FROM buffered_polygons
    WHERE ST_Area(geometry) > power(ZRes(8+1) * 3, 2)
),
cleaned_polygons AS (
    SELECT 
        ST_MakePolygon(
            ST_ExteriorRing(poly.geometry),
            ARRAY(
                SELECT ST_ExteriorRing(rings.geom)
                FROM ST_DumpRings(poly.geometry) AS rings
                WHERE rings.path[1] > 0 
                  AND ST_Area(rings.geom) > power(ZRes(8+1) * 3, 2)
            )
        ) AS geometry
    FROM filtered_polygons AS poly
),
simplified_polygons AS (
    SELECT 
        ST_SimplifyVW(geometry, power(ZRes(9.8), 2)) AS geometry
    FROM cleaned_polygons
)
SELECT ST_MakeValid(ST_ForcePolygonCW(geometry)) AS geometry 
FROM simplified_polygons;
CREATE INDEX IF NOT EXISTS osm_ocean_polygon_gen_z8_idx ON osm_ocean_polygon_gen_z8 USING gist (geometry);


-- ============================================================================
-- ZOOM 7
-- ============================================================================
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
WITH buffered_polygons AS (
    SELECT 
        ST_MakeValid((ST_Dump(
            ST_Buffer(
                ST_Union(
                    ST_Buffer(
                        ST_SimplifyPreserveTopology(geometry, ZRes(8.9)), 
                        -ZRes(7+3),
                        'join=round quad_segs=1'
                    )
                ),
                ZRes(7+3),
                'join=round quad_segs=1'
            )
        )).geom) AS geometry
    FROM osm_ocean_polygon_gen_z8
),
filtered_polygons AS (
    SELECT geometry 
    FROM buffered_polygons
    WHERE ST_Area(geometry) > power(ZRes(7+1) * 3, 2)
),
cleaned_polygons AS (
    SELECT 
        ST_MakePolygon(
            ST_ExteriorRing(poly.geometry),
            ARRAY(
                SELECT ST_ExteriorRing(rings.geom)
                FROM ST_DumpRings(poly.geometry) AS rings
                WHERE rings.path[1] > 0 
                  AND ST_Area(rings.geom) > power(ZRes(7+1) * 3, 2)
            )
        ) AS geometry
    FROM filtered_polygons AS poly
),
simplified_polygons AS (
    SELECT 
        ST_SimplifyVW(geometry, power(ZRes(8.9), 2)) AS geometry
    FROM cleaned_polygons
)
SELECT ST_MakeValid(ST_ForcePolygonCW(geometry)) AS geometry 
FROM simplified_polygons;
CREATE INDEX IF NOT EXISTS osm_ocean_polygon_gen_z7_idx ON osm_ocean_polygon_gen_z7 USING gist (geometry);


-- ============================================================================
-- ZOOM 6
-- ============================================================================
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
WITH buffered_polygons AS (
    SELECT 
        ST_MakeValid((ST_Dump(
            ST_Buffer(
                ST_Union(
                    ST_Buffer(
                        ST_SimplifyPreserveTopology(geometry, ZRes(8)), 
                        -ZRes(6+3),
                        'join=round quad_segs=1'
                    )
                ),
                ZRes(6+3),
                'join=round quad_segs=1'
            )
        )).geom) AS geometry
    FROM osm_ocean_polygon_gen_z7
),
filtered_polygons AS (
    SELECT geometry 
    FROM buffered_polygons
    WHERE ST_Area(geometry) > power(ZRes(6+1) * 3, 2)
),
cleaned_polygons AS (
    SELECT 
        ST_MakePolygon(
            ST_ExteriorRing(poly.geometry),
            ARRAY(
                SELECT ST_ExteriorRing(rings.geom)
                FROM ST_DumpRings(poly.geometry) AS rings
                WHERE rings.path[1] > 0 
                  AND ST_Area(rings.geom) > power(ZRes(6+1) * 3, 2)
            )
        ) AS geometry
    FROM filtered_polygons AS poly
),
simplified_polygons AS (
    SELECT 
        ST_SimplifyVW(geometry, power(ZRes(8), 2)) AS geometry
    FROM cleaned_polygons
)
SELECT ST_MakeValid(ST_ForcePolygonCW(geometry)) AS geometry 
FROM simplified_polygons;
CREATE INDEX IF NOT EXISTS osm_ocean_polygon_gen_z6_idx ON osm_ocean_polygon_gen_z6 USING gist (geometry);


-- ============================================================================
-- ZOOM 5
-- ============================================================================
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
WITH buffered_polygons AS (
    SELECT 
        ST_MakeValid((ST_Dump(
            ST_Buffer(
                ST_Union(
                    ST_Buffer(
                        ST_SimplifyPreserveTopology(geometry, ZRes(7.1)), 
                        -ZRes(5+3),
                        'join=round quad_segs=1'
                    )
                ),
                ZRes(5+3),
                'join=round quad_segs=1'
            )
        )).geom) AS geometry
    FROM osm_ocean_polygon_gen_z6
),
filtered_polygons AS (
    SELECT geometry 
    FROM buffered_polygons
    WHERE ST_Area(geometry) > power(ZRes(5+1) * 3, 2)
),
cleaned_polygons AS (
    SELECT 
        ST_MakePolygon(
            ST_ExteriorRing(poly.geometry),
            ARRAY(
                SELECT ST_ExteriorRing(rings.geom)
                FROM ST_DumpRings(poly.geometry) AS rings
                WHERE rings.path[1] > 0 
                  AND ST_Area(rings.geom) > power(ZRes(5+1) * 3, 2)
            )
        ) AS geometry
    FROM filtered_polygons AS poly
),
simplified_polygons AS (
    SELECT 
        ST_SimplifyVW(geometry, power(ZRes(7.1), 2)) AS geometry
    FROM cleaned_polygons
)
SELECT ST_MakeValid(ST_ForcePolygonCW(geometry)) AS geometry 
FROM simplified_polygons;
CREATE INDEX IF NOT EXISTS osm_ocean_polygon_gen_z5_idx ON osm_ocean_polygon_gen_z5 USING gist (geometry);


-- ============================================================================
-- ZOOM 4
-- ============================================================================
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
WITH buffered_polygons AS (
    SELECT 
        ST_MakeValid((ST_Dump(
            ST_Buffer(
                ST_Union(
                    ST_Buffer(
                        ST_SimplifyPreserveTopology(geometry, ZRes(6.2)), 
                        -ZRes(4+3),
                        'join=round quad_segs=1'
                    )
                ),
                ZRes(4+3),
                'join=round quad_segs=1'
            )
        )).geom) AS geometry
    FROM osm_ocean_polygon_gen_z5
),
filtered_polygons AS (
    SELECT geometry 
    FROM buffered_polygons
    WHERE ST_Area(geometry) > power(ZRes(4+1) * 3, 2)
),
cleaned_polygons AS (
    SELECT 
        ST_MakePolygon(
            ST_ExteriorRing(poly.geometry),
            ARRAY(
                SELECT ST_ExteriorRing(rings.geom)
                FROM ST_DumpRings(poly.geometry) AS rings
                WHERE rings.path[1] > 0 
                  AND ST_Area(rings.geom) > power(ZRes(4+1) * 3, 2)
            )
        ) AS geometry
    FROM filtered_polygons AS poly
),
simplified_polygons AS (
    SELECT 
        ST_SimplifyVW(geometry, power(ZRes(6.2), 2)) AS geometry
    FROM cleaned_polygons
)
SELECT ST_MakeValid(ST_ForcePolygonCW(geometry)) AS geometry 
FROM simplified_polygons;
CREATE INDEX IF NOT EXISTS osm_ocean_polygon_gen_z4_idx ON osm_ocean_polygon_gen_z4 USING gist (geometry);


-- ============================================================================
-- ZOOM 3
-- ============================================================================
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
WITH buffered_polygons AS (
    SELECT 
        ST_MakeValid((ST_Dump(
            ST_Buffer(
                ST_Union(
                    ST_Buffer(
                        ST_SimplifyPreserveTopology(geometry, ZRes(5.3)), 
                        -ZRes(3+4),
                        'join=round quad_segs=1'
                    )
                ),
                ZRes(3+4),
                'join=round quad_segs=1'
            )
        )).geom) AS geometry
    FROM osm_ocean_polygon_gen_z4
),
filtered_polygons AS (
    SELECT geometry 
    FROM buffered_polygons
    WHERE ST_Area(geometry) > power(ZRes(3+1.9) * 3, 2)
),
cleaned_polygons AS (
    SELECT 
        ST_MakePolygon(
            ST_ExteriorRing(poly.geometry),
            ARRAY(
                SELECT ST_ExteriorRing(rings.geom)
                FROM ST_DumpRings(poly.geometry) AS rings
                WHERE rings.path[1] > 0 
                  AND ST_Area(rings.geom) > power(ZRes(3+1.9) * 3, 2)
            )
        ) AS geometry
    FROM filtered_polygons AS poly
),
simplified_polygons AS (
    SELECT 
        ST_SimplifyVW(geometry, power(ZRes(3+2.4), 2)) AS geometry
    FROM cleaned_polygons
)
SELECT ST_MakeValid(ST_ForcePolygonCW(geometry)) AS geometry 
FROM simplified_polygons;

CREATE INDEX IF NOT EXISTS osm_ocean_polygon_gen_z3_idx ON osm_ocean_polygon_gen_z3 USING gist (geometry);


-- ============================================================================
-- ZOOM 2
-- ============================================================================
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
WITH buffered_polygons AS (
    SELECT 
        ST_MakeValid((ST_Dump(
            ST_Buffer(
                ST_Union(
                    ST_Buffer(
                        ST_SimplifyPreserveTopology(geometry, ZRes(4.8)), 
                        -ZRes(2+3),
                        'join=round quad_segs=1'
                    )
                ),
                ZRes(2+3),
                'join=round quad_segs=1'
            )
        )).geom) AS geometry
    FROM osm_ocean_polygon_gen_z3
),
filtered_polygons AS (
    SELECT geometry 
    FROM buffered_polygons
    WHERE ST_Area(geometry) > power(ZRes(2+1.8) * 3, 2)
),
cleaned_polygons AS (
    SELECT 
        ST_MakePolygon(
            ST_ExteriorRing(poly.geometry),
            ARRAY(
                SELECT ST_ExteriorRing(rings.geom)
                FROM ST_DumpRings(poly.geometry) AS rings
                WHERE rings.path[1] > 0 
                  AND ST_Area(rings.geom) > power(ZRes(2+1.8) * 3, 2)
            )
        ) AS geometry
    FROM filtered_polygons AS poly
),
simplified_polygons AS (
    SELECT 
        ST_SimplifyVW(geometry, power(ZRes(2+2.6), 2)) AS geometry
    FROM cleaned_polygons
)
SELECT ST_MakeValid(ST_ForcePolygonCW(geometry)) AS geometry 
FROM simplified_polygons;
CREATE INDEX IF NOT EXISTS osm_ocean_polygon_gen_z2_idx ON osm_ocean_polygon_gen_z2 USING gist (geometry);


-- ============================================================================
-- ZOOM 1
-- ============================================================================
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
WITH buffered_polygons AS (
    SELECT 
        ST_MakeValid((ST_Dump(
            ST_Buffer(
                ST_Union(
                    ST_Buffer(
                        ST_SimplifyPreserveTopology(geometry, ZRes(4.4)), 
                        -ZRes(1+3),
                        'join=round quad_segs=1'
                    )
                ),
                ZRes(1+3),
                'join=round quad_segs=1'
            )
        )).geom) AS geometry
    FROM osm_ocean_polygon_gen_z2
),
filtered_polygons AS (
    SELECT geometry 
    FROM buffered_polygons
    WHERE ST_Area(geometry) > power(ZRes(1+1.7) * 3, 2)
),
cleaned_polygons AS (
    SELECT 
        ST_MakePolygon(
            ST_ExteriorRing(poly.geometry),
            ARRAY(
                SELECT ST_ExteriorRing(rings.geom)
                FROM ST_DumpRings(poly.geometry) AS rings
                WHERE rings.path[1] > 0 
                  AND ST_Area(rings.geom) > power(ZRes(1+1.7) * 3, 2)
            )
        ) AS geometry
    FROM filtered_polygons AS poly
),
simplified_polygons AS (
    SELECT 
        ST_SimplifyVW(geometry, power(ZRes(1+2.8), 2)) AS geometry
    FROM cleaned_polygons
)
SELECT ST_MakeValid(ST_ForcePolygonCW(geometry)) AS geometry 
FROM simplified_polygons;
CREATE INDEX IF NOT EXISTS osm_ocean_polygon_gen_z1_idx ON osm_ocean_polygon_gen_z1 USING gist (geometry);


-- ============================================================================
-- ZOOM 0
-- ============================================================================
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
WITH buffered_polygons AS (
    SELECT 
        ST_MakeValid((ST_Dump(
            ST_Buffer(
                ST_Union(
                    ST_Buffer(
                        ST_SimplifyPreserveTopology(geometry, ZRes(0+4)), 
                        -ZRes(0+3),
                        'join=round quad_segs=1'
                    )
                ),
                ZRes(0+3),
                'join=round quad_segs=1'
            )
        )).geom) AS geometry
    FROM osm_ocean_polygon_gen_z1
),
filtered_polygons AS (
    SELECT geometry 
    FROM buffered_polygons
    WHERE ST_Area(geometry) > power(ZRes(0+1.6) * 3, 2)
),
cleaned_polygons AS (
    SELECT 
        ST_MakePolygon(
            ST_ExteriorRing(poly.geometry),
            ARRAY(
                SELECT ST_ExteriorRing(rings.geom)
                FROM ST_DumpRings(poly.geometry) AS rings
                WHERE rings.path[1] > 0 
                  AND ST_Area(rings.geom) > power(ZRes(0+1.6) * 3, 2)
            )
        ) AS geometry
    FROM filtered_polygons AS poly
),
simplified_polygons AS (
    SELECT 
        ST_SimplifyVW(geometry, power(ZRes(0+3), 2)) AS geometry
    FROM cleaned_polygons
)
SELECT ST_MakeValid(ST_ForcePolygonCW(geometry)) AS geometry 
FROM simplified_polygons;
CREATE INDEX IF NOT EXISTS osm_ocean_polygon_gen_z0_idx ON osm_ocean_polygon_gen_z0 USING gist (geometry);

