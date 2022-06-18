CREATE VIEW shipping_datamart AS
with tmp as(select shippingid, vendorid, payment_amount,
case
when status = 'finished' then 1
else 0 end as finished,
row_number() over (partition by shippingid order by state_datetime desc) as rw,
regexp_split_to_array(vendor_agreement_description, ':') as vendors,
regexp_split_to_array(shipping_transfer_description, ':') as transfers,
shipping_country_base_rate,
shipping_transfer_rate,
shipping_plan_datetime
from shipping) select shippingid, vendorid, transfers[1],
date(shipping_end_fact_datetime) - date(shipping_start_fact_datetime) as full_day_at_shipping,
case when shipping_end_fact_datetime > shipping_plan_datetime then 1 else 0 end as is_delay,
case when status = 'finished' then 1 else 0 end as is_shipping_finish,
case when shipping_end_fact_datetime > shipping_plan_datetime then date(shipping_end_fact_datetime) - date(shipping_plan_datetime) else 0 end as delay_days,
payment_amount,
payment_amount * (shipping_country_base_rate + cast(vendors[3] as numeric(14, 2)) + shipping_transfer_rate) as vat,
payment_amount * cast(vendors[4] as numeric(14,2)) as profit
 from tmp
join shipping_status on shipping_status.shipping_id = tmp.shippingid
where rw = 1;