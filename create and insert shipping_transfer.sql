create table shipping_transfer (
    transfer_type_id serial,
    transfer_type text,
    transfer_model text,
    shipping_transfer_rate numeric(14,3),

    primary key (transfer_type_id)
);

insert into shipping_transfer(transfer_type, transfer_model, shipping_transfer_rate)
select distinct transfers[1], transfers[2], cast(shipping_transfer_rate as numeric(14,3))
from (select regexp_split_to_array(shipping_transfer_description, ':') as transfers, shipping_transfer_rate  from shipping)t;
