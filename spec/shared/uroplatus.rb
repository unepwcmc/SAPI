shared_context 'Uroplatus' do
  before(:all) do
    @order = create_cites_eu_order(
      :taxon_name => create(:taxon_name, :scientific_name => 'Sauria'),
      :parent => cites_eu_reptilia
    )
    @family = create_cites_eu_family(
      :taxon_name => create(:taxon_name, :scientific_name => 'Gekkonidae'),
      :parent => @order
    )
    @genus = create_cites_eu_genus(
      :taxon_name => create(:taxon_name, :scientific_name => 'Uroplatus'),
      :parent => @family,
      :data => { :usr_no_std_ref => true }
    )
    @species1 = create_cites_eu_species(
      :taxon_name => create(:taxon_name, :scientific_name => 'Alluaudi'),
      :parent => @genus
    )
    @species2 = create_cites_eu_species(
      :taxon_name => create(:taxon_name, :scientific_name => 'Giganteus'),
      :parent => @genus
    )

    create_cites_II_addition(
      :taxon_concept => @genus,
      :effective_at => '2005-01-12',
      :is_current => true
    )
    create_eu_B_addition(
      :taxon_concept => @genus,
      :effective_at => '2013-10-08',
      :event => reg2013,
      :is_current => true
    )

    @ref = create(
      :reference,
      :author => 'Glaw, F., Kosuch, J., Henkel, W. F., Sound, P. and Böhme, W.',
      :title =>
        'Genetic and morphological variation of the leaf-tailed gecko Uroplatus
        fimbriatus from Madagascar, with description of a new giant species.',
      :year => 2006
    )

    create(
      :taxon_concept_reference,
      :taxon_concept => @species2,
      :reference => @ref,
      :is_standard => true,
      :is_cascaded => true
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
