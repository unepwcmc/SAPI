shared_context 'Agalychnis' do
  before(:all) do
    @klass = cites_eu_amphibia
    @order = create_cites_eu_order(
      :taxon_name => create(:taxon_name, :scientific_name => 'Anura'),
      :parent => @klass
    )
    @family = create_cites_eu_family(
      :taxon_name => create(:taxon_name, :scientific_name => 'Hylidae'),
      :parent => @order
    )
    @genus = create_cites_eu_genus(
      :taxon_name => create(:taxon_name, :scientific_name => 'Agalychnis'),
      :parent => @family
    )

    create_cites_II_addition(
      :taxon_concept => @genus,
      :effective_at => '2010-06-23',
      :is_current => true
    )

    create_eu_B_addition(
      :taxon_concept => @genus,
      :effective_at => '2012-12-15',
      :event => reg2012,
      :is_current => false
    )

    create_eu_B_addition(
      :taxon_concept => @genus,
      :effective_at => '2013-08-10',
      :event => reg2013,
      :is_current => true
    )

    @ref = create(
      :reference,
      :author => 'Frost, D. R.',
      :title =>
        'Taxonomic Checklist of CITES-listed Amphibians',
      :year => 2006
    )

    create(
      :taxon_concept_reference,
      :taxon_concept => cites_eu_amphibia,
      :reference => @ref,
      :is_standard => true,
      :is_cascaded => true,
      :excluded_taxon_concepts_ids => "{#{@genus.id}}"
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
