SELECT 
        SRV.SESUSUSC NUMERO_CUENTA,
        SRV.SESUNUSE PRODUCTO,
        GEO.DISPLAY_DESCRIPTION MUNICIPIO,
        SUB.SUCADESC SUBCATEGORIA,
        CL.CICLDESC CICLO_FACTURACION,
        REGEXP_SUBSTR(CRG.CARGDOSO, '[^- ]+', 1, 2) ID_VENTA,
        PFAC.PEFAANO||PFAC.PEFAMES PERIODO,
        CRG.CARGCONC CONCEPTO_SEGURO,
        CRG.CARGVALO VALOR_FACTURADO,
        SUM(DIFE.DIFESAPE) VALOR_PENDIENTE,
        CUE.CUCOCODI CUENTA_COBRO,
        CUE.CUCOFEVE FECHA_VENC_FACTURA,
        FAC.FACTCODI NUM_FACTURA_CORRIENTE,
        COUNT(CUE.CUCOCODI)CUOTAS_PENDIENTES_PAGO,
        ROUND((SYSDATE-CUE.CUCOFEVE )) EDAD_CARTERA_VENCI
FROM 
        SFBZ0800.SERVSUSC SRV,
        SFBZ0800.AB_ADDRESS AB,
        SFBZ0800.SUSCRIPC SUS,
        SFBZ0800.GE_GEOGRA_LOCATION GEO,
        SFBZ0800.SUBCATEG SUB,
        SFBZ0800.CATEGORI CAT,
        SFBZ0800.CICLO CL,
        SFBZ0800.CARGOS CRG,
        SFBZ0800.CONCEPTO CON,
        SFBZ0800.FACTURA FAC,
        SFBZ0800.PERIFACT PFAC,
        SFBZ0800.DIFERIDO DIFE,
        SFBZ0800.CUENCOBR CUE
WHERE 
        SRV.SESUSUSC=SUS.SUSCCODI
        AND SUS.SUSCIDDI=AB.ADDRESS_ID
        AND AB.NEIGHBORTHOOD_ID = GEO.GEOGRAP_LOCATION_ID
        AND SRV.SESUCATE=CAT.CATECODI
        AND SRV.SESUCATE=SUB.SUCACATE
        AND SRV.SESUSUCA=SUB.SUCACODI
        AND SRV.SESUCICL=CL.CICLCODI
        AND SRV.SESUNUSE=CRG.CARGNUSE
        AND FAC.FACTSUSC = SRV.SESUSUSC
        AND PFAC.PEFACODI = FAC.FACTPEFA
        AND CRG.CARGCONC=CON.CONCCODI
        AND CRG.CARGPEFA = PFAC.PEFACODI
        AND DIFE.DIFESUSC=SUS.SUSCCODI
        AND DIFE.DIFENUSE=SRV.SESUNUSE
        AND CUE.CUCONUSE = SRV.SESUNUSE
        AND CUE.CUCOFACT=FAC.FACTCODI
        AND CRG.CARGCONC IN (439,440,441,445,446,447) 
/*--------------------FILTROS------------------*/
        AND SRV.SESUSUSC =  (:CUENTA) 
        AND CL.CICLDESC  =  (:DESCC) -- TENER EN CUENTA SINTAXIS DE LOS DATOS 
        AND PFAC.PEFAANO >= (:ANO)  AND PFAC.PEFAANO  <=(:ANO2)
        AND PFAC.PEFAMES >= (:MES1) AND PFAC.PEFAMES <=(:MES2) 

/*---------------------------------------------*/
        group by SRV.SESUSUSC, SRV.SESUNUSE, GEO.DISPLAY_DESCRIPTION, SUB.SUCADESC, CL.CICLDESC, 
        REGEXP_SUBSTR(CRG.CARGDOSO, '[^- ]+', 1, 2), PFAC.PEFAANO||PFAC.PEFAMES, CRG.CARGCONC, CRG.CARGVALO, CUE.CUCOCODI, 
        CUE.CUCOFEVE, FAC.FACTCODI, ROUND((SYSDATE-CUE.CUCOFEVE ))
