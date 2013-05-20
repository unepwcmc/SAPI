DROP VIEW IF EXISTS valid_appendix_view;
CREATE VIEW valid_appendix_view AS
SELECT abbreviation AS appendix FROM species_listings
JOIN designations ON designation.id = species_listings.designation_id
WHERE designations.name = 'CITES';
