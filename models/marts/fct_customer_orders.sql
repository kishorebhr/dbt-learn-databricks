{{ config(
    materialized='table',
    liquid_clustered_by=['first_order_date']
) }}

with customers as (
    select * from {{ ref ('stg_jaffle_shop__customers')}}
),

orders as (
    select * from {{ ref ('stg_jaffle_shop__orders' )}}
),

customer_orders as (
    select
        customer_id,
        min(order_date) as first_order_date,
        max(order_date) as most_recent_order_date,
        count(order_id) as number_of_orders
    from orders
    group by 1
)

select
    c.customer_id,
    c.first_name,
    c.last_name,
    coalesce(co.first_order_date, current_date()) as first_order_date,
    co.most_recent_order_date,
    coalesce(co.number_of_orders, 0) as number_of_orders,
    -- Custom transformation flag logic
    case 
        when co.number_of_orders >= 5 then 'VIP'
        when co.number_of_orders > 0 then 'Active'
        else 'Inactive'
    end as customer_segment
from customers c
left join customer_orders co on c.customer_id = co.customer_id