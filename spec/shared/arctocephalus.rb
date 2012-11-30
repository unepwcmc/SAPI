#Encoding: UTF-8
shared_context "Arctocephalus" do
  before(:all) do
    @klass = TaxonConcept.find_by_taxon_name_id(TaxonName.find_by_scientific_name('Mammalia').id)
    @order = create(
      :order,
      :taxon_name => create(:taxon_name, :scientific_name => 'Carnivora'),
      :parent => @klass
    )
    @family = create(
      :family,
      :taxon_name => create(:taxon_name, :scientific_name => 'Otariidae'),
      :parent => @order,
      :common_names => [
        create(:english_common_name, :name => 'Fur seals'),
        create(:english_common_name, :name => 'Sealions'),
        create(:spanish_common_name, :name => 'Focas'),
        create(:spanish_common_name, :name => 'Leones marinos'),
        create(:french_common_name, :name => 'Arctocéphales')
      ]
    )
    @genus = create(
      :genus,
      :taxon_name => create(:taxon_name, :scientific_name => 'Arctocephalus'),
      :parent => @family,
      :common_names => [
        create(:english_common_name, :name => 'Fur seals'),
        create(:english_common_name, :name => 'Southern fur seals'),
        create(:spanish_common_name, :name => 'Osos marinos'),
        create(:french_common_name, :name => 'Arctocéphales du sud'),
        create(:french_common_name, :name => 'Otaries à fourrure'),
        create(:french_common_name, :name => 'Otaries à fourrure du sud')
      ]
    )
    @species1 = create(
      :species,
      :taxon_name => create(:taxon_name, :scientific_name => 'Australis'),
      :parent => @genus,
      :common_names => [
        create(:english_common_name, :name => 'South American Fur Seal'),
        create(:english_common_name, :name => 'Southern Fur Seal'),
        create(:spanish_common_name, :name => 'Lobo fino sudamericano'),
        create(:spanish_common_name, :name => 'Oso marino austral'),
        create(:french_common_name, :name => 'Otarie à fourrure australe')
      ]
    )
    @species2 = create(
      :species,
      :taxon_name => create(:taxon_name, :scientific_name => 'Townsendi'),
      :parent => @genus,
      :common_names => [
        create(:english_common_name, :name => 'Guadalupe Fur Seal'),
        create(:english_common_name, :name => 'Lower Californian Fur Seal'),
        create(:spanish_common_name, :name => 'Oso marino de Guadalupe'),
        create(:spanish_common_name, :name => 'Otaria americano'),
        create(:french_common_name, :name => 'Arctocéphale de Guadalupe'),
        create(:french_common_name, :name => 'Otarie à fourrure d\'Amérique')
      ]
    )
    @species3 = create(
      :species,
      :taxon_name => create(:taxon_name, :scientific_name => 'Pusillus'),
      :parent => @genus
    )

    create(
     :cites_II_addition,
     :taxon_concept => @species1,
     :effective_at => '1975-07-01'
    )
    create(
     :cites_II_addition,
     :taxon_concept => @species2,
     :effective_at => '1975-07-01'
    )
    create(
     :cites_II_addition,
     :taxon_concept => @genus,
     :effective_at => '1977-02-04',
     :is_current => true
    )
    create(
     :cites_II_addition,
     :taxon_concept => @species1,
     :effective_at => '1977-02-04',
     :inclusion_taxon_concept_id => @genus.id,
     :is_current => true
    )
    create(
     :cites_II_addition,
     :taxon_concept => @species2,
     :effective_at => '1977-02-04',
     :inclusion_taxon_concept_id => @genus.id
    )
    create(
     :cites_I_addition,
     :taxon_concept => @species2,
     :effective_at => '1979-06-28',
     :is_current => true
    )

    Sapi::rebuild
    self.instance_variables.each do |t|
      var = self.instance_variable_get(t)
      if var.kind_of? TaxonConcept
        self.instance_variable_set(t,MTaxonConcept.find(var.id))
        self.instance_variable_get(t).reload
      end
    end
  end
end