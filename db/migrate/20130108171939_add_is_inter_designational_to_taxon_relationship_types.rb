class AddIsInterDesignationalToTaxonRelationshipTypes < ActiveRecord::Migration
  def up
    add_column :taxon_relationship_types, :is_inter_designational, :boolean
    ['EQUAL_TO', 'INCLUDES', 'INCLUDED_IN', 'OVERLAPS', 'DISJUNCT'].each do |relationship|
      trt = TaxonRelationshipType.find_or_initialize_by_name(relationship)
      trt.is_inter_designational = true
      trt.save
    end
    ['HAS_SYNONYM', 'HAS_HOMONYM'].each do |relationship|
      trt = TaxonRelationshipType.find_or_initialize_by_name(relationship)
      trt.is_inter_designational = false
      trt.save
    end
  end
  def down
    remove_column :taxon_relationship_types, :is_inter_designational
  end
end
