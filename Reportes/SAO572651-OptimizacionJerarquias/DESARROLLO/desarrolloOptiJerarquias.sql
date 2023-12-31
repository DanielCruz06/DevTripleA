WITH 
VM_HIJOS AS (
SELECT  
        EMEDI.ELMEEMAC ID_PADRE,
        ESESU.EMSSSESU PRODUCTO_HIJO,
        EMEDI.ELMECODI SERIAL_HIJO,
        SUM(DECODE(CONS.COSSMECC,4,CONS.COSSCOCA,0))CONSUMO,
        CONS.COSSPEFA PERIODO_HIJO,
        ESESU.EMSSFEIN FECH_INST_HIJO,
        ESESU.EMSSFERE FECH_REST_HIJO,
        AB.ADDRESS_PARSED DIRECCION_HIJO,
        CAT.CATEDESC CATEGORIA_HIJO,
        SUB.SUCADESC SUBCATEGORIA_HIJO,
        CONS.COSSFUFA CALCULO,
        (SELECT OBLEDESC FROM SFBZ0800.OBSELECT WHERE OBLECODI = LEC.LEEMOBLE) OBS1,
        (SELECT OBLEDESC FROM SFBZ0800.OBSELECT WHERE OBLECODI = LEC.LEEMOBSB) OBS2,
        (SELECT OBLEDESC FROM SFBZ0800.OBSELECT WHERE OBLECODI = LEC.LEEMOBSC) OBS3
FROM 
        SFBZ0800.SERVSUSC SRV,
        SFBZ0800.SUSCRIPC SUS,
        SFBZ0800.AB_ADDRESS AB,
        SFBZ0800.ELEMMEDI EMEDI,
        SFBZ0800.ELMESESU ESESU,
        SFBZ0800.CONSSESU CONS,
        SFBZ0800.CATEGORI CAT,
        SFBZ0800.SUBCATEG SUB,
        SFBZ0800.LECTELME LEC  
WHERE 
        EMEDI.ELMEIDEM = ESESU.EMSSELME 
        AND SRV.SESUNUSE = ESESU.EMSSSESU
        AND SUS.SUSCCODI = SRV.SESUSUSC
        AND CONS.COSSSESU=SRV.SESUNUSE
        AND AB.ADDRESS_ID = SUS.SUSCIDDI
        AND ESESU.EMSSFERE > SYSDATE
        AND SRV.SESUCATE = CAT.CATECODI
        AND SRV.SESUCATE = SUB.SUCACATE 
        AND SRV.SESUSUCA = SUB.SUCACODI
        AND LEC.LEEMELME = EMEDI.ELMEIDEM 
        AND CONS.COSSPEFA = LEC.LEEMPEFA
        AND EMEDI.ELMEEMAC IS NOT NULL
        --AND EMEDI.ELMEEMAC = 393114
        group by EMEDI.ELMEEMAC, ESESU.EMSSSESU, EMEDI.ELMECODI, CONS.COSSPEFA, ESESU.EMSSFEIN, 
        ESESU.EMSSFERE, AB.ADDRESS_PARSED, CAT.CATEDESC, SUB.SUCADESC, CONS.COSSFUFA,LEC.LEEMOBLE,LEC.LEEMOBSB,LEC.LEEMOBSC),
VM_PADRES AS (
SELECT
        EMEDI.ELMEIDEM,
        ESESU.EMSSSESU PRODUCTO_PADRE,
        EMEDI.ELMECODI SERIAL_PADRE,
        SUM(DECODE(CONS.COSSMECC,4,CONS.COSSCOCA,0))CONSUMO_PADRE,
        LEC.LEEMLETO,
        LEC.LEEMLEAN,
        CONS.COSSPEFA PERIODO_PADRE,
        ESESU.EMSSFEIN FECHA_INS_PADRE,
        ESESU.EMSSFERE FECHA_RET_PADRE,
        AB.ADDRESS_PARSED DIRECCION_PADRE,
        CAT.CATEDESC CATEGORIA_PADRE,
        SUB.SUCADESC SUBCATEGORIA_PADRE
FROM
        SFBZ0800.SERVSUSC SRV,
        SFBZ0800.SUSCRIPC SUS,
        SFBZ0800.AB_ADDRESS AB,
        SFBZ0800.ELEMMEDI EMEDI,
        SFBZ0800.ELMESESU ESESU,
        SFBZ0800.CONSSESU CONS,
        SFBZ0800.CATEGORI CAT,
        SFBZ0800.SUBCATEG SUB,
        SFBZ0800.LECTELME LEC  
WHERE
        EMEDI.ELMEIDEM = ESESU.EMSSELME 
        AND SRV.SESUNUSE = ESESU.EMSSSESU
        AND SUS.SUSCCODI = SRV.SESUSUSC
        AND CONS.COSSSESU=SRV.SESUNUSE
        AND AB.ADDRESS_ID = SUS.SUSCIDDI
        AND SRV.SESUCATE = CAT.CATECODI
        AND SRV.SESUCATE = SUB.SUCACATE 
        AND SRV.SESUSUCA = SUB.SUCACODI
        AND LEC.LEEMELME = EMEDI.ELMEIDEM 
        AND CONS.COSSPEFA = LEC.LEEMPEFA 
        group by EMEDI.ELMEIDEM, ESESU.EMSSSESU, EMEDI.ELMECODI, LEC.LEEMLETO, LEC.LEEMLEAN, 
        CONS.COSSPEFA, ESESU.EMSSFEIN, ESESU.EMSSFERE, AB.ADDRESS_PARSED, CAT.CATEDESC, 
        SUB.SUCADESC)
SELECT
        CL.CICLDESC CICLO,
        PFAC.PEFADESC PERIODO,
        A.PRODUCTO_PADRE,
        A.SERIAL_PADRE,
        A.PERIODO_PADRE,
        A.FECHA_INS_PADRE,
        A.FECHA_RET_PADRE,
        A.DIRECCION_PADRE,
        A.CATEGORIA_PADRE,
        A.SUBCATEGORIA_PADRE,
        A.CONSUMO_PADRE CONSUMO_PADRE,
        A.LEEMLETO LECTURA_TOMADA,
        A.LEEMLEAN LECTURA_ANTERIOR,
        B.PRODUCTO_HIJO,
        B.SERIAL_HIJO,
        B.FECH_INST_HIJO,
        B.FECH_REST_HIJO,
        B.DIRECCION_HIJO,
        B.CATEGORIA_HIJO,
        B.SUBCATEGORIA_HIJO,
        B.CONSUMO CONSUMO_HIJO,
        B.CALCULO FUNCION_CALCULO,
        B.OBS1,
        B.OBS2,
        B.OBS3
FROM 
        VM_HIJOS B,
        VM_PADRES A,
        SFBZ0800.PERIFACT PFAC,
        SFBZ0800.CICLO CL
WHERE 
        B.ID_PADRE=A.ELMEIDEM
        AND B.PERIODO_HIJO=A.PERIODO_PADRE
        AND PFAC.PEFACODI=A.PERIODO_PADRE
        AND PFAC.PEFACICL = CL.CICLCODI
        AND PFAC.PEFACODI IN (:ID_PERIODO)
        ORDER BY B.ID_PADRE
;