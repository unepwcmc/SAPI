class CreateToptens < ActiveRecord::Migration
 def up
 	execute <<-SQL
 	  CREATE VIEW toptens AS
 	  (SELECT properties->>'full_name' AS species, COUNT(*)
 	  	FROM ahoy_events
 	  	WHERE name='Taxon Concept'
 	  	GROUP BY species
 	  	ORDER BY COUNT DESC
 	  	LIMIT 10);
 	SQL
  end

  def down
	execute 'DROP VIEW toptens;'
  end	
end