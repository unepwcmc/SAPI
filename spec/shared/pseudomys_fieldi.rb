shared_context "Pseudomys fieldi" do
  before(:all) do
    @order = create_cites_eu_order(
      :taxon_name => create(:taxon_name, :scientific_name => 'Rodentia'),
      :parent => cites_eu_mammalia
    )
    @family = create_cites_eu_family(
      :taxon_name => create(:taxon_name, :scientific_name => 'Muridae'),
      :parent => @order
    )
    @genus = create_cites_eu_genus(
      :taxon_name => create(:taxon_name, :scientific_name => 'Pseudomys'),
      :parent => @family
    )
    @species = create_cites_eu_species(
      :taxon_name => create(:taxon_name, :scientific_name => 'fieldi'),
      :parent => @genus,
      :name_status => 'A'
    )
    @subspecies = create_cites_eu_subspecies(
      :taxon_name => create(:taxon_name, :scientific_name => 'praeconis'),
      :parent => @species,
      :name_status => 'A'
    )

    create_cites_I_addition(
      :taxon_concept => @species,
      :effective_at => '1975-07-01'
    )
    cites_del = create_cites_I_deletion(
      :taxon_concept => @species,
      :effective_at => '1979-06-28',
      :annotation => create(:annotation, :short_note_en => 'Except for subspecies <i>praeconis</i>'),
      :is_current => true
    )
    create_cites_I_exception(
      :taxon_concept => @subspecies,
      :parent_id => cites_del.id
    )
    create_cites_I_addition(
      :taxon_concept => @subspecies,
      :effective_at => '1975-07-01',
      :is_current => true
    )

    create_eu_A_addition(
      :taxon_concept => @subspecies,
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
