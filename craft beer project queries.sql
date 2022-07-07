/*
Exploratory analysis of breweries and craft beer in the United States. Arrange the breweries by state, 
find the most popular styles of craft beer brewed, the total number of beers at each brewery, craft beers broken out into
3 different ABV ranges, and the average ABV for the 12 most popular styles of craft beer.

Skills used: Create procedures, create views, subqueries, correlated subqueries, numeric functions, 
             joins, logical operators, aggregate functions
*/

-- Create a stored procedure to find breweries by state.

DROP PROCEDURE IF EXISTS get_breweries_by_state;
DELIMITER $$
CREATE PROCEDURE get_breweries_by_state
(
state CHAR(2)
)
BEGIN
    SELECT *
    FROM breweries b
    WHERE b.state = IFNULL(state, b.state)
    ORDER BY city ASC;
END $$

DELIMITER ;

-- Show craft beers by brewery, organized by state and city.

CREATE OR REPLACE VIEW beers_by_brewery AS
SELECT 
    br.name AS brewery,
    br.city,
    br.state,
    be.name AS beer_name,
       be.style,
    ROUND((be.abv * 100), 1) AS abv,
    be.ibu,
    be.ounces
FROM beers be
JOIN breweries br
    ON (be.brewery_id = br.id)
ORDER BY state, city;

-- Show the total number of craft beers by each brewery, ordered from most to least.

CREATE OR REPLACE VIEW total_beers_by_brewery AS
SELECT
    DISTINCT br.name AS brewery,
    br.city,
    br.state,
    (SELECT 
        COUNT(id)
        FROM beers
        WHERE be.brewery_id = brewery_id) AS number_of_craft_beers
FROM beers be
JOIN breweries br
    ON (be.brewery_id = br.id)
ORDER BY number_of_craft_beers DESC;

-- Show the most popular craft beer styles. Count the total amount for each style, across all breweries. 

CREATE OR REPLACE VIEW totals_by_style AS
SELECT
    (SELECT
        COUNT(*) 
        FROM beers
        WHERE style LIKE '%IPA%' 
            AND style NOT LIKE '%Double%') AS IPAs,
    (SELECT
        COUNT(*) 
        FROM beers
        WHERE style LIKE '%Pale Ale%'
            OR style LIKE '%APA%') AS Pale_Ales,
    (SELECT
        COUNT(*) 
        FROM beers
        WHERE style LIKE '%Amber%') AS Ambers,
    (SELECT 
        COUNT(*)
        FROM beers
        WHERE style LIKE '%Lager%') AS Lagers,
    (SELECT 
        COUNT(*) 
        FROM beers
        WHERE style LIKE '%Blonde%') AS Blonde_Ales,
    (SELECT
        COUNT(*) 
        FROM beers
        WHERE style LIKE '%Double% %IPA%') AS Double_IPAs,
    (SELECT
        COUNT(*) 
        FROM beers
        WHERE style LIKE '%Stout%') AS Stouts,
    (SELECT 
        COUNT(*)
        FROM beers
        WHERE style LIKE '%Pilsener%' OR style LIKE '%Pilsner%') AS Pilseners,
    (SELECT
        COUNT(*) 
        FROM beers
        WHERE style LIKE '%Brown%') AS Brown_Ales,
    (SELECT
        COUNT(*) 
        FROM beers
        WHERE style LIKE '%Porter%') AS Porters,
    (SELECT
        COUNT(*) 
        FROM beers
        WHERE style LIKE '%Hefeweizen%') AS Hefeweizens,
    (SELECT
        COUNT(*) 
        FROM beers
        WHERE style LIKE '%Irish Red%') AS Irish_Reds;
        
-- Show each brewery's craft beer counts for the 5 most popular styles.
-- Based on the previous view created to show the total amount of each style across all breweries.

CREATE OR REPLACE VIEW beer_style_by_brewery AS
SELECT
    DISTINCT br.name AS brewery,
    br.city,
    br.state,
    (SELECT 
        COUNT(DISTINCT(style))
        FROM beers
        WHERE be.brewery_id = brewery_id
            AND style LIKE '%IPA%' 
            AND style NOT LIKE '%Double%') AS IPAs,
    (SELECT 
        COUNT(DISTINCT(style))
        FROM beers
        WHERE be.brewery_id = brewery_id
            AND style LIKE '%Pale Ale%'
            OR style LIKE '%APA%') AS Pale_Ales,
    (SELECT 
        COUNT(DISTINCT(style))
        FROM beers
        WHERE be.brewery_id = brewery_id
            AND style LIKE '%Amber%') AS Ambers,
    (SELECT 
        COUNT(DISTINCT(style))
        FROM beers
        WHERE be.brewery_id = brewery_id
            AND style LIKE '%Lager%') AS Lagers,
    (SELECT 
        COUNT(DISTINCT(style))
        FROM beers
        WHERE be.brewery_id = brewery_id
            AND style LIKE '%Blonde%') AS Blonde_Ales
FROM beers be
JOIN breweries br
    ON (be.brewery_id = br.id)
ORDER BY IPAs DESC, Pale_Ales DESC, Ambers DESC, Lagers DESC, Blonde_Ales DESC;

-- Show craft beers with an ABV of 8.0% or higher, ordered from highest to lowest ABV and then highest to lowest IBU

CREATE OR REPLACE VIEW high_abv_beers AS
SELECT
    be.name AS beer,
    ROUND((be.abv * 100), 1) AS abv,
    be.ibu,
    br.name AS brewery,
    br.city,
    br.state
FROM beers be
JOIN breweries br
    ON (be.brewery_id = br.id)
WHERE ROUND((be.abv * 100), 1) >= 8
ORDER BY abv DESC, ibu DESC;

-- Show craft beers with an ABV of 5.0% to 7.9%, ordered from highest to lowest ABV and then highest to lowest IBU

CREATE OR REPLACE VIEW moderate_abv_beers AS
SELECT
    be.name AS beer,
    ROUND((be.abv * 100), 1) AS abv,
    be.ibu,
    br.name AS brewery,
    br.city,
    br.state
FROM beers be
JOIN breweries br
    ON (be.brewery_id = br.id)
WHERE ROUND((be.abv * 100), 1) > 5 AND ROUND((be.abv * 100), 1) < 8
ORDER BY abv DESC, ibu DESC;

-- Show craft beers with an ABV of less than 5.0%, ordered from highest to lowest ABV and then highest to lowest IBU

CREATE OR REPLACE VIEW low_abv_beers AS
SELECT
    be.name AS beer,
    ROUND((be.abv * 100), 1) AS abv,
    be.ibu,
    br.name AS brewery,
    br.city,
    br.state
FROM beers be
JOIN breweries br
    ON (be.brewery_id = br.id)
WHERE ROUND((be.abv * 100), 1) < 5 
ORDER BY abv DESC, ibu DESC;

-- Calculate the average alcohol by volume (abv) for the main styles of craft beer

CREATE OR REPLACE VIEW average_abv_by_style AS
SELECT
    (SELECT
        ROUND(AVG(abv) * 100, 1)
        FROM beers
        WHERE style LIKE '%Double% %IPA%') AS Double_IPAs,
    (SELECT
        ROUND(AVG(abv) * 100, 1)
        FROM beers
        WHERE style LIKE '%Stout%') AS Stouts,
    (SELECT
        ROUND(AVG(abv) * 100, 1)
        FROM beers
        WHERE style LIKE '%IPA%' 
            AND style NOT LIKE '%Double%') AS IPAs,
    (SELECT
        ROUND(AVG(abv) * 100, 1)
        FROM beers
        WHERE style LIKE '%Porter%') AS Porters,
    (SELECT
        ROUND(AVG(abv) * 100, 1)
        FROM beers
        WHERE style LIKE '%Brown%') AS Brown_Ales,
    (SELECT
        ROUND(AVG(abv) * 100, 1)
        FROM beers
        WHERE style LIKE '%Pale Ale%'
            OR style LIKE '%APA%') AS Pale_Ales,
    (SELECT
        ROUND(AVG(abv) * 100, 1)
        FROM beers
        WHERE style LIKE '%Amber%') AS Ambers,
    (SELECT
        ROUND(AVG(abv) * 100, 1)
        FROM beers
        WHERE style LIKE '%Irish Red%') AS Irish_Reds,
    (SELECT 
        ROUND(AVG(abv) * 100, 1)
        FROM beers
        WHERE style LIKE '%Pilsener%' OR style LIKE '%Pilsner%') AS Pilseners,
    (SELECT
        ROUND(AVG(abv) * 100, 1)
        FROM beers
        WHERE style LIKE '%Hefeweizen%') AS Hefeweizens,
    (SELECT 
        ROUND(AVG(abv) * 100, 1)
        FROM beers
        WHERE style LIKE '%Lager%') AS Lagers,
    (SELECT 
        ROUND(AVG(abv) * 100, 1)
        FROM beers
        WHERE style LIKE '%Blonde%') AS Blonde_Ales
