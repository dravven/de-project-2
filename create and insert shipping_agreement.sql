create table shipping_agreement (
    agreementid bigint,
    agreement_number text,
    agreement_rate numeric(14,3),
    agreement_commission numeric(14,3),

    primary key (agreementid)
);
insert into shipping_agreement(agreementid, agreement_number, agreement_rate, agreement_commission)
select cast(vendors[1] as bigint), vendors[2], cast(vendors[3] as numeric(14,3)), cast(vendors[4] as numeric(14,3))
from (select distinct regexp_split_to_array(vendor_agreement_description, ':') as vendors from shipping)t;