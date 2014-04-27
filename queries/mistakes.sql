/* cost of place and cost / sq m is the same */
select * from postings
where locale = 'en'
and (rent_price = rent_price_sq_meter || sale_price = sale_price_sq_meter);


