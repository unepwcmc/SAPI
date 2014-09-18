class CreateTop10CmsAndCreateTop10Cites < ActiveRecord::Migration
  def up
  	execute <<-SQL
  	CREATE VIEW toptens_cites AS
  	(SELECT properties->>'full_name' AS species,COUNT(*) AS number_of_visits
  	FROM ahoy_events
  	WHERE name='Taxon Concept'
  	AND properties->>'taxonomy_name'='CITES_EU'
  	GROUP BY species
  	ORDER BY number_of_visits DESC
  	LIMIT 10);
  	SQL

  	execute <<-SQL
  	CREATE VIEW toptens_cms AS
  	(SELECT properties->>'full_name' AS species, COUNT(*) AS number_of_visits
    FROM ahoy_events
    WHERE name='Taxon Concept'
    AND properties->>'taxonomy_name'='CMS'
    GROUP BY species
    ORDER BY number_of_visits DESC
    LIMIT 10);
    SQL
  end

  def down
  	execute 'DROP VIEW toptens_cites;'
  	execute 'DROP VIEW toptens_cms;'
  end
end
