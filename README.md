# 💼 Cas d'Étude Portfolio : Analyse de la Valeur Client (Segment VIP 2005)

## 1. Le Contexte & Le Problème Métier
Dans le cadre de l'analyse de la base de données relationnelle Sakila, un défi structurel majeur se pose :

* La table des transactions (`payment`) contient les montants et les dates d'achats, mais n'associe qu'un identifiant technique (`customer_id`). Aucun nom, prénom ou contact n'y figure, ce qui rend la donnée inexploitable pour un gestionnaire ou un commercial (personne ne retient les clients par leur ID numérique).
* La table des clients (`customer`) contient les informations d'état civil (prénom, nom, email), mais ne contient aucun historique financier ni montant d'achat.

## 2. La Solution : La Jointure et l'Agrégation
Pour résoudre cette limite, il est impératif de croiser les deux tables grâce à leur clé de liaison commune, le `customer_id`.
Puisque chaque client effectue de multiples transactions, un simple croisement générerait des lignes dupliquées. Nous avons donc combiné :

* Un `RIGHT JOIN` pour sécuriser l'intégrité de l'historique financier.
* Une fonction d'agrégation (`SUM()`) associée à un `GROUP BY` pour consolider l'ensemble des transactions par client et obtenir son chiffre d'affaires individuel global.

## 3. La Requête SQL Optimisée
```sql
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

## 4. Justification Technique Ligne par Ligne (Pour vos entretiens)
* FROM customer RIGHT JOIN payment ON ... : Résout la problématique de séparation des données en connectant l'univers financier et l'univers client via le customer_id.
* WHERE payment.payment_date BETWEEN ... : Restreint l'analyse à une période comptable précise (l'année 2005) pour coller à un besoin de reporting temporel standard.
* AND (customer.first_name NOT LIKE '%&%' OR customer.first_name NOT LIKE '%$%') : Étape cruciale de Data Cleaning (nettoyage des données). On écarte les prénoms corrompus par des caractères spéciaux (erreurs de saisie ou bugs d'import de base de données) pour ne garder que des profils clients propres.
* AND payment.amount > 0.99 : Filtre les micro-transactions ou anomalies de caisse en amont du calcul.
* GROUP BY ... & HAVING SUM(...) > 100 : Isole la cible marketing recherchée en ne sélectionnant que les clients ayant généré plus de 100 $ de chiffre d'affaires cumulé sur la période.
* ORDER BY & LIMIT 50 : Met en forme un Top 50 clair, trié alphabétiquement pour les livrables du management.
