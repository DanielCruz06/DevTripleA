select a.PERIODO_CONSUMO, PERIODO_FACT, DESC_PERIODO, CICLO, ZONA, CUENTA, ID_PRODUCTO, NOMBRE_CLIENTE, TIPO_CLIENTE, DESC_NOMINA, ID_PLAN, PLAN, ALTERNATIVA, ID_CALIFICA, CALIFICACION, ID_TIPO_CONS, SERVICIO, TIPO_CONSUMO, ID_CATEGORIA, CATEGORIA, ID_SUBCATEG, SUBCATEGORIA, ID_PREDIO, DIRECCION, MUNICIPIO,
DECODE(ab.PREMISE_STATUS_ID,1,'HABITADO' , 2, 'DESOCUPADO' , 'No definido') estado_predio,
ZONA_TARIFARIA, MEDIDOR, FEC_INST_MEDI, CONSUMO, CONSUM_FACT, CONSUM_RECUPERADO, CONSUMO_CRITICA, CALIF_CRITICA, ORDEN_CRITICA, COMENTARIO, ANALISTA_CRITICA, ORDEN_LECTURA, ORDEN_RELECTURA, ORDEN_ADICIONAL, PROMEDIO, FUNCION, DIAS, LECT_ACTUAL, FEC_LEC_ACT, LECT_ANTERIOR, FEC_LEC_ANT, FACTOR, CAUSA_LECT, DESC_CAUSA_LECT, OBSERVACION1, OBSERVACION2, OBSERVACION3, CARGA, METOD_CONSUMO, VALORFACTURADO, SALDO, VALORABONADO, VALORTOTAL
from (


SELECT consu.cosspecs||' - '||((select cicldesc from SFBZ0800.ciclo where ciclcodi = sesu.sesucicl and rownum=1))||'- '||to_char((select pecsfeci from SFBZ0800.pericose where PECSCONS =consu.cosspecs), 'YYYY/MM/DD')||' - '||to_char((select pecsfecf from SFBZ0800.pericose where PECSCONS =consu.cosspecs), 'YYYY/MM/DD')periodo_consumo,
(
select pefacodi from SFBZ0800.perifact where pefapecs = consu.cosspecs
)periodo_fact,
(
select pefadesc from SFBZ0800.perifact where pefapecs = consu.cosspecs
and rownum=1
)desc_periodo,
sesu.sesucico ciclo,
(
select cicldesc from SFBZ0800.ciclo where ciclcodi = sesu.sesucicl
and rownum=1
)zona,
sesu.sesususc cuenta,
sesu.sesunuse id_producto,
(
select subscriber_name||' '||subs_last_name
from SFBZ0800.suscripc, SFBZ0800.ge_subscriber
where sesususc=susccodi and suscclie=subscriber_id 
and rownum=1--validacion por cuenta y por cliente
) NOMBRE_CLIENTE,

(
select st.subscriber_type_id||' - '||description description
from SFBZ0800.suscripc su, SFBZ0800.ge_subscriber s, SFBZ0800.ge_subscriber_type st
where sesususc=su.susccodi and su.suscclie=s.subscriber_id --validacion por cuenta y por cliente
and s.subscriber_type_id = st.subscriber_type_id
and rownum=1
)Tipo_Cliente,

(
CASE WHEN (sesu.sesususc in (select SUSCCODI from SFBZ0800.suscripc where susctdco='DA' and suscbanc in (189,190))) THEN
'SI'
ELSE
'NO'
END

)Desc_Nomina,
sesu.sesuplfa id_plan,

(SELECT plsudesc  FROM SFBZ0800.plansusc  
WHERE plsucodi =sesu.sesuplfa
and rownum=1
)
 plan,
(
select description
from SFBZ0800.compsesu a, SFBZ0800.servsusc se, SFBZ0800.ps_class_service c
where a.cmsssesu=sesu.sesunuse
and se.sesususc=sesu.sesususc
and c.class_service_id = a.cmssclse
and a.cmsstcom = 58
and a.cmssfere>sysdate
and rownum = 1
) Alternativa,
consu.cosscavc id_califica, --calificacion del consumo
(Select cavcdesc from SFBZ0800.calivaco
Where cavccodi = consu.cosscavc 
and rownum=1)calificacion, --calificacion del consumo
consu.cosstcon id_tipo_cons,
(
select servdesc from SFBZ0800.servicio s, SFBZ0800.pr_product p where p.product_id = consu.cosssesu
and s.servcodi = p.product_type_id
and rownum=1
)servicio,
(
select tcon.tcondesc FROM SFBZ0800.tipocons tcon
WHERE consu.cosstcon=tcon.tconcodi
and rownum=1
) tipo_consumo,
sesu.sesucate id_categoria,
(select catedesc from SFBZ0800.categori where catecodi = sesu.sesucate
and rownum=1) categoria,
sesu.sesusuca id_subcateg,
(select sucadesc from SFBZ0800.subcateg where sucacodi = sesu.sesusuca and sucacate = sesu.sesucate
and rownum=1)subcategoria,
(
select y.address_id from SFBZ0800.ab_address y, SFBZ0800.pr_product x where x.product_id=sesunuse
and x.address_id=y.address_id
and rownum=1
) id_predio,
(
select y.address_parsed from SFBZ0800.ab_address y, SFBZ0800.pr_product x where x.product_id=sesunuse
and x.address_id=y.address_id
and rownum=1
) direccion,
(
select z.description from SFBZ0800.ge_geogra_location z, SFBZ0800.ab_address y, SFBZ0800.pr_product x where x.product_id=sesunuse
and x.address_id=y.address_id and y.geograp_location_id=z.geograp_location_id
and rownum=1
) municipio,

(
select w.description from SFBZ0800.ab_pricing_zone w, SFBZ0800.ab_premise z, SFBZ0800.ab_address y, SFBZ0800.pr_product x where x.product_id=sesunuse
and x.address_id=y.address_id and y.estate_number=z.premise_id and z.pricing_zone_id=w.pricing_zone_id
and rownum=1
) zona_tarifaria,
(
select elme.emsscoem FROM SFBZ0800.elmesesu elme
WHERE elme.emssfere > sysdate
and elme.emsssesu = sesu.sesunuse
and rownum=1
) medidor,
(
select elme.emssfein FROM SFBZ0800.elmesesu elme
WHERE elme.emssfere > sysdate
and elme.emsssesu = sesu.sesunuse
and rownum=1
) fec_inst_medi,
nvl(consu.cosscoca,0) consumo, --unidades de consumo
(
select sum(nvl(cosscoca,0)) FROM SFBZ0800.conssesu z --unidades de consumo
WHERE consu.cosssesu=z.cosssesu
AND consu.cosstcon=z.cosstcon --tipo de consumo
AND consu.cosspecs=z.cosspecs --periodo de consumo
AND z.cossmecc=4 --metodo de calculo de consumo = consumo facturado

) consum_fact,
(
select sum(nvl(cosscoca,0)) FROM SFBZ0800.conssesu z
WHERE consu.cosssesu=z.cosssesu --producto
AND consu.cosstcon=z.cosstcon --tipo de consumo
AND consu.cosspecs=z.cosspefa --periodo de facturacion
AND consu.cosspecs<>z.cosspecs --periodo de consumo --?
AND z.cossmecc=4 --metodo de calculo de consumo = consumo facturado
and rownum=1
) consum_recuperado, --?
(
SELECT z.cosscoca --unidades de consumo
FROM SFBZ0800.conssesu z
WHERE z.cosssesu = consu.cosssesu --producto
AND z.cosspecs = consu.cosspecs --periodo de consumo
AND z.cosstcon = consu.cosstcon --tipo de consumo
AND z.cossmecc <> 4 --metodo de calculo de consumo = consumo facturado
and z.cosscavc is not null --calificacion del analisis
and exists (select 'X' from SFBZ0800.calivaco where cosscavc=cavccodi and cavcpror is not null) --que exista la calificacion y que tenga prioridad
and rownum=1
) CONSUMO_CRITICA,
(
SELECT cavcdesc --calificacion
FROM SFBZ0800.calivaco,SFBZ0800.conssesu z
WHERE z.cosssesu = consu.cosssesu --producto
AND z.cosspecs = consu.cosspecs --periodo de consumo
AND z.cosstcon = consu.cosstcon --tipo de consumo
AND z.cossmecc <> 4 --metodo de calculo de consumo = consumo facturado
and z.cosscavc is not null --existe la calificacion
AND z.cosscavc=cavccodi
and exists (select 'X' from SFBZ0800.calivaco where cosscavc=cavccodi and cavcpror is not null) --que exista la calificacion y que tenga prioridad
and rownum=1
) CALIF_CRITICA,
(
SELECT y.order_id
FROM SFBZ0800.or_order_activity y, SFBZ0800.cm_ordecrit z
WHERE z.orcrsesu = consu.cosssesu --producto
AND z.orcrpeco = consu.cosspecs --periodo consumo
AND z.orcrtico = consu.cosstcon --tipo de consumo
AND z.orcracti = y.order_activity_id --actividad
and rownum=1
) ORDEN_CRITICA,
(
SELECT order_comment from SFBZ0800.or_order_comment x, SFBZ0800.cm_ordecrit z, SFBZ0800.or_order_activity y
WHERE z.orcrsesu = consu.cosssesu --producto
AND z.orcrpeco = consu.cosspecs --periodo consumo
AND z.orcrtico = consu.cosstcon --tipo de consumo
AND z.orcrlect = leem.leemelme
AND z.orcracti = y.order_activity_id --actividad
and x.order_id = y.order_id
and x.order_comment_id = (select max(order_comment_id) from SFBZ0800.or_order_comment c where c.order_id = y.order_id and rownum=1)
and x.register_date = (select max(register_date) from SFBZ0800.or_order_comment c where c.order_id = y.order_id and rownum=1)
and rownum=1
)Comentario,
(
SELECT name_
FROM SFBZ0800.ge_person v, SFBZ0800.sa_user w, SFBZ0800.or_order_stat_change x, SFBZ0800.or_order_activity y, SFBZ0800.cm_ordecrit z
WHERE z.orcrsesu = consu.cosssesu --producto
AND z.orcrpeco = consu.cosspecs --periodo de consumo
AND z.orcrtico = consu.cosstcon --tipo de consumo
AND z.orcracti = y.order_activity_id --actividad
and y.order_id = x.order_id --orden
and x.final_status_id = 8 --orden cerrada
and x.user_id = w.mask --nick del usuario
and w.user_id=v.user_id --codigo del usuario
and rownum=1
) ANALISTA_CRITICA, --lectelme,
(
SELECT least(order_id, nvl((SELECT min(order_id) FROM SFBZ0800.or_order_activity x, SFBZ0800.hileelme z where hlemelme=leemcons and hlemdocu=order_activity_id),999999999999999))
FROM SFBZ0800.or_order_activity
where leemdocu=order_activity_id
and rownum=1
) ORDEN_LECTURA,
(
SELECT max(order_id) FROM SFBZ0800.or_order_activity x, SFBZ0800.hileelme z
where hlemelme=leemcons and hlemdocu=order_activity_id --lectura --actividad
and rownum=1
) ORDEN_RELECTURA,
(
SELECT y.order_id||'-'||v.description
FROM SFBZ0800.or_task_type v, SFBZ0800.or_order_activity w, SFBZ0800.or_support_activity x, SFBZ0800.or_order_activity y, SFBZ0800.cm_ordecrit z
where z.orcrsesu=consu.cosssesu AND z.orcrpeco=consu.cosspecs AND z.orcrtico=consu.cosstcon --producto --periodo de consumo --tipo de consumo
and z.orcracti=y.order_activity_id and y.activity_id=x.activity_id and x.support_activity_id=w.activity_id --actividad --actividad --actividad adicional
and orcrsesu=w.product_id --producto
and w.register_date between y.register_date and y.register_date+7 --valida si hay una actividad del mismo tipo
and w.task_type_id=v.task_type_id
and rownum=1
) ORDEN_ADICIONAL,
(
SELECT a.hcppcopr
FROM SFBZ0800.hicoprpm a --Consumos promedio por producto y tipo de consumo
WHERE a.hcppsesu=consu.cosssesu --producto
AND a.hcpptico=consu.cosstcon --tipo de consumo
AND rownum=1
AND a.hcpppeco IN --periodo de consumo
(
(SELECT PEC FROM(select pecscons PEC from SFBZ0800.pericose
                                    where pecscons < consu.cosspecs
                                    and pecscico = sesu.sesucicl
                                    order by 1 desc)
                    WHERE rownum <=1)
))promedio,
consu.cossfufa funcion, --funcion de calculo
consu.cossdico dias, --dias de consumo
leem.leemleto lect_actual,
leem.leemfele fec_lec_act,
leem.leemlean lect_anterior,
leem.leemfela fec_lec_ant,
nvl(leem.leemfame,1) factor, --factor de calculo de consumo
leem.leemclec causa_lect, --proposito de la lectura
decode(leem.leemclec,'F', 'Facturación', 'I', 'Instalación', 'R', 'Retiro', 'T', 'Trabajo',leem.leemclec) desc_causa_lect, --proposito de la lectura

(select oblecodi ||' - '|| obledesc description from SFBZ0800.obselect where OBLECODI=leem.leemoble and rownum=1)observacion1,
(select oblecodi ||' - '|| obledesc description from SFBZ0800.obselect where OBLECODI=leem.leemobsb and rownum=1)observacion2,
(select oblecodi ||' - '|| obledesc description from SFBZ0800.obselect where OBLECODI=leem.leemobsc and rownum=1)observacion3,
--leem.leemoble id_obs1, --obs de lectura 1
--leem.leemobsb id_obs2,
--leem.leemobsc id_obs3,
(select prdu.amount_of_service carga FROM SFBZ0800.pr_data_utilities prdu --datos de servicios publicos
where consu.cosssesu=prdu.product_id and rownum=1) carga, 
(select plfa.mavccodi FROM SFBZ0800.meanvaco plfa 
WHERE sesu.sesumecv=plfa.mavccodi
and rownum=1) Metod_Consumo, --metodos de analisis de consumo
(
select sum(cucovafa) ValorFacturado
from SFBZ0800.cuencobr, SFBZ0800.factura where cucofact=factcodi and factsusc=sesu.sesususc and factpefa = consu.COSSPEFA
and rownum=1
)ValorFacturado,
(
select sum(cucosacu) Saldo
from SFBZ0800.cuencobr, SFBZ0800.factura where cucofact=factcodi and factsusc=sesu.sesususc and factpefa = consu.COSSPEFA
and rownum=1
)Saldo,
(
select sum(cucovaab) ValorAbonado
from SFBZ0800.cuencobr, SFBZ0800.factura where cucofact=factcodi and factsusc=sesu.sesususc and factpefa = consu.COSSPEFA
and rownum=1
)ValorAbonado,
(
select sum(cucovato) ValorTotal
from SFBZ0800.cuencobr, SFBZ0800.factura where cucofact=factcodi and factsusc=sesu.sesususc and factpefa = consu.COSSPEFA
and rownum=1
)ValorTotal
FROM
SFBZ0800.servsusc sesu,
SFBZ0800.lectelme leem,
(
SELECT a.*
FROM SFBZ0800.conssesu a
WHERE (a.cosssesu, a.cosstcon, a.rowid) in
(SELECT x.cosssesu, x.cosstcon, max(x.rowid)
FROM SFBZ0800.conssesu x
WHERE a.cosssesu=x.cosssesu --producto
AND a.cosstcon=x.cosstcon --tipo de consumo
AND a.cosspecs=x.cosspecs --periodo de consumo
AND x.cossmecc not in (2, 4) --metodo calculo de consumo
AND (x.cosssesu, x.cosstcon, x.cossfere) = --fecha de registro de consumo
(SELECT z.cosssesu, z.cosstcon, max(z.cossfere) --max fecha de registro de consumo
FROM SFBZ0800.conssesu z
WHERE z.cosssesu=x.cosssesu --producto
AND z.cosstcon=x.cosstcon --tipo de consumo
AND z.cosspecs=x.cosspecs --periodo de consumo
AND z.cossmecc not in (2, 4) --metodo calculo de consumo
GROUP BY z.cosssesu, z.cosstcon)
AND x.cossmecc not in (2, 4)
GROUP BY x.cosssesu, x.cosstcon)
) consu
WHERE sesu.sesunuse=consu.cosssesu(+)
AND consu.cosssesu=leem.leemsesu(+) --producto
AND consu.cosstcon=leem.leemtcon(+) --tipo de consumo
AND consu.cosspecs=leem.leempecs(+) --periodo de consunmo
AND consu.cosselme=leem.leemelme(+) --elemento de medicion
AND leem.leemclec(+)='F' --proposito de la lectura = Facturacion
and sesu.sesuesco not in (92,95)
AND consu.cosspecs=:periodo ---Periodo_facturacion_consumo
)a
left join SFBZ0800.ab_premise ab on a.ID_PREDIO = ab.PREMISE_ID