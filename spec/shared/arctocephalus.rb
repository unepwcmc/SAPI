shared_context "Arctocephalus" do
  def en
    @en ||= create(:language, :name => 'English', :iso_code1 => 'EN', :iso_code3 => 'ENG')
  end
  def es
    @es ||= create(:language, :name => 'Spanish', :iso_code1 => 'ES', :iso_code3 => 'SPA')
  end
  def fr
    @fr ||= create(:language, :name => 'French', :iso_code1 => 'FR', :iso_code3 => 'FRA')
  end
  before(:all) do
    @order = create_cites_eu_order(
      :taxon_name => create(:taxon_name, :scientific_name => 'Carnivora'),
      :parent => cites_eu_mammalia
    )
    @family = create_cites_eu_family(
      :taxon_name => create(:taxon_name, :scientific_name => 'Otariidae'),
      :parent => @order,
      :common_names => [
        create(:common_name, :name => 'Fur seals', :language => en),
        create(:common_name, :name => 'Sealions', :language => en),
        create(:common_name, :name => 'Focas', :language => es),
        create(:common_name, :name => 'Leones marinos', :language => es),
        create(:common_name, :name => 'Arctocéphales', :language => fr)
      ]
    )
    @genus = create_cites_eu_genus(
      :taxon_name => create(:taxon_name, :scientific_name => 'Arctocephalus'),
      :parent => @family,
      :common_names => [
        create(:common_name, :name => 'Fur seals 1', :language => en),
        create(:common_name, :name => 'Southern fur seals', :language => en),
        create(:common_name, :name => 'Osos marinos', :language => es),
        create(:common_name, :name => 'Arctocéphales du sud', :language => fr),
        create(:common_name, :name => 'Otaries à fourrure', :language => fr),
        create(:common_name, :name => 'Otaries à fourrure du sud', :language => fr)
      ],
      :name_status => 'A'
    )
    @species1 = create_cites_eu_species(
      :taxon_name => create(:taxon_name, :scientific_name => 'Australis'),
      :parent => @genus,
      :common_names => [
        create(:common_name, :name => 'South American Fur Seal', :language => en),
        create(:common_name, :name => 'Southern Fur Seal', :language => en),
        create(:common_name, :name => 'Lobo fino sudamericano', :language => es),
        create(:common_name, :name => 'Oso marino austral', :language => es),
        create(:common_name, :name => 'Otarie à fourrure australe', :language => fr)
      ],
      :name_status => 'A'
    )
    @species2 = create_cites_eu_species(
      :taxon_name => create(:taxon_name, :scientific_name => 'Townsendi'),
      :parent => @genus,
      :common_names => [
        create(:common_name, :name => 'Guadalupe Fur Seal', :language => en),
        create(:common_name, :name => 'Lower Californian Fur Seal', :language => en),
        create(:common_name, :name => 'Oso marino de Guadalupe', :language => es),
        create(:common_name, :name => 'Otaria americano', :language => es),
        create(:common_name, :name => 'Arctocéphale de Guadalupe', :language => fr),
        create(:common_name, :name => 'Otarie à fourrure d\'Amérique', :language => fr)
      ],
      :name_status => 'A'
    )
    @species3 = create_cites_eu_species(
      :taxon_name => create(:taxon_name, :scientific_name => 'Pusillus'),
      :parent => @genus,
      :name_status => 'A'
    )

    create_cites_II_addition(
      :taxon_concept => @species1,
      :effective_at => '1975-07-01'
    )
    create_cites_II_addition(
      :taxon_concept => @species2,
      :effective_at => '1975-07-01'
    )
    create_cites_II_addition(
      :taxon_concept => @genus,
      :effective_at => '1977-02-04',
      :is_current => true
    )
    create_cites_II_addition(
      :taxon_concept => @species1,
      :effective_at => '1977-02-04',
      :inclusion_taxon_concept_id => @genus.id,
      :is_current => true
    )
    create_cites_II_addition(
      :taxon_concept => @species2,
      :effective_at => '1977-02-04',
      :inclusion_taxon_concept_id => @genus.id
    )
    create_cites_I_addition(
      :taxon_concept => @species2,
      :effective_at => '1979-06-28',
      :is_current => true
    )

    create_eu_A_addition(
      :taxon_concept => @species2,
      :effective_at => '2013-08-10',
      :event => reg2013,
      :is_current => true
    )
    create_eu_B_addition(
      :taxon_concept => @genus,
      :effective_at => '2013-08-10',
      :event => reg2013,
      :is_current => true
    )

    Sapi::StoredProcedures.rebuild_cites_taxonomy_and_listings
    self.instance_variables.each do |t|
      #Skip old sapi context let statements,
      #which are now instance variables starting with _
      next if t.to_s.include?('@_')
      var = self.instance_variable_get(t)
      if var.kind_of? TaxonConcept
        self.instance_variable_set(t, MTaxonConcept.find(var.id))
        self.instance_variable_get(t).reload
      end
    end
  end
end
