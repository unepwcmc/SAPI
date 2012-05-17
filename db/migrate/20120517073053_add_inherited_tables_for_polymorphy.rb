class AddInheritedTablesForPolymorphy < ActiveRecord::Migration
  def up
  sql = <<-eos
    CREATE TABLE "country_distribution_components" (
     CHECK ("component_type" = 'Country'),
     PRIMARY KEY ("id"),
     FOREIGN KEY ("component_id") REFERENCES "countries"("id")
    ) INHERITS ("distribution_components");
    
    CREATE TABLE "bru_distribution_components" (
     CHECK ("component_type" = 'Bru'),
     PRIMARY KEY ("id"),
     FOREIGN KEY ("component_id") REFERENCES "brus"("id")
    ) INHERITS ("distribution_components");
    
    CREATE TABLE "region_distribution_components" (
     CHECK ("component_type" = 'Region'),
     PRIMARY KEY ("id"),
     FOREIGN KEY ("component_id") REFERENCES "regions"("id")
    ) INHERITS ("distribution_components");
  eos
    execute sql
  end
  def down
    execute("
      DROP TABLE country_distribution_components;
      DROP TABLE bru_distribution_components;
      DROP TABLE region_distribution_components;
    ")
  end
end
