create table shipping_info (
    shipping_id bigint,
    vendor_id bigint,
    payment_amount numeric(14,2),
    shipping_plan_datetime timestamp,
    transfer_type_id bigint,
    shipping_country_id bigint,
    agreement_id bigint,

    primary key (shipping_id),
    foreign key (transfer_type_id) references shipping_transfer(transfer_type_id),
    foreign key (shipping_country_id) references shipping_country_rates(shipping_country_id),
    foreign key (shipping_country_id) references shipping_agreement(agreement_id)
);

insert into shipping_info
select distinct t.shippingid, t.vendorid, t.payment_amount, t.shipping_plan_datetime,
tr.transfer_type_id, cr.shipping_country_id, cast(vendors[1] as bigint) from (select *, regexp_split_to_array(shipping_transfer_description, ':') as transfers,
regexp_split_to_array(vendor_agreement_description, ':') as vendors from shipping)t
join shipping_transfer tr on tr.transfer_type || ':' || tr.transfer_model = t.shipping_transfer_description
join shipping_country_rates cr on cr.shipping_country = t.shipping_country;

