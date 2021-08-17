DROP TABLE IF EXISTS "ad_types";
DROP SEQUENCE IF EXISTS ad_type_id_seq;
CREATE SEQUENCE ad_type_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1;

CREATE TABLE "public"."ad_types"
(
    "id"    integer DEFAULT nextval('ad_type_id_seq') NOT NULL,
    "value" character varying(20)                     NOT NULL,
    CONSTRAINT "ad_type_pkey" PRIMARY KEY ("id"),
    CONSTRAINT "ad_type_value" UNIQUE ("value")
) WITH (oids = false);

DROP TABLE IF EXISTS "ads";
DROP SEQUENCE IF EXISTS ads_id_seq;
CREATE SEQUENCE ads_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1;

CREATE TABLE "public"."ads"
(
    "id"               integer DEFAULT nextval('ads_id_seq') NOT NULL,
    "title"            character varying(60)                 NOT NULL,
    "locality"         character varying(40)                 NOT NULL,
    "coordinates"      geometry(Point,4326) NOT NULL,
    "price"            integer                               NOT NULL,
    "company"          character varying(40),
    "seller"           character varying(40)                 NOT NULL,
    "building_type"    character varying(10)                 NOT NULL,
    "ownership"        character varying(20),
    "floor"            smallint,
    "usable_area"      smallint                              NOT NULL,
    "floor_area"       smallint,
    "energy_intensity" character varying(1)                  NOT NULL,
    "parking"          smallint                              NOT NULL,
    "elevator"         boolean                               NOT NULL,
    "terrace"          smallint                              NOT NULL,
    "ad_type_id"       integer                               NOT NULL,
    CONSTRAINT "ads_pkey" PRIMARY KEY ("id")
) WITH (oids = false);

DROP TABLE IF EXISTS "districts";
DROP SEQUENCE IF EXISTS districts_id_seq;
CREATE SEQUENCE districts_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1;

CREATE TABLE "public"."districts"
(
    "id"          integer DEFAULT nextval('districts_id_seq') NOT NULL,
    "name"        character varying(25)                       NOT NULL,
    "coordinates" geometry(Polygon,4326) NOT NULL,
    CONSTRAINT "districts_name" UNIQUE ("name"),
    CONSTRAINT "districts_pkey" PRIMARY KEY ("id")
) WITH (oids = false);

DROP VIEW IF EXISTS "geography_columns";
CREATE TABLE "geography_columns"
(
    "f_table_catalog"    name,
    "f_table_schema"     name,
    "f_table_name"       name,
    "f_geography_column" name,
    "coord_dimension"    integer,
    "srid"               integer,
    "type"               text
);

DROP VIEW IF EXISTS "geometry_columns";
CREATE TABLE "geometry_columns"
(
    "f_table_catalog"   character varying(256),
    "f_table_schema"    name,
    "f_table_name"      name,
    "f_geometry_column" name,
    "coord_dimension"   integer,
    "srid"              integer,
    "type"              character varying(30)
);

DROP TABLE IF EXISTS "pois";
DROP SEQUENCE IF EXISTS pois_id_seq;
CREATE SEQUENCE pois_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1;

CREATE TABLE "public"."pois"
(
    "id"          integer DEFAULT nextval('pois_id_seq') NOT NULL,
    "name"        character varying(20)                  NOT NULL,
    "description" character varying(60)                  NOT NULL,
    "coordinates" geometry(Point,4326) NOT NULL,
    CONSTRAINT "pois_pkey" PRIMARY KEY ("id")
) WITH (oids = false);

DROP TABLE IF EXISTS "spatial_ref_sys";
CREATE TABLE "public"."spatial_ref_sys"
(
    "srid"      integer NOT NULL,
    "auth_name" character varying(256),
    "auth_srid" integer,
    "srtext"    character varying(2048),
    "proj4text" character varying(2048),
    CONSTRAINT "spatial_ref_sys_pkey" PRIMARY KEY ("srid")
) WITH (oids = false);

DROP TABLE IF EXISTS "stations";
DROP SEQUENCE IF EXISTS stations_id_seq;
CREATE SEQUENCE stations_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1;

CREATE TABLE "public"."stations"
(
    "id"           integer DEFAULT nextval('stations_id_seq') NOT NULL,
    "name"         character varying(45)                      NOT NULL,
    "coordinates"  geometry(Point,4326) NOT NULL,
    "barrier_free" boolean                                    NOT NULL,
    CONSTRAINT "stations_name_coordinates" UNIQUE ("name", "coordinates"),
    CONSTRAINT "stations_pkey" PRIMARY KEY ("id")
) WITH (oids = false);

DROP TABLE IF EXISTS "tariff_bands";
DROP SEQUENCE IF EXISTS tariff_bands_id_seq;
CREATE SEQUENCE tariff_bands_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1;

CREATE TABLE "public"."tariff_bands"
(
    "id"          integer DEFAULT nextval('tariff_bands_id_seq') NOT NULL,
    "name"        character varying(7)                           NOT NULL,
    "coordinates" geometry(MultiPolygon,4326) NOT NULL,
    CONSTRAINT "tariff_bands_name" UNIQUE ("name"),
    CONSTRAINT "tariff_bands_pkey" PRIMARY KEY ("id")
) WITH (oids = false);

DROP TABLE IF EXISTS "transport_lines";
DROP SEQUENCE IF EXISTS transport_lines_id_seq;
CREATE SEQUENCE transport_lines_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1;

CREATE TABLE "public"."transport_lines"
(
    "id"            integer DEFAULT nextval('transport_lines_id_seq') NOT NULL,
    "short_name"    character varying(25)                             NOT NULL,
    "long_name"     character varying(100)                            NOT NULL,
    "coordinates"   geometry(MultiLineString,4326) NOT NULL,
    "night_traffic" boolean                                           NOT NULL,
    CONSTRAINT "transport_lines_pkey" PRIMARY KEY ("id"),
    CONSTRAINT "transport_lines_short_name" UNIQUE ("short_name")
) WITH (oids = false);

ALTER TABLE ONLY "public"."ads" ADD CONSTRAINT "ads_ad_type_id_fkey" FOREIGN KEY (ad_type_id) REFERENCES ad_types(id) ON UPDATE RESTRICT ON DELETE RESTRICT NOT DEFERRABLE;

DROP TABLE IF EXISTS "geography_columns";
CREATE VIEW "geography_columns" AS
SELECT current_database()               AS f_table_catalog,
       n.nspname                        AS f_table_schema,
       c.relname                        AS f_table_name,
       a.attname                        AS f_geography_column,
       postgis_typmod_dims(a.atttypmod) AS coord_dimension,
       postgis_typmod_srid(a.atttypmod) AS srid,
       postgis_typmod_type(a.atttypmod) AS type
FROM pg_class c,
     pg_attribute a,
     pg_type t,
     pg_namespace n
WHERE ((t.typname = 'geography'::name) AND (a.attisdropped = false) AND (a.atttypid = t.oid) AND
       (a.attrelid = c.oid) AND (c.relnamespace = n.oid) AND
       (c.relkind = ANY (ARRAY['r'::"char", 'v'::"char", 'm'::"char", 'f'::"char", 'p'::"char"])) AND
       (NOT pg_is_other_temp_schema(c.relnamespace)) AND has_table_privilege(c.oid, 'SELECT'::text));

DROP TABLE IF EXISTS "geometry_columns";
CREATE VIEW "geometry_columns" AS
SELECT (current_database()) ::character varying(256) AS f_table_catalog,
    n.nspname AS f_table_schema,
    c.relname AS f_table_name,
    a.attname AS f_geometry_column,
    COALESCE(postgis_typmod_dims(a.atttypmod), sn.ndims, 2) AS coord_dimension,
    COALESCE(NULLIF(postgis_typmod_srid(a.atttypmod), 0), sr.srid, 0) AS srid,
    (replace(replace(COALESCE(NULLIF(upper(postgis_typmod_type(a.atttypmod)), 'GEOMETRY'::text), st.type, 'GEOMETRY'::text), 'ZM'::text, ''::text), 'Z'::text, ''::text))::character varying(30) AS type
   FROM ((((((pg_class c
     JOIN pg_attribute a ON (((a.attrelid = c.oid) AND (NOT a.attisdropped))))
     JOIN pg_namespace n ON ((c.relnamespace = n.oid)))
     JOIN pg_type t ON ((a.atttypid = t.oid)))
     LEFT JOIN ( SELECT s.connamespace,
            s.conrelid,
            s.conkey,
            replace(split_part(s.consrc, ''''::text, 2), ')'::text, ''::text) AS type
           FROM ( SELECT pg_constraint.connamespace,
                    pg_constraint.conrelid,
                    pg_constraint.conkey,
                    pg_get_constraintdef(pg_constraint.oid) AS consrc
                   FROM pg_constraint) s
          WHERE (s.consrc ~~* '%geometrytype(% = %'::text)) st ON (((st.connamespace = n.oid) AND (st.conrelid = c.oid) AND (a.attnum = ANY (st.conkey)))))
     LEFT JOIN ( SELECT s.connamespace,
            s.conrelid,
            s.conkey,
            (replace(split_part(s.consrc, ' = '::text, 2), ')'::text, ''::text))::integer AS ndims
           FROM ( SELECT pg_constraint.connamespace,
                    pg_constraint.conrelid,
                    pg_constraint.conkey,
                    pg_get_constraintdef(pg_constraint.oid) AS consrc
                   FROM pg_constraint) s
          WHERE (s.consrc ~~* '%ndims(% = %'::text)) sn ON (((sn.connamespace = n.oid) AND (sn.conrelid = c.oid) AND (a.attnum = ANY (sn.conkey)))))
     LEFT JOIN ( SELECT s.connamespace,
            s.conrelid,
            s.conkey,
            (replace(replace(split_part(s.consrc, ' = '::text, 2), ')'::text, ''::text), '('::text, ''::text))::integer AS srid
           FROM ( SELECT pg_constraint.connamespace,
                    pg_constraint.conrelid,
                    pg_constraint.conkey,
                    pg_get_constraintdef(pg_constraint.oid) AS consrc
                   FROM pg_constraint) s
          WHERE (s.consrc ~~* '%srid(% = %'::text)) sr ON (((sr.connamespace = n.oid) AND (sr.conrelid = c.oid) AND (a.attnum = ANY (sr.conkey)))))
  WHERE ((c.relkind = ANY (ARRAY['r'::"char", 'v'::"char", 'm'::"char", 'f'::"char", 'p'::"char"])) AND (NOT (c.relname = 'raster_columns'::name)) AND (t.typname = 'geometry'::name) AND (NOT pg_is_other_temp_schema(c.relnamespace)) AND has_table_privilege(c.oid, 'SELECT'::text));
