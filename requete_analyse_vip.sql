SELECT 
    customer.customer_id AS id_client,
    customer.first_name AS prenom, 
    customer.last_name AS nom, 
    customer.email, 
    SUM(payment.amount) AS ca_total_client
FROM customer
RIGHT JOIN payment
ON customer.customer_id = payment.customer_id
WHERE payment.payment_date BETWEEN '2005-01-01' AND '2005-12-31'
  AND customer.customer_id NOT IN (375, 367, 454) 
  AND (customer.first_name NOT LIKE '%&%' OR customer.first_name NOT LIKE '%$%') 
  AND payment.amount > 0.99
GROUP BY customer.customer_id, customer.first_name, customer.last_name, customer.email
HAVING SUM(payment.amount) > 100
ORDER BY prenom ASC, nom DESC
LIMIT 50;
