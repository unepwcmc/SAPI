#Encoding: utf-8
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
      :data => {:usr_is_std_ref => 't', :cascade => 't', :exclusions => "{#{@genus.id}}"}
    )

    Sapi::rebuild(:except => [:names_and_ranks, :taxonomic_positions])
    self.instance_variables.each do |t|
      var = self.instance_variable_get(t)
      if var.kind_of? TaxonConcept
        self.instance_variable_set(t,MTaxonConcept.find(var.id))
        self.instance_variable_get(t).reload
      end
    end
  end
end
