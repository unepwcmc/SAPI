DROP VIEW IF EXISTS valid_trading_partner_view;
CREATE VIEW valid_trading_partner_view AS
SELECT iso_code2 AS trading_partner FROM geo_entities
JOIN geo_entity_types ON geo_entity_types.id = geo_entities.geo_entity_type_id
WHERE geo_entity_types.name IN ('COUNTRY', 'TERRITORY');

-- this is essentially the same view at the moment, but it is kept separate
-- because this way validation implementation can be simplified
DROP VIEW IF EXISTS valid_country_of_origin_view;
CREATE VIEW valid_country_of_origin_view AS
SELECT iso_code2 AS country_of_origin FROM geo_entities
JOIN geo_entity_types ON geo_entity_types.id = geo_entities.geo_entity_type_id
WHERE geo_entity_types.name IN ('COUNTRY', 'TERRITORY');
