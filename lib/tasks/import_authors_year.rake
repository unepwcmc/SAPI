namespace :import do

  desc 'update author_year TaxonConcept attribute'
  task :authors_year => [:environment] do
    CSV.foreach("lib/files/Orchids_author_changes.csv", headers: true) do |row|
      tc = TaxonConcept.where(id: row['RecID'])
      if tc.empty?
        puts "TaxonConcept #{row['RecID']} not found"
        next
      end
      tc.first.update_attributes(author_year: row['Species author'])
    end
    count = TaxonConcept.where(updated_at: Date.today).count
    puts "#{count} TaxonConcepts updated"
  end
end
