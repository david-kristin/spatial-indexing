CREATE TABLE spatial_ref_sys
(
    srid         INTEGER NOT NULL PRIMARY KEY,
    auth_name    TEXT    NOT NULL,
    auth_srid    INTEGER NOT NULL,
    ref_sys_name TEXT    NOT NULL DEFAULT 'Unknown',
    proj4text    TEXT    NOT NULL,
    srtext       TEXT    NOT NULL DEFAULT 'Undefined'
);
CREATE UNIQUE INDEX idx_spatial_ref_sys
    ON spatial_ref_sys (auth_srid, auth_name);
CREATE TABLE spatialite_history
(
    event_id        INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    table_name      TEXT    NOT NULL,
    geometry_column TEXT,
    event           TEXT    NOT NULL,
    timestamp       TEXT    NOT NULL,
    ver_sqlite      TEXT    NOT NULL,
    ver_splite      TEXT    NOT NULL
);
CREATE TABLE sqlite_sequence
(
    name,
    seq
);
CREATE TABLE geometry_columns
(
    f_table_name          TEXT    NOT NULL,
    f_geometry_column     TEXT    NOT NULL,
    geometry_type         INTEGER NOT NULL,
    coord_dimension       INTEGER NOT NULL,
    srid                  INTEGER NOT NULL,
    spatial_index_enabled INTEGER NOT NULL,
    CONSTRAINT pk_geom_cols PRIMARY KEY (f_table_name, f_geometry_column),
    CONSTRAINT fk_gc_srs FOREIGN KEY (srid) REFERENCES spatial_ref_sys (srid),
    CONSTRAINT ck_gc_rtree CHECK (spatial_index_enabled IN (0, 1, 2))
);
CREATE INDEX idx_srid_geocols ON geometry_columns
    (srid);
CREATE TRIGGER geometry_columns_f_table_name_insert
    BEFORE INSERT
    ON 'geometry_columns'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'insert on geometry_columns violates constraint: f_table_name value must not contain a single quote') WHERE NEW.f_table_name LIKE ('%''%');
SELECT RAISE(ABORT,
             'insert on geometry_columns violates constraint: f_table_name value must not contain a double quote') WHERE NEW.f_table_name LIKE ('%"%');
SELECT RAISE(ABORT, 'insert on geometry_columns violates constraint:
f_table_name value must be lower case') WHERE NEW.f_table_name <> lower(NEW.f_table_name);
END;
CREATE TRIGGER geometry_columns_f_table_name_update
    BEFORE UPDATE OF 'f_table_name' ON 'geometry_columns'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'update on geometry_columns violates constraint: f_table_name value must not contain a single quote') WHERE NEW.f_table_name LIKE ('%''%');
SELECT RAISE(ABORT,
             'update on geometry_columns violates constraint: f_table_name value must not contain a double quote') WHERE NEW.f_table_name LIKE ('%"%');
SELECT RAISE(ABORT,
             'update on geometry_columns violates constraint: f_table_name value must be lower case') WHERE NEW.f_table_name <> lower(NEW.f_table_name);
END;
CREATE TRIGGER geometry_columns_f_geometry_column_insert
    BEFORE INSERT
    ON 'geometry_columns'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'insert on geometry_columns violates constraint: f_geometry_column value must not contain a single quote') WHERE NEW.f_geometry_column LIKE ('%''%');
SELECT RAISE(ABORT, 'insert on geometry_columns violates constraint:
f_geometry_column value must not contain a double quote') WHERE NEW.f_geometry_column LIKE ('%"%');
SELECT RAISE(ABORT,
             'insert on geometry_columns violates constraint: f_geometry_column value must be lower case') WHERE NEW.f_geometry_column <> lower(NEW.f_geometry_column);
END;
CREATE TRIGGER geometry_columns_f_geometry_column_update
    BEFORE UPDATE OF 'f_geometry_column' ON 'geometry_columns'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'update on geometry_columns violates constraint: f_geometry_column value must not contain a single quote') WHERE NEW.f_geometry_column LIKE ('%''%');
SELECT RAISE(ABORT,
             'update on geometry_columns violates constraint: f_geometry_column value must not contain a double quote') WHERE NEW.f_geometry_column LIKE ('%"%');
SELECT RAISE(ABORT,
             'update on geometry_columns violates constraint: f_geometry_column value must be lower case') WHERE NEW.f_geometry_column <> lower(NEW.f_geometry_column);
END;
CREATE TRIGGER geometry_columns_geometry_type_insert
    BEFORE INSERT
    ON 'geometry_columns'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'geometry_type must be one of 0,1,2,3,4,5,6,7,1000,1001,1002,1003,1004,1005,1006,1007,2000,2001,2002,2003,2004,2005,2006,2007,3000,3001,3002,3003,3004,3005,3006,3007') WHERE NOT(NEW.geometry_type IN (0,1,2,3,4,5,6,7,1000,1001,1002,1003,1004,1005,1006,1007,2000,2001,2002,2003,2004,2005,2006,2007,3000,3001,3002,3003,3004,3005,3006,3007));
END;
CREATE TRIGGER geometry_columns_geometry_type_update
    BEFORE UPDATE OF 'geometry_type' ON 'geometry_columns'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'geometry_type must be one of 0,1,2,3,4,5,6,7,1000,1001,1002,1003,1004,1005,1006,1007,2000,2001,2002,2003,2004,2005,2006,2007,3000,3001,3002,3003,3004,3005,3006,3007') WHERE NOT(NEW.geometry_type IN (0,1,2,3,4,5,6,7,1000,1001,1002,1003,1004,1005,1006,1007,2000,2001,2002,2003,2004,2005,2006,2007,3000,3001,3002,3003,3004,3005,3006,3007));
END;
CREATE TRIGGER geometry_columns_coord_dimension_insert
    BEFORE INSERT
    ON 'geometry_columns'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT, 'coord_dimension must be one of 2,3,4') WHERE NOT(NEW.coord_dimension IN (2,3,4));
END;
CREATE TRIGGER geometry_columns_coord_dimension_update
    BEFORE UPDATE OF 'coord_dimension' ON 'geometry_columns'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT, 'coord_dimension must be one of 2,3,4') WHERE NOT(NEW.coord_dimension IN (2,3,4));
END;
CREATE VIEW geom_cols_ref_sys AS
SELECT f_table_name,
       f_geometry_column,
       geometry_type,
       coord_dimension,
       spatial_ref_sys.srid AS srid,
       auth_name,
       auth_srid,
       ref_sys_name,
       proj4text,
       srtext
FROM geometry_columns,
     spatial_ref_sys
WHERE geometry_columns.srid = spatial_ref_sys.srid
/* geom_cols_ref_sys(f_table_name,f_geometry_column,geometry_type,coord_dimension,srid,auth_name,auth_srid,ref_sys_name,proj4text,srtext) */;
CREATE TABLE spatial_ref_sys_aux
(
    srid               INTEGER NOT NULL PRIMARY KEY,
    is_geographic      INTEGER,
    has_flipped_axes   INTEGER,
    spheroid           TEXT,
    prime_meridian     TEXT,
    datum              TEXT,
    projection         TEXT,
    unit               TEXT,
    axis_1_name        TEXT,
    axis_1_orientation TEXT,
    axis_2_name        TEXT,
    axis_2_orientation TEXT,
    CONSTRAINT fk_sprefsys FOREIGN KEY (srid) REFERENCES spatial_ref_sys (srid)
);
CREATE VIEW spatial_ref_sys_all AS
SELECT a.srid               AS srid,
       a.auth_name          AS auth_name,
       a.auth_srid          AS auth_srid,
       a.ref_sys_name       AS ref_sys_name,
       b.is_geographic      AS is_geographic,
       b.has_flipped_axes   AS has_flipped_axes,
       b.spheroid           AS spheroid,
       b.prime_meridian     AS prime_meridian,
       b.datum              AS datum,
       b.projection         AS projection,
       b.unit               AS unit,
       b.axis_1_name        AS axis_1_name,
       b.axis_1_orientation AS axis_1_orientation,
       b.axis_2_name        AS axis_2_name,
       b.axis_2_orientation AS axis_2_orientation,
       a.proj4text          AS proj4text,
       a.srtext             AS srtext
FROM spatial_ref_sys AS a
         LEFT JOIN spatial_ref_sys_aux AS b ON (a.srid = b.srid)
/* spatial_ref_sys_all(srid,auth_name,auth_srid,ref_sys_name,is_geographic,has_flipped_axes,spheroid,prime_meridian,datum,projection,unit,axis_1_name,axis_1_orientation,axis_2_name,axis_2_orientation,proj4text,srtext) */;
CREATE TABLE views_geometry_columns
(
    view_name         TEXT    NOT NULL,
    view_geometry     TEXT    NOT NULL,
    view_rowid        TEXT    NOT NULL,
    f_table_name      TEXT    NOT NULL,
    f_geometry_column TEXT    NOT NULL,
    read_only         INTEGER NOT NULL,
    CONSTRAINT pk_geom_cols_views PRIMARY KEY (view_name, view_geometry),
    CONSTRAINT fk_views_geom_cols FOREIGN KEY (f_table_name, f_geometry_column) REFERENCES geometry_columns (f_table_name, f_geometry_column) ON DELETE CASCADE,
    CONSTRAINT ck_vw_rdonly CHECK (read_only IN (0, 1))
);
CREATE INDEX idx_viewsjoin ON views_geometry_columns
    (f_table_name, f_geometry_column);
CREATE TRIGGER vwgc_view_name_insert
    BEFORE INSERT
    ON 'views_geometry_columns'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'insert on views_geometry_columns violates constraint: view_name value must not contain a single quote') WHERE NEW.view_name LIKE ('%''%');
SELECT RAISE(ABORT,
             'insert on views_geometry_columns violates constraint: view_name value must not contain a double quote') WHERE NEW.view_name LIKE ('%"%');
SELECT RAISE(ABORT, 'insert on views_geometry_columns violates constraint:
view_name value must be lower case') WHERE NEW.view_name <> lower(NEW.view_name);
END;
CREATE TRIGGER vwgc_view_name_update
    BEFORE UPDATE OF 'view_name' ON 'views_geometry_columns'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'update on views_geometry_columns violates constraint: view_name value must not contain a single quote') WHERE NEW.view_name LIKE ('%''%');
SELECT RAISE(ABORT,
             'update on views_geometry_columns violates constraint: view_name value must not contain a double quote') WHERE NEW.view_name LIKE ('%"%');
SELECT RAISE(ABORT,
             'update on views_geometry_columns violates constraint: view_name value must be lower case') WHERE NEW.view_name <> lower(NEW.view_name);
END;
CREATE TRIGGER vwgc_view_geometry_insert
    BEFORE INSERT
    ON 'views_geometry_columns'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'insert on views_geometry_columns violates constraint: view_geometry value must not contain a single quote') WHERE NEW.view_geometry LIKE ('%''%');
SELECT RAISE(ABORT, 'insert on views_geometry_columns violates constraint:
view_geometry value must not contain a double quote') WHERE NEW.view_geometry LIKE ('%"%');
SELECT RAISE(ABORT,
             'insert on views_geometry_columns violates constraint: view_geometry value must be lower case') WHERE NEW.view_geometry <> lower(NEW.view_geometry);
END;
CREATE TRIGGER vwgc_view_geometry_update
    BEFORE UPDATE OF 'view_geometry' ON 'views_geometry_columns'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'update on views_geometry_columns violates constraint: view_geometry value must not contain a single quote') WHERE NEW.view_geometry LIKE ('%''%');
SELECT RAISE(ABORT, 'update on views_geometry_columns violates constraint:
view_geometry value must not contain a double quote') WHERE NEW.view_geometry LIKE ('%"%');
SELECT RAISE(ABORT,
             'update on views_geometry_columns violates constraint: view_geometry value must be lower case') WHERE NEW.view_geometry <> lower(NEW.view_geometry);
END;
CREATE TRIGGER vwgc_view_rowid_update
    BEFORE UPDATE OF 'view_rowid' ON 'views_geometry_columns'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'update on views_geometry_columns violates constraint: view_rowid value must not contain a single quote') WHERE NEW.f_geometry_column LIKE ('%''%');
SELECT RAISE(ABORT,
             'update on views_geometry_columns violates constraint: view_rowid value must not contain a double quote') WHERE NEW.view_rowid LIKE ('%"%');
SELECT RAISE(ABORT,
             'update on views_geometry_columns violates constraint: view_rowid value must be lower case') WHERE NEW.view_rowid <> lower(NEW.view_rowid);
END;
CREATE TRIGGER vwgc_view_rowid_insert
    BEFORE INSERT
    ON 'views_geometry_columns'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'insert on views_geometry_columns violates constraint: view_rowid value must not contain a single quote') WHERE NEW.view_rowid LIKE ('%''%');
SELECT RAISE(ABORT, 'insert on views_geometry_columns violates constraint:
view_rowid value must not contain a double quote') WHERE NEW.view_rowid LIKE ('%"%');
SELECT RAISE(ABORT,
             'insert on views_geometry_columns violates constraint: view_rowid value must be lower case') WHERE NEW.view_rowid <> lower(NEW.view_rowid);
END;
CREATE TRIGGER vwgc_f_table_name_insert
    BEFORE INSERT
    ON 'views_geometry_columns'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'insert on views_geometry_columns violates constraint: f_table_name value must not contain a single quote') WHERE NEW.f_table_name LIKE ('%''%');
SELECT RAISE(ABORT,
             'insert on views_geometry_columns violates constraint: f_table_name value must not contain a double quote') WHERE NEW.f_table_name LIKE ('%"%');
SELECT RAISE(ABORT, 'insert on views_geometry_columns violates constraint:
f_table_name value must be lower case') WHERE NEW.f_table_name <> lower(NEW.f_table_name);
END;
CREATE TRIGGER vwgc_f_table_name_update
    BEFORE UPDATE OF 'f_table_name' ON 'views_geometry_columns'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'update on views_geometry_columns violates constraint: f_table_name value must not contain a single quote') WHERE NEW.f_table_name LIKE ('%''%');
SELECT RAISE(ABORT,
             'update on views_geometry_columns violates constraint: f_table_name value must not contain a double quote') WHERE NEW.f_table_name LIKE ('%"%');
SELECT RAISE(ABORT,
             'update on views_geometry_columns violates constraint: f_table_name value must be lower case') WHERE NEW.f_table_name <> lower(NEW.f_table_name);
END;
CREATE TRIGGER vwgc_f_geometry_column_insert
    BEFORE INSERT
    ON 'views_geometry_columns'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'insert on views_geometry_columns violates constraint: f_geometry_column value must not contain a single quote') WHERE NEW.f_geometry_column LIKE ('%''%');
SELECT RAISE(ABORT, 'insert on views_geometry_columns violates constraint:
f_geometry_column value must not contain a double quote') WHERE NEW.f_geometry_column LIKE ('%"%');
SELECT RAISE(ABORT,
             'insert on views_geometry_columns violates constraint: f_geometry_column value must be lower case') WHERE NEW.f_geometry_column <> lower(NEW.f_geometry_column);
END;
CREATE TRIGGER vwgc_f_geometry_column_update
    BEFORE UPDATE OF 'f_geometry_column' ON 'views_geometry_columns'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'update on views_geometry_columns violates constraint: f_geometry_column value must not contain a single quote') WHERE NEW.f_geometry_column LIKE ('%''%');
SELECT RAISE(ABORT,
             'update on views_geometry_columns violates constraint: f_geometry_column value must not contain a double quote') WHERE NEW.f_geometry_column LIKE ('%"%');
SELECT RAISE(ABORT,
             'update on views_geometry_columns violates constraint: f_geometry_column value must be lower case') WHERE NEW.f_geometry_column <> lower(NEW.f_geometry_column);
END;
CREATE TABLE virts_geometry_columns
(
    virt_name       TEXT    NOT NULL,
    virt_geometry   TEXT    NOT NULL,
    geometry_type   INTEGER NOT NULL,
    coord_dimension INTEGER NOT NULL,
    srid            INTEGER NOT NULL,
    CONSTRAINT pk_geom_cols_virts PRIMARY KEY (virt_name, virt_geometry),
    CONSTRAINT fk_vgc_srid FOREIGN KEY (srid) REFERENCES spatial_ref_sys (srid)
);
CREATE INDEX idx_virtssrid ON virts_geometry_columns
    (srid);
CREATE TRIGGER vtgc_virt_name_insert
    BEFORE INSERT
    ON 'virts_geometry_columns'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'insert on virts_geometry_columns violates constraint: virt_name value must not contain a single quote') WHERE NEW.virt_name LIKE ('%''%');
SELECT RAISE(ABORT,
             'insert on virts_geometry_columns violates constraint: virt_name value must not contain a double quote') WHERE NEW.virt_name LIKE ('%"%');
SELECT RAISE(ABORT, 'insert on virts_geometry_columns violates constraint:
virt_name value must be lower case') WHERE NEW.virt_name <> lower(NEW.virt_name);
END;
CREATE TRIGGER vtgc_virt_name_update
    BEFORE UPDATE OF 'virt_name' ON 'virts_geometry_columns'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'update on virts_geometry_columns violates constraint: virt_name value must not contain a single quote') WHERE NEW.virt_name LIKE ('%''%');
SELECT RAISE(ABORT,
             'update on virts_geometry_columns violates constraint: virt_name value must not contain a double quote') WHERE NEW.virt_name LIKE ('%"%');
SELECT RAISE(ABORT,
             'update on virts_geometry_columns violates constraint: virt_name value must be lower case') WHERE NEW.virt_name <> lower(NEW.virt_name);
END;
CREATE TRIGGER vtgc_virt_geometry_insert
    BEFORE INSERT
    ON 'virts_geometry_columns'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'insert on virts_geometry_columns violates constraint: virt_geometry value must not contain a single quote') WHERE NEW.virt_geometry LIKE ('%''%');
SELECT RAISE(ABORT, 'insert on virts_geometry_columns violates constraint:
virt_geometry value must not contain a double quote') WHERE NEW.virt_geometry LIKE ('%"%');
SELECT RAISE(ABORT,
             'insert on virts_geometry_columns violates constraint: virt_geometry value must be lower case') WHERE NEW.virt_geometry <> lower(NEW.virt_geometry);
END;
CREATE TRIGGER vtgc_virt_geometry_update
    BEFORE UPDATE OF 'virt_geometry' ON 'virts_geometry_columns'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'update on virts_geometry_columns violates constraint: virt_geometry value must not contain a single quote') WHERE NEW.virt_geometry LIKE ('%''%');
SELECT RAISE(ABORT, 'update on virts_geometry_columns violates constraint:
virt_geometry value must not contain a double quote') WHERE NEW.virt_geometry LIKE ('%"%');
SELECT RAISE(ABORT,
             'update on virts_geometry_columns violates constraint: virt_geometry value must be lower case') WHERE NEW.virt_geometry <> lower(NEW.virt_geometry);
END;
CREATE TRIGGER vtgc_geometry_type_insert
    BEFORE INSERT
    ON 'virts_geometry_columns'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'geometry_type must be one of 0,1,2,3,4,5,6,7,1000,1001,1002,1003,1004,1005,1006,1007,2000,2001,2002,2003,2004,2005,2006,2007,3000,3001,3002,3003,3004,3005,3006,3007') WHERE NOT(NEW.geometry_type IN (0,1,2,3,4,5,6,7,1000,1001,1002,1003,1004,1005,1006,1007,2000,2001,2002,2003,2004,2005,2006,2007,3000,3001,3002,3003,3004,3005,3006,3007));
END;
CREATE TRIGGER vtgc_geometry_type_update
    BEFORE UPDATE OF 'geometry_type' ON 'virts_geometry_columns'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'geometry_type must be one of 0,1,2,3,4,5,6,7,1000,1001,1002,1003,1004,1005,1006,1007,2000,2001,2002,2003,2004,2005,2006,2007,3000,3001,3002,3003,3004,3005,3006,3007') WHERE NOT(NEW.geometry_type IN (0,1,2,3,4,5,6,7,1000,1001,1002,1003,1004,1005,1006,1007,2000,2001,2002,2003,2004,2005,2006,2007,3000,3001,3002,3003,3004,3005,3006,3007));
END;
CREATE TRIGGER vtgc_coord_dimension_insert
    BEFORE INSERT
    ON 'virts_geometry_columns'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT, 'coord_dimension must be one of 2,3,4') WHERE NOT(NEW.coord_dimension IN (2,3,4));
END;
CREATE TRIGGER vtgc_coord_dimension_update
    BEFORE UPDATE OF 'coord_dimension' ON 'virts_geometry_columns'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT, 'coord_dimension must be one of 2,3,4') WHERE NOT(NEW.coord_dimension IN (2,3,4));
END;
CREATE TABLE geometry_columns_statistics
(
    f_table_name      TEXT NOT NULL,
    f_geometry_column TEXT NOT NULL,
    last_verified     TIMESTAMP,
    row_count         INTEGER,
    extent_min_x      DOUBLE,
    extent_min_y      DOUBLE,
    extent_max_x      DOUBLE,
    extent_max_y      DOUBLE,
    CONSTRAINT pk_gc_statistics PRIMARY KEY (f_table_name, f_geometry_column),
    CONSTRAINT fk_gc_statistics FOREIGN KEY (f_table_name, f_geometry_column) REFERENCES geometry_columns (f_table_name, f_geometry_column) ON DELETE CASCADE
);
CREATE TRIGGER gcs_f_table_name_insert
    BEFORE INSERT
    ON 'geometry_columns_statistics'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'insert on geometry_columns_statistics violates constraint: f_table_name value must not contain a single quote') WHERE NEW.f_table_name LIKE ('%''%');
SELECT RAISE(ABORT,
             'insert on geometry_columns_statistics violates constraint: f_table_name value must not contain a double quote') WHERE NEW.f_table_name LIKE ('%"%');
SELECT RAISE(ABORT, 'insert on geometry_columns_statistics violates constraint:
f_table_name value must be lower case') WHERE NEW.f_table_name <> lower(NEW.f_table_name);
END;
CREATE TRIGGER gcs_f_table_name_update
    BEFORE UPDATE OF 'f_table_name' ON 'geometry_columns_statistics'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'update on geometry_columns_statistics violates constraint: f_table_name value must not contain a single quote') WHERE NEW.f_table_name LIKE ('%''%');
SELECT RAISE(ABORT,
             'update on geometry_columns_statistics violates constraint: f_table_name value must not contain a double quote') WHERE NEW.f_table_name LIKE ('%"%');
