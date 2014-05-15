I am using https://github.com/house9/clerk to track creates and updates from users.

The following models are tracked with the above gem:
* app/models/common_name.rb
* app/models/user.rb
* app/models/listing_change.rb
* app/models/trade_restriction.rb
* app/models/distribution.rb
* app/models/event.rb
* app/models/trade/shipment.rb
* app/models/eu_decision.rb

'Duplicate CITES quotas' (in the batch updates) is tracked with a created_by_id

The 'raw shipments download' in the trade section and the 'Common Names' download in the admin section have the 'updated by', 'created by' fields.

To run the application you need migrations and to rebuild the following views:
* db/views/shipments_view.sql
* db/views/common_names_view.sql
