SELECT ts.*,terms.name_es AS term_es,terms.name_fr AS term_fr,units.name_es AS unit_es,units.name_fr AS unit_fr,
       CASE WHEN ts.reported_by_exporter IS FALSE THEN
         CASE
           WHEN ts.term_quantity_modifier = '*' THEN
             CASE
               WHEN unit_quantity_modifier = '*' THEN ts.quantity * ts.term_modifier_value * ts.unit_modifier_value
               WHEN unit_quantity_modifier = '/' THEN ts.quantity * ts.term_modifier_value / ts.unit_modifier_value
               ELSE ts.quantity * ts.term_modifier_value
             END
           WHEN ts.term_quantity_modifier = '/' THEN
             CASE
               WHEN unit_quantity_modifier = '*' THEN ts.quantity / ts.term_modifier_value * ts.unit_modifier_value
               WHEN unit_quantity_modifier = '/' THEN ts.quantity / ts.term_modifier_value / ts.unit_modifier_value
               ELSE ts.quantity / ts.term_modifier_value
             END
           ELSE
             CASE
               WHEN unit_quantity_modifier = '*' THEN ts.quantity * ts.unit_modifier_value
               WHEN unit_quantity_modifier = '/' THEN ts.quantity / ts.unit_modifier_value
               ELSE ts.quantity
             END
           END
         ELSE NULL
       END AS importer_reported_quantity,
       CASE WHEN ts.reported_by_exporter IS TRUE THEN
         CASE
           WHEN ts.term_quantity_modifier = '*' THEN
             CASE
               WHEN unit_quantity_modifier = '*' THEN ts.quantity * ts.term_modifier_value * ts.unit_modifier_value
               WHEN unit_quantity_modifier = '/' THEN ts.quantity * ts.term_modifier_value / ts.unit_modifier_value
               ELSE ts.quantity * term_modifier_value
             END
           WHEN ts.term_quantity_modifier = '/' THEN
             CASE
               WHEN unit_quantity_modifier = '*' THEN ts.quantity / ts.term_modifier_value * ts.unit_modifier_value
               WHEN unit_quantity_modifier = '/' THEN ts.quantity / ts.term_modifier_value / ts.unit_modifier_value
               ELSE ts.quantity / ts.term_modifier_value
             END
           ELSE
             CASE
               WHEN unit_quantity_modifier = '*' THEN ts.quantity * ts.unit_modifier_value
               WHEN unit_quantity_modifier = '/' THEN ts.quantity / ts.unit_modifier_value
               ELSE ts.quantity
             END
           END
         ELSE NULL
       END AS exporter_reported_quantity
FROM trade_plus_formatted_data_final_view ts
LEFT OUTER JOIN trade_codes terms ON ts.term_id = terms.id
LEFT OUTER JOIN trade_codes units ON ts.unit_id = units.id
