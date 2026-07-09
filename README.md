# Olist: Delivery Performance & Revenue Impact

Analysis of 110,188 orders from the Brazilian e-commerce platform Olist, analysing how delivery delays can affect customer satisfaction rate and where the Olist loses money through unprofitable freight prices.

**Stack:** Python (Pandas, NumPy, Seaborn), Tableau Public  
**Dataset:** [Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) - Kaggle  
**Dashboard:** [View on Tableau Public](https://public.tableau.com/app/profile/danylo.uhrinovych/viz/Oliste-commerce_17828353152790/Dashboard2)



## Business Problem

The logistics and marketing directors at Olist are facing declining review ratings and want to understand two things:

1. Where are we losing customer loyalty — and how do delivery delays drive that loss?
2. Which product categories have an unsustainable freight-to-price ratio that erodes unit economics?

## Dataset & Preparation

The raw dataset was assembled from four tables joined on `order_id` and `product_id`:

| Table | Description |
|---|---|
| `orders` | Order status and timestamps |
| `order_items` | Price and freight value per item |
| `order_reviews` | Customer review scores (1–5) |
| `products` + translation file | Category names (translated PT → EN) |

**Cleaning steps:**
- 1,559 missing category names → filled with `"Unknown"`
- 827 missing review scores → filled with median (5.0)
- 1 missing carrier date → row dropped after imputation
- All date fields converted to `datetime64` with UTC timezone
- Final clean dataset: **110,188 rows, 16 columns**

**Key engineered feature:**
```python
delivery_delay_days = order_delivered_customer_date − order_estimated_delivery_date
```
Negative = delivered earlier than promised. Positive = late.  
Range in dataset: **−147 days to +188 days**.

---

## Analysis & Findings

### 1. Delivery Delays Collapse Review Scores

Orders were segmented into 8 delay groups. The drop in average review score is immediate and severe — not gradual:

| Delay Group | Orders | Avg Review Score |
|---|---|---|
| Very early (30+ days early) | 3,257 | **4.11** |
| Early (15–30 days early) | 37,240 | **4.23** |
| On time / slightly early (0–14 days) | 62,428 | **4.21** |
| Minor delay (1–7 days) | 4,116 | **2.73** |
| Delay (8–15 days) | 1,800 | **1.76** |
| Major delay (16–30 days) | 978 | **1.71** |
| Critical delay (31–60 days) | 285 | **1.98** |
| Extreme delay (60+ days) | 84 | **2.91** |

**Key insight:** Review score falls from 4.2 to 2.7 after just 1–7 days of delay. There is no gradual decline — the damage happens at the first breach of the promised date. This suggests customers respond to the broken promise itself, not the magnitude of the delay.

The slight score recovery at extreme delays (60+ days, n=84) is likely a sampling artifact from the small group size and should not be interpreted as a positive trend.

### 2. Seasonal Spike in Delays — November 2017

The time series of monthly delay rates reveals a clear anomaly: the share of delayed orders peaked at **18.10% in November 2017**, more than double the surrounding months (7.32% in September, 6.35% in March 2018). This aligns with Brazil's Black Friday period and strongly suggests logistics capacity was overwhelmed by demand surge — a predictable, preventable failure.

### 3. Regional Delay Patterns

Northern and western states show systematically shorter delivery lead times relative to estimates — meaning Olist's delivery promises are calibrated conservatively for remote regions. The states with the smallest buffer (i.e., highest actual delay risk) are concentrated in the northeast:

| State | Avg Delay (days) | Orders |
|---|---|---|
| AL | −8.7 | 427 |
| MA | −9.9 | 800 |
| SE | −10.0 | 375 |

States like SP (São Paulo, 46,440 orders) sit at −11.2 days — well-buffered but accounting for 42% of all volume, making it the highest absolute risk concentration.

### 4. Freight/Price Ratio Anomalies by Category

Categories where freight cost represents a disproportionate share of item price (filtered to categories with 50+ orders to exclude noise):

| Category | Avg Freight/Price Ratio | Orders |
|---|---|---|
| dvds_blu_ray | **83.6%** | 61 |
| electronics | **68.4%** | 2,729 |
| christmas_supplies | **67.5%** | 150 |
| fashion_underwear_beach | **55.1%** | 127 |
| signaling_and_security | **55.0%** | 197 |
| telephony | **50.8%** | 4,430 |

Electronics and telephony are particularly critical — high order volume combined with freight costs exceeding 50–68% of the item price makes these categories structurally unprofitable unless pricing or logistics contracts are renegotiated.

### 5. Revenue at Risk

Total revenue associated with delayed orders (delay group 4–8), segmented by group:

| Delay Group | Revenue at Risk |
|---|---|
| Minor delay (1–7 days) | R$ 307,254 |
| Delay (8–15 days) | R$ 243,208 |
| Major delay (16–30 days) | R$ 128,037 |
| Critical delay (31–60 days) | R$ 33,909 |
| Extreme delay (60+ days) | R$ 7,507 |
| **Total** | **R$ 719,915** |

This represents revenue transacted under conditions that demonstrably produce review scores below 3.0 — the threshold associated with customer churn risk.

---

## Business Recommendations

**For the logistics director:**
- Prioritize SLA renegotiation for northeast states (AL, MA, SE) where delivery buffer is thinnest
- Pre-position capacity ahead of November to prevent the seasonal spike seen in 2017 — the 18% delay rate in that month is a repeatable risk, not a one-off event
- Flag the 7,263 orders annually that arrive with delays of 8+ days as the primary driver of score collapse (avg score 1.7) — these alone represent the reputational damage that's visible in aggregate ratings

**For the product/commercial team:**
- Electronics and telephony require immediate freight cost review — at 68% freight-to-price ratio, customer acquisition through free shipping on these categories likely runs at a loss
- dvds_blu_ray at 83.6% ratio with 61 orders is a candidate for category removal or mandatory freight surcharge

---

## Repository Structure

```
├── notebook/
│   └── E_comm_brazil.ipynb       # Full analysis: ETL, EDA, metrics
├── data/
│   └── olist_cleaned_for_bi.csv  # Export for Tableau (generated by notebook)
└── README.md
```

---

## Methodology Notes

- Delivery delay is measured against the **promised** delivery date, not the carrier handoff date — this reflects the customer's actual experience
- Revenue at risk is calculated as `SUM(price + freight_value)` per delay group, not projected lifetime value — figures are conservative
- Categories with fewer than 50 orders were excluded from freight ratio analysis to avoid misleading averages from low-volume outliers
- The score recovery at 60+ day delays (avg 2.91 vs 1.71 for major delays) should not be interpreted as a positive finding — the group has only 84 orders and is statistically unreliable
