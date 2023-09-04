SELECT
FAC.FACTCODI ID_FACTURA,
(SELECT PEF.PEFADESC FROM SFBZ0800.PERIFACT PEF,SFBZ0800.FACTURA FAC WHERE FAC.FACTPEFA = PEF.PEFACODI AND  CUE.CUCOFACT = FAC.FACTCODI )PERIODO_FACTURACION,
(case when CON.CONCCLCO between 1000 AND 1999
          then 'ACUEDUCTO'
            else
         case when CON.CONCCLCO between 2000 AND 2999
         then 'ALCANTARILLADO'
            else
         case when CON.CONCCLCO between 3000 AND 3999 AND CON.CONCCLCO NOT IN(3050,3501,3501,3502) AND CON.CONCCODI NOT IN (80,81,82,83)
          then 'ASEO'
            else
          case when CON.CONCCLCO IN (3050,3501,3501,3502) AND CON.CONCCODI IN (80,81,82,83)
          then 'SERVICIO OTROS CONCEPTOS'
            else
         case when CON.CONCCLCO in (9910, 9940)
          then 'ACUEDUCTO'
            else
         case when CON.CONCCLCO in (9920, 9950)
          then 'ALCANTARILLADO'
            else
         case when CON.CONCCLCO in (9930, 9960)
          then 'ASEO'
          else
          'ASEO'
                    END
                 END
              END
           END
        END
     END
          END) RUBRO,
SUM(CRG.CARGVALO)MONTO
FROM 
--SFBZ0800.SERVSUSC SRV,
SFBZ0800.CARGOS   CRG,
SFBZ0800.CONCEPTO CON,
SFBZ0800.CUENCOBR CUE,
SFBZ0800.FACTURA FAC,
SFBZ0800.PERIFACT PFAC
--SFBZ0800.CATEGORI CAT
WHERE
--CRG.CARGCUCO IN (72049505,72057166  /*73352908,73365064 */)
--FAC.FACTCODI = 44913396
--AND SRV.SESUSUSC = FAC.FACTSUSC
--AND SRV.SESUCATE = CAT.CATECODI
 FAC.FACTPEFA=PFAC.PEFACODI
AND CRG.CARGCONC =CON.CONCCODI 
AND CRG.CARGCUCO=CUE.CUCOCODI
AND CUE.CUCOFACT=FAC.FACTCODI
/*--------------------------FILTROS-----------------------------------*/
AND FAC.FACTPROG = DECODE(:recurrente, NULL,FAC.FACTPROG,:recurrente)
AND PFAC.PEFAANO = (:ANO) AND PFAC.PEFAMES = (:MES) 
--AND CAT.CATEDESC = (:CATEDESC)
AND CRG.CARGSIGN <> 'PA'
/*--------------------------------------------------------------------*/
GROUP BY 
FAC.FACTCODI,
CUE.CUCOFACT,
(case when CON.CONCCLCO between 1000 AND 1999
          then 'ACUEDUCTO'
            else
         case when CON.CONCCLCO between 2000 AND 2999
         then 'ALCANTARILLADO'
            else
         case when CON.CONCCLCO between 3000 AND 3999 AND CON.CONCCLCO NOT IN(3050,3501,3501,3502) AND CON.CONCCODI NOT IN (80,81,82,83)
          then 'ASEO'
            else
          case when CON.CONCCLCO IN (3050,3501,3501,3502) AND CON.CONCCODI IN (80,81,82,83)
          then 'SERVICIO OTROS CONCEPTOS'
            else
         case when CON.CONCCLCO in (9910, 9940)
          then 'ACUEDUCTO'
            else
         case when CON.CONCCLCO in (9920, 9950)
          then 'ALCANTARILLADO'
            else
         case when CON.CONCCLCO in (9930, 9960)
          then 'ASEO'
          else
          'ASEO'
                    END
                 END
              END
           END
        END
     END
          END
         );
CRG.CARGVALO;