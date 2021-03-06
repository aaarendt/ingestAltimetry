﻿-- Materialized View: ergi_mat_view_new

-- new method for making the ergi view table
-- no need to use the points files to identify the various types
-- now this is determined directly from the four character RGI table codes

DROP MATERIALIZED VIEW ergi_mat_view;
CREATE MATERIALIZED VIEW ergi_mat_view AS 
 SELECT DISTINCT ON (ergi.glimsid) ergi.glimsid,
    ergi.ergiid,
    ergi.area,
    ergi.albersgeom,
    ergi.name,
	ergi.max,
	ergi.min,
	CASE 
	   WHEN ergi.gltype LIKE '_0__' THEN 0 -- Land Terminating
	   WHEN ergi.gltype LIKE '_1__' THEN 1 -- Tidewater
	   WHEN ergi.gltype LIKE '_2__' THEN 2 -- Lake
	END
	AS gltype,
	CASE 
	   WHEN (ergi.gltype LIKE '__1_' OR ergi.gltype LIKE '__3_') THEN TRUE
	   ELSE FALSE
	END
	AS surge,
    b.region,
    a.paperid AS arendtregion
   FROM ergi
     LEFT JOIN ( SELECT ergi_1.ergiid,
            ar.paperid
           FROM ergi ergi_1,
            arendtregions ar
          WHERE st_contains(ar.albersgeom, st_centroid(ergi_1.albersgeom))) a ON ergi.ergiid = a.ergiid
     LEFT JOIN ( SELECT ergi_1.ergiid,
            br.region
           FROM ergi ergi_1,
            burgessregions br
          WHERE st_contains(br.albersgeom, st_centroid(ergi_1.albersgeom))) b ON ergi.ergiid = b.ergiid
WITH DATA;

ALTER TABLE ergi_mat_view
  OWNER TO admin;
GRANT ALL ON TABLE ergi_mat_view TO admin;
GRANT ALL ON TABLE ergi_mat_view TO altimetryuser;
