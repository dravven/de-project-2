create table shipping_status (
    shippingid bigint,
    status text,
    state text,
    shipping_start_fact_datetime timestamp,
    shipping_end_fact_datetime timestamp,

    primary key (shippingid)
);

insert into shipping_status
with tmp as(
    select *, row_number() over (partition by shippingid order by state_datetime desc) as rw from shipping
) select tmp.shippingid, tmp.status, tmp.state, bk.state_datetime, rc.state_datetime from tmp
left join (select * from shipping
where state = 'booked')bk on bk.shippingid = tmp.shippingid
left join (select * from shipping
where state = 'recieved')rc on rc.shippingid = tmp.shippingid
where rw = 1;