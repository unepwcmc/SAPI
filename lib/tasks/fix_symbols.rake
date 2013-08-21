#encoding: utf-8

namespace :import do

  desc 'Fix symbols in the data files'
  task :fix_symbols => :environment do
    Sapi.disable_triggers
    CSV.foreach('lib/assets/files/ascii_symbols_utf8.csv', :quote_char => 'h') do |row|
      puts "############################# Cleaning References  of ( #{row[0]} => #{row[1]}) #############################"
      count = Reference.where('citation Like ?', "%#{row[0]}%").count
      puts "#{count} records affected"
      Reference.where('citation Like ?', "%#{row[0]}%").each do |o|
        o.citation = o.citation.gsub(row[0], row[1])
        o.save
      end
      puts "############################# Cleaning Geo Entityes  of ( #{row[0]} => #{row[1]})  #############################"
      count = GeoEntity.where('name_en Like ?', "%#{row[0]}%").count
      puts "#{count} records affected"
      GeoEntity.where('name_en Like ?', "%#{row[0]}%").each do |o|
        o.name_en = o.name_en.gsub(row[0], row[1])
        o.save
      end
      puts "############################# Cleaning Taxon Concept of ( #{row[0]} => #{row[1]}) #############################"
      count = TaxonConcept.where('author_year Like ?', "%#{row[0]}%").count
      puts "#{count} records affected"
      TaxonConcept.where('author_year Like ?', "%#{row[0]}%").each do |o|
        o.author_year = o.author_year.gsub(row[0], row[1])
        o.save
      end
      puts "############################# Cleaning Common Names  of ( #{row[0]} => #{row[1]}) #############################"
      count = CommonName.where('name Like ?', "%#{row[0]}%").count
      puts "#{count} records affected"
      CommonName.where('name Like ?', "%#{row[0]}%").each do |o|
        o.name = o.name.gsub(row[0], row[1])
        o.save
      end
    end
    puts "Adding italics into references"
    puts "#{Reference.where('citation like ?', "_%_").count} records affected"
    Reference.where('citation like ? ', "_%_").each do |o|
      o.citation = o.citation.gsub(/_([^_]+)_/, "<i>\\1</i>")
      o.save
    end
    Sapi.enable_triggers
  end
end
