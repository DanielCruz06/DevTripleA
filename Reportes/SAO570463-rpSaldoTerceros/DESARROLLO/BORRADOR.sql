ALTER SESSION SET CURRENT_SCHEMA = SFBZ0800;
SELECT * FROM SFBZ0800.GE_GEOGRA_LOCATION; --1297
SELECT * FROM SUSCRIPC, AB_ADDRESS,GE_GEOGRA_LOCATION GEO
WHERE SUSCIDDI = 1322610 
AND SUSCIDDI = ADDRESS_ID
AND NEIGHBORTHOOD_ID = GEO.GEOGRAP_LOCATION_ID;
SELECT * FROM SERVSUSC;
SELECT CARGNUSE,SESUNUSE,CARGDOSO FROM CARGOS, SERVSUSC  WHERE CARGNUSE=1001658051 AND CARGNUSE = SESUNUSE ;
SELECT 
CARGDOSO,
  REGEXP_SUBSTR(CARGDOSO, '[^- ]+', 1, 1) AS parte1,
  REGEXP_SUBSTR(CARGDOSO, '[^- ]+', 1, 2) AS ID_VENTA
FROM CARGOS WHERE CARGNUSE=1001658051 
AND CARGCONC IN (439,440,441,445,446,447);
SELECT * FROM CONCEPTO WHERE CONCCODI IN (439,440,441,445,446,447);
SELECT * FROM PERIFACT;
SELECT * FROM FACTURA ;
SELECT DIFE.DIFECODI ,SUM(DIFE.DIFESAPE),DIFE.DIFESUSC FROM DIFERIDO DIFE, SERVSUSC SRV 
WHERE  DIFE.DIFESUSC=SRV.SESUSUSC 
--AND DIFE.DIFESAPE <>0
AND DIFE.DIFECONC IN (439,440,441,445,446,447)
group by DIFE.DIFECODI,DIFE.DIFESUSC ;
SELECT * FROM DIFERIDO WHERE DIFESUSC = 165805 ;--WHERE DIFECONC IN (439,440,441,445,446,447) ;
SELECT * from CARGOS WHERE CARGNUSE  in (1001658051,2165805101)
AND CARGCONC IN (439,440,441,445,446,447);
--AND CARGECR LIKE '%/10/2022%';
SELECT * FROM CUENCOBR WHERE CUCONUSE IN (1001658051,2165805101);