SELECT RAISE(ABORT,
             'update on geometry_columns_statistics violates constraint: f_table_name value must be lower case') WHERE NEW.f_table_name <> lower(NEW.f_table_name);
END;
CREATE TRIGGER gcs_f_geometry_column_insert
    BEFORE INSERT
    ON 'geometry_columns_statistics'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'insert on geometry_columns_statistics violates constraint: f_geometry_column value must not contain a single quote') WHERE NEW.f_geometry_column LIKE ('%''%');
SELECT RAISE(ABORT, 'insert on geometry_columns_statistics violates constraint:
f_geometry_column value must not contain a double quote') WHERE NEW.f_geometry_column LIKE ('%"%');
SELECT RAISE(ABORT,
             'insert on geometry_columns_statistics violates constraint: f_geometry_column value must be lower case') WHERE NEW.f_geometry_column <> lower(NEW.f_geometry_column);
END;
CREATE TRIGGER gcs_f_geometry_column_update
    BEFORE UPDATE OF 'f_geometry_column' ON 'geometry_columns_statistics'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'update on geometry_columns_statistics violates constraint: f_geometry_column value must not contain a single quote') WHERE NEW.f_geometry_column LIKE ('%''%');
SELECT RAISE(ABORT,
             'update on geometry_columns_statistics violates constraint: f_geometry_column value must not contain a double quote') WHERE NEW.f_geometry_column LIKE ('%"%');
SELECT RAISE(ABORT,
             'update on geometry_columns_statistics violates constraint: f_geometry_column value must be lower case') WHERE NEW.f_geometry_column <> lower(NEW.f_geometry_column);
END;
CREATE TABLE views_geometry_columns_statistics
(
    view_name     TEXT NOT NULL,
    view_geometry TEXT NOT NULL,
    last_verified TIMESTAMP,
    row_count     INTEGER,
    extent_min_x  DOUBLE,
    extent_min_y  DOUBLE,
    extent_max_x  DOUBLE,
    extent_max_y  DOUBLE,
    CONSTRAINT pk_vwgc_statistics PRIMARY KEY (view_name, view_geometry),
    CONSTRAINT fk_vwgc_statistics FOREIGN KEY (view_name, view_geometry) REFERENCES views_geometry_columns (view_name, view_geometry) ON DELETE CASCADE
);
CREATE TRIGGER vwgcs_view_name_insert
    BEFORE INSERT
    ON 'views_geometry_columns_statistics'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'insert on views_geometry_columns_statistics violates constraint: view_name value must not contain a single quote') WHERE NEW.view_name LIKE ('%''%');
SELECT RAISE(ABORT,
             'insert on views_geometry_columns_statistics violates constraint: view_name value must not contain a double quote') WHERE NEW.view_name LIKE ('%"%');
SELECT RAISE(ABORT, 'insert on views_geometry_columns_statistics violates constraint:
view_name value must be lower case') WHERE NEW.view_name <> lower(NEW.view_name);
END;
CREATE TRIGGER vwgcs_view_name_update
    BEFORE UPDATE OF 'view_name' ON 'views_geometry_columns_statistics'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'update on views_geometry_columns_statistics violates constraint: view_name value must not contain a single quote') WHERE NEW.view_name LIKE ('%''%');
SELECT RAISE(ABORT,
             'update on views_geometry_columns_statistics violates constraint: view_name value must not contain a double quote') WHERE NEW.view_name LIKE ('%"%');
SELECT RAISE(ABORT,
             'update on views_geometry_columns_statistics violates constraint: view_name value must be lower case') WHERE NEW.view_name <> lower(NEW.view_name);
END;
CREATE TRIGGER vwgcs_view_geometry_insert
    BEFORE INSERT
    ON 'views_geometry_columns_statistics'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'insert on views_geometry_columns_statistics violates constraint: view_geometry value must not contain a single quote') WHERE NEW.view_geometry LIKE ('%''%');
SELECT RAISE(ABORT, 'insert on views_geometry_columns_statistics violates constraint:
view_geometry value must not contain a double quote') WHERE NEW.view_geometry LIKE ('%"%');
SELECT RAISE(ABORT,
             'insert on views_geometry_columns_statistics violates constraint: view_geometry value must be lower case') WHERE NEW.view_geometry <> lower(NEW.view_geometry);
END;
CREATE TRIGGER vwgcs_view_geometry_update
    BEFORE UPDATE OF 'view_geometry' ON 'views_geometry_columns_statistics'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'update on views_geometry_columns_statistics violates constraint: view_geometry value must not contain a single quote') WHERE NEW.view_geometry LIKE ('%''%');
SELECT RAISE(ABORT, 'update on views_geometry_columns_statistics violates constraint:
view_geometry value must not contain a double quote') WHERE NEW.view_geometry LIKE ('%"%');
SELECT RAISE(ABORT,
             'update on views_geometry_columns_statistics violates constraint: view_geometry value must be lower case') WHERE NEW.view_geometry <> lower(NEW.view_geometry);
END;
CREATE TABLE virts_geometry_columns_statistics
(
    virt_name     TEXT NOT NULL,
    virt_geometry TEXT NOT NULL,
    last_verified TIMESTAMP,
    row_count     INTEGER,
    extent_min_x  DOUBLE,
    extent_min_y  DOUBLE,
    extent_max_x  DOUBLE,
    extent_max_y  DOUBLE,
    CONSTRAINT pk_vrtgc_statistics PRIMARY KEY (virt_name, virt_geometry),
    CONSTRAINT fk_vrtgc_statistics FOREIGN KEY (virt_name, virt_geometry) REFERENCES virts_geometry_columns (virt_name, virt_geometry) ON DELETE CASCADE
);
CREATE TRIGGER vtgcs_virt_name_insert
    BEFORE INSERT
    ON 'virts_geometry_columns_statistics'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'insert on virts_geometry_columns_statistics violates constraint: virt_name value must not contain a single quote') WHERE NEW.virt_name LIKE ('%''%');
SELECT RAISE(ABORT,
             'insert on virts_geometry_columns_statistics violates constraint: virt_name value must not contain a double quote') WHERE NEW.virt_name LIKE ('%"%');
SELECT RAISE(ABORT, 'insert on virts_geometry_columns_statistics violates constraint:
virt_name value must be lower case') WHERE NEW.virt_name <> lower(NEW.virt_name);
END;
CREATE TRIGGER vtgcs_virt_name_update
    BEFORE UPDATE OF 'virt_name' ON 'virts_geometry_columns_statistics'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'update on virts_geometry_columns_statistics violates constraint: virt_name value must not contain a single quote') WHERE NEW.virt_name LIKE ('%''%');
SELECT RAISE(ABORT,
             'update on virts_geometry_columns_statistics violates constraint: virt_name value must not contain a double quote') WHERE NEW.virt_name LIKE ('%"%');
SELECT RAISE(ABORT,
             'update on virts_geometry_columns_statistics violates constraint: virt_name value must be lower case') WHERE NEW.virt_name <> lower(NEW.virt_name);
END;
CREATE TRIGGER vtgcs_virt_geometry_insert
    BEFORE INSERT
    ON 'virts_geometry_columns_statistics'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'insert on virts_geometry_columns_statistics violates constraint: virt_geometry value must not contain a single quote') WHERE NEW.virt_geometry LIKE ('%''%');
SELECT RAISE(ABORT, 'insert on virts_geometry_columns_statistics violates constraint:
virt_geometry value must not contain a double quote') WHERE NEW.virt_geometry LIKE ('%"%');
SELECT RAISE(ABORT,
             'insert on virts_geometry_columns_statistics violates constraint: virt_geometry value must be lower case') WHERE NEW.virt_geometry <> lower(NEW.virt_geometry);
END;
CREATE TRIGGER vtgcs_virt_geometry_update
    BEFORE UPDATE OF 'virt_geometry' ON 'virts_geometry_columns_statistics'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'update on virts_geometry_columns_statistics violates constraint: virt_geometry value must not contain a single quote') WHERE NEW.virt_geometry LIKE ('%''%');
SELECT RAISE(ABORT, 'update on virts_geometry_columns_statistics violates constraint:
virt_geometry value must not contain a double quote') WHERE NEW.virt_geometry LIKE ('%"%');
SELECT RAISE(ABORT,
             'update on virts_geometry_columns_statistics violates constraint: virt_geometry value must be lower case') WHERE NEW.virt_geometry <> lower(NEW.virt_geometry);
END;
CREATE TABLE geometry_columns_field_infos
(
    f_table_name      TEXT    NOT NULL,
    f_geometry_column TEXT    NOT NULL,
    ordinal           INTEGER NOT NULL,
    column_name       TEXT    NOT NULL,
    null_values       INTEGER NOT NULL,
    integer_values    INTEGER NOT NULL,
    double_values     INTEGER NOT NULL,
    text_values       INTEGER NOT NULL,
    blob_values       INTEGER NOT NULL,
    max_size          INTEGER,
    integer_min       INTEGER,
    integer_max       INTEGER,
    double_min        DOUBLE,
    double_max        DOUBLE,
    CONSTRAINT pk_gcfld_infos PRIMARY KEY (f_table_name, f_geometry_column, ordinal, column_name),
    CONSTRAINT fk_gcfld_infos FOREIGN KEY (f_table_name, f_geometry_column) REFERENCES geometry_columns (f_table_name, f_geometry_column) ON DELETE CASCADE
);
CREATE TRIGGER gcfi_f_table_name_insert
    BEFORE INSERT
    ON 'geometry_columns_field_infos'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'insert on geometry_columns_field_infos violates constraint: f_table_name value must not contain a single quote') WHERE NEW.f_table_name LIKE ('%''%');
SELECT RAISE(ABORT,
             'insert on geometry_columns_field_infos violates constraint: f_table_name value must not contain a double quote') WHERE NEW.f_table_name LIKE ('%"%');
SELECT RAISE(ABORT, 'insert on geometry_columns_field_infos violates constraint:
f_table_name value must be lower case') WHERE NEW.f_table_name <> lower(NEW.f_table_name);
END;
CREATE TRIGGER gcfi_f_table_name_update
    BEFORE UPDATE OF 'f_table_name' ON 'geometry_columns_field_infos'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'update on geometry_columns_field_infos violates constraint: f_table_name value must not contain a single quote') WHERE NEW.f_table_name LIKE ('%''%');
SELECT RAISE(ABORT,
             'update on geometry_columns_field_infos violates constraint: f_table_name value must not contain a double quote') WHERE NEW.f_table_name LIKE ('%"%');
SELECT RAISE(ABORT,
             'update on geometry_columns_field_infos violates constraint: f_table_name value must be lower case') WHERE NEW.f_table_name <> lower(NEW.f_table_name);
END;
CREATE TRIGGER gcfi_f_geometry_column_insert
    BEFORE INSERT
    ON 'geometry_columns_field_infos'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'insert on geometry_columns_field_infos violates constraint: f_geometry_column value must not contain a single quote') WHERE NEW.f_geometry_column LIKE ('%''%');
SELECT RAISE(ABORT, 'insert on geometry_columns_field_infos violates constraint:
f_geometry_column value must not contain a double quote') WHERE NEW.f_geometry_column LIKE ('%"%');
SELECT RAISE(ABORT,
             'insert on geometry_columns_field_infos violates constraint: f_geometry_column value must be lower case') WHERE NEW.f_geometry_column <> lower(NEW.f_geometry_column);
END;
CREATE TRIGGER gcfi_f_geometry_column_update
    BEFORE UPDATE OF 'f_geometry_column' ON 'geometry_columns_field_infos'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'update on geometry_columns_field_infos violates constraint: f_geometry_column value must not contain a single quote') WHERE NEW.f_geometry_column LIKE ('%''%');
SELECT RAISE(ABORT,
             'update on geometry_columns_field_infos violates constraint: f_geometry_column value must not contain a double quote') WHERE NEW.f_geometry_column LIKE ('%"%');
SELECT RAISE(ABORT,
             'update on geometry_columns_field_infos violates constraint: f_geometry_column value must be lower case') WHERE NEW.f_geometry_column <> lower(NEW.f_geometry_column);
END;
CREATE TABLE views_geometry_columns_field_infos
(
    view_name      TEXT    NOT NULL,
    view_geometry  TEXT    NOT NULL,
    ordinal        INTEGER NOT NULL,
    column_name    TEXT    NOT NULL,
    null_values    INTEGER NOT NULL,
    integer_values INTEGER NOT NULL,
    double_values  INTEGER NOT NULL,
    text_values    INTEGER NOT NULL,
    blob_values    INTEGER NOT NULL,
    max_size       INTEGER,
    integer_min    INTEGER,
    integer_max    INTEGER,
    double_min     DOUBLE,
    double_max     DOUBLE,
    CONSTRAINT pk_vwgcfld_infos PRIMARY KEY (view_name, view_geometry, ordinal, column_name),
    CONSTRAINT fk_vwgcfld_infos FOREIGN KEY (view_name, view_geometry) REFERENCES views_geometry_columns (view_name, view_geometry) ON DELETE CASCADE
);
CREATE TRIGGER vwgcfi_view_name_insert
    BEFORE INSERT
    ON 'views_geometry_columns_field_infos'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'insert on views_geometry_columns_field_infos violates constraint: view_name value must not contain a single quote') WHERE NEW.view_name LIKE ('%''%');
SELECT RAISE(ABORT,
             'insert on views_geometry_columns_field_infos violates constraint: view_name value must not contain a double quote') WHERE NEW.view_name LIKE ('%"%');
SELECT RAISE(ABORT, 'insert on views_geometry_columns_field_infos violates constraint:
view_name value must be lower case') WHERE NEW.view_name <> lower(NEW.view_name);
END;
CREATE TRIGGER vwgcfi_view_name_update
    BEFORE UPDATE OF 'view_name' ON 'views_geometry_columns_field_infos'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'update on views_geometry_columns_field_infos violates constraint: view_name value must not contain a single quote') WHERE NEW.view_name LIKE ('%''%');
SELECT RAISE(ABORT,
             'update on views_geometry_columns_field_infos violates constraint: view_name value must not contain a double quote') WHERE NEW.view_name LIKE ('%"%');
SELECT RAISE(ABORT,
             'update on views_geometry_columns_field_infos violates constraint: view_name value must be lower case') WHERE NEW.view_name <> lower(NEW.view_name);
END;
CREATE TRIGGER vwgcfi_view_geometry_insert
    BEFORE INSERT
    ON 'views_geometry_columns_field_infos'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'insert on views_geometry_columns_field_infos violates constraint: view_geometry value must not contain a single quote') WHERE NEW.view_geometry LIKE ('%''%');
SELECT RAISE(ABORT, 'insert on views_geometry_columns_field_infos violates constraint:
view_geometry value must not contain a double quote') WHERE NEW.view_geometry LIKE ('%"%');
SELECT RAISE(ABORT,
             'insert on views_geometry_columns_field_infos violates constraint: view_geometry value must be lower case') WHERE NEW.view_geometry <> lower(NEW.view_geometry);
END;
CREATE TRIGGER vwgcfi_view_geometry_update
    BEFORE UPDATE OF 'view_geometry' ON 'views_geometry_columns_field_infos'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'update on views_geometry_columns_field_infos violates constraint: view_geometry value must not contain a single quote') WHERE NEW.view_geometry LIKE ('%''%');
SELECT RAISE(ABORT, 'update on views_geometry_columns_field_infos violates constraint:
view_geometry value must not contain a double quote') WHERE NEW.view_geometry LIKE ('%"%');
SELECT RAISE(ABORT,
             'update on views_geometry_columns_field_infos violates constraint: view_geometry value must be lower case') WHERE NEW.view_geometry <> lower(NEW.view_geometry);
END;
CREATE TABLE virts_geometry_columns_field_infos
(
    virt_name      TEXT    NOT NULL,
    virt_geometry  TEXT    NOT NULL,
    ordinal        INTEGER NOT NULL,
    column_name    TEXT    NOT NULL,
    null_values    INTEGER NOT NULL,
    integer_values INTEGER NOT NULL,
    double_values  INTEGER NOT NULL,
    text_values    INTEGER NOT NULL,
    blob_values    INTEGER NOT NULL,
    max_size       INTEGER,
    integer_min    INTEGER,
    integer_max    INTEGER,
    double_min     DOUBLE,
    double_max     DOUBLE,
    CONSTRAINT pk_vrtgcfld_infos PRIMARY KEY (virt_name, virt_geometry, ordinal, column_name),
    CONSTRAINT fk_vrtgcfld_infos FOREIGN KEY (virt_name, virt_geometry) REFERENCES virts_geometry_columns (virt_name, virt_geometry) ON DELETE CASCADE
);
CREATE TRIGGER vtgcfi_virt_name_insert
    BEFORE INSERT
    ON 'virts_geometry_columns_field_infos'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'insert on virts_geometry_columns_field_infos violates constraint: virt_name value must not contain a single quote') WHERE NEW.virt_name LIKE ('%''%');
SELECT RAISE(ABORT,
             'insert on virts_geometry_columns_field_infos violates constraint: virt_name value must not contain a double quote') WHERE NEW.virt_name LIKE ('%"%');
SELECT RAISE(ABORT, 'insert on virts_geometry_columns_field_infos violates constraint:
virt_name value must be lower case') WHERE NEW.virt_name <> lower(NEW.virt_name);
END;
CREATE TRIGGER vtgcfi_virt_name_update
    BEFORE UPDATE OF 'virt_name' ON 'virts_geometry_columns_field_infos'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'update on virts_geometry_columns_field_infos violates constraint: virt_name value must not contain a single quote') WHERE NEW.virt_name LIKE ('%''%');
SELECT RAISE(ABORT,
             'update on virts_geometry_columns_field_infos violates constraint: virt_name value must not contain a double quote') WHERE NEW.virt_name LIKE ('%"%');
SELECT RAISE(ABORT,
             'update on virts_geometry_columns_field_infos violates constraint: virt_name value must be lower case') WHERE NEW.virt_name <> lower(NEW.virt_name);
END;
CREATE TRIGGER vtgcfi_virt_geometry_insert
    BEFORE INSERT
    ON 'virts_geometry_columns_field_infos'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'insert on virts_geometry_columns_field_infos violates constraint: virt_geometry value must not contain a single quote') WHERE NEW.virt_geometry LIKE ('%''%');
SELECT RAISE(ABORT, 'insert on virts_geometry_columns_field_infos violates constraint:
virt_geometry value must not contain a double quote') WHERE NEW.virt_geometry LIKE ('%"%');
SELECT RAISE(ABORT,
             'insert on virts_geometry_columns_field_infos violates constraint: virt_geometry value must be lower case') WHERE NEW.virt_geometry <> lower(NEW.virt_geometry);
END;
CREATE TRIGGER vtgcfi_virt_geometry_update
    BEFORE UPDATE OF 'virt_geometry' ON 'virts_geometry_columns_field_infos'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'update on virts_geometry_columns_field_infos violates constraint: virt_geometry value must not contain a single quote') WHERE NEW.virt_geometry LIKE ('%''%');
SELECT RAISE(ABORT, 'update on virts_geometry_columns_field_infos violates constraint:
virt_geometry value must not contain a double quote') WHERE NEW.virt_geometry LIKE ('%"%');
SELECT RAISE(ABORT,
             'update on virts_geometry_columns_field_infos violates constraint: virt_geometry value must be lower case') WHERE NEW.virt_geometry <> lower(NEW.virt_geometry);
END;
CREATE TABLE geometry_columns_time
(
    f_table_name      TEXT      NOT NULL,
    f_geometry_column TEXT      NOT NULL,
    last_insert       TIMESTAMP NOT NULL DEFAULT '0000-01-01T00:00:00.000Z',
    last_update       TIMESTAMP NOT NULL DEFAULT '0000-01-01T00:00:00.000Z',
    last_delete       TIMESTAMP NOT NULL DEFAULT '0000-01-01T00:00:00.000Z',
    CONSTRAINT pk_gc_time PRIMARY KEY (f_table_name, f_geometry_column),
    CONSTRAINT fk_gc_time FOREIGN KEY (f_table_name, f_geometry_column) REFERENCES geometry_columns (f_table_name, f_geometry_column) ON DELETE CASCADE
);
CREATE TRIGGER gctm_f_table_name_insert
    BEFORE INSERT
    ON 'geometry_columns_time'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'insert on geometry_columns_time violates constraint: f_table_name value must not contain a single quote') WHERE NEW.f_table_name LIKE ('%''%');
SELECT RAISE(ABORT,
             'insert on geometry_columns_time violates constraint: f_table_name value must not contain a double quote') WHERE NEW.f_table_name LIKE ('%"%');
SELECT RAISE(ABORT, 'insert on geometry_columns_time violates constraint:
f_table_name value must be lower case') WHERE NEW.f_table_name <> lower(NEW.f_table_name);
END;
CREATE TRIGGER gctm_f_table_name_update
    BEFORE UPDATE OF 'f_table_name' ON 'geometry_columns_time'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'update on geometry_columns_time violates constraint: f_table_name value must not contain a single quote') WHERE NEW.f_table_name LIKE ('%''%');
SELECT RAISE(ABORT,
             'update on geometry_columns_time violates constraint: f_table_name value must not contain a double quote') WHERE NEW.f_table_name LIKE ('%"%');
SELECT RAISE(ABORT,
             'update on geometry_columns_time violates constraint: f_table_name value must be lower case') WHERE NEW.f_table_name <> lower(NEW.f_table_name);
END;
CREATE TRIGGER gctm_f_geometry_column_insert
    BEFORE INSERT
    ON 'geometry_columns_time'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'insert on geometry_columns_time violates constraint: f_geometry_column value must not contain a single quote') WHERE NEW.f_geometry_column LIKE ('%''%');
SELECT RAISE(ABORT, 'insert on geometry_columns_time violates constraint:
f_geometry_column value must not contain a double quote') WHERE NEW.f_geometry_column LIKE ('%"%');
SELECT RAISE(ABORT,
             'insert on geometry_columns_time violates constraint: f_geometry_column value must be lower case') WHERE NEW.f_geometry_column <> lower(NEW.f_geometry_column);
END;
CREATE TRIGGER gctm_f_geometry_column_update
    BEFORE UPDATE OF 'f_geometry_column' ON 'geometry_columns_time'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'update on geometry_columns_time violates constraint: f_geometry_column value must not contain a single quote') WHERE NEW.f_geometry_column LIKE ('%''%');
SELECT RAISE(ABORT,
             'update on geometry_columns_time violates constraint: f_geometry_column value must not contain a double quote') WHERE NEW.f_geometry_column LIKE ('%"%');
SELECT RAISE(ABORT,
             'update on geometry_columns_time violates constraint: f_geometry_column value must be lower case') WHERE NEW.f_geometry_column <> lower(NEW.f_geometry_column);
