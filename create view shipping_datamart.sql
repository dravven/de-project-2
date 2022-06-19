CREATE VIEW shipping_datamart AS
select inf.shippingid, vendorid, transfer_type, date(shipping_end_fact_datetime) - date(shipping_start_fact_datetime) as full_day_at_shipping,
case when shipping_end_fact_datetime > shipping_plan_datetime then 1 else 0 end as is_delay,
case when status = 'finished' then 1 else 0 end as is_shipping_finish,
case when shipping_end_fact_datetime > shipping_plan_datetime then date(shipping_end_fact_datetime) - date(shipping_plan_datetime) else 0 end as delay_day_at_shipping,
payment_amount, payment_amount * (shipping_country_base_rate + agreement_rate + shipping_transfer_rate) as vat,
payment_amount * agreement_commission as profit
from shipping_status st
join shipping_info inf on inf.shippingid = st.shippingid
join shipping_transfer trans on trans.transfer_type_id = inf.transfer_type_id
join shipping_agreement agr on agr.agreementid = inf.agreementid
join shipping_country_rates rate on rate.shipping_country_id = inf.shipping_country_id
order by inf.shippingid;