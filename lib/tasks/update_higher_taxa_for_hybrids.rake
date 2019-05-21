namespace :update do
  task :higher_taxa_for_hybrids => [:environment] do
    TaxonConcept.where("name_status = 'H' AND (data IS NULL OR (data->'kingdom_name')::TEXT IS NULL)").each do |tc|
      puts "Updating #{tc.id} #{tc.full_name} #{tc.author_year} [#{tc.name_status}]"
      data = TaxonConceptData.new(tc).to_h
      data && tc.update_column(:data, data)
    end
  end
end