END;
CREATE TABLE geometry_columns_auth
(
    f_table_name      TEXT    NOT NULL,
    f_geometry_column TEXT    NOT NULL,
    read_only         INTEGER NOT NULL,
    hidden            INTEGER NOT NULL,
    CONSTRAINT pk_gc_auth PRIMARY KEY (f_table_name, f_geometry_column),
    CONSTRAINT fk_gc_auth FOREIGN KEY (f_table_name, f_geometry_column) REFERENCES geometry_columns (f_table_name, f_geometry_column) ON DELETE CASCADE,
    CONSTRAINT ck_gc_ronly CHECK (read_only IN (0, 1)),
    CONSTRAINT ck_gc_hidden CHECK (hidden IN (0, 1))
);
CREATE TRIGGER gcau_f_table_name_insert
    BEFORE INSERT
    ON 'geometry_columns_auth'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'insert on geometry_columns_auth violates constraint: f_table_name value must not contain a single quote') WHERE NEW.f_table_name LIKE ('%''%');
SELECT RAISE(ABORT,
             'insert on geometry_columns_auth violates constraint: f_table_name value must not contain a double quote') WHERE NEW.f_table_name LIKE ('%"%');
SELECT RAISE(ABORT, 'insert on geometry_columns_auth violates constraint:
f_table_name value must be lower case') WHERE NEW.f_table_name <> lower(NEW.f_table_name);
END;
CREATE TRIGGER gcau_f_table_name_update
    BEFORE UPDATE OF 'f_table_name' ON 'geometry_columns_auth'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'update on geometry_columns_auth violates constraint: f_table_name value must not contain a single quote') WHERE NEW.f_table_name LIKE ('%''%');
SELECT RAISE(ABORT,
             'update on geometry_columns_auth violates constraint: f_table_name value must not contain a double quote') WHERE NEW.f_table_name LIKE ('%"%');
SELECT RAISE(ABORT,
             'update on geometry_columns_auth violates constraint: f_table_name value must be lower case') WHERE NEW.f_table_name <> lower(NEW.f_table_name);
END;
CREATE TRIGGER gcau_f_geometry_column_insert
    BEFORE INSERT
    ON 'geometry_columns_auth'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'insert on geometry_columns_auth violates constraint: f_geometry_column value must not contain a single quote') WHERE NEW.f_geometry_column LIKE ('%''%');
SELECT RAISE(ABORT, 'insert on geometry_columns_auth violates constraint:
f_geometry_column value must not contain a double quote') WHERE NEW.f_geometry_column LIKE ('%"%');
SELECT RAISE(ABORT,
             'insert on geometry_columns_auth violates constraint: f_geometry_column value must be lower case') WHERE NEW.f_geometry_column <> lower(NEW.f_geometry_column);
END;
CREATE TRIGGER gcau_f_geometry_column_update
    BEFORE UPDATE OF 'f_geometry_column' ON 'geometry_columns_auth'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'update on geometry_columns_auth violates constraint: f_geometry_column value must not contain a single quote') WHERE NEW.f_geometry_column LIKE ('%''%');
SELECT RAISE(ABORT,
             'update on geometry_columns_auth violates constraint: f_geometry_column value must not contain a double quote') WHERE NEW.f_geometry_column LIKE ('%"%');
SELECT RAISE(ABORT,
             'update on geometry_columns_auth violates constraint: f_geometry_column value must be lower case') WHERE NEW.f_geometry_column <> lower(NEW.f_geometry_column);
END;
CREATE TABLE views_geometry_columns_auth
(
    view_name     TEXT    NOT NULL,
    view_geometry TEXT    NOT NULL,
    hidden        INTEGER NOT NULL,
    CONSTRAINT pk_vwgc_auth PRIMARY KEY (view_name, view_geometry),
    CONSTRAINT fk_vwgc_auth FOREIGN KEY (view_name, view_geometry) REFERENCES views_geometry_columns (view_name, view_geometry) ON DELETE CASCADE,
    CONSTRAINT ck_vwgc_hidden CHECK (hidden IN (0, 1))
);
CREATE TRIGGER vwgcau_view_name_insert
    BEFORE INSERT
    ON 'views_geometry_columns_auth'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'insert on views_geometry_columns_auth violates constraint: view_name value must not contain a single quote') WHERE NEW.view_name LIKE ('%''%');
SELECT RAISE(ABORT,
             'insert on views_geometry_columns_auth violates constraint: view_name value must not contain a double quote') WHERE NEW.view_name LIKE ('%"%');
SELECT RAISE(ABORT, 'insert on views_geometry_columns_auth violates constraint:
view_name value must be lower case') WHERE NEW.view_name <> lower(NEW.view_name);
END;
CREATE TRIGGER vwgcau_view_name_update
    BEFORE UPDATE OF 'view_name' ON 'views_geometry_columns_auth'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'update on views_geometry_columns_auth violates constraint: view_name value must not contain a single quote') WHERE NEW.view_name LIKE ('%''%');
SELECT RAISE(ABORT,
             'update on views_geometry_columns_auth violates constraint: view_name value must not contain a double quote') WHERE NEW.view_name LIKE ('%"%');
SELECT RAISE(ABORT,
             'update on views_geometry_columns_auth violates constraint: view_name value must be lower case') WHERE NEW.view_name <> lower(NEW.view_name);
END;
CREATE TRIGGER vwgcau_view_geometry_insert
    BEFORE INSERT
    ON 'views_geometry_columns_auth'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'insert on views_geometry_columns_auth violates constraint: view_geometry value must not contain a single quote') WHERE NEW.view_geometry LIKE ('%''%');
SELECT RAISE(ABORT, 'insert on views_geometry_columns_auth violates constraint:
view_geometry value must not contain a double quote') WHERE NEW.view_geometry LIKE ('%"%');
SELECT RAISE(ABORT,
             'insert on views_geometry_columns_auth violates constraint: view_geometry value must be lower case') WHERE NEW.view_geometry <> lower(NEW.view_geometry);
END;
CREATE TRIGGER vwgcau_view_geometry_update
    BEFORE UPDATE OF 'view_geometry'  ON 'views_geometry_columns_auth'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'update on views_geometry_columns_auth violates constraint: view_geometry value must not contain a single quote') WHERE NEW.view_geometry LIKE ('%''%');
SELECT RAISE(ABORT, 'update on views_geometry_columns_auth violates constraint:
view_geometry value must not contain a double quote') WHERE NEW.view_geometry LIKE ('%"%');
SELECT RAISE(ABORT,
             'update on views_geometry_columns_auth violates constraint: view_geometry value must be lower case') WHERE NEW.view_geometry <> lower(NEW.view_geometry);
END;
CREATE TABLE virts_geometry_columns_auth
(
    virt_name     TEXT    NOT NULL,
    virt_geometry TEXT    NOT NULL,
    hidden        INTEGER NOT NULL,
    CONSTRAINT pk_vrtgc_auth PRIMARY KEY (virt_name, virt_geometry),
    CONSTRAINT fk_vrtgc_auth FOREIGN KEY (virt_name, virt_geometry) REFERENCES virts_geometry_columns (virt_name, virt_geometry) ON DELETE CASCADE,
    CONSTRAINT ck_vrtgc_hidden CHECK (hidden IN (0, 1))
);
CREATE TRIGGER vtgcau_virt_name_insert
    BEFORE INSERT
    ON 'virts_geometry_columns_auth'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'insert on virts_geometry_columns_auth violates constraint: virt_name value must not contain a single quote') WHERE NEW.virt_name LIKE ('%''%');
SELECT RAISE(ABORT,
             'insert on virts_geometry_columns_auth violates constraint: virt_name value must not contain a double quote') WHERE NEW.virt_name LIKE ('%"%');
SELECT RAISE(ABORT, 'insert on virts_geometry_columns_auth violates constraint:
virt_name value must be lower case') WHERE NEW.virt_name <> lower(NEW.virt_name);
END;
CREATE TRIGGER vtgcau_virt_name_update
    BEFORE UPDATE OF 'virt_name' ON 'virts_geometry_columns_auth'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'update on virts_geometry_columns_auth violates constraint: virt_name value must not contain a single quote') WHERE NEW.virt_name LIKE ('%''%');
SELECT RAISE(ABORT,
             'update on virts_geometry_columns_auth violates constraint: virt_name value must not contain a double quote') WHERE NEW.virt_name LIKE ('%"%');
SELECT RAISE(ABORT,
             'update on virts_geometry_columns_auth violates constraint: virt_name value must be lower case') WHERE NEW.virt_name <> lower(NEW.virt_name);
END;
CREATE TRIGGER vtgcau_virt_geometry_insert
    BEFORE INSERT
    ON 'virts_geometry_columns_auth'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'insert on virts_geometry_columns_auth violates constraint: virt_geometry value must not contain a single quote') WHERE NEW.virt_geometry LIKE ('%''%');
SELECT RAISE(ABORT, 'insert on virts_geometry_columns_auth violates constraint:
virt_geometry value must not contain a double quote') WHERE NEW.virt_geometry LIKE ('%"%');
SELECT RAISE(ABORT,
             'insert on virts_geometry_columns_auth violates constraint: virt_geometry value must be lower case') WHERE NEW.virt_geometry <> lower(NEW.virt_geometry);
END;
CREATE TRIGGER vtgcau_virt_geometry_update
    BEFORE UPDATE OF 'virt_geometry' ON 'virts_geometry_columns_auth'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'update on virts_geometry_columns_auth violates constraint: virt_geometry value must not contain a single quote') WHERE NEW.virt_geometry LIKE ('%''%');
