shared_context "Agave" do
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
      :taxon_name => create(:taxon_name, :scientific_name => 'Liliales'),
      :parent => cites_eu_plantae.reload # reload is needed for full name
    )
    @family = create_cites_eu_family(
      :taxon_name => create(:taxon_name, :scientific_name => 'Agavaceae'),
      :parent => @order,
      :common_names => [
        create(:common_name, :name => 'Agaves', :language => en),
        create(:common_name, :name => 'Agaves', :language => es),
        create(:common_name, :name => 'Agaves', :language => fr)
      ]
    )
    @genus = create_cites_eu_genus(
      :taxon_name => create(:taxon_name, :scientific_name => 'Agave'),
      :parent => @family
    )
    @species1 = create_cites_eu_species(
      :taxon_name => create(:taxon_name, :scientific_name => 'Arizonica'),
      :parent => @genus
    )
    @species2 = create_cites_eu_species(
      :taxon_name => create(:taxon_name, :scientific_name => 'Parviflora'),
      :parent => @genus
    )

    create_cites_I_addition(
      :taxon_concept => @species1,
      :effective_at => '1983-07-29'
    )
    create_cites_I_addition(
      :taxon_concept => @species2,
      :effective_at => '1983-07-29',
      :is_current => true
    )
    create_cites_I_deletion(
      :taxon_concept => @species1,
      :effective_at => '2007-09-13',
      :is_current => true
    )

    create_eu_A_addition(
      :taxon_concept => @species1,
      :effective_at => '1997-06-01',
      :is_current => false
    )
    create_eu_A_addition(
      :taxon_concept => @species2,
      :effective_at => '1997-06-01',
      :is_current => false
    )
    create_eu_A_deletion(
      :taxon_concept => @species1,
      :effective_at => '2008-04-11',
      :is_current => false
    )
    create_eu_A_addition(
      :taxon_concept => @species2,
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
