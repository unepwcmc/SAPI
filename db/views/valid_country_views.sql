DROP VIEW IF EXISTS valid_trading_partner_code_view;
CREATE VIEW valid_trading_partner_code_view AS
SELECT iso_code2 AS trading_partner_code FROM geo_entities
JOIN geo_entity_types ON geo_entity_types.id = geo_entities.geo_entity_type_id
WHERE geo_entity_types.name='Country';

-- this is essentially the same view at the moment, but it is kept separate
-- because this way validation implementation can be simplified
DROP VIEW IF EXISTS valid_origin_country_code_view;
CREATE VIEW valid_origin_country_code_view AS
SELECT iso_code2 AS origin_country_code FROM geo_entities
JOIN geo_entity_types ON geo_entity_types.id = geo_entities.geo_entity_type_id
WHERE geo_entity_types.name='Country';
