CREATE VIEW shipping_datamart AS
with tmp as(select shippingid, vendorid, payment_amount,
case
when status = 'finished' then 1
else 0 end as finished,
row_number() over (partition by shippingid order by state_datetime desc) as rw,
                   shipping_transfer_description,
                   vendor_agreement_description,
shipping_country_base_rate,
shipping_transfer_rate,
shipping_plan_datetime
from shipping) select tmp.shippingid, vendorid, sptr.transfer_type,
date(shipping_end_fact_datetime) - date(shipping_start_fact_datetime) as full_day_at_shipping,
case when shipping_end_fact_datetime > shipping_plan_datetime then 1 else 0 end as is_delay,
case when status = 'finished' then 1 else 0 end as is_shipping_finish,
case when shipping_end_fact_datetime > shipping_plan_datetime then date(shipping_end_fact_datetime) - date(shipping_plan_datetime) else 0 end as delay_days,
payment_amount,
payment_amount * (shipping_country_base_rate + agr.agreement_rate + sptr.shipping_transfer_rate) as vat,
payment_amount * agr.agreement_commission as profit
 from tmp
join shipping_status on shipping_status.shippingid = tmp.shippingid
left join shipping_transfer sptr on sptr.transfer_type ||  ':' || sptr.transfer_model = tmp.shipping_transfer_description
left join shipping_agreement agr on agr.agreementid ||  ':' || agr.agreement_number ||  ':' || agr.agreement_rate ||  ':' || agr.agreement_commission = tmp.vendor_agreement_description
where rw = 1
order by shippingid;