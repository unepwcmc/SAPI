#Encoding: utf-8
namespace :import do

  desc "Import hardcoded CITES standard references"
  task :standard_references => [:environment] do

    cites = Designation.find_by_name('CITES')
    cites_reference_ids = cites.reference_ids
    cites.references.delete_all
    unless cites_reference_ids.empty?
      sql = <<-SQL
      DELETE FROM taxon_concept_references
      WHERE reference_id IN (#{cites_reference_ids.join(',')})
      SQL
      ActiveRecord::Base.connection.execute(sql)
      Reference.where(:id => cites_reference_ids).delete_all
    end

    ref1 = Reference.create(
      :author => 'Wilson, D. E. & Reeder, D. M. (Third edition 2005)',
      :title => 'Mammal Species of the World. A Taxonomic and Geographic Reference',
      :year => 2005
    )
# [for all mammals –
# with the exception of the recognition of the following names for wild forms of species (in preference to names for
# domestic forms): Bos gaurus, Bos mutus, Bubalus arnee, Equus africanus, Equus przewalskii, Ovis orientalis
# ophion; and with the exception of the species mentioned below]

    mammalia = TaxonConcept.where("data->'full_name' = 'Mammalia'").first
    if mammalia
      mammalia.references << ref1
    end

    ref2 = Reference.create(
      :author => 'Beasley, I., Robertson, K. M. & Arnold, P. W.',
      :title => 'Description of a new dolphin, the Australian Snubfin Dolphin, Orcaella heinsohni sp. n. (Cetacea, Delphinidae).',
      :year => 2005
    )
# [for Orcaella heinsohni]

    orcaella = TaxonConcept.where("data->'full_name' = 'Orcaella heinsohni'").first
    if orcaella
      orcaella.references << ref2
    end

    ref3 = Reference.create(
      :author => 'Caballero, S., Trujillo, F., Vianna, J. A., Barrios-Garrido, H., Montiel, M. G., Beltrán-Pedreros, S. Marmontel, M., Santos, M. C., Rossi-Santos, M. R., Santos, F. R. & Baker, C. S.',
      :title => 'Taxonomic status of the genus Sotalia: species level ranking for "tucuxi" (Sotalia fluviatilis) and "costero" (Sotalia guianensis) dolphins.',
      :year => 2007
    )
# [for Sotalia fluviatilis and Sotalia guianensis]

    sotalia_f = TaxonConcept.where("data->'full_name' = 'Sotalia fluviatilis'").first
    if sotalia_f
      sotalia_f.references << ref3
    end
    sotalia_g = TaxonConcept.where("data->'full_name' = 'Sotalia guianensis'").first
    if sotalia_g
      sotalia_g.references << ref3
    end

    ref4 = Reference.create(
      :author => 'Merker, S. & Groves, C. P.',
      :title => 'Tarsius lariang: A new primate species from Western Central Sulawesi.',
      :year => 2006
    )
# [for Tarsius lariang]

    tarsius = TaxonConcept.where("data->'full_name' = 'Tarsius lariang'").first
    if tarsius
      tarsius.references << ref4
    end

    ref5 = Reference.create(
      :author => 'Rice, D. W.',
      :title => 'Marine Mammals of the World: Systematics and Distribution',
      :year => 1998
    )
# [for Physeter macrocephalus and Platanista gangetica]

    physeter = TaxonConcept.where("data->'full_name' = 'Physeter macrocephalus'").first
    if physeter
      physeter.references << ref5
    end

    platanista = TaxonConcept.where("data->'full_name' = 'Platanista gangetica'").first
    if platanista
      platanista.references << ref5
    end

    ref6 = Reference.create(
      :author => 'Wada, S., Oishi, M. & Yamada, T. K.',
      :title => 'A newly discovered species of living baleen whales.',
      :year => 2003
    )
# [for Balaenoptera omurai]

    balaenoptera = TaxonConcept.where("data->'full_name' = 'Balaenoptera omurai'").first
    if balaenoptera
      balaenoptera.references << ref6
    end

    ref7 = Reference.create(
      :author => 'Wilson, D. E. & Reeder, D. M.',
      :title => 'Mammal Species of the World: a Taxonomic and Geographic Reference. (Second edition 1993)',
      :year => 1993
    )
# [for Loxodonta africana, Puma concolor, Lama guanicoe and Ovis vignei]

    loxodonta = TaxonConcept.where("data->'full_name' = 'Loxodonta africana'").first
    if loxodonta
      loxodonta.references << ref7
    end

    puma = TaxonConcept.where("data->'full_name' = 'Puma concolor'").first
    if puma
      puma.references << ref7
    end

    ovis = TaxonConcept.where("data->'full_name' = 'Ovis vignei'").first
    if ovis
      ovis.references << ref7
    end

    [ref1, ref2, ref3, ref4, ref5, ref6, ref7].each do |ref|
      cites.references << ref
    end

  end

end