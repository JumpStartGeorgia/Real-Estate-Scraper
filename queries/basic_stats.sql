/* sale */
select 
property_type,
avg(sale_price_dollars) as avg_sale ,
min(sale_price_dollars) as min_sale, 
max(sale_price_dollars) as max_sale,
stddev(sale_price_dollars) as stddev_sale
from postings 
where locale = 'en'
and sale_price_dollars is not null
and type = 'for sale'
group by property_type;

select 
property_type,
avg(sale_price_sq_meter_dollars) as avg_sq_m_sale ,
min(sale_price_sq_meter_dollars) as min_sq_m_sale, 
max(sale_price_sq_meter_dollars) as max_sq_m_sale,
stddev(sale_price_sq_meter_dollars) as stddev_sq_m_sale
from postings 
where locale = 'en'
and sale_price_sq_meter_dollars is not null
and type = 'for sale'
group by property_type;

/* rent */
select 
property_type,
avg(rent_price_dollars) as avg_rent ,
min(rent_price_dollars) as min_rent, 
max(rent_price_dollars) as max_rent, 
stddev(rent_price_dollars) as stddev_rent
from postings 
where locale = 'en'
and rent_price_dollars is not null
and type = 'for rent'
group by property_type;


select 
property_type,
avg(rent_price_sq_meter_dollars) as avg_sq_m_rent ,
min(rent_price_sq_meter_dollars) as min_sq_m_rent, 
max(rent_price_sq_meter_dollars) as max_sq_m_rent, 
stddev(rent_price_sq_meter_dollars) as stddev_sq_m_rent
from postings 
where locale = 'en'
and rent_price_sq_meter_dollars is not null
and type = 'for rent'
group by property_type;
