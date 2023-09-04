with
vw_hijos as (
select  
        m.elmeemac id_padre,
        ms.emsssesu producto_hijo,
        m.elmecodi serial_hijo,
        SUM(DECODE(c.COSSMECC, 4,c.COSSCOCA,0)) consumo,        
        c.cosspefa periodo_hijo,
        ms.emssfein fec_inst_hijo,
        ms.emssfere fec_ret_hijo,
        a.address_parsed direccion_hijo,
        ca.catedesc categoria_hijo,
        sub.sucadesc subcategoria_hijo,
        c.cossfufa,
        (select obledesc from sfbz0800.obselect where oblecodi = l.leemoble) obs1,
        (select obledesc from sfbz0800.obselect where oblecodi = l.leemobsb) obs2,
        (select obledesc from sfbz0800.obselect where oblecodi = l.leemobsc) obs3
from sfbz0800.elemmedi m 
inner join sfbz0800.elmesesu ms on (m.elmeidem = ms.emsselme and ms.emssfere > sysdate)
inner join sfbz0800.servsusc s on ms.emsssesu = s.sesunuse
inner join sfbz0800.categori ca on s.sesucate = ca.catecodi
inner join sfbz0800.subcateg sub on (s.sesucate = sub.sucacate and s.sesusuca = sub.sucacodi)
inner join sfbz0800.suscripc su on s.sesususc = su.susccodi
inner join sfbz0800.ab_address a on su.susciddi = a.address_id
inner join sfbz0800.conssesu c on (s.sesunuse = c.cosssesu)
inner join sfbz0800.lectelme l on (m.elmeidem = l.leemelme and c.cosspefa = l.leempefa)
where m.elmeemac is not null
--and p.pefacodi in(:Id_periodo)
group by ms.emsssesu, m.elmecodi, m.elmeemac, ms.emssfein, ms.emssfere, 
a.address_parsed, ca.catedesc, sub.sucadesc, l.leemoble, 
l.leemobsb, c.cosspefa, l.leemobsc, c.cossfufa
),
vw_padres as(
--padres
select  
        m.elmeidem,
        ms.emsssesu producto_padre,
        m.elmecodi serial_padre,
        SUM(DECODE(c.COSSMECC, 4,c.COSSCOCA,0)) consumo_padre,    
        l.leemleto,
        l.leemlean,
        c.cosspefa periodo_padre,
        ms.emssfein fec_inst_padre,
        ms.emssfere fec_ret_padre,
        a.address_parsed direccion_padre,
        ca.catedesc categoria_padre,
        sub.sucadesc subcategoria_padre
from sfbz0800.elemmedi m 
inner join sfbz0800.elmesesu ms on (m.elmeidem = ms.emsselme and ms.emssfere > sysdate)
inner join sfbz0800.servsusc s on ms.emsssesu = s.sesunuse
inner join sfbz0800.categori ca on s.sesucate = ca.catecodi
inner join sfbz0800.subcateg sub on (s.sesucate = sub.sucacate and s.sesusuca = sub.sucacodi)
inner join sfbz0800.suscripc su on s.sesususc = su.susccodi
inner join sfbz0800.ab_address a on su.susciddi = a.address_id
inner join sfbz0800.conssesu c on (s.sesunuse = c.cosssesu)
inner join sfbz0800.lectelme l on (m.elmeidem = l.leemelme and c.cosspefa = l.leempefa)
--where --p.pefacodi in(:Id_periodo)
group by ms.emsssesu, m.elmecodi, ms.emssfein, ms.emssfere, a.address_parsed, 
ca.catedesc, sub.sucadesc, l.leemleto, l.leemlean, c.cosspefa,
m.elmeidem)
select c.CICLDESC ciclo, 
       p.PEFADESC periodo ,
       a.producto_padre,
       a.serial_padre,       
       a.fec_inst_padre,
       a.fec_ret_padre,
       a.direccion_padre,
       a.categoria_padre,
       a.subcategoria_padre,
       a.consumo_padre consumo_padre,
       a.leemleto lectura_tomada,
       a.leemlean lectura_anterior,
       b.producto_hijo,
       b.serial_hijo,
       b.fec_inst_hijo,
       b.fec_ret_hijo,
       b.direccion_hijo,
       b.categoria_hijo,
       b.subcategoria_hijo,
       b.consumo consumo_hijo,
       b.cossfufa funcion_calculo,
       b.obs1,
       b.obs2,
       b.obs3
from vw_hijos b
inner join vw_padres a on (b.id_padre= a.elmeidem and b.periodo_hijo = a.periodo_padre)
inner join sfbz0800.perifact p on p.pefacodi = a.periodo_padre
inner join sfbz0800.ciclo c on  p.pefacicl =c.CICLCODI
where p.pefacodi in(:Id_periodo)
order by b.id_padre