select * from ALL_TABLES WHERE OWNER = 'SFBZ0800' AND TABLE_NAME LIKE UPPER('%SEG%');
/*AAA_TIPO_POLIZA
AAA_VIGEN_TIPO_POLIZA
AU_AUDIT_POLICY
AU_AUDIT_POLICY_LOG
AU_AUD_POLICY_USERS
AU_LOG_POLICY
CT_POLICY_TYPE
GC_POLICACA
GE_POLICY_CONF
GE_PURGE_POLICY
SA_COMPANY_POLICIES
SA_POLICY
SA_POLICY_COL_VALUES
SA_POLICY_REDACTION
SA_ROLE_POLICY*/
SELECT * FROM SFBZ0800.AAA_TIPO_POLIZA;
SELECT * FROM SFBZ0800.AAA_VIGEN_TIPO_POLIZA;
SELECT * FROM SFBZ0800.AU_AUDIT_POLICY;
SELECT * FROM SFBZ0800.AU_AUDIT_POLICY;
SELECT * FROM SFBZ0800.SA_POLICY_COL_VALUES;
SELECT * FROM SFBZ0800.SA_POLICY;
select * from SFBZ0800.cuencobr; --165805
---------------------------------------------
select *
from Sfbz0800.CARGOS
WHERE CARGDOSO = 'CUPT-12771673';
/*63813192
65377147
67012628
61999265*/
select * from SFBZ0800.cuencobr where cucocodi in (63813192,65377147,67012628,61999265) ; --165805
select count(cucocodi) from SFBZ0800.cuencobr where cucocodi in (63813192,65377147,67012628,61999265) and cucosacu is not null;
select * from SFBZ0800.cuencobr where cucocodi= 63567536;
select * from SFBZ0800.factura where factcodi=38824428;
select * from SFBZ0800.servsusc where sesususc = 165805;
select * from SFBZ0800.cargos where cargcuco = 63567536;
select cargconc,conccodi,concdesc from SFBZ0800.cargos,SFBZ0800.concepto where cargconc=conccodi and cargcuco = 63567536