SELECT RAISE(ABORT, 'update on virts_geometry_columns_auth violates constraint:
virt_geometry value must not contain a double quote') WHERE NEW.virt_geometry LIKE ('%"%');
SELECT RAISE(ABORT,
             'update on virts_geometry_columns_auth violates constraint: virt_geometry value must be lower case') WHERE NEW.virt_geometry <> lower(NEW.virt_geometry);
END;
CREATE VIEW vector_layers AS
SELECT 'SpatialTable'        AS layer_type,
       f_table_name          AS table_name,
       f_geometry_column     AS geometry_column,
       geometry_type         AS geometry_type,
       coord_dimension       AS coord_dimension,
       srid                  AS srid,
       spatial_index_enabled AS spatial_index_enabled
FROM geometry_columns
UNION
SELECT 'SpatialView'           AS layer_type,
       a.view_name             AS table_name,
       a.view_geometry         AS geometry_column,
       b.geometry_type         AS geometry_type,
       b.coord_dimension       AS coord_dimension,
       b.srid                  AS srid,
       b.spatial_index_enabled AS spatial_index_enabled
FROM views_geometry_columns AS a
         LEFT JOIN geometry_columns AS b ON (Upper(a.f_table_name) = Upper(b.f_table_name) AND
                                             Upper(a.f_geometry_column) = Upper(b.f_geometry_column))
UNION
SELECT 'VirtualShape'  AS layer_type,
       virt_name       AS table_name,
       virt_geometry   AS geometry_column,
       geometry_type   AS geometry_type,
       coord_dimension AS coord_dimension,
       srid            AS srid,
       0               AS spatial_index_enabled
FROM virts_geometry_columns
/* vector_layers(layer_type,table_name,geometry_column,geometry_type,coord_dimension,srid,spatial_index_enabled) */;
CREATE VIEW vector_layers_auth AS
SELECT 'SpatialTable'    AS layer_type,
       f_table_name      AS table_name,
       f_geometry_column AS geometry_column,
       read_only         AS read_only,
       hidden            AS hidden
FROM geometry_columns_auth
UNION
SELECT 'SpatialView'   AS layer_type,
       a.view_name     AS table_name,
       a.view_geometry AS geometry_column,
       b.read_only     AS read_only,
       a.hidden        AS hidden
FROM views_geometry_columns_auth AS a
         JOIN views_geometry_columns AS b
              ON (Upper(a.view_name) = Upper(b.view_name) AND Upper(a.view_geometry) = Upper(b.view_geometry))
UNION
SELECT 'VirtualShape' AS layer_type,
       virt_name      AS table_name,
       virt_geometry  AS geometry_column,
       1              AS read_only,
       hidden         AS hidden
FROM virts_geometry_columns_auth
/* vector_layers_auth(layer_type,table_name,geometry_column,read_only,hidden) */;
CREATE VIEW vector_layers_statistics AS
SELECT 'SpatialTable'    AS layer_type,
       f_table_name      AS table_name,
       f_geometry_column AS geometry_column,
       last_verified     AS last_verified,
       row_count         AS row_count,
       extent_min_x      AS extent_min_x,
       extent_min_y      AS extent_min_y,
       extent_max_x      AS extent_max_x,
       extent_max_y      AS extent_max_y
FROM geometry_columns_statistics
UNION
SELECT 'SpatialView' AS layer_type,
       view_name     AS table_name,
       view_geometry AS geometry_column,
       last_verified AS last_verified,
       row_count     AS row_count,
       extent_min_x  AS extent_min_x,
       extent_min_y  AS extent_min_y,
       extent_max_x  AS extent_max_x,
       extent_max_y  AS extent_max_y
FROM views_geometry_columns_statistics
UNION
SELECT 'VirtualShape' AS layer_type,
       virt_name      AS table_name,
       virt_geometry  AS geometry_column,
       last_verified  AS last_verified,
       row_count      AS row_count,
       extent_min_x   AS extent_min_x,
       extent_min_y   AS extent_min_y,
       extent_max_x   AS extent_max_x,
       extent_max_y   AS extent_max_y
FROM virts_geometry_columns_statistics
/* vector_layers_statistics(layer_type,table_name,geometry_column,last_verified,row_count,extent_min_x,extent_min_y,extent_max_x,extent_max_y) */;
CREATE VIEW vector_layers_field_infos AS
SELECT 'SpatialTable'    AS layer_type,
       f_table_name      AS table_name,
       f_geometry_column AS geometry_column,
       ordinal           AS ordinal,
       column_name       AS column_name,
       null_values       AS null_values,
       integer_values    AS integer_values,
       double_values     AS double_values,
       text_values       AS text_values,
       blob_values       AS blob_values,
       max_size          AS max_size,
       integer_min       AS integer_min,
       integer_max       AS integer_max,
       double_min        AS double_min,
       double_max           double_max
FROM geometry_columns_field_infos
UNION
SELECT 'SpatialView'  AS layer_type,
       view_name      AS table_name,
       view_geometry  AS geometry_column,
       ordinal        AS ordinal,
       column_name    AS column_name,
       null_values    AS null_values,
       integer_values AS integer_values,
       double_values  AS double_values,
       text_values    AS text_values,
       blob_values    AS blob_values,
       max_size       AS max_size,
       integer_min    AS integer_min,
       integer_max    AS integer_max,
       double_min     AS double_min,
       double_max        double_max
FROM views_geometry_columns_field_infos
UNION
SELECT 'VirtualShape' AS layer_type,
       virt_name      AS table_name,
       virt_geometry  AS geometry_column,
       ordinal        AS ordinal,
       column_name    AS column_name,
       null_values    AS null_values,
       integer_values AS integer_values,
       double_values  AS double_values,
       text_values    AS text_values,
       blob_values    AS blob_values,
       max_size       AS max_size,
       integer_min    AS integer_min,
       integer_max    AS integer_max,
       double_min     AS double_min,
       double_max        double_max
FROM virts_geometry_columns_field_infos
/* vector_layers_field_infos(layer_type,table_name,geometry_column,ordinal,column_name,null_values,integer_values,double_values,text_values,blob_values,max_size,integer_min,integer_max,double_min,double_max) */;
CREATE TABLE data_licenses
(
    id   INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE,
    url  TEXT
);
CREATE TABLE sql_statements_log
(
    id            INTEGER PRIMARY KEY AUTOINCREMENT,
    time_start    TIMESTAMP NOT NULL DEFAULT '0000-01-01T00:00:00.000Z',
    time_end      TIMESTAMP NOT NULL DEFAULT '0000-01-01T00:00:00.000Z',
    user_agent    TEXT      NOT NULL,
    sql_statement TEXT      NOT NULL,
    success       INTEGER   NOT NULL DEFAULT 0,
    error_cause   TEXT      NOT NULL DEFAULT 'ABORTED',
    CONSTRAINT sqllog_success CHECK (success IN (0, 1))
);
CREATE
VIRTUAL TABLE SpatialIndex USING VirtualSpatialIndex();
CREATE
VIRTUAL TABLE ElementaryGeometries USING VirtualElementary();
CREATE
VIRTUAL TABLE KNN USING VirtualKNN();
CREATE TABLE IF NOT EXISTS "ad_types"
(
    "id"
    integer
    NOT
    NULL
    PRIMARY
    KEY
    AUTOINCREMENT,
    "value"
    text
(
    20
) NOT NULL
    );
CREATE UNIQUE INDEX "ad_types_value" ON "ad_types" ("value");
CREATE TABLE IF NOT EXISTS "ads"
(
    "id"
    integer
    NOT
    NULL
    PRIMARY
    KEY
    AUTOINCREMENT,
    "title"
    text
    NOT
    NULL,
    "locality"
    text
    NOT
    NULL,
    "price"
    integer
    NOT
    NULL,
    "company"
    text
    NULL,
    "seller"
    text
    NOT
    NULL,
    "building_type"
    text
    NOT
    NULL,
    "ownership"
    text
    NULL,
    "floor"
    integer
    NULL,
    "usable_area"
    integer
    NOT
    NULL,
    "floor_area"
    integer
    NULL,
    "energy_intensity"
    text
    NOT
    NULL,
    "parking"
    integer
    NOT
    NULL,
    "elevator"
    numeric
    NOT
    NULL,
    "terrace"
    integer
    NOT
    NULL,
    "ad_type_id"
    integer
    NOT
    NULL,
    "coordinates"
    POINT,
    FOREIGN
    KEY
(
    "ad_type_id"
) REFERENCES "ad_types"
(
    "id"
) ON DELETE RESTRICT
  ON UPDATE NO ACTION
    );
CREATE TABLE IF NOT EXISTS "districts"
(
    "id"
    integer
    NOT
    NULL
    PRIMARY
    KEY
    AUTOINCREMENT,
    "name"
    text
    NOT
    NULL,
    "coordinates"
    POLYGON
);
CREATE UNIQUE INDEX "districts_name" ON "districts" ("name");
CREATE TABLE IF NOT EXISTS "pois"
(
    "id"
    integer
    NOT
    NULL
    PRIMARY
    KEY
    AUTOINCREMENT,
    "name"
    text
    NOT
    NULL,
    "description"
    text
    NOT
    NULL,
    "coordinates"
    POINT
);
CREATE TABLE IF NOT EXISTS "stations"
(
    "id"
    integer
    NOT
    NULL
    PRIMARY
    KEY
    AUTOINCREMENT,
    "name"
    text
    NOT
    NULL,
    "barrier_free"
    numeric
    NOT
    NULL,
    "coordinates"
    POINT
);
CREATE TABLE IF NOT EXISTS "tariff_bands"
(
    "id"
    integer
    NOT
    NULL
    PRIMARY
    KEY
    AUTOINCREMENT,
    "name"
    text
    NOT
    NULL,
    "coordinates"
    MULTIPOLYGON
);
CREATE UNIQUE INDEX "tariff_bands_name" ON "tariff_bands" ("name");
CREATE TABLE IF NOT EXISTS "transport_lines"
(
    "id"
    integer
    NOT
    NULL
    PRIMARY
    KEY
    AUTOINCREMENT,
    "short_name"
    text
    NOT
    NULL,
    "long_name"
    text
    NOT
    NULL,
    "night_traffic"
    numeric
    NOT
    NULL,
    "coordinates"
    MULTILINESTRING
);
CREATE TRIGGER "ggi_ads_coordinates"
    BEFORE INSERT
    ON "ads"
    FOR EACH ROW
BEGIN
    SELECT RAISE(ROLLBACK, 'ads.coordinates violates Geometry constraint [geom-type or SRID not allowed]') WHERE (SELECT geometry_type FROM geometry_columns
WHERE Lower(f_table_name) = Lower('ads') AND Lower(f_geometry_column) = Lower('coordinates')
AND GeometryConstraints(NEW."coordinates", geometry_type, srid) = 1) IS NULL;
END;
CREATE TRIGGER "ggu_ads_coordinates"
    BEFORE UPDATE OF "coordinates"
    ON "ads"
    FOR EACH ROW
BEGIN
    SELECT RAISE(ROLLBACK, 'ads.coordinates violates Geometry constraint [geom-type or SRID not allowed]') WHERE (SELECT geometry_type FROM geometry_columns
WHERE Lower(f_table_name) = Lower('ads') AND Lower(f_geometry_column) = Lower('coordinates')
AND GeometryConstraints(NEW."coordinates", geometry_type, srid) = 1) IS NULL;
END;
CREATE TRIGGER "tmu_ads_coordinates"
    AFTER UPDATE
    ON "ads"
    FOR EACH ROW
BEGIN
    UPDATE geometry_columns_time
    SET last_update = strftime('%Y-%m-%dT%H:%M:%fZ', 'now')
    WHERE Lower(f_table_name) = Lower('ads')
      AND Lower(f_geometry_column) = Lower('coordinates');
END;
CREATE TRIGGER "tmi_ads_coordinates"
    AFTER INSERT
    ON "ads"
    FOR EACH ROW
BEGIN
    UPDATE geometry_columns_time
    SET last_insert = strftime('%Y-%m-%dT%H:%M:%fZ', 'now')
    WHERE Lower(f_table_name) = Lower('ads')
      AND Lower(f_geometry_column) = Lower('coordinates');
END;
CREATE TRIGGER "tmd_ads_coordinates"
    AFTER DELETE
    ON "ads"
    FOR EACH ROW
BEGIN
    UPDATE geometry_columns_time
    SET last_delete = strftime('%Y-%m-%dT%H:%M:%fZ', 'now')
    WHERE Lower(f_table_name) = Lower('ads')
      AND Lower(f_geometry_column) = Lower('coordinates');
END;
CREATE TRIGGER "gii_ads_coordinates"
    AFTER INSERT
    ON "ads"
    FOR EACH ROW
BEGIN
    DELETE FROM "idx_ads_coordinates" WHERE pkid = NEW.ROWID;
    SELECT RTreeAlign('idx_ads_coordinates', NEW.ROWID, NEW."coordinates");
END;
CREATE TRIGGER "giu_ads_coordinates"
    AFTER UPDATE OF "coordinates"
    ON "ads"
    FOR EACH ROW
BEGIN
    DELETE FROM "idx_ads_coordinates" WHERE pkid = NEW.ROWID;
    SELECT RTreeAlign('idx_ads_coordinates', NEW.ROWID, NEW."coordinates");
END;
CREATE TRIGGER "gid_ads_coordinates"
    AFTER DELETE
    ON "ads"
    FOR EACH ROW
BEGIN
    DELETE FROM "idx_ads_coordinates" WHERE pkid = OLD.ROWID;
END;
CREATE
VIRTUAL TABLE "idx_ads_coordinates" USING rtree(pkid, xmin, xmax, ymin, ymax)
/* idx_ads_coordinates(pkid,xmin,xmax,ymin,ymax) */;
CREATE TABLE IF NOT EXISTS "idx_ads_coordinates_rowid"
(
    rowid
    INTEGER
    PRIMARY
    KEY,
    nodeno
);
CREATE TABLE IF NOT EXISTS "idx_ads_coordinates_node"
(
    nodeno
    INTEGER
    PRIMARY
    KEY,
    data
);
CREATE TABLE IF NOT EXISTS "idx_ads_coordinates_parent"
(
    nodeno
    INTEGER
    PRIMARY
    KEY,
    parentnode
);
CREATE TRIGGER "ggi_pois_coordinates"
    BEFORE INSERT
    ON "pois"
    FOR EACH ROW
BEGIN
    SELECT RAISE(ROLLBACK, 'pois.coordinates violates Geometry constraint [geom-type or SRID not allowed]') WHERE (SELECT geometry_type FROM geometry_columns
WHERE Lower(f_table_name) = Lower('pois') AND Lower(f_geometry_column) = Lower('coordinates')
AND GeometryConstraints(NEW."coordinates", geometry_type, srid) = 1) IS NULL;
END;
CREATE TRIGGER "ggu_pois_coordinates"
    BEFORE UPDATE OF "coordinates"
    ON "pois"
    FOR EACH ROW
BEGIN
    SELECT RAISE(ROLLBACK, 'pois.coordinates violates Geometry constraint [geom-type or SRID not allowed]') WHERE (SELECT geometry_type FROM geometry_columns
WHERE Lower(f_table_name) = Lower('pois') AND Lower(f_geometry_column) = Lower('coordinates')
AND GeometryConstraints(NEW."coordinates", geometry_type, srid) = 1) IS NULL;
END;
CREATE TRIGGER "tmu_pois_coordinates"
    AFTER UPDATE
    ON "pois"
    FOR EACH ROW
BEGIN
    UPDATE geometry_columns_time
    SET last_update = strftime('%Y-%m-%dT%H:%M:%fZ', 'now')
    WHERE Lower(f_table_name) = Lower('pois')
      AND Lower(f_geometry_column) = Lower('coordinates');
END;
CREATE TRIGGER "tmi_pois_coordinates"
    AFTER INSERT
    ON "pois"
    FOR EACH ROW
BEGIN
    UPDATE geometry_columns_time
    SET last_insert = strftime('%Y-%m-%dT%H:%M:%fZ', 'now')
    WHERE Lower(f_table_name) = Lower('pois')
      AND Lower(f_geometry_column) = Lower('coordinates');
END;
CREATE TRIGGER "tmd_pois_coordinates"
    AFTER DELETE
    ON "pois"
    FOR EACH ROW
BEGIN
    UPDATE geometry_columns_time
    SET last_delete = strftime('%Y-%m-%dT%H:%M:%fZ', 'now')
    WHERE Lower(f_table_name) = Lower('pois')
      AND Lower(f_geometry_column) = Lower('coordinates');
END;
CREATE TRIGGER "gii_pois_coordinates"
    AFTER INSERT
    ON "pois"
    FOR EACH ROW
BEGIN
    DELETE FROM "idx_pois_coordinates" WHERE pkid = NEW.ROWID;
    SELECT RTreeAlign('idx_pois_coordinates', NEW.ROWID, NEW."coordinates");
END;
CREATE TRIGGER "giu_pois_coordinates"
    AFTER UPDATE OF "coordinates"
    ON "pois"
    FOR EACH ROW
BEGIN
    DELETE FROM "idx_pois_coordinates" WHERE pkid = NEW.ROWID;
    SELECT RTreeAlign('idx_pois_coordinates', NEW.ROWID, NEW."coordinates");
END;
CREATE TRIGGER "gid_pois_coordinates"
    AFTER DELETE
    ON "pois"
    FOR EACH ROW
BEGIN
    DELETE FROM "idx_pois_coordinates" WHERE pkid = OLD.ROWID;
END;
CREATE
VIRTUAL TABLE "idx_pois_coordinates" USING rtree(pkid, xmin, xmax, ymin, ymax)
/* idx_pois_coordinates(pkid,xmin,xmax,ymin,ymax) */;
CREATE TABLE IF NOT EXISTS "idx_pois_coordinates_rowid"
(
    rowid
    INTEGER
    PRIMARY
    KEY,
    nodeno
);
CREATE TABLE IF NOT EXISTS "idx_pois_coordinates_node"
(
    nodeno
    INTEGER
    PRIMARY
    KEY,
    data
);
CREATE TABLE IF NOT EXISTS "idx_pois_coordinates_parent"
(
    nodeno
    INTEGER
    PRIMARY
    KEY,
    parentnode
);
CREATE TRIGGER "ggi_stations_coordinates"
    BEFORE INSERT
    ON "stations"
    FOR EACH ROW
BEGIN
    SELECT RAISE(ROLLBACK, 'stations.coordinates violates Geometry constraint [geom-type or SRID not allowed]') WHERE (SELECT geometry_type FROM geometry_columns
WHERE Lower(f_table_name) = Lower('stations') AND Lower(f_geometry_column) = Lower('coordinates')
AND GeometryConstraints(NEW."coordinates", geometry_type, srid) = 1) IS NULL;
END;
CREATE TRIGGER "ggu_stations_coordinates"
    BEFORE UPDATE OF "coordinates"
    ON "stations"
    FOR EACH ROW
BEGIN
    SELECT RAISE(ROLLBACK, 'stations.coordinates violates Geometry constraint [geom-type or SRID not allowed]') WHERE (SELECT geometry_type FROM geometry_columns
WHERE Lower(f_table_name) = Lower('stations') AND Lower(f_geometry_column) = Lower('coordinates')
AND GeometryConstraints(NEW."coordinates", geometry_type, srid) = 1) IS NULL;
END;
CREATE TRIGGER "tmu_stations_coordinates"
    AFTER UPDATE
    ON "stations"
    FOR EACH ROW
BEGIN
    UPDATE geometry_columns_time
    SET last_update = strftime('%Y-%m-%dT%H:%M:%fZ', 'now')
    WHERE Lower(f_table_name) = Lower('stations')
      AND Lower(f_geometry_column) = Lower('coordinates');
END;
CREATE TRIGGER "tmi_stations_coordinates"
    AFTER INSERT
    ON "stations"
    FOR EACH ROW
BEGIN
    UPDATE geometry_columns_time
    SET last_insert = strftime('%Y-%m-%dT%H:%M:%fZ', 'now')
    WHERE Lower(f_table_name) = Lower('stations')
      AND Lower(f_geometry_column) = Lower('coordinates');
END;
CREATE TRIGGER "tmd_stations_coordinates"
    AFTER DELETE
    ON "stations"
    FOR EACH ROW
BEGIN
    UPDATE geometry_columns_time
    SET last_delete = strftime('%Y-%m-%dT%H:%M:%fZ', 'now')
    WHERE Lower(f_table_name) = Lower('stations')
      AND Lower(f_geometry_column) = Lower('coordinates');
END;
CREATE TRIGGER "gii_stations_coordinates"
    AFTER INSERT
    ON "stations"
    FOR EACH ROW
BEGIN
    DELETE FROM "idx_stations_coordinates" WHERE pkid = NEW.ROWID;
    SELECT RTreeAlign('idx_stations_coordinates', NEW.ROWID, NEW."coordinates");
END;
CREATE TRIGGER "giu_stations_coordinates"
    AFTER UPDATE OF "coordinates"
    ON "stations"
    FOR EACH ROW
BEGIN
    DELETE FROM "idx_stations_coordinates" WHERE pkid = NEW.ROWID;
    SELECT RTreeAlign('idx_stations_coordinates', NEW.ROWID, NEW."coordinates");
END;
CREATE TRIGGER "gid_stations_coordinates"
    AFTER DELETE
    ON "stations"
    FOR EACH ROW
BEGIN
    DELETE FROM "idx_stations_coordinates" WHERE pkid = OLD.ROWID;
END;
CREATE
VIRTUAL TABLE "idx_stations_coordinates" USING rtree(pkid, xmin, xmax, ymin, ymax)
/* idx_stations_coordinates(pkid,xmin,xmax,ymin,ymax) */;
CREATE TABLE IF NOT EXISTS "idx_stations_coordinates_rowid"
(
    rowid
    INTEGER
    PRIMARY
    KEY,
    nodeno
);
CREATE TABLE IF NOT EXISTS "idx_stations_coordinates_node"
(
    nodeno
    INTEGER
    PRIMARY
    KEY,
    data
);
CREATE TABLE IF NOT EXISTS "idx_stations_coordinates_parent"
(
    nodeno
    INTEGER
    PRIMARY
    KEY,
    parentnode
);
CREATE TRIGGER "ggi_transport_lines_coordinates"
    BEFORE INSERT
    ON "transport_lines"
    FOR EACH ROW
BEGIN
    SELECT RAISE(ROLLBACK, 'transport_lines.coordinates violates Geometry constraint [geom-type or SRID not allowed]') WHERE (SELECT geometry_type FROM geometry_columns
WHERE Lower(f_table_name) = Lower('transport_lines') AND Lower(f_geometry_column) = Lower('coordinates')
AND GeometryConstraints(NEW."coordinates", geometry_type, srid) = 1) IS NULL;
END;
CREATE TRIGGER "ggu_transport_lines_coordinates"
    BEFORE UPDATE OF "coordinates"
    ON "transport_lines"
    FOR EACH ROW
BEGIN
    SELECT RAISE(ROLLBACK, 'transport_lines.coordinates violates Geometry constraint [geom-type or SRID not allowed]') WHERE (SELECT geometry_type FROM geometry_columns
WHERE Lower(f_table_name) = Lower('transport_lines') AND Lower(f_geometry_column) = Lower('coordinates')
AND GeometryConstraints(NEW."coordinates", geometry_type, srid) = 1) IS NULL;
END;
CREATE TRIGGER "tmu_transport_lines_coordinates"
    AFTER UPDATE
    ON "transport_lines"
    FOR EACH ROW
BEGIN
    UPDATE geometry_columns_time
    SET last_update = strftime('%Y-%m-%dT%H:%M:%fZ', 'now')
    WHERE Lower(f_table_name) = Lower('transport_lines')
      AND Lower(f_geometry_column) = Lower('coordinates');
END;
CREATE TRIGGER "tmi_transport_lines_coordinates"
    AFTER INSERT
    ON "transport_lines"
    FOR EACH ROW
BEGIN
    UPDATE geometry_columns_time
    SET last_insert = strftime('%Y-%m-%dT%H:%M:%fZ', 'now')
    WHERE Lower(f_table_name) = Lower('transport_lines')
      AND Lower(f_geometry_column) = Lower('coordinates');
END;
CREATE TRIGGER "tmd_transport_lines_coordinates"
    AFTER DELETE
    ON "transport_lines"
    FOR EACH ROW
BEGIN
    UPDATE geometry_columns_time
    SET last_delete = strftime('%Y-%m-%dT%H:%M:%fZ', 'now')
    WHERE Lower(f_table_name) = Lower('transport_lines')
      AND Lower(f_geometry_column) = Lower('coordinates');
END;
CREATE TRIGGER "gii_transport_lines_coordinates"
    AFTER INSERT
    ON "transport_lines"
    FOR EACH ROW
BEGIN
    DELETE FROM "idx_transport_lines_coordinates" WHERE pkid = NEW.ROWID;
    SELECT RTreeAlign('idx_transport_lines_coordinates', NEW.ROWID, NEW."coordinates");
END;
CREATE TRIGGER "giu_transport_lines_coordinates"
    AFTER UPDATE OF "coordinates"
    ON "transport_lines"
    FOR EACH ROW
BEGIN
    DELETE FROM "idx_transport_lines_coordinates" WHERE pkid = NEW.ROWID;
    SELECT RTreeAlign('idx_transport_lines_coordinates', NEW.ROWID, NEW."coordinates");
END;
CREATE TRIGGER "gid_transport_lines_coordinates"
    AFTER DELETE
    ON "transport_lines"
    FOR EACH ROW
BEGIN
    DELETE FROM "idx_transport_lines_coordinates" WHERE pkid = OLD.ROWID;
END;
CREATE
VIRTUAL TABLE "idx_transport_lines_coordinates" USING rtree(pkid, xmin, xmax, ymin, ymax)
/* idx_transport_lines_coordinates(pkid,xmin,xmax,ymin,ymax) */;
CREATE TABLE IF NOT EXISTS "idx_transport_lines_coordinates_rowid"
(
    rowid
    INTEGER
    PRIMARY
    KEY,
    nodeno
);
CREATE TABLE IF NOT EXISTS "idx_transport_lines_coordinates_node"
(
    nodeno
    INTEGER
    PRIMARY
    KEY,
    data
);
CREATE TABLE IF NOT EXISTS "idx_transport_lines_coordinates_parent"
(
    nodeno
    INTEGER
    PRIMARY
    KEY,
    parentnode
);
CREATE TRIGGER "ggi_tariff_bands_coordinates"
    BEFORE INSERT
    ON "tariff_bands"
    FOR EACH ROW
BEGIN
    SELECT RAISE(ROLLBACK, 'tariff_bands.coordinates violates Geometry constraint [geom-type or SRID not allowed]') WHERE (SELECT geometry_type FROM geometry_columns
WHERE Lower(f_table_name) = Lower('tariff_bands') AND Lower(f_geometry_column) = Lower('coordinates')
AND GeometryConstraints(NEW."coordinates", geometry_type, srid) = 1) IS NULL;
END;
CREATE TRIGGER "ggu_tariff_bands_coordinates"
    BEFORE UPDATE OF "coordinates"
    ON "tariff_bands"
    FOR EACH ROW
BEGIN
    SELECT RAISE(ROLLBACK, 'tariff_bands.coordinates violates Geometry constraint [geom-type or SRID not allowed]') WHERE (SELECT geometry_type FROM geometry_columns
WHERE Lower(f_table_name) = Lower('tariff_bands') AND Lower(f_geometry_column) = Lower('coordinates')
AND GeometryConstraints(NEW."coordinates", geometry_type, srid) = 1) IS NULL;
END;
CREATE TRIGGER "tmu_tariff_bands_coordinates"
    AFTER UPDATE
    ON "tariff_bands"
    FOR EACH ROW
BEGIN
    UPDATE geometry_columns_time
    SET last_update = strftime('%Y-%m-%dT%H:%M:%fZ', 'now')
    WHERE Lower(f_table_name) = Lower('tariff_bands')
      AND Lower(f_geometry_column) = Lower('coordinates');
END;
CREATE TRIGGER "tmi_tariff_bands_coordinates"
    AFTER INSERT
    ON "tariff_bands"
    FOR EACH ROW
BEGIN
    UPDATE geometry_columns_time
    SET last_insert = strftime('%Y-%m-%dT%H:%M:%fZ', 'now')
    WHERE Lower(f_table_name) = Lower('tariff_bands')
      AND Lower(f_geometry_column) = Lower('coordinates');
END;
CREATE TRIGGER "tmd_tariff_bands_coordinates"
    AFTER DELETE
    ON "tariff_bands"
    FOR EACH ROW
BEGIN
    UPDATE geometry_columns_time
    SET last_delete = strftime('%Y-%m-%dT%H:%M:%fZ', 'now')
    WHERE Lower(f_table_name) = Lower('tariff_bands')
      AND Lower(f_geometry_column) = Lower('coordinates');
END;
CREATE TRIGGER "gii_tariff_bands_coordinates"
    AFTER INSERT
    ON "tariff_bands"
    FOR EACH ROW
BEGIN
    DELETE FROM "idx_tariff_bands_coordinates" WHERE pkid = NEW.ROWID;
    SELECT RTreeAlign('idx_tariff_bands_coordinates', NEW.ROWID, NEW."coordinates");
END;
CREATE TRIGGER "giu_tariff_bands_coordinates"
    AFTER UPDATE OF "coordinates"
    ON "tariff_bands"
    FOR EACH ROW
BEGIN
    DELETE FROM "idx_tariff_bands_coordinates" WHERE pkid = NEW.ROWID;
    SELECT RTreeAlign('idx_tariff_bands_coordinates', NEW.ROWID, NEW."coordinates");
END;
CREATE TRIGGER "gid_tariff_bands_coordinates"
    AFTER DELETE
    ON "tariff_bands"
    FOR EACH ROW
BEGIN
    DELETE FROM "idx_tariff_bands_coordinates" WHERE pkid = OLD.ROWID;
END;
CREATE
VIRTUAL TABLE "idx_tariff_bands_coordinates" USING rtree(pkid, xmin, xmax, ymin, ymax)
/* idx_tariff_bands_coordinates(pkid,xmin,xmax,ymin,ymax) */;
CREATE TABLE IF NOT EXISTS "idx_tariff_bands_coordinates_rowid"
(
    rowid
    INTEGER
    PRIMARY
    KEY,
    nodeno
);
CREATE TABLE IF NOT EXISTS "idx_tariff_bands_coordinates_node"
(
    nodeno
    INTEGER
    PRIMARY
    KEY,
    data
);
CREATE TABLE IF NOT EXISTS "idx_tariff_bands_coordinates_parent"
(
    nodeno
    INTEGER
    PRIMARY
    KEY,
    parentnode
);
CREATE TRIGGER "ggi_districts_coordinates"
    BEFORE INSERT
    ON "districts"
    FOR EACH ROW
BEGIN
    SELECT RAISE(ROLLBACK, 'districts.coordinates violates Geometry constraint [geom-type or SRID not allowed]') WHERE (SELECT geometry_type FROM geometry_columns
WHERE Lower(f_table_name) = Lower('districts') AND Lower(f_geometry_column) = Lower('coordinates')
AND GeometryConstraints(NEW."coordinates", geometry_type, srid) = 1) IS NULL;
END;
CREATE TRIGGER "ggu_districts_coordinates"
    BEFORE UPDATE OF "coordinates"
    ON "districts"
    FOR EACH ROW
BEGIN
    SELECT RAISE(ROLLBACK, 'districts.coordinates violates Geometry constraint [geom-type or SRID not allowed]') WHERE (SELECT geometry_type FROM geometry_columns
WHERE Lower(f_table_name) = Lower('districts') AND Lower(f_geometry_column) = Lower('coordinates')
AND GeometryConstraints(NEW."coordinates", geometry_type, srid) = 1) IS NULL;
END;
CREATE TRIGGER "tmu_districts_coordinates"
    AFTER UPDATE
    ON "districts"
    FOR EACH ROW
BEGIN
    UPDATE geometry_columns_time
    SET last_update = strftime('%Y-%m-%dT%H:%M:%fZ', 'now')
    WHERE Lower(f_table_name) = Lower('districts')
      AND Lower(f_geometry_column) = Lower('coordinates');
END;
CREATE TRIGGER "tmi_districts_coordinates"
    AFTER INSERT
    ON "districts"
    FOR EACH ROW
BEGIN
    UPDATE geometry_columns_time
    SET last_insert = strftime('%Y-%m-%dT%H:%M:%fZ', 'now')
    WHERE Lower(f_table_name) = Lower('districts')
      AND Lower(f_geometry_column) = Lower('coordinates');
END;
CREATE TRIGGER "tmd_districts_coordinates"
    AFTER DELETE
    ON "districts"
    FOR EACH ROW
BEGIN
    UPDATE geometry_columns_time
    SET last_delete = strftime('%Y-%m-%dT%H:%M:%fZ', 'now')
    WHERE Lower(f_table_name) = Lower('districts')
      AND Lower(f_geometry_column) = Lower('coordinates');
END;
CREATE TRIGGER "gii_districts_coordinates"
    AFTER INSERT
    ON "districts"
    FOR EACH ROW
BEGIN
    DELETE FROM "idx_districts_coordinates" WHERE pkid = NEW.ROWID;
    SELECT RTreeAlign('idx_districts_coordinates', NEW.ROWID, NEW."coordinates");
END;
CREATE TRIGGER "giu_districts_coordinates"
    AFTER UPDATE OF "coordinates"
    ON "districts"
    FOR EACH ROW
BEGIN
    DELETE FROM "idx_districts_coordinates" WHERE pkid = NEW.ROWID;
    SELECT RTreeAlign('idx_districts_coordinates', NEW.ROWID, NEW."coordinates");
END;
CREATE TRIGGER "gid_districts_coordinates"
    AFTER DELETE
    ON "districts"
    FOR EACH ROW
BEGIN
    DELETE FROM "idx_districts_coordinates" WHERE pkid = OLD.ROWID;
END;
CREATE
VIRTUAL TABLE "idx_districts_coordinates" USING rtree(pkid, xmin, xmax, ymin, ymax)
/* idx_districts_coordinates(pkid,xmin,xmax,ymin,ymax) */;
CREATE TABLE IF NOT EXISTS "idx_districts_coordinates_rowid"
(
    rowid
    INTEGER
    PRIMARY
    KEY,
    nodeno
);
CREATE TABLE IF NOT EXISTS "idx_districts_coordinates_node"
(
    nodeno
    INTEGER
    PRIMARY
    KEY,
    data
);
CREATE TABLE IF NOT EXISTS "idx_districts_coordinates_parent"
(
    nodeno
    INTEGER
    PRIMARY
    KEY,
    parentnode
);
CREATE TABLE raster_coverages
(
    coverage_name     TEXT    NOT NULL PRIMARY KEY,
    title             TEXT    NOT NULL DEFAULT '*** missing Title ***',
    abstract          TEXT    NOT NULL DEFAULT '*** missing Abstract ***',
    sample_type       TEXT    NOT NULL DEFAULT '*** undefined ***',
    pixel_type        TEXT    NOT NULL DEFAULT '*** undefined ***',
    num_bands         INTEGER NOT NULL DEFAULT 1,
    compression       TEXT    NOT NULL DEFAULT 'NONE',
    quality           INTEGER NOT NULL DEFAULT 100,
    tile_width        INTEGER NOT NULL DEFAULT 512,
    tile_height       INTEGER NOT NULL DEFAULT 512,
    horz_resolution   DOUBLE  NOT NULL,
    vert_resolution   DOUBLE  NOT NULL,
    srid              INTEGER NOT NULL,
    nodata_pixel      BLOB    NOT NULL,
    palette           BLOB,
    statistics        BLOB,
    geo_minx          DOUBLE,
    geo_miny          DOUBLE,
    geo_maxx          DOUBLE,
    geo_maxy          DOUBLE,
    extent_minx       DOUBLE,
    extent_miny       DOUBLE,
    extent_maxx       DOUBLE,
    extent_maxy       DOUBLE,
    strict_resolution INTEGER NOT NULL,
    mixed_resolutions INTEGER NOT NULL,
    section_paths     INTEGER NOT NULL,
    section_md5       INTEGER NOT NULL,
    section_summary   INTEGER NOT NULL,
    is_queryable      INTEGER NOT NULL,
    red_band_index    INTEGER,
    green_band_index  INTEGER,
    blue_band_index   INTEGER,
    nir_band_index    INTEGER,
    enable_auto_ndvi  INTEGER,
    copyright         TEXT    NOT NULL DEFAULT '*** unknown ***',
    license           INTEGER NOT NULL DEFAULT 0,
    CONSTRAINT fk_rc_srs FOREIGN KEY (srid) REFERENCES spatial_ref_sys (srid),
    CONSTRAINT fk_rc_lic FOREIGN KEY (license) REFERENCES data_licenses (id)
);
CREATE TABLE raster_coverages_srid
(
    coverage_name TEXT    NOT NULL,
    srid          INTEGER NOT NULL,
    extent_minx   DOUBLE,
    extent_miny   DOUBLE,
    extent_maxx   DOUBLE,
    extent_maxy   DOUBLE,
    CONSTRAINT pk_raster_coverages_srid PRIMARY KEY (coverage_name, srid),
    CONSTRAINT fk_raster_coverages_srid FOREIGN KEY (coverage_name) REFERENCES raster_coverages (coverage_name) ON DELETE CASCADE,
    CONSTRAINT fk_raster_srid FOREIGN KEY (srid) REFERENCES spatial_ref_sys (srid)
);
CREATE VIEW raster_coverages_ref_sys AS
SELECT c.coverage_name     AS coverage_name,
       c.title             AS title,
       c.abstract          AS abstract,
       c.sample_type       AS sample_type,
       c.pixel_type        AS pixel_type,
       c.num_bands         AS num_bands,
       c.compression       AS compression,
       c.quality           AS quality,
       c.tile_width        AS tile_width,
       c.tile_height       AS tile_height,
       c.horz_resolution   AS horz_resolution,
       c.vert_resolution   AS vert_resolution,
       c.nodata_pixel      AS nodata_pixel,
       c.palette           AS palette,
       c.statistics        AS statistics,
       c.geo_minx          AS geo_minx,
       c.geo_miny          AS geo_miny,
       c.geo_maxx          AS geo_maxx,
       c.geo_maxy          AS geo_maxy,
       c.extent_minx       AS extent_minx,
       c.extent_miny       AS extent_miny,
       c.extent_maxx       AS extent_maxx,
       c.extent_maxy       AS extent_maxy,
       c.srid              AS srid,
       1                   AS native_srid,
       s.auth_name         AS auth_name,
       s.auth_srid         AS auth_srid,
       s.ref_sys_name      AS ref_sys_name,
       s.proj4text         AS proj4text,
       c.strict_resolution AS strict_resolution,
       c.mixed_resolutions AS mixed_resolutions,
       c.section_paths     AS section_paths,
       c.section_md5       AS section_md5,
       c.section_summary   AS section_summary,
       c.is_queryable      AS is_queryable,
       c.red_band_index,
       c.green_band_index,
       c.blue_band_index,
       c.nir_band_index,
       c.enable_auto_ndvi
FROM raster_coverages AS c
         LEFT JOIN spatial_ref_sys AS s ON (c.srid = s.srid)
UNION
SELECT c.coverage_name     AS coverage_name,
       c.title             AS title,
       c.abstract          AS abstract,
       c.sample_type       AS sample_type,
       c.pixel_type        AS pixel_type,
       c.num_bands         AS num_bands,
       c.compression       AS compression,
       c.quality           AS quality,
       c.tile_width        AS tile_width,
       c.tile_height       AS tile_height,
       c.horz_resolution   AS horz_resolution,
       c.vert_resolution   AS vert_resolution,
       c.nodata_pixel      AS nodata_pixel,
       c.palette           AS palette,
       c.statistics        AS statistics,
       c.geo_minx          AS geo_minx,
       c.geo_miny          AS geo_miny,
       c.geo_maxx          AS geo_maxx,
       c.geo_maxy          AS geo_maxy,
       x.extent_minx       AS extent_minx,
       x.extent_miny       AS extent_miny,
       x.extent_maxx       AS extent_maxx,
       x.extent_maxy       AS extent_maxy,
       s.srid              AS srid,
       0                   AS native_srid,
       s.auth_name         AS auth_name,
       s.auth_srid         AS auth_srid,
       s.ref_sys_name      AS ref_sys_name,
       s.proj4text         AS proj4text,
       c.strict_resolution AS strict_resolution,
       c.mixed_resolutions AS mixed_resolutions,
       c.section_paths     AS section_paths,
       c.section_md5       AS section_md5,
       c.section_summary   AS section_summary,
       c.is_queryable      AS is_queryable,
       c.red_band_index,
       c.green_band_index,
       c.blue_band_index,
       c.nir_band_index,
       c.enable_auto_ndvi
FROM raster_coverages AS c
         JOIN raster_coverages_srid AS x ON (c.coverage_name = x.coverage_name)
         LEFT JOIN spatial_ref_sys AS s ON (x.srid = s.srid)
/* raster_coverages_ref_sys(coverage_name,title,abstract,sample_type,pixel_type,num_bands,compression,quality,tile_width,tile_height,horz_resolution,vert_resolution,nodata_pixel,palette,statistics,geo_minx,geo_miny,geo_maxx,geo_maxy,extent_minx,extent_miny,extent_maxx,extent_maxy,srid,native_srid,auth_name,auth_srid,ref_sys_name,proj4text,strict_resolution,mixed_resolutions,section_paths,section_md5,section_summary,is_queryable,red_band_index,green_band_index,blue_band_index,nir_band_index,enable_auto_ndvi) */;
CREATE TABLE raster_coverages_keyword
(
    coverage_name TEXT NOT NULL,
    keyword       TEXT NOT NULL,
    CONSTRAINT pk_raster_coverages_keyword PRIMARY KEY (coverage_name, keyword),
    CONSTRAINT fk_raster_coverages_keyword FOREIGN KEY (coverage_name) REFERENCES raster_coverages (coverage_name) ON DELETE CASCADE
);
CREATE TRIGGER raster_coverages_name_insert
    BEFORE INSERT
    ON 'raster_coverages'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'insert on raster_coverages violates constraint: coverage_name value must not contain a single quote') WHERE NEW.coverage_name LIKE ('%''%');
SELECT RAISE(ABORT,
             'insert on raster_coverages violates constraint: coverage_name value must not contain a double quote') WHERE NEW.coverage_name LIKE ('%"%');
SELECT RAISE(ABORT,
             'insert on raster_coverages violates constraint: coverage_name value must be lower case') WHERE NEW.coverage_name <> lower(NEW.coverage_name);
END;
CREATE TRIGGER raster_coverages_name_update
    BEFORE UPDATE OF 'coverage_name' ON 'raster_coverages'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'update on raster_coverages violates constraint: coverage_name value must not contain a single quote') WHERE NEW.coverage_name LIKE ('%''%');
SELECT RAISE(ABORT,
             'update on raster_coverages violates constraint: coverage_name value must not contain a double quote') WHERE NEW.coverage_name LIKE ('%"%');
SELECT RAISE(ABORT,
             'update on raster_coverages violates constraint: coverage_name value must be lower case') WHERE NEW.coverage_name <> lower(NEW.coverage_name);
END;
CREATE TRIGGER raster_coverages_sample_insert
    BEFORE INSERT
    ON 'raster_coverages'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'insert on raster_coverages violates constraint: sample_type must be one of ''1-BIT'' | ''2-BIT'' | ''4-BIT'' | ''INT8'' | ''UINT8'' | ''INT16'' | ''UINT16'' | ''INT32'' | ''UINT32'' | ''FLOAT'' | ''DOUBLE''') WHERE NEW.sample_type NOT IN ('1-BIT', '2-BIT', '4-BIT', 'INT8', 'UINT8', 'INT16', 'UINT16', 'INT32', 'UINT32', 'FLOAT', 'DOUBLE');
END;
CREATE TRIGGER raster_coverages_sample_update
    BEFORE UPDATE OF 'sample_type' ON 'raster_coverages'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'update on raster_coverages violates constraint: sample_type must be one of ''1-BIT'' | ''2-BIT'' | ''4-BIT'' | ''INT8'' | ''UINT8'' | ''INT16'' | ''UINT16'' | ''INT32'' | ''UINT32'' | ''FLOAT'' | ''DOUBLE''') WHERE NEW.sample_type NOT IN ('1-BIT', '2-BIT', '4-BIT', 'INT8', 'UINT8', 'INT16', 'UINT16', 'INT32', 'UINT32', 'FLOAT', 'DOUBLE');
END;
CREATE TRIGGER raster_coverages_pixel_insert
    BEFORE INSERT
    ON 'raster_coverages'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'insert on raster_coverages violates constraint: pixel_type must be one of ''MONOCHROME'' | ''PALETTE'' | ''GRAYSCALE'' | ''RGB'' | ''MULTIBAND'' | ''DATAGRID''') WHERE NEW.pixel_type NOT IN ('MONOCHROME', 'PALETTE', 'GRAYSCALE', 'RGB', 'MULTIBAND', 'DATAGRID');
END;
CREATE TRIGGER raster_coverages_pixel_update
    BEFORE UPDATE OF 'pixel_type' ON 'raster_coverages'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'update on raster_coverages violates constraint: pixel_type must be one of ''MONOCHROME'' | ''PALETTE'' | ''GRAYSCALE'' | ''RGB'' | ''MULTIBAND'' | ''DATAGRID''') WHERE NEW.pixel_type NOT IN ('MONOCHROME', 'PALETTE', 'GRAYSCALE', 'RGB', 'MULTIBAND', 'DATAGRID');
END;
CREATE TRIGGER raster_coverages_bands_insert
    BEFORE INSERT
    ON 'raster_coverages'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT, 'insert on raster_coverages violates constraint: num_bands must be >= 1') WHERE NEW.num_bands < 1;
END;
CREATE TRIGGER raster_coverages_bands_update
    BEFORE UPDATE OF 'num_bands' ON 'raster_coverages'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT, 'update on raster_coverages violates constraint: num_bands must be >= 1') WHERE NEW.num_bands < 1;
END;
CREATE TRIGGER raster_coverages_compression_insert
    BEFORE INSERT
    ON 'raster_coverages'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'insert on raster_coverages violates constraint: compression must be one of ''NONE'' | ''DEFLATE'' | ''DEFLATE_NO'' | ''LZMA'' | ''LZMA_NO'' | ''LZ4'' | ''LZ4_NO'' | ''ZSTD'' | ''ZSTD_NO'' | ''PNG'' | ''JPEG'' | ''LOSSY_WEBP'' | ''LOSSLESS_WEBP'' | ''CCITTFAX4'' | ''LOSSY_JP2'' | ''LOSSLESS_JP2''') WHERE NEW.compression NOT IN ('NONE', 'DEFLATE',  'DEFLATE_NO', 'LZMA', 'LZMA_NO', 'LZ4', 'LZ4_NO', 'ZSTD', 'ZSTD_NO', 'PNG', 'JPEG', 'LOSSY_WEBP', 'LOSSLESS_WEBP', 'CCITTFAX4', 'LOSSY_JP2', 'LOSSLESS_JP2');
END;
CREATE TRIGGER raster_coverages_compression_update
    BEFORE UPDATE OF 'compression' ON 'raster_coverages'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'update on raster_coverages violates constraint: compression must be one of ''NONE'' | ''DEFLATE'' | ''DEFLATE_NO'' | ''LZMA'' | ''LZMA_NO'' | ''LZ4'' | ''LZ4_NO'' | ''ZSTD'' | ''ZSTD_NO'' | ''PNG'' | ''JPEG'' | ''LOSSY_WEBP'' | ''LOSSLESS_WEBP'' | ''CCITTFAX4'' | ''LOSSY_JP2'' | ''LOSSLESS_JP2''') WHERE NEW.compression NOT IN ('NONE', 'DEFLATE', 'DEFLATE_NO', 'LZMA', 'LZMA_NO', 'LZ4', 'LZ4_NO', 'ZSTD', 'ZSTD_NO', 'PNG', 'JPEG', 'LOSSY_WEBP', 'LOSSLESS_WEBP', 'CCITTFAX4', 'LOSSY_JP2', 'LOSSLESS_JP2');
END;
CREATE TRIGGER raster_coverages_quality_insert
    BEFORE INSERT
    ON 'raster_coverages'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'insert on raster_coverages violates constraint: quality must be between 0 and 100') WHERE NEW.quality NOT BETWEEN 0 AND 100;
END;
CREATE TRIGGER raster_coverages_quality_update
    BEFORE UPDATE OF 'quality' ON 'raster_coverages'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'update on raster_coverages violates constraint: quality must be between 0 and 100') WHERE NEW.quality NOT BETWEEN 0 AND 100;
END;
CREATE TRIGGER raster_coverages_tilew_insert
    BEFORE INSERT
    ON 'raster_coverages'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'insert on raster_coverages violates constraint: tile_width must be an exact multiple of 8 between 256 and 1024') WHERE CastToInteger(NEW.tile_width) IS NULL OR NEW.tile_width NOT BETWEEN 256 AND 1024 OR (NEW.tile_width % 8) <> 0;
END;
CREATE TRIGGER raster_coverages_tilew_update
    BEFORE UPDATE OF 'tile_width' ON 'raster_coverages'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'update on raster_coverages violates constraint: tile_width must be an exact multiple of 8 between 256 and 1024') WHERE CastToInteger(NEW.tile_width) IS NULL OR NEW.tile_width NOT BETWEEN 256 AND 1024 OR (NEW.tile_width % 8) <> 0;
END;
CREATE TRIGGER raster_coverages_tileh_insert
    BEFORE INSERT
    ON 'raster_coverages'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'insert on raster_coverages violates constraint: tile_height must be an exact multiple of 8 between 256 and 1024') WHERE CastToInteger(NEW.tile_height) IS NULL OR NEW.tile_height NOT BETWEEN 256 AND 1024 OR (NEW.tile_height % 8) <> 0;
END;
CREATE TRIGGER raster_coverages_tileh_update
    BEFORE UPDATE OF 'tile_height' ON 'raster_coverages'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'update on raster_coverages violates constraint: tile_height must be an exact multiple of 8 between 256 and 1024') WHERE CastToInteger(NEW.tile_height) IS NULL OR NEW.tile_height NOT BETWEEN 256 AND 1024 OR (NEW.tile_height % 8) <> 0;
END;
CREATE TRIGGER raster_coverages_horzres_insert
    BEFORE INSERT
    ON 'raster_coverages'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'insert on raster_coverages violates constraint: horz_resolution must be positive') WHERE NEW.horz_resolution IS NOT NULL AND (NEW.horz_resolution <= 0.0 OR CastToDouble(NEW.horz_resolution) IS NULL);
END;
CREATE TRIGGER raster_coverages_horzres_update
    BEFORE UPDATE OF 'horz_resolution' ON 'raster_coverages'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'update on raster_coverages violates constraint: horz_resolution must be positive') WHERE NEW.horz_resolution IS NOT NULL AND (NEW.horz_resolution <= 0.0 OR CastToDouble(NEW.horz_resolution) IS NULL);
END;
CREATE TRIGGER raster_coverages_vertres_insert
    BEFORE INSERT
    ON 'raster_coverages'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'insert on raster_coverages violates constraint: vert_resolution must be positive') WHERE NEW.vert_resolution IS NOT NULL AND (NEW.vert_resolution <= 0.0 OR CastToDouble(NEW.vert_resolution) IS NULL);
END;
CREATE TRIGGER raster_coverages_vertres_update
    BEFORE UPDATE OF 'vert_resolution' ON 'raster_coverages'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'update on raster_coverages violates constraint: vert_resolution must be positive') WHERE NEW.vert_resolution IS NOT NULL AND (NEW.vert_resolution <= 0.0 OR CastToDouble(NEW.vert_resolution) IS NULL);
END;
CREATE TRIGGER raster_coverages_nodata_insert
    BEFORE INSERT
    ON 'raster_coverages'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'insert on raster_coverages violates constraint: invalid nodata_pixel') WHERE NEW.nodata_pixel IS NOT NULL AND IsValidPixel(NEW.nodata_pixel, NEW.sample_type, NEW.num_bands) <> 1;
END;
CREATE TRIGGER raster_coverages_nodata_update
    BEFORE UPDATE OF 'nodata_pixel' ON 'raster_coverages'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'update on raster_coverages violates constraint: invalid nodata_pixel') WHERE NEW.nodata_pixel IS NOT NULL AND IsValidPixel(NEW.nodata_pixel, NEW.sample_type, NEW.num_bands) <> 1;
END;
CREATE TRIGGER raster_coverages_palette_insert
    BEFORE INSERT
    ON 'raster_coverages'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'insert on raster_coverages violates constraint: invalid palette') WHERE NEW.palette IS NOT NULL AND (NEW.pixel_type <> 'PALETTE' OR NEW.num_bands <> 1 OR IsValidRasterPalette(NEW.palette, NEW.sample_type) <> 1);
END;
CREATE TRIGGER raster_coverages_palette_update
    BEFORE UPDATE OF 'palette' ON 'raster_coverages'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'update on raster_coverages violates constraint: invalid palette') WHERE NEW.palette IS NOT NULL AND (NEW.pixel_type <> 'PALETTE' OR NEW.num_bands <> 1 OR IsValidRasterPalette(NEW.palette, NEW.sample_type) <> 1);
END;
CREATE TRIGGER raster_coverages_statistics_insert
    BEFORE INSERT
    ON 'raster_coverages'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'insert on raster_coverages violates constraint: invalid statistics') WHERE NEW.statistics IS NOT NULL AND IsValidRasterStatistics(NEW.statistics, NEW.sample_type, NEW.num_bands) <> 1;
END;
CREATE TRIGGER raster_coverages_statistics_update
    BEFORE UPDATE OF 'statistics' ON 'raster_coverages'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'update on raster_coverages violates constraint: invalid statistics') WHERE NEW.statistics IS NOT NULL AND IsValidRasterStatistics(NEW.statistics, NEW.sample_type, NEW.num_bands) <> 1;
END;
CREATE TRIGGER raster_coverages_monosample_insert
    BEFORE INSERT
    ON 'raster_coverages'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'insert on raster_coverages violates constraint: inconsistent MONOCHROME sample_type') WHERE NEW.pixel_type = 'MONOCHROME' AND NEW.sample_type <> '1-BIT';
END;
CREATE TRIGGER raster_coverages_monosample_update
    BEFORE UPDATE
    ON 'raster_coverages'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'update on raster_coverages violates constraint: inconsistent MONOCHROME sample_type') WHERE NEW.pixel_type = 'MONOCHROME' AND NEW.sample_type <>'1-BIT';
END;
CREATE TRIGGER raster_coverages_monocompr_insert
    BEFORE INSERT
    ON 'raster_coverages'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'insert on raster_coverages violates constraint: inconsistent MONOCHROME compression') WHERE NEW.pixel_type = 'MONOCHROME' AND NEW.compression NOT IN ('NONE', 'DEFLATE', 'DEFLATE_NO', 'LZMA', 'LZMA_NO', 'LZ4', 'LZ4_NO', 'ZSTD', 'ZSTD_NO', 'PNG', 'CCITTFAX4');
END;
CREATE TRIGGER raster_coverages_monocompr_update
    BEFORE UPDATE
    ON 'raster_coverages'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'update on raster_coverages violates constraint: inconsistent MONOCHROME compression') WHERE NEW.pixel_type = 'MONOCHROME' AND NEW.compression NOT IN ('NONE', 'DEFLATE', 'DEFLATE_NO', 'LZMA', 'LZMA_NO', 'LZ4', 'LZ4_NO', 'ZSTD', 'ZSTD_NO', 'PNG', 'CCITTFAX4');
END;
CREATE TRIGGER raster_coverages_monobands_insert
    BEFORE INSERT
    ON 'raster_coverages'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'insert on raster_coverages violates constraint: inconsistent MONOCHROME num_bands') WHERE NEW.pixel_type = 'MONOCHROME' AND NEW.num_bands <> 1;
END;
CREATE TRIGGER raster_coverages_monobands_update
    BEFORE UPDATE
    ON 'raster_coverages'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'update on raster_coverages violates constraint: inconsistent MONOCHROME num_bands') WHERE NEW.pixel_type = 'MONOCHROME' AND NEW.num_bands <> 1;
END;
CREATE TRIGGER raster_coverages_pltsample_insert
    BEFORE INSERT
    ON 'raster_coverages'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'insert on raster_coverages violates constraint: inconsistent PALETTE sample_type') WHERE NEW.pixel_type = 'PALETTE' AND NEW.sample_type NOT IN ('1-BIT', '2-BIT', '4-BIT', 'UINT8');
END;
CREATE TRIGGER raster_coverages_pltsample_update
    BEFORE UPDATE
    ON 'raster_coverages'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'update on raster_coverages violates constraint: inconsistent PALETTE sample_type') WHERE NEW.pixel_type = 'PALETTE' AND NEW.sample_type NOT IN ('1-BIT', '2-BIT', '4-BIT', 'UINT8');
END;
CREATE TRIGGER raster_coverages_pltcompr_insert
    BEFORE INSERT
    ON 'raster_coverages'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'insert on raster_coverages violates constraint: inconsistent PALETTE compression') WHERE NEW.pixel_type = 'PALETTE' AND NEW.compression NOT IN ('NONE', 'DEFLATE', 'DEFLATE_NO', 'LZMA', 'LZMA_NO', 'LZ4', 'LZ4_NO', 'ZSTD', 'ZSTD_NO', 'PNG');
END;
CREATE TRIGGER raster_coverages_pltcompr_update
    BEFORE UPDATE
    ON 'raster_coverages'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'update on raster_coverages violates constraint: inconsistent PALETTE compression') WHERE NEW.pixel_type = 'PALETTE' AND NEW.compression NOT IN ('NONE', 'DEFLATE', 'DEFLATE_NO', 'LZMA', 'LZMA_NO', 'LZ4', 'LZ4_NO', 'ZSTD', 'ZSTD_NO', 'PNG');
END;
CREATE TRIGGER raster_coverages_pltbands_insert
    BEFORE INSERT
    ON 'raster_coverages'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'insert on raster_coverages violates constraint: inconsistent PALETTE num_bands') WHERE NEW.pixel_type = 'PALETTE' AND NEW.num_bands <> 1;
END;
CREATE TRIGGER raster_coverages_pltbands_update
    BEFORE UPDATE
    ON 'raster_coverages'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'update on raster_coverages violates constraint: inconsistent PALETTE num_bands') WHERE NEW.pixel_type = 'PALETTE' AND NEW.num_bands <> 1;
END;
CREATE TRIGGER raster_coverages_graysample_insert
    BEFORE INSERT
    ON 'raster_coverages'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'insert on raster_coverages violates constraint: inconsistent GRAYSCALE sample_type') WHERE NEW.pixel_type = 'GRAYSCALE' AND NEW.sample_type NOT IN ('2-BIT', '4-BIT', 'UINT8');
END;
CREATE TRIGGER raster_coverages_graysample_update
    BEFORE UPDATE
    ON 'raster_coverages'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'update on raster_coverages violates constraint: inconsistent GRAYSCALE sample_type') WHERE NEW.pixel_type = 'GRAYSCALE' AND NEW.sample_type NOT IN ('2-BIT', '4-BIT', 'UINT8');
END;
CREATE TRIGGER raster_coverages_graybands_insert
    BEFORE INSERT
    ON 'raster_coverages'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'insert on raster_coverages violates constraint: inconsistent GRAYSCALE num_bands') WHERE NEW.pixel_type = 'GRAYSCALE' AND NEW.num_bands <> 1;
END;
CREATE TRIGGER raster_coverages_graybands_update
    BEFORE UPDATE
    ON 'raster_coverages'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'update on raster_coverages violates constraint: inconsistent GRAYSCALE num_bands') WHERE NEW.pixel_type = 'GRAYSCALE' AND NEW.num_bands <> 1;
END;
CREATE TRIGGER raster_coverages_graycompr_insert
    BEFORE INSERT
    ON 'raster_coverages'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'insert on raster_coverages violates constraint: inconsistent GRAYSCALE compression') WHERE NEW.pixel_type = 'GRAYSCALE' AND NEW.compression NOT IN ('NONE', 'DEFLATE', 'DEFLATE_NO', 'LZMA', 'LZMA_NO', 'LZ4', 'LZ4_NO', 'ZSTD', 'ZSTD_NO', 'PNG', 'JPEG', 'LOSSY_WEBP', 'LOSSLESS_WEBP', 'LOSSY_JP2', 'LOSSLESS_JP2');
END;
CREATE TRIGGER raster_coverages_graycompr_update
    BEFORE UPDATE
    ON 'raster_coverages'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'update on raster_coverages violates constraint: inconsistent GRAYSCALE compression') WHERE NEW.pixel_type = 'GRAYSCALE' AND NEW.compression NOT IN ('NONE', 'DEFLATE', 'DEFLATE_NO', 'LZMA', 'LZMA_NO', 'LZ4', 'LZ4_NO', 'ZSTD', 'ZSTD_NO', 'PNG', 'JPEG', 'LOSSY_WEBP', 'LOSSLESS_WEBP', 'LOSSY_JP2', 'LOSSLESS_JP2');
END;
CREATE TRIGGER raster_coverages_rgbsample_insert
    BEFORE INSERT
    ON 'raster_coverages'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'insert on raster_coverages violates constraint: inconsistent RGB sample_type') WHERE NEW.pixel_type = 'RGB' AND NEW.sample_type NOT IN ('UINT8', 'UINT16');
END;
CREATE TRIGGER raster_coverages_rgbsample_update
    BEFORE UPDATE
    ON 'raster_coverages'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'update on raster_coverages violates constraint: inconsistent RGB sample_type') WHERE NEW.pixel_type = 'RGB' AND NEW.sample_type NOT IN ('UINT8', 'UINT16');
END;
CREATE TRIGGER raster_coverages_rgbcompr_insert
    BEFORE INSERT
    ON 'raster_coverages'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'insert on raster_coverages violates constraint: inconsistent RGB compression') WHERE NEW.pixel_type = 'RGB' AND ((NEW.sample_type = 'UINT8' AND NEW.compression NOT IN ('NONE', 'DEFLATE', 'DEFLATE_NO', 'LZMA', 'LZMA_NO', 'LZ4', 'LZ4_NO', 'ZSTD', 'ZSTD_NO', 'PNG', 'JPEG', 'LOSSY_WEBP', 'LOSSLESS_WEBP', 'LOSSY_JP2', 'LOSSLESS_JP2') OR (NEW.sample_type = 'UINT16' AND NEW.compression NOT IN ('NONE', 'DEFLATE', 'DEFLATE_NO', 'LZMA', 'LZMA_NO', 'LZ4', 'LZ4_NO', 'ZSTD', 'ZSTD_NO', 'PNG', 'LOSSY_JP2', 'LOSSLESS_JP2'))));
END;
CREATE TRIGGER raster_coverages_rgbcompr_update
    BEFORE UPDATE
    ON 'raster_coverages'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'update on raster_coverages violates constraint: inconsistent RGB compression') WHERE NEW.pixel_type = 'RGB' AND ((NEW.sample_type = 'UINT8' AND NEW.compression NOT IN ('NONE', 'DEFLATE', 'DEFLATE_NO', 'LZMA', 'LZMA_NO', 'LZ4', 'LZ4_NO', 'ZSTD', 'ZSTD_NO', 'PNG', 'JPEG', 'LOSSY_WEBP', 'LOSSLESS_WEBP', 'LOSSY_JP2', 'LOSSLESS_JP2') OR (NEW.sample_type = 'UINT16' AND NEW.compression NOT IN ('NONE', 'DEFLATE', 'DEFLATE_NO', 'LZMA', 'LZMA_NO', 'LZ4', 'LZ4_NO', 'ZSTD', 'ZSTD_NO', 'PNG', 'LOSSY_JP2', 'LOSSLESS_JP2'))));
END;
CREATE TRIGGER raster_coverages_rgbbands_insert
    BEFORE INSERT
    ON 'raster_coverages'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'insert on raster_coverages violates constraint: inconsistent RGB num_bands') WHERE NEW.pixel_type = 'RGB' AND NEW.num_bands <> 3;
END;
CREATE TRIGGER raster_coverages_rgbbands_update
    BEFORE UPDATE
    ON 'raster_coverages'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'update on raster_coverages violates constraint: inconsistent RGB num_bands') WHERE NEW.pixel_type = 'RGB' AND NEW.num_bands <> 3;
END;
CREATE TRIGGER raster_coverages_multisample_insert
    BEFORE INSERT
    ON 'raster_coverages'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'insert on raster_coverages violates constraint: inconsistent MULTIBAND sample_type') WHERE NEW.pixel_type = 'MULTIBAND' AND NEW.sample_type NOT IN ('UINT8', 'UINT16');
END;
CREATE TRIGGER raster_coverages_multisample_update
    BEFORE UPDATE
    ON 'raster_coverages'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'update on raster_coverages violates constraint: inconsistent MULTIBAND sample_type') WHERE NEW.pixel_type = 'MULTIBAND' AND NEW.sample_type NOT IN ('UINT8', 'UINT16');
END;
CREATE TRIGGER raster_coverages_multicompr_insert
    BEFORE INSERT
    ON 'raster_coverages'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'insert on raster_coverages violates constraint: inconsistent MULTIBAND compression') WHERE NEW.pixel_type = 'MULTIBAND' AND ((NEW.num_bands NOT IN (3, 4) AND NEW.compression NOT IN ('NONE', 'DEFLATE', 'DEFLATE_NO', 'LZMA', 'LZMA_NO', 'LZ4', 'LZ4_NO', 'ZSTD', 'ZSTD_NO')) OR	(NEW.sample_type <> 'UINT16' AND NEW.num_bands IN (3, 4) AND NEW.compression NOT IN ('NONE', 'DEFLATE', 'DEFLATE_NO', 'LZMA', 'LZMA_NO', 'LZ4', 'LZ4_NO', 'ZSTD', 'ZSTD_NO', 'PNG', 'LOSSY_WEBP', 'LOSSLESS_WEBP', 'LOSSY_JP2', 'LOSSLESS_JP2')) OR (NEW.sample_type = 'UINT16' AND NEW.num_bands IN (3, 4) AND NEW.compression NOT IN ('NONE', 'DEFLATE', 'DEFLATE_NO', 'LZMA', 'LZMA_NO', 'LZ4', 'LZ4_NO', 'ZSTD', 'ZSTD_NO', 'PNG', 'LOSSY_JP2', 'LOSSLESS_JP2')));
END;
CREATE TRIGGER raster_coverages_multicompr_update
    BEFORE UPDATE
    ON 'raster_coverages'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'update on raster_coverages violates constraint: inconsistent MULTIBAND compression') WHERE NEW.pixel_type = 'MULTIBAND' AND ((NEW.num_bands NOT IN (3, 4) AND NEW.compression NOT IN ('NONE', 'DEFLATE', 'DEFLATE_NO', 'LZMA', 'LZMA_NO', 'LZ4', 'LZ4_NO', 'ZSTD', 'ZSTD_NO')) OR	(NEW.sample_type <> 'UINT16' AND NEW.num_bands IN (3, 4) AND NEW.compression NOT IN ('NONE', 'DEFLATE', 'DEFLATE_NO', 'LZMA', 'LZMA_NO', 'LZ4', 'LZ4_NO', 'ZSTD', 'ZSTD_NO', 'PNG', 'LOSSY_WEBP', 'LOSSLESS_WEBP', 'LOSSY_JP2', 'LOSSLESS_JP2')) OR (NEW.sample_type = 'UINT16' AND NEW.num_bands IN (3, 4) AND NEW.compression NOT IN ('NONE', 'DEFLATE', 'DEFLATE_NO', 'LZMA', 'LZMA_NO', 'LZ4', 'LZ4_NO', 'ZSTD', 'ZSTD_NO', 'PNG', 'LOSSY_JP2', 'LOSSLESS_JP2')));
END;
CREATE TRIGGER raster_coverages_multibands_insert
    BEFORE INSERT
    ON 'raster_coverages'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'insert on raster_coverages violates constraint: inconsistent MULTIBAND num_bands') WHERE NEW.pixel_type = 'MULTIBAND' AND NEW.num_bands < 2;
END;
CREATE TRIGGER raster_coverages_multibands_update
    BEFORE UPDATE
    ON 'raster_coverages'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'update on raster_coverages violates constraint: inconsistent MULTIBAND num_bands') WHERE NEW.pixel_type = 'MULTIBAND' AND NEW.num_bands < 2;
END;
CREATE TRIGGER raster_coverages_gridsample_insert
    BEFORE INSERT
    ON 'raster_coverages'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'insert on raster_coverages violates constraint: inconsistent DATAGRID sample_type') WHERE NEW.pixel_type = 'DATAGRID' AND NEW.sample_type NOT IN ('INT8', 'UINT8', 'INT16', 'UINT16', 'INT32', 'UINT32', 'FLOAT', 'DOUBLE');
END;
CREATE TRIGGER raster_coverages_gridsample_update
    BEFORE UPDATE
    ON 'raster_coverages'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'update on raster_coverages violates constraint: inconsistent DATAGRID sample_type') WHERE NEW.pixel_type = 'DATAGRID' AND NEW.sample_type NOT IN ('INT8', 'UINT8', 'INT16', 'UINT16', 'INT32', 'UINT32', 'FLOAT', 'DOUBLE');
END;
CREATE TRIGGER raster_coverages_gridcompr_insert
    BEFORE INSERT
    ON 'raster_coverages'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'insert on raster_coverages violates constraint: inconsistent DATAGRID compression') WHERE NEW.pixel_type = 'DATAGRID' AND (((NEW.sample_type NOT IN ('UINT8', 'UINT16')) AND NEW.compression NOT IN ('NONE', 'DEFLATE', 'DEFLATE_NO', 'LZMA', 'LZMA_NO', 'LZ4', 'LZ4_NO', 'ZSTD', 'ZSTD_NO')) OR ((NEW.sample_type IN ('UINT8', 'UINT16')) AND NEW.compression NOT IN ('NONE', 'DEFLATE', 'DEFLATE_NO', 'LZMA', 'LZMA_NO', 'LZ4', 'LZ4_NO', 'ZSTD', 'ZSTD_NO', 'PNG', 'LOSSY_JP2', 'LOSSLESS_JP2')));
END;
CREATE TRIGGER raster_coverages_gridcompr_update
    BEFORE UPDATE
    ON 'raster_coverages'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'update on raster_coverages violates constraint: inconsistent DATAGRID compression') WHERE NEW.pixel_type = 'DATAGRID' AND (((NEW.sample_type NOT IN ('UINT8', 'UINT16')) AND NEW.compression NOT IN ('NONE', 'DEFLATE', 'DEFLATE_NO', 'LZMA', 'LZMA_NO', 'LZ4', 'LZ4_NO', 'ZSTD', 'ZSTD_NO')) OR ((NEW.sample_type IN ('UINT8', 'UINT16')) AND NEW.compression NOT IN ('NONE', 'DEFLATE', 'DEFLATE_NO', 'LZMA', 'LZMA_NO', 'LZ4', 'LZ4_NO', 'ZSTD', 'ZSTD_NO', 'PNG', 'LOSSY_JP2', 'LOSSLESS_JP2')));
END;
CREATE TRIGGER raster_coverages_gridbands_insert
    BEFORE INSERT
    ON 'raster_coverages'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'insert on raster_coverages violates constraint: inconsistent DATAGRID num_bands') WHERE NEW.pixel_type = 'DATAGRID' AND NEW.num_bands <> 1;
END;
CREATE TRIGGER raster_coverages_gridbands_update
    BEFORE UPDATE
    ON 'raster_coverages'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'update on raster_coverages violates constraint: inconsistent DATAGRID num_bands') WHERE NEW.pixel_type = 'DATAGRID' AND NEW.num_bands <> 1;
END;
CREATE TRIGGER raster_coverages_georef_insert
    BEFORE INSERT
    ON 'raster_coverages'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'insert on raster_coverages violates constraint: inconsistent georeferencing infos') WHERE NOT ((NEW.horz_resolution IS NULL AND NEW.vert_resolution IS NULL AND NEW.srid IS NULL) OR (NEW.horz_resolution IS NOT NULL AND NEW.vert_resolution IS NOT NULL AND NEW.srid IS NOT NULL));
END;
CREATE TRIGGER raster_coverages_georef_update
    BEFORE UPDATE
    ON 'raster_coverages'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'update on raster_coverages violates constraint: inconsistent georeferencing infos') WHERE NOT ((NEW.horz_resolution IS NULL AND NEW.vert_resolution IS NULL AND NEW.srid IS NULL) OR (NEW.horz_resolution IS NOT NULL AND NEW.vert_resolution IS NOT NULL AND NEW.srid IS NOT NULL));
END;
CREATE TRIGGER raster_coverages_update
    BEFORE UPDATE
    ON 'raster_coverages'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'update on raster_coverages violates constraint: attempting to change the definition of an already populated Coverage') WHERE IsPopulatedCoverage(NULL, OLD.coverage_name) = 1 AND ((OLD.sample_type <> NEW.sample_type) AND (OLD.pixel_type <> NEW.sample_type) OR (OLD.num_bands <> NEW.num_bands) OR (OLD.compression <> NEW.compression) OR (OLD.quality <> NEW.quality) OR (OLD.tile_width <> NEW.tile_width) OR (OLD.tile_height <> NEW.tile_height) OR (OLD.horz_resolution <> NEW.horz_resolution) OR (OLD.vert_resolution <> NEW.vert_resolution) OR (OLD.srid <> NEW.srid) OR (OLD.nodata_pixel <> NEW.nodata_pixel));
END;
CREATE TRIGGER raster_coverages_delete
    BEFORE DELETE
    ON 'raster_coverages'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'delete on raster_coverages violates constraint: attempting to delete the definition of an already populated Coverage') WHERE IsPopulatedCoverage(NULL, OLD.coverage_name) = 1;
END;
CREATE TRIGGER raster_coverages_srid_name_insert
    BEFORE INSERT
    ON 'raster_coverages_srid'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'insert on raster_coverages_srid violates constraint: coverage_name value must not contain a single quote') WHERE NEW.coverage_name LIKE ('%''%');
SELECT RAISE(ABORT,
             'insert on raster_coverages_srid violates constraint: coverage_name value must not contain a double quote') WHERE NEW.coverage_name LIKE ('%"%');
SELECT RAISE(ABORT,
             'insert on raster_coverages_srid violates constraint: coverage_name value must be lower case') WHERE NEW.coverage_name <> lower(NEW.coverage_name);
END;
CREATE TRIGGER raster_coverages_srid_name_update
    BEFORE UPDATE OF 'coverage_name' ON 'raster_coverages_srid'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'update on raster_coverages_srid violates constraint: coverage_name value must not contain a single quote') WHERE NEW.coverage_name LIKE ('%''%');
SELECT RAISE(ABORT,
             'update on raster_coverages_srid violates constraint: coverage_name value must not contain a double quote') WHERE NEW.coverage_name LIKE ('%"%');
SELECT RAISE(ABORT,
             'update on raster_coverages_srid violates constraint: coverage_name value must be lower case') WHERE NEW.coverage_name <> lower(NEW.coverage_name);
END;
CREATE TRIGGER raster_coverages_keyword_name_insert
    BEFORE INSERT
    ON 'raster_coverages_keyword'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'insert on raster_coverages_keyword violates constraint: coverage_name value must not contain a single quote') WHERE NEW.coverage_name LIKE ('%''%');
SELECT RAISE(ABORT,
             'insert on raster_coverages_keyword violates constraint: coverage_name value must not contain a double quote') WHERE NEW.coverage_name LIKE ('%"%');
SELECT RAISE(ABORT,
             'insert on raster_coverages_keyword violates constraint: coverage_name value must be lower case') WHERE NEW.coverage_name <> lower(NEW.coverage_name);
END;
CREATE TRIGGER raster_coverages_keyword_name_update
    BEFORE UPDATE OF 'coverage_name' ON 'raster_coverages_keyword'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'update on raster_coverages_keyword violates constraint: coverage_name value must not contain a single quote') WHERE NEW.coverage_name LIKE ('%''%');
SELECT RAISE(ABORT,
             'update on raster_coverages_keyword violates constraint: coverage_name value must not contain a double quote') WHERE NEW.coverage_name LIKE ('%"%');
SELECT RAISE(ABORT,
             'update on raster_coverages_keyword violates constraint: coverage_name value must be lower case') WHERE NEW.coverage_name <> lower(NEW.coverage_name);
END;
CREATE TABLE vector_coverages
(
    coverage_name     TEXT    NOT NULL PRIMARY KEY,
    f_table_name      TEXT,
    f_geometry_column TEXT,
    view_name         TEXT,
    view_geometry     TEXT,
    virt_name         TEXT,
    virt_geometry     TEXT,
    topology_name     TEXT,
    network_name      TEXT,
    geo_minx          DOUBLE,
    geo_miny          DOUBLE,
    geo_maxx          DOUBLE,
    geo_maxy          DOUBLE,
    extent_minx       DOUBLE,
    extent_miny       DOUBLE,
    extent_maxx       DOUBLE,
    extent_maxy       DOUBLE,
    title             TEXT    NOT NULL DEFAULT '*** missing Title ***',
    abstract          TEXT    NOT NULL DEFAULT '*** missing Abstract ***',
    is_queryable      INTEGER NOT NULL,
    is_editable       INTEGER NOT NULL,
    copyright         TEXT    NOT NULL DEFAULT '*** unknown ***',
    license           INTEGER NOT NULL DEFAULT 0,
    CONSTRAINT fk_vc_gc FOREIGN KEY (f_table_name, f_geometry_column) REFERENCES geometry_columns (f_table_name, f_geometry_column) ON DELETE CASCADE,
    CONSTRAINT fk_vc_sv FOREIGN KEY (view_name, view_geometry) REFERENCES views_geometry_columns (view_name, view_geometry) ON DELETE CASCADE,
    CONSTRAINT fk_vc_vt FOREIGN KEY (virt_name, virt_geometry) REFERENCES virts_geometry_columns (virt_name, virt_geometry) ON DELETE CASCADE,
    CONSTRAINT fk_vc_lic FOREIGN KEY (license) REFERENCES data_licenses (id)
);
CREATE UNIQUE INDEX idx_vector_coverages ON vector_coverages (f_table_name, f_geometry_column);
CREATE TABLE vector_coverages_srid
(
    coverage_name TEXT    NOT NULL,
    srid          INTEGER NOT NULL,
    extent_minx   DOUBLE,
    extent_miny   DOUBLE,
    extent_maxx   DOUBLE,
    extent_maxy   DOUBLE,
    CONSTRAINT pk_vector_coverages_srid PRIMARY KEY (coverage_name, srid),
    CONSTRAINT fk_vector_coverages_srid FOREIGN KEY (coverage_name) REFERENCES vector_coverages (coverage_name) ON DELETE CASCADE,
    CONSTRAINT fk_vector_srid FOREIGN KEY (srid) REFERENCES spatial_ref_sys (srid)
);
CREATE VIEW vector_coverages_ref_sys AS
SELECT v.coverage_name AS coverage_name,
       v.title         AS title,
       v.abstract      AS abstract,
       v.is_queryable  AS is_queryable,
       v.geo_minx      AS geo_minx,
       v.geo_miny      AS geo_miny,
       v.geo_maxx      AS geo_maxx,
       v.geo_maxy      AS geo_maxy,
       v.extent_minx   AS extent_minx,
       v.extent_miny   AS extent_miny,
       v.extent_maxx   AS extent_maxx,
       v.extent_maxy   AS extent_maxy,
       s.srid          AS srid,
       1               AS native_srid,
       s.auth_name     AS auth_name,
       s.auth_srid     AS auth_srid,
       s.ref_sys_name  AS ref_sys_name,
       s.proj4text     AS proj4text
FROM vector_coverages AS v
         JOIN geometry_columns AS x
              ON (v.topology_name IS NULL AND v.network_name IS NULL AND v.f_table_name IS NOT NULL AND
                  v.f_geometry_column IS NOT NULL AND v.f_table_name = x.f_table_name AND
                  v.f_geometry_column = x.f_geometry_column)
         LEFT JOIN spatial_ref_sys AS s ON (x.srid = s.srid)
UNION
SELECT v.coverage_name AS coverage_name,
       v.title         AS title,
       v.abstract      AS abstract,
       v.is_queryable  AS is_queryable,
       v.geo_minx      AS geo_minx,
       v.geo_miny      AS geo_miny,
       v.geo_maxx      AS geo_maxx,
       v.geo_maxy      AS geo_maxy,
       v.extent_minx   AS extent_minx,
       v.extent_miny   AS extent_miny,
       v.extent_maxx   AS extent_maxx,
       v.extent_maxy   AS extent_maxy,
       s.srid          AS srid,
       1               AS native_srid,
       s.auth_name     AS auth_name,
       s.auth_srid     AS auth_srid,
       s.ref_sys_name  AS ref_sys_name,
       s.proj4text     AS proj4text
FROM vector_coverages AS v
         JOIN views_geometry_columns AS y
              ON (v.view_name IS NOT NULL AND v.view_geometry IS NOT NULL AND v.view_name = y.view_name AND
                  v.view_geometry = y.view_geometry)
         JOIN geometry_columns AS x ON (y.f_table_name = x.f_table_name AND y.f_geometry_column = x.f_geometry_column)
         LEFT JOIN spatial_ref_sys AS s ON (x.srid = s.srid)
UNION
SELECT v.coverage_name AS coverage_name,
       v.title         AS title,
       v.abstract      AS abstract,
       v.is_queryable  AS is_queryable,
       v.geo_minx      AS geo_minx,
       v.geo_miny      AS geo_miny,
       v.geo_maxx      AS geo_maxx,
       v.geo_maxy      AS geo_maxy,
       v.extent_minx   AS extent_minx,
       v.extent_miny   AS extent_miny,
       v.extent_maxx   AS extent_maxx,
       v.extent_maxy   AS extent_maxy,
       s.srid          AS srid,
       1               AS native_srid,
       s.auth_name     AS auth_name,
       s.auth_srid     AS auth_srid,
       s.ref_sys_name  AS ref_sys_name,
       s.proj4text     AS proj4text
FROM vector_coverages AS v
         JOIN virts_geometry_columns AS x
              ON (v.virt_name IS NOT NULL AND v.virt_geometry IS NOT NULL AND v.virt_name = x.virt_name AND
                  v.virt_geometry = x.virt_geometry)
         LEFT JOIN spatial_ref_sys AS s ON (x.srid = s.srid)
UNION
SELECT v.coverage_name AS coverage_name,
       v.title         AS title,
       v.abstract      AS abstract,
       v.is_queryable  AS is_queryable,
       v.geo_minx      AS geo_minx,
       v.geo_miny      AS geo_miny,
       v.geo_maxx      AS geo_maxx,
       v.geo_maxy      AS geo_maxy,
       v.extent_minx   AS extent_minx,
       v.extent_miny   AS extent_miny,
       v.extent_maxx   AS extent_maxx,
       v.extent_maxy   AS extent_maxy,
       s.srid          AS srid,
       1               AS native_srid,
       s.auth_name     AS auth_name,
       s.auth_srid     AS auth_srid,
       s.ref_sys_name  AS ref_sys_name,
       s.proj4text     AS proj4text
FROM vector_coverages AS v
         JOIN topologies AS x ON (v.topology_name IS NOT NULL AND v.topology_name = x.topology_name)
         LEFT JOIN spatial_ref_sys AS s ON (x.srid = s.srid)
UNION
SELECT v.coverage_name AS coverage_name,
       v.title         AS title,
       v.abstract      AS abstract,
       v.is_queryable  AS is_queryable,
       v.geo_minx      AS geo_minx,
       v.geo_miny      AS geo_miny,
       v.geo_maxx      AS geo_maxx,
       v.geo_maxy      AS geo_maxy,
       v.extent_minx   AS extent_minx,
       v.extent_miny   AS extent_miny,
       v.extent_maxx   AS extent_maxx,
       v.extent_maxy   AS extent_maxy,
       s.srid          AS srid,
       1               AS native_srid,
       s.auth_name     AS auth_name,
       s.auth_srid     AS auth_srid,
       s.ref_sys_name  AS ref_sys_name,
       s.proj4text     AS proj4text
FROM vector_coverages AS v
         JOIN networks AS x ON (v.network_name IS NOT NULL AND v.network_name = x.network_name)
         LEFT JOIN spatial_ref_sys AS s ON (x.srid = s.srid)
UNION
SELECT v.coverage_name AS coverage_name,
       v.title         AS title,
       v.abstract      AS abstract,
       v.is_queryable  AS is_queryable,
       v.geo_minx      AS geo_minx,
       v.geo_miny      AS geo_miny,
       v.geo_maxx      AS geo_maxx,
       v.geo_maxy      AS geo_maxy,
       x.extent_minx   AS extent_minx,
       x.extent_miny   AS extent_miny,
       x.extent_maxx   AS extent_maxx,
       x.extent_maxy   AS extent_maxy,
       s.srid          AS srid,
       0               AS native_srid,
       s.auth_name     AS auth_name,
       s.auth_srid     AS auth_srid,
       s.ref_sys_name  AS ref_sys_name,
       s.proj4text     AS proj4text
FROM vector_coverages AS v
         JOIN vector_coverages_srid AS x ON (v.coverage_name = x.coverage_name)
         LEFT JOIN spatial_ref_sys AS s ON (x.srid = s.srid)
/* vector_coverages_ref_sys(coverage_name,title,abstract,is_queryable,geo_minx,geo_miny,geo_maxx,geo_maxy,extent_minx,extent_miny,extent_maxx,extent_maxy,srid,native_srid,auth_name,auth_srid,ref_sys_name,proj4text) */;
CREATE TABLE vector_coverages_keyword
(
    coverage_name TEXT NOT NULL,
    keyword       TEXT NOT NULL,
    CONSTRAINT pk_vector_coverages_keyword PRIMARY KEY (coverage_name, keyword),
    CONSTRAINT fk_vector_coverages_keyword FOREIGN KEY (coverage_name) REFERENCES vector_coverages (coverage_name) ON DELETE CASCADE
);
CREATE TRIGGER vector_coverages_name_insert
    BEFORE INSERT
    ON 'vector_coverages'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'insert on vector_coverages violates constraint: coverage_name value must not contain a single quote') WHERE NEW.coverage_name LIKE ('%''%');
SELECT RAISE(ABORT,
             'insert on vector_coverages violates constraint: coverage_name value must not contain a double quote') WHERE NEW.coverage_name LIKE ('%"%');
SELECT RAISE(ABORT,
             'insert on layer_vectors violates constraint: coverage_name value must be lower case') WHERE NEW.coverage_name <> lower(NEW.coverage_name);
END;
CREATE TRIGGER vector_coverages_name_update
    BEFORE UPDATE OF 'coverage_name' ON 'vector_coverages'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'update on vector_coverages violates constraint: coverage_name value must not contain a single quote') WHERE NEW.coverage_name LIKE ('%''%');
SELECT RAISE(ABORT,
             'update on vector_coverages violates constraint: coverage_name value must not contain a double quote') WHERE NEW.coverage_name LIKE ('%"%');
SELECT RAISE(ABORT,
             'update on vector_coverages violates constraint: coverage_name value must be lower case') WHERE NEW.coverage_name <> lower(NEW.coverage_name);
END;
CREATE TRIGGER vector_coverages_srid_name_insert
    BEFORE INSERT
    ON 'vector_coverages_srid'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'insert on vector_coverages_srid violates constraint: coverage_name value must not contain a single quote') WHERE NEW.coverage_name LIKE ('%''%');
SELECT RAISE(ABORT,
             'insert on vector_coverages_srid violates constraint: coverage_name value must not contain a double quote') WHERE NEW.coverage_name LIKE ('%"%');
SELECT RAISE(ABORT,
             'insert on vector_coverages_srid violates constraint: coverage_name value must be lower case') WHERE NEW.coverage_name <> lower(NEW.coverage_name);
END;
CREATE TRIGGER vector_coverages_srid_name_update
    BEFORE UPDATE OF 'coverage_name' ON 'vector_coverages_srid'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'update on vector_coverages_srid violates constraint: coverage_name value must not contain a single quote') WHERE NEW.coverage_name LIKE ('%''%');
SELECT RAISE(ABORT,
             'update on vector_coverages_srid violates constraint: coverage_name value must not contain a double quote') WHERE NEW.coverage_name LIKE ('%"%');
SELECT RAISE(ABORT,
             'update on vector_coverages_srid violates constraint: coverage_name value must be lower case') WHERE NEW.coverage_name <> lower(NEW.coverage_name);
END;
CREATE TRIGGER vector_coverages_keyword_name_insert
    BEFORE INSERT
    ON 'vector_coverages_keyword'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'insert on vector_coverages_keyword violates constraint: coverage_name value must not contain a single quote') WHERE NEW.coverage_name LIKE ('%''%');
SELECT RAISE(ABORT,
             'insert on vector_coverages_keyword violates constraint: coverage_name value must not contain a double quote') WHERE NEW.coverage_name LIKE ('%"%');
SELECT RAISE(ABORT,
             'insert on vector_coverages_keyword violates constraint: coverage_name value must be lower case') WHERE NEW.coverage_name <> lower(NEW.coverage_name);
END;
CREATE TRIGGER vector_coverages_keyword_name_update
    BEFORE UPDATE OF 'coverage_name' ON 'vector_coverages_keyword'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'update on vector_coverages_keyword violates constraint: coverage_name value must not contain a single quote') WHERE NEW.coverage_name LIKE ('%''%');
SELECT RAISE(ABORT,
             'update on vector_coverages_keyword violates constraint: coverage_name value must not contain a double quote') WHERE NEW.coverage_name LIKE ('%"%');
SELECT RAISE(ABORT,
             'update on vector_coverages_keyword violates constraint: coverage_name value must be lower case') WHERE NEW.coverage_name <> lower(NEW.coverage_name);
END;
CREATE TABLE wms_getcapabilities
(
    id       INTEGER PRIMARY KEY AUTOINCREMENT,
    url      TEXT NOT NULL,
    title    TEXT NOT NULL DEFAULT '*** undefined ***',
    abstract TEXT NOT NULL DEFAULT '*** undefined ***'
);
CREATE UNIQUE INDEX idx_wms_getcapabilities ON wms_getcapabilities (url);
CREATE TABLE wms_getmap
(
    id                 INTEGER PRIMARY KEY AUTOINCREMENT,
    parent_id          INTEGER NOT NULL,
    url                TEXT    NOT NULL,
    layer_name         TEXT    NOT NULL,
    title              TEXT    NOT NULL DEFAULT '*** undefined ***',
    abstract           TEXT    NOT NULL DEFAULT '*** undefined ***',
    version            TEXT    NOT NULL,
    srs                TEXT    NOT NULL,
    format             TEXT    NOT NULL,
    style              TEXT    NOT NULL,
    transparent        INTEGER NOT NULL CHECK (transparent IN (0, 1)),
    flip_axes          INTEGER NOT NULL CHECK (flip_axes IN (0, 1)),
    is_queryable       INTEGER NOT NULL CHECK (is_queryable IN (0, 1)),
    getfeatureinfo_url TEXT,
    bgcolor            TEXT,
    tiled              INTEGER NOT NULL CHECK (tiled IN (0, 1)),
    tile_width         INTEGER NOT NULL CHECK (tile_width BETWEEN 256 AND 5000),
    tile_height        INTEGER NOT NULL CHECK (tile_width BETWEEN 256 AND 5000),
    is_cached          INTEGER NOT NULL CHECK (is_cached IN (0, 1)),
    copyright          TEXT    NOT NULL DEFAULT '*** unknown ***',
    license            INTEGER NOT NULL DEFAULT 0,
    CONSTRAINT fk_wms_getmap FOREIGN KEY (parent_id) REFERENCES wms_getcapabilities (id) ON DELETE CASCADE,
    CONSTRAINT fk_wms_lic FOREIGN KEY (license) REFERENCES data_licenses (id)
);
CREATE UNIQUE INDEX idx_wms_getmap ON wms_getmap (url, layer_name);
CREATE TABLE wms_settings
(
    id         INTEGER PRIMARY KEY AUTOINCREMENT,
    parent_id  INTEGER NOT NULL,
    key        TEXT    NOT NULL CHECK (Lower(key) IN ('version', 'format', 'style')),
    value      TEXT    NOT NULL,
    is_default INTEGER NOT NULL CHECK (is_default IN (0, 1)),
    CONSTRAINT fk_wms_settings FOREIGN KEY (parent_id) REFERENCES wms_getmap (id) ON DELETE CASCADE
);
CREATE UNIQUE INDEX idx_wms_settings ON wms_settings (parent_id, key, value);
CREATE TABLE wms_ref_sys
(
    id         INTEGER PRIMARY KEY AUTOINCREMENT,
    parent_id  INTEGER NOT NULL,
    srs        TEXT    NOT NULL,
    minx       DOUBLE  NOT NULL,
    miny       DOUBLE  NOT NULL,
    maxx       DOUBLE  NOT NULL,
    maxy       DOUBLE  NOT NULL,
    is_default INTEGER NOT NULL CHECK (is_default IN (0, 1)),
    CONSTRAINT fk_wms_ref_sys FOREIGN KEY (parent_id) REFERENCES wms_getmap (id) ON DELETE CASCADE
);
CREATE UNIQUE INDEX idx_wms_ref_sys ON wms_ref_sys (parent_id, srs);
CREATE TABLE topologies
(
    topology_name TEXT    NOT NULL PRIMARY KEY,
    srid          INTEGER NOT NULL,
    tolerance     DOUBLE  NOT NULL,
    has_z         INTEGER NOT NULL,
    next_edge_id  INTEGER NOT NULL DEFAULT 1,
    CONSTRAINT topo_srid_fk FOREIGN KEY (srid) REFERENCES spatial_ref_sys (srid)
);
CREATE TRIGGER topology_name_insert
    BEFORE INSERT
    ON 'topologies'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'insert on topologies violates constraint: topology_name value must not contain a single quote') WHERE NEW.topology_name LIKE ('%''%');
SELECT RAISE(ABORT,
             'insert on topologies violates constraint: topology_name value must not contain a double quote') WHERE NEW.topology_name LIKE ('%"%');
SELECT RAISE(ABORT,
             'insert on topologies violates constraint: topology_name value must be lower case') WHERE NEW.topology_name <> lower(NEW.topology_name);
END;
CREATE TRIGGER topology_name_update
    BEFORE UPDATE OF 'topology_name' ON 'topologies'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'update on topologies violates constraint: topology_name value must not contain a single quote') WHERE NEW.topology_name LIKE ('%''%');
SELECT RAISE(ABORT,
             'update on topologies violates constraint: topology_name value must not contain a double quote') WHERE NEW.topology_name LIKE ('%"%');
SELECT RAISE(ABORT,
             'update on topologies violates constraint: topology_name value must be lower case') WHERE NEW.topology_name <> lower(NEW.topology_name);
END;
CREATE TABLE networks
(
    network_name     TEXT    NOT NULL PRIMARY KEY,
    spatial          INTEGER NOT NULL,
    srid             INTEGER NOT NULL,
    has_z            INTEGER NOT NULL,
    allow_coincident INTEGER NOT NULL,
    next_node_id     INTEGER NOT NULL DEFAULT 1,
    next_link_id     INTEGER NOT NULL DEFAULT 1,
    CONSTRAINT net_srid_fk FOREIGN KEY (srid) REFERENCES spatial_ref_sys (srid)
);
CREATE TRIGGER network_name_insert
    BEFORE INSERT
    ON 'networks'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'insert on networks violates constraint: network_name value must not contain a single quote') WHERE NEW.network_name LIKE ('%''%');
SELECT RAISE(ABORT,
             'insert on networks violates constraint: network_name value must not contain a double quote') WHERE NEW.network_name LIKE ('%"%');
SELECT RAISE(ABORT,
             'insert on networks violates constraint: network_name value must be lower case') WHERE NEW.network_name <> lower(NEW.network_name);
END;
CREATE TRIGGER network_name_update
    BEFORE UPDATE OF 'network_name' ON 'networks'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'update on networks violates constraint: network_name value must not contain a single quote') WHERE NEW.network_name LIKE ('%''%');
SELECT RAISE(ABORT,
             'update on networks violates constraint: network_name value must not contain a double quote') WHERE NEW.network_name LIKE ('%"%');
SELECT RAISE(ABORT,
             'update on networks violates constraint: network_name value must be lower case') WHERE NEW.network_name <> lower(NEW.network_name);
END;
CREATE TABLE SE_external_graphics
(
    xlink_href TEXT NOT NULL PRIMARY KEY,
    title      TEXT NOT NULL DEFAULT '*** undefined ***',
    abstract   TEXT NOT NULL DEFAULT '*** undefined ***',
    resource   BLOB NOT NULL,
    file_name  TEXT NOT NULL DEFAULT '*** undefined ***'
);
CREATE TRIGGER sextgr_mime_type_insert
    BEFORE INSERT
    ON 'SE_external_graphics'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'insert on SE_external_graphics violates constraint: GetMimeType(resource) must be one of ''image/gif'' | ''image/png'' | ''image/jpeg'' | ''image/svg+xml''') WHERE GetMimeType(NEW.resource) NOT IN ('image/gif', 'image/png', 'image/jpeg', 'image/svg+xml');
END;
CREATE TRIGGER sextgr_mime_type_update
    BEFORE UPDATE OF 'mime_type' ON 'SE_external_graphics'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'update on SE_external_graphics violates constraint: GetMimeType(resource) must be one of ''image/gif'' | ''image/png'' | ''image/jpeg'' | ''image/svg+xml''') WHERE GetMimeType(NEW.resource) NOT IN ('image/gif', 'image/png', 'image/jpeg', 'image/svg+xml');
END;
CREATE VIEW SE_external_graphics_view AS
SELECT xlink_href            AS xlink_href,
       title                 AS title,
       abstract              AS abstract,
       resource              AS resource,
       file_name             AS file_name,
       GetMimeType(resource) AS mime_type
FROM SE_external_graphics;
CREATE TABLE SE_fonts
(
    font_facename TEXT NOT NULL PRIMARY KEY,
    font          BLOB NOT NULL
);
CREATE VIEW SE_fonts_view AS
SELECT font_facename       AS font_facename,
       GetFontFamily(font) AS family_name,
       IsFontBold(font)    AS bold,
       IsFontItalic(font)  AS italic,
       font                AS font
FROM SE_fonts;
CREATE TABLE SE_raster_styles
(
    style_id   INTEGER PRIMARY KEY AUTOINCREMENT,
    style_name TEXT NOT NULL DEFAULT 'missing_name' UNIQUE,
    style      BLOB NOT NULL
);
CREATE INDEX idx_raster_styles ON SE_raster_styles (style_name);
CREATE TRIGGER seraster_style_insert
    BEFORE INSERT
    ON 'SE_raster_styles'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'insert on SE_raster_styles violates constraint: not a valid SLD/SE Raster Style') WHERE XB_IsSldSeRasterStyle(NEW.style) <> 1;
END;
CREATE TRIGGER seraster_style_update
    BEFORE UPDATE
    ON 'SE_raster_styles'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'update on SE_raster_styles violates constraint: not a valid SLD/SE Raster Style') WHERE XB_IsSldSeRasterStyle(NEW.style) <> 1;
END;
CREATE TRIGGER seraster_style_name_ins
    AFTER INSERT
    ON 'SE_raster_styles'
FOR EACH ROW
BEGIN
UPDATE SE_raster_styles
SET style_name = XB_GetName(NEW.style)
WHERE style_id = NEW.style_id;
END;
CREATE TRIGGER seraster_style_name_upd
    AFTER UPDATE OF style
    ON 'SE_raster_styles'
FOR EACH ROW
BEGIN
UPDATE SE_raster_styles
SET style_name = XB_GetName(NEW.style)
WHERE style_id = NEW.style_id;
END;
CREATE VIEW SE_raster_styles_view AS
SELECT style_name                  AS name,
       XB_GetTitle(style)          AS title,
       XB_GetAbstract(style)       AS abstract,
       style                       AS style,
       XB_IsSchemaValidated(style) AS schema_validated,
       XB_GetSchemaURI(style)      AS schema_uri
FROM SE_raster_styles;
CREATE TABLE SE_raster_styled_layers
(
    coverage_name TEXT    NOT NULL,
    style_id      INTEGER NOT NULL,
    CONSTRAINT pk_serstl PRIMARY KEY (coverage_name, style_id),
    CONSTRAINT fk_serstl_cov FOREIGN KEY (coverage_name) REFERENCES raster_coverages (coverage_name) ON DELETE CASCADE,
    CONSTRAINT fk_serstl_stl FOREIGN KEY (style_id) REFERENCES SE_raster_styles (style_id) ON DELETE CASCADE
);
CREATE INDEX idx_serstl_style ON SE_raster_styled_layers (style_id);
CREATE TRIGGER serstl_coverage_name_insert
    BEFORE INSERT
    ON 'SE_raster_styled_layers'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'insert on SE_raster_styled_layers violates constraint: coverage_name value must not contain a single quote') WHERE NEW.coverage_name LIKE ('%''%');
SELECT RAISE(ABORT,
             'insert on SE_raster_styled_layers violates constraint: coverage_name value must not contain a double quote') WHERE NEW.coverage_name LIKE ('%"%');
SELECT RAISE(ABORT,
             'insert on SE_raster_styled_layers violates constraint: coverage_name value must be lower case') WHERE NEW.coverage_name <> lower(NEW.coverage_name);
END;
CREATE TRIGGER serstl_coverage_name_update
    BEFORE UPDATE OF 'coverage_name' ON 'SE_raster_styled_layers'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'update on SE_raster_styled_layers violates constraint: coverage_name value must not contain a single quote') WHERE NEW.coverage_name LIKE ('%''%');
SELECT RAISE(ABORT,
             'update on SE_raster_styled_layers violates constraint: coverage_name value must not contain a double quote') WHERE NEW.coverage_name LIKE ('%"%');
SELECT RAISE(ABORT,
             'update on SE_raster_styled_layers violates constraint: coverage_name value must be lower case') WHERE NEW.coverage_name <> lower(NEW.coverage_name);
END;
CREATE VIEW SE_raster_styled_layers_view AS
SELECT l.coverage_name               AS coverage_name,
       l.style_id                    AS style_id,
       s.style_name                  AS name,
       XB_GetTitle(s.style)          AS title,
       XB_GetAbstract(s.style)       AS abstract,
       s.style                       AS style,
       XB_IsSchemaValidated(s.style) AS schema_validated,
       XB_GetSchemaURI(s.style)      AS schema_uri
FROM SE_raster_styled_layers AS l
         JOIN SE_raster_styles AS s ON (l.style_id = s.style_id);
CREATE TABLE SE_vector_styles
(
    style_id   INTEGER PRIMARY KEY AUTOINCREMENT,
    style_name TEXT NOT NULL DEFAULT 'missing_name' UNIQUE,
    style      BLOB NOT NULL
);
CREATE INDEX idx_vector_styles ON SE_vector_styles (style_name);
CREATE TRIGGER sevector_style_insert
    BEFORE INSERT
    ON 'SE_vector_styles'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'insert on SE_vector_styles violates constraint: not a valid SLD/SE Vector Style') WHERE XB_IsSldSeVectorStyle(NEW.style) <> 1;
END;
CREATE TRIGGER sevector_style_update
    BEFORE UPDATE
    ON 'SE_vector_styles'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'update on SE_vector_styles violates constraint: not a valid SLD/SE Vector Style') WHERE XB_IsSldSeVectorStyle(NEW.style) <> 1;
END;
CREATE TRIGGER sevector_style_name_ins
    AFTER INSERT
    ON 'SE_vector_styles'
FOR EACH ROW
BEGIN
UPDATE SE_vector_styles
SET style_name = XB_GetName(NEW.style)
WHERE style_id = NEW.style_id;
END;
CREATE TRIGGER sevector_style_name_upd
    AFTER UPDATE OF style
    ON 'SE_vector_styles'
FOR EACH ROW
BEGIN
UPDATE SE_vector_styles
SET style_name = XB_GetName(NEW.style)
WHERE style_id = NEW.style_id;
END;
CREATE VIEW SE_vector_styles_view AS
SELECT style_name                  AS name,
       XB_GetTitle(style)          AS title,
       XB_GetAbstract(style)       AS abstract,
       style                       AS style,
       XB_IsSchemaValidated(style) AS schema_validated,
       XB_GetSchemaURI(style)      AS schema_uri
FROM SE_vector_styles;
CREATE TABLE SE_vector_styled_layers
(
    coverage_name TEXT    NOT NULL,
    style_id      INTEGER NOT NULL,
    CONSTRAINT pk_sevstl PRIMARY KEY (coverage_name, style_id),
    CONSTRAINT fk_sevstl_cvg FOREIGN KEY (coverage_name) REFERENCES vector_coverages (coverage_name) ON DELETE CASCADE,
    CONSTRAINT fk_sevstl_stl FOREIGN KEY (style_id) REFERENCES SE_vector_styles (style_id) ON DELETE CASCADE
);
CREATE INDEX idx_sevstl_style ON SE_vector_styled_layers (style_id);
CREATE TRIGGER sevstl_coverage_name_insert
    BEFORE INSERT
    ON 'SE_vector_styled_layers'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'insert on SE_vector_styled_layers violates constraint: coverage_name value must not contain a single quote') WHERE NEW.coverage_name LIKE ('%''%');
SELECT RAISE(ABORT,
             'insert on SE_vector_styled_layers violates constraint: coverage_name value must not contain a double quote') WHERE NEW.coverage_name LIKE ('%"%');
SELECT RAISE(ABORT,
             'insert on SE_vector_styled_layers violates constraint: coverage_name value must be lower case') WHERE NEW.coverage_name <> lower(NEW.coverage_name);
END;
CREATE TRIGGER sevstl_coverage_name_update
    BEFORE UPDATE OF 'coverage_name' ON 'SE_vector_styled_layers'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'update on SE_vector_styled_layers violates constraint: coverage_name value must not contain a single quote') WHERE NEW.coverage_name LIKE ('%''%');
SELECT RAISE(ABORT,
             'update on SE_vector_styled_layers violates constraint: coverage_name value must not contain a double quote') WHERE NEW.coverage_name LIKE ('%"%');
SELECT RAISE(ABORT,
             'update on SE_vector_styled_layers violates constraint: coverage_name value must be lower case') WHERE NEW.coverage_name <> lower(NEW.coverage_name);
END;
CREATE VIEW SE_vector_styled_layers_view AS
SELECT l.coverage_name               AS coverage_name,
       v.f_table_name                AS f_table_name,
       v.f_geometry_column           AS f_geometry_column,
       l.style_id                    AS style_id,
       s.style_name                  AS name,
       XB_GetTitle(s.style)          AS title,
       XB_GetAbstract(s.style)       AS abstract,
       s.style                       AS style,
       XB_IsSchemaValidated(s.style) AS schema_validated,
       XB_GetSchemaURI(s.style)      AS schema_uri
FROM SE_vector_styled_layers AS l
         JOIN vector_coverages AS v ON (l.coverage_name = v.coverage_name)
         JOIN SE_vector_styles AS s ON (l.style_id = s.style_id);
CREATE TABLE ISO_metadata
(
    id         INTEGER PRIMARY KEY AUTOINCREMENT,
    md_scope   TEXT NOT NULL DEFAULT 'dataset',
    metadata   BLOB NOT NULL DEFAULT (zeroblob(4)),
    fileId     TEXT,
    parentId   TEXT,
    "geometry" MULTIPOLYGON
);
CREATE TRIGGER "ggi_ISO_metadata_geometry"
    BEFORE INSERT
    ON "ISO_metadata"
    FOR EACH ROW
BEGIN
    SELECT RAISE(ROLLBACK, 'ISO_metadata.geometry violates Geometry constraint [geom-type or SRID not allowed]') WHERE (SELECT geometry_type FROM geometry_columns
WHERE Lower(f_table_name) = Lower('ISO_metadata') AND Lower(f_geometry_column) = Lower('geometry')
AND GeometryConstraints(NEW."geometry", geometry_type, srid) = 1) IS NULL;
END;
CREATE TRIGGER "ggu_ISO_metadata_geometry"
    BEFORE UPDATE OF "geometry"
    ON "ISO_metadata"
    FOR EACH ROW
BEGIN
    SELECT RAISE(ROLLBACK, 'ISO_metadata.geometry violates Geometry constraint [geom-type or SRID not allowed]') WHERE (SELECT geometry_type FROM geometry_columns
WHERE Lower(f_table_name) = Lower('ISO_metadata') AND Lower(f_geometry_column) = Lower('geometry')
AND GeometryConstraints(NEW."geometry", geometry_type, srid) = 1) IS NULL;
END;
CREATE TRIGGER "tmu_ISO_metadata_geometry"
    AFTER UPDATE
    ON "ISO_metadata"
    FOR EACH ROW
BEGIN
    UPDATE geometry_columns_time
    SET last_update = strftime('%Y-%m-%dT%H:%M:%fZ', 'now')
    WHERE Lower(f_table_name) = Lower('ISO_metadata')
      AND Lower(f_geometry_column) = Lower('geometry');
END;
CREATE TRIGGER "tmi_ISO_metadata_geometry"
    AFTER INSERT
    ON "ISO_metadata"
    FOR EACH ROW
BEGIN
    UPDATE geometry_columns_time
    SET last_insert = strftime('%Y-%m-%dT%H:%M:%fZ', 'now')
    WHERE Lower(f_table_name) = Lower('ISO_metadata')
      AND Lower(f_geometry_column) = Lower('geometry');
END;
CREATE TRIGGER "tmd_ISO_metadata_geometry"
    AFTER DELETE
    ON "ISO_metadata"
    FOR EACH ROW
BEGIN
    UPDATE geometry_columns_time
    SET last_delete = strftime('%Y-%m-%dT%H:%M:%fZ', 'now')
    WHERE Lower(f_table_name) = Lower('ISO_metadata')
      AND Lower(f_geometry_column) = Lower('geometry');
END;
CREATE TRIGGER "gii_ISO_metadata_geometry"
    AFTER INSERT
    ON "ISO_metadata"
    FOR EACH ROW
BEGIN
    DELETE FROM "idx_ISO_metadata_geometry" WHERE pkid = NEW.ROWID;
    SELECT RTreeAlign('idx_ISO_metadata_geometry', NEW.ROWID, NEW."geometry");
END;
CREATE TRIGGER "giu_ISO_metadata_geometry"
    AFTER UPDATE OF "geometry"
    ON "ISO_metadata"
    FOR EACH ROW
BEGIN
    DELETE FROM "idx_ISO_metadata_geometry" WHERE pkid = NEW.ROWID;
    SELECT RTreeAlign('idx_ISO_metadata_geometry', NEW.ROWID, NEW."geometry");
END;
CREATE TRIGGER "gid_ISO_metadata_geometry"
    AFTER DELETE
    ON "ISO_metadata"
    FOR EACH ROW
BEGIN
    DELETE FROM "idx_ISO_metadata_geometry" WHERE pkid = OLD.ROWID;
END;
CREATE
VIRTUAL TABLE "idx_ISO_metadata_geometry" USING rtree(pkid, xmin, xmax, ymin, ymax)
/* idx_ISO_metadata_geometry(pkid,xmin,xmax,ymin,ymax) */;
CREATE TABLE IF NOT EXISTS "idx_ISO_metadata_geometry_rowid"
(
    rowid
    INTEGER
    PRIMARY
    KEY,
    nodeno
);
CREATE TABLE IF NOT EXISTS "idx_ISO_metadata_geometry_node"
(
    nodeno
    INTEGER
    PRIMARY
    KEY,
    data
);
CREATE TABLE IF NOT EXISTS "idx_ISO_metadata_geometry_parent"
(
    nodeno
    INTEGER
    PRIMARY
    KEY,
    parentnode
);
CREATE TRIGGER 'ISO_metadata_md_scope_insert'
BEFORE INSERT ON 'ISO_metadata'
FOR EACH ROW
BEGIN
SELECT RAISE(ROLLBACK, 'insert on table ISO_metadata violates constraint: md_scope must be one of ''undefined'' | ''fieldSession'' | ''collectionSession'' | ''series'' | ''dataset'' | ''featureType'' | ''feature'' | ''attributeType'' | ''attribute'' | ''tile'' | ''model'' | ''catalogue'' | ''schema'' | ''taxonomy'' | ''software'' | ''service'' | ''collectionHardware'' | ''nonGeographicDataset'' | ''dimensionGroup''') WHERE NOT(NEW.md_scope IN ('undefined','fieldSession','collectionSession','series','dataset','featureType','feature','attributeType','attribute','tile','model','catalogue','schema','taxonomy','software','service','collectionHardware','nonGeographicDataset','dimensionGroup'));
END;
CREATE TRIGGER 'ISO_metadata_md_scope_update'
BEFORE
UPDATE OF 'md_scope'
ON 'ISO_metadata'
    FOR EACH ROW
BEGIN
SELECT RAISE(ROLLBACK, 'update on table ISO_metadata violates constraint: md_scope must be one of ''undefined'' | ''fieldSession'' | ''collectionSession'' | ''series'' | ''dataset'' | ''featureType'' | ''feature'' | ''attributeType'' | ''attribute'' | ''tile'' | ''model'' | ''catalogue'' | ''schema'' | ''taxonomy'' | ''software'' | ''service'' | ''collectionHardware'' | ''nonGeographicDataset'' | ''dimensionGroup''') WHERE NOT(NEW.md_scope IN ('undefined','fieldSession','collectionSession','series','dataset','featureType','feature','attributeType','attribute','tile','model','catalogue','schema','taxonomy','software','service','collectionHardware','nonGeographicDataset','dimensionGroup'));
END;
CREATE TRIGGER 'ISO_metadata_fileIdentifier_insert'
AFTER INSERT ON 'ISO_metadata'
FOR EACH ROW
BEGIN
UPDATE ISO_metadata
SET fileId   = XB_GetFileId(NEW.metadata),
    parentId = XB_GetParentId(NEW.metadata),
    geometry = XB_GetGeometry(NEW.metadata)
WHERE id = NEW.id;
UPDATE ISO_metadata_reference
SET md_parent_id = GetIsoMetadataId(NEW.parentId)
WHERE md_file_id = NEW.id;
END;
CREATE TRIGGER 'ISO_metadata_fileIdentifier_update'
AFTER
UPDATE ON 'ISO_metadata'
    FOR EACH ROW
BEGIN
UPDATE ISO_metadata
SET fileId   = XB_GetFileId(NEW.metadata),
    parentId = XB_GetParentId(NEW.metadata),
    geometry = XB_GetGeometry(NEW.metadata)
WHERE id = NEW.id;
UPDATE ISO_metadata_reference
SET md_parent_id = GetIsoMetadataId(NEW.parentId)
WHERE md_file_id = NEW.id;
END;
CREATE TRIGGER ISO_metadata_insert
    BEFORE INSERT
    ON 'ISO_metadata'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'insert on ISO_metadata violates constraint: not a valid ISO Metadata XML') WHERE XB_IsIsoMetadata(NEW.metadata) <> 1 AND NEW.id <> 0;
END;
CREATE TRIGGER ISO_metadata_update
    BEFORE UPDATE
    ON 'ISO_metadata'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'update on ISO_metadata violates constraint: not a valid ISO Metadata XML') WHERE XB_IsIsoMetadata(NEW.metadata) <> 1 AND NEW.id <> 0;
END;
CREATE UNIQUE INDEX idx_ISO_metadata_ids ON ISO_metadata (fileId);
CREATE INDEX idx_ISO_metadata_parents ON ISO_metadata (parentId);
CREATE TABLE ISO_metadata_reference
(
    reference_scope TEXT    NOT NULL DEFAULT 'table',
    table_name      TEXT    NOT NULL DEFAULT 'undefined',
    column_name     TEXT    NOT NULL DEFAULT 'undefined',
    row_id_value    INTEGER NOT NULL DEFAULT 0,
    timestamp       TEXT    NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', CURRENT_TIMESTAMP)),
    md_file_id      INTEGER NOT NULL DEFAULT 0,
    md_parent_id    INTEGER NOT NULL DEFAULT 0,
    CONSTRAINT fk_isometa_mfi FOREIGN KEY (md_file_id) REFERENCES ISO_metadata (id),
    CONSTRAINT fk_isometa_mpi FOREIGN KEY (md_parent_id) REFERENCES ISO_metadata (id)
);
CREATE TRIGGER 'ISO_metadata_reference_scope_insert'
BEFORE INSERT ON 'ISO_metadata_reference'
FOR EACH ROW
BEGIN
SELECT RAISE(ROLLBACK, 'insert on table ISO_metadata_reference violates constraint: reference_scope must be one of ''table'' | ''column'' | ''row'' | ''row/col''') WHERE NOT NEW.reference_scope IN ('table','column','row','row/col');
END;
CREATE TRIGGER 'ISO_metadata_reference_scope_update'
BEFORE
UPDATE OF 'reference_scope'
ON 'ISO_metadata_reference'
    FOR EACH ROW
BEGIN
SELECT RAISE(ROLLBACK, 'update on table ISO_metadata_reference violates constraint: referrence_scope must be one of ''table'' | ''column'' | ''row'' | ''row/col''') WHERE NOT NEW.reference_scope IN ('table','column','row','row/col');
END;
CREATE TRIGGER 'ISO_metadata_reference_table_name_insert'
BEFORE INSERT ON 'ISO_metadata_reference'
FOR EACH ROW
BEGIN
SELECT RAISE(ROLLBACK, 'insert on table ISO_metadata_reference violates constraint: table_name must be the name of a table in geometry_columns') WHERE NOT NEW.table_name IN (
SELECT f_table_name AS table_name FROM geometry_columns);
END;
CREATE TRIGGER 'ISO_metadata_reference_table_name_update'
BEFORE
UPDATE OF 'table_name'
ON 'ISO_metadata_reference'
    FOR EACH ROW
BEGIN
SELECT RAISE(ROLLBACK, 'update on table ISO_metadata_reference violates constraint: table_name must be the name of a table in geometry_columns') WHERE NOT NEW.table_name IN (
SELECT f_table_name AS table_name FROM geometry_columns);
END;
CREATE TRIGGER 'ISO_metadata_reference_row_id_value_insert'
BEFORE INSERT ON 'ISO_metadata_reference'
FOR EACH ROW
BEGIN
SELECT RAISE(ROLLBACK, 'insert on ISO_table ISO_metadata_reference violates constraint: row_id_value must be 0 when reference_scope is ''table'' or ''column''') WHERE NEW.reference_scope IN ('table','column') AND NEW.row_id_value <> 0;
SELECT RAISE(ROLLBACK, 'insert on table ISO_metadata_reference violates constraint: row_id_value must exist in specified table when reference_scope is ''row'' or ''row/col''') WHERE NEW.reference_scope IN ('row','row/col') AND NOT EXISTS
(SELECT rowid FROM (SELECT NEW.table_name AS table_name) WHERE rowid = NEW.row_id_value);
END;
CREATE TRIGGER 'ISO_metadata_reference_row_id_value_update'
BEFORE
UPDATE OF 'row_id_value'
ON 'ISO_metadata_reference'
    FOR EACH ROW
BEGIN
SELECT RAISE(ROLLBACK, 'update on table ISO_metadata_reference violates constraint: row_id_value must be 0 when reference_scope is ''table'' or ''column''') WHERE NEW.reference_scope IN ('table','column') AND NEW.row_id_value <> 0;
SELECT RAISE(ROLLBACK, 'update on ISO_table metadata_reference violates constraint: row_id_value must exist in specified table when reference_scope is ''row'' or ''row/col''') WHERE NEW.reference_scope IN ('row','row/col') AND NOT EXISTS
(SELECT rowid FROM (SELECT NEW.table_name AS table_name) WHERE rowid = NEW.row_id_value);
END;
CREATE TRIGGER 'ISO_metadata_reference_timestamp_insert'
BEFORE INSERT ON 'ISO_metadata_reference'
FOR EACH ROW
BEGIN
SELECT RAISE(ROLLBACK, 'insert on table ISO_metadata_reference violates constraint: timestamp must be a valid time in ISO 8601 ''yyyy-mm-ddThh:mm:ss.cccZ'' form') WHERE NOT (NEW.timestamp GLOB'[1-2][0-9][0-9][0-9]-[0-1][0-9]-[1-3][0-9]T[0-2][0-9]:[0-5][0-9]:[0-5][0-9].[0-9][0-9][0-9]Z' AND strftime('%s',NEW.timestamp) NOT NULL);
END;
CREATE TRIGGER 'ISO_metadata_reference_timestamp_update'
BEFORE
UPDATE OF 'timestamp'
ON 'ISO_metadata_reference'
    FOR EACH ROW
BEGIN
SELECT RAISE(ROLLBACK, 'update on table ISO_metadata_reference violates constraint: timestamp must be a valid time in ISO 8601 ''yyyy-mm-ddThh:mm:ss.cccZ'' form') WHERE NOT (NEW.timestamp GLOB'[1-2][0-9][0-9][0-9]-[0-1][0-9]-[1-3][0-9]T[0-2][0-9]:[0-5][0-9]:[0-5][0-9].[0-9][0-9][0-9]Z' AND strftime('%s',NEW.timestamp) NOT NULL);
END;
CREATE INDEX idx_ISO_metadata_reference_ids ON ISO_metadata_reference (md_file_id);
CREATE INDEX idx_ISO_metadata_reference_parents ON ISO_metadata_reference (md_parent_id);
CREATE VIEW ISO_metadata_view AS
SELECT id                             AS id,
       md_scope                       AS md_scope,
       XB_GetTitle(metadata)          AS title,
       XB_GetAbstract(metadata)       AS abstract,
       geometry                       AS geometry,
       fileId                         AS fileIdentifier,
       parentId                       AS parentIdentifier,
       metadata                       AS metadata,
       XB_IsSchemaValidated(metadata) AS schema_validated,
       XB_GetSchemaURI(metadata)      AS metadata_schema_URI
FROM ISO_metadata;
CREATE TABLE stored_procedures
(
    name     TEXT NOT NULL PRIMARY KEY,
    title    TEXT NOT NULL,
    sql_proc BLOB NOT NULL
);
CREATE TRIGGER storproc_ins
    BEFORE INSERT
    ON stored_procedures
    FOR EACH ROW
BEGIN
    SELECT RAISE(ROLLBACK, 'Invalid "sql_proc": not a BLOB of the SQL Procedure type') WHERE SqlProc_IsValid(NEW.sql_proc) <> 1;
END;
CREATE TRIGGER storproc_upd
    BEFORE UPDATE OF sql_proc
    ON stored_procedures
    FOR EACH ROW
BEGIN
    SELECT RAISE(ROLLBACK, 'Invalid "sql_proc": not a BLOB of the SQL Procedure type') WHERE SqlProc_IsValid(NEW.sql_proc) <> 1;
END;
CREATE TABLE stored_variables
(
    name  TEXT NOT NULL PRIMARY KEY,
    title TEXT NOT NULL,
    value TEXT NOT NULL
);
CREATE TABLE rl2map_configurations
(
    id     INTEGER PRIMARY KEY AUTOINCREMENT,
    name   TEXT NOT NULL DEFAULT 'missing_name' UNIQUE,
    config BLOB NOT NULL
);
CREATE TRIGGER rl2map_config_insert
    BEFORE INSERT
    ON 'rl2map_configurations'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'insert on rl2map_configurations violates constraint: not a valid RL2MapConfig') WHERE XB_IsMapConfig(NEW.config) <> 1;
END;
CREATE TRIGGER rl2map_config_update
    BEFORE UPDATE
    ON 'rl2map_configurations'
FOR EACH ROW
BEGIN
SELECT RAISE(ABORT,
             'update on rl2map_configurations violates constraint: not a valid RL2MapConfig') WHERE XB_IsMapConfig(NEW.config) <> 1;
END;
CREATE TRIGGER rl2map_config_name_ins
    AFTER INSERT
    ON 'rl2map_configurations'
FOR EACH ROW
BEGIN
UPDATE rl2map_configurations
SET name = XB_GetName(NEW.config)
WHERE id = NEW.id;
END;
CREATE TRIGGER rl2map_config_name_upd
    AFTER UPDATE OF config
    ON 'rl2map_configurations'
FOR EACH ROW
BEGIN
UPDATE rl2map_configurations
SET name = XB_GetName(NEW.config)
WHERE id = NEW.id;
END;
CREATE VIEW rl2map_configurations_view AS
SELECT name                         AS name,
       XB_GetTitle(config)          AS title,
       XB_GetAbstract(config)       AS abstract,
       config                       AS config,
       XB_IsSchemaValidated(config) AS schema_validated,
       XB_GetSchemaURI(config)      AS schema_uri
FROM rl2map_configurations;
