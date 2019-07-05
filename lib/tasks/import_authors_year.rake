namespace :import do

  desc 'update author_year TaxonConcept attribute'
  task :authors_year => [:environment] do
    count = 0
    CSV.foreach("lib/files/Orchids_author_changes.csv", headers: true) do |row|
      tc = TaxonConcept.where(id: row['RecID'])
      if tc.empty?
        puts "TaxonConcept #{row['RecID']} not found"
        next
      end
      tc.first.update_attributes(author_year: row['Species author'])
      count =+1
    end
    puts "#{count} TaxonConcepts updated"
  end
end
