{% snapshot snap_customers %}

{{ config(
    target_catalog=env_var('raw', 'analytics'),
    target_schema='snapshots',
    unique_key='id',
    strategy='check',
   check_cols=['FIRST_NAME', 'LAST_NAME'],

    invalidate_hard_deletes=True
) }}

-- The basic SELECT query pointing directly to your clean source data
select 
    id,
   FIRST_NAME,
   LAST_NAME,
    updated_at
from {{ source('jaffle_shop', 'customers') }}

{% endsnapshot %}