USE sakila;

# Primer paso: Extraer datos

WITH ventas AS (
    SELECT
        CONCAT(city, ',', country) AS tienda,
        CONCAT(staff.first_name,' ', staff.last_name) AS empleado,
        YEAR(payment_date) as anno,
        MONTH(payment_date) as mes,
        SUM(amount) as valor
    FROM country
        INNER JOIN city USING(country_id)
        INNER JOIN address USING(city_id)
        INNER JOIN store USING(address_id)
        INNER JOIN staff USING(store_id)
        INNER JOIN payment USING(staff_id)
        INNER JOIN customer USING(customer_id)
    GROUP BY tienda, empleado, anno, mes
    ),
    pivote AS (
        SELECT
            tienda,
            empleado,
            SUM(
                CASE WHEN anno=2005 AND mes=5 THEN valor ELSE 0 END
            ) as mayo,
            SUM(
                CASE WHEN anno=2005 AND mes=6 THEN valor ELSE 0 END
            ) junio
        FROM ventas
        GROUP BY tienda, empleado
    ),

SELECT 
    tienda,
    empleado,
    mayo,
    junio,
    (junio-mayo) AS dif,
    ((junio-mayo)/mayo) as perc
FROM pivote
LIMIT 5
; 

with datos_pagos as (

    SELECT 
        staff_id, 
        MONTH(payment_date) as mes,
        YEAR(payment_date) as anno,
        SUM(amount) as amount
    FROM payment
    GROUP BY 
        staff_id,
        MONTH(payment_date),
        YEAR(payment_date)
),

datos_alquiler as (
    SELECT 
        staff_id,
        MONTH(rental_date) as mes,
        YEAR(rental_date) as anno,
        COUNT(*) as qty
    FROM rental
    GROUP BY 
        staff_id,
        MONTH(rental_date),
        YEAR(rental_date)
),

datos_alquiler_y_pagos as (
    SELECT * 
        FROM datos_alquiler
        JOIN datos_pagos USING (staff_id, mes, anno) 
        

),