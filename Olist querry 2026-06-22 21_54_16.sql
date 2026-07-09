WITH review_rate AS(
  SELECT
  order_id,
  AVG (review_score) AS average_review_rate
  FROM `Olist_dataset.order_reviews`
  GROUP BY order_id 
)

SELECT
ord.order_id,
ord.customer_id,
ord.order_purchase_timestamp,
ord.order_delivered_carrier_date,
ord.order_delivered_customer_date,
ord.order_estimated_delivery_date,

oi.seller_id,
oi.price,
oi.shipping_limit_date,
oi.freight_value,

nt.product_category_name_english AS product_category_name,

rer.average_review_rate

FROM `Olist_dataset.orders` ord
LEFT JOIN `Olist_dataset.order_items` oi
ON ord.order_id = oi.order_id

LEFT JOIN `Olist_dataset.products` prd
ON oi.product_id = prd.product_id

LEFT JOIN `Olist_dataset.name_translations` nt
ON prd.product_category_name = nt.product_category_name

LEFT JOIN review_rate rer
ON ord.order_id = rer.order_id

WHERE ord.order_status <> "cancelled"
  AND ord.order_delivered_customer_date IS NOT NULL