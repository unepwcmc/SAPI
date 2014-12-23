SELECT iso_code2 AS country_of_origin FROM geo_entities
JOIN geo_entity_types ON geo_entity_types.id = geo_entities.geo_entity_type_id
WHERE geo_entity_types.name IN ('COUNTRY', 'TERRITORY', 'TRADE_ENTITY');
