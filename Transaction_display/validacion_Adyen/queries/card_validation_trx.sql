with card_validation as(
	select (TIMESTAMP 'epoch' + fecharegistro / 1000000000 * INTERVAL '1 second') as fecha, o.*
	from is_pii_parabilium.operaciones o
	where o.cod_respuesta = '00' -- Trx aproved
		and o.importe = 20 -- Trx amount
		and (o.codigoproceso like '00%' or o.codigoproceso like '02%') -- response code
		and o.mti in ('0200', '0220') -- messages of auth and cancelation
		and fecha >= '2025-01-01 00:00:00.000' -- only current year
	order by klrid
)
select cv.fecha, cv.klrid, cv.id_operacion, cv.codigoproceso, cv.fechaoperacion, cv.codigomoneda, cv.importe,
	cv.operador, cv.cod_respuesta, cv.mti, oimt.c037, oimt.c060
from is_pii_parabilium.operation_iso_messages_temp oimt 
join card_validation cv 
on oimt.omi_id_operacion = cv.id_operacion
where oimt.c004 = '000000002000' -- Trx amount
	and (oimt.c003 like '00%' or oimt.c003 like '02%') -- response code
	and c060 = 'P278ADYN+000' -- Adyen terminal data
order by cv.fecha desc, cv.klrid desc
