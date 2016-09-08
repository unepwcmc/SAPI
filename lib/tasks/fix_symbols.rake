namespace :import do

  desc 'Fix symbols in the data files'
  task :fix_symbols => :environment do
    Rake::Task["import:fix_references_symbols"].invoke
    Rake::Task["import:fix_taxon_concepts_symbols"].invoke
    Rake::Task["import:fix_geo_entities_symbols"].invoke
    Rake::Task["import:fix_common_names_symbols"].invoke
    Rake::Task["import:add_italics_to_references"].invoke
  end

  desc 'Fix symbols in Annotations'
  task :fix_annotations_symbols => :environment do
    CSV.foreach('lib/files/ascii_symbols_utf8.csv', :quote_char => 'h') do |row|
      puts "############################# Cleaning Annotations  of ( #{row[0]} => #{row[1]}) #############################"
      count = Annotation.where('short_note_en LIKE :sym OR full_note_en LIKE :sym', :sym => "%#{row[0]}%").count
      puts "#{count} records affected"
      Annotation.where('short_note_en LIKE :sym OR full_note_en LIKE :sym', :sym => "%#{row[0]}%").each do |o|
        o.short_note_en = o.short_note_en.gsub(row[0], row[1].strip)
        o.full_note_en = o.full_note_en.gsub(row[0], row[1].strip)
        o.save
      end
    end
  end

  desc 'Fix symbols in Common Names'
  task :fix_common_names_symbols => :environment do
    CSV.foreach('lib/files/ascii_symbols_utf8.csv', :quote_char => 'h') do |row|
      puts "############################# Cleaning Common Names  of ( #{row[0]} => #{row[1]}) #############################"
      count = CommonName.where('name Like ?', "%#{row[0]}%").count
      puts "#{count} records affected"
      CommonName.where('name Like ?', "%#{row[0]}%").each do |o|
        o.name = o.name.gsub(row[0], row[1].strip)
        o.save
      end
    end
  end

  desc 'Fix symbols in Taxon Concepts'
  task :fix_taxon_concepts_symbols => :environment do
    CSV.foreach('lib/files/ascii_symbols_utf8.csv', :quote_char => 'h') do |row|
      puts "############################# Cleaning Taxon Concept of ( #{row[0]} => #{row[1]}) #############################"
      count = TaxonConcept.where('author_year Like ?', "%#{row[0]}%").count
      puts "#{count} records affected"
      TaxonConcept.where('author_year Like ?', "%#{row[0]}%").each do |o|
        o.author_year = o.author_year.gsub(row[0], row[1].strip)
        o.save
      end
    end
  end

  desc 'Fix symbols in Geo Entities'
  task :fix_geo_entities_symbols => :environment do
    CSV.foreach('lib/files/ascii_symbols_utf8.csv', :quote_char => 'h') do |row|
      puts "############################# Cleaning Geo Entityes  of ( #{row[0]} => #{row[1]})  #############################"
      count = GeoEntity.where('name_en Like ?', "%#{row[0]}%").count
      puts "#{count} records affected"
      GeoEntity.where('name_en Like ?', "%#{row[0]}%").each do |o|
        o.name_en = o.name_en.gsub(row[0], row[1].strip)
        o.save
      end
    end
  end

  desc 'Fix symbols in References'
  task :fix_references_symbols => :environment do
    CSV.foreach('lib/files/ascii_symbols_utf8.csv', :quote_char => 'h') do |row|
      puts "############################# Cleaning References  of ( #{row[0]} => #{row[1]}) #############################"
      count = Reference.where('citation Like ?', "%#{row[0]}%").count
      puts "#{count} records affected"
      Reference.where('citation Like ?', "%#{row[0]}%").each do |o|
        o.citation = o.citation.gsub(row[0], row[1].strip)
        o.save
      end
    end
  end

  desc 'Add italics to references'
  task :add_italics_to_references => :environment do
    puts "Adding italics into references"
    puts "#{Reference.where('citation like ?', "_%_").count} records affected"
    Reference.where('citation like ? ', "_%_").each do |o|
      o.citation = o.citation.gsub(/_([^_]+)_/, "<i>\\1</i>")
      o.save
    end
  end
end
