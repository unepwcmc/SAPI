#Encoding: utf-8
shared_context 'Agalychnis' do
  before(:all) do
    @klass = TaxonConcept.find_by_taxon_name_id(TaxonName.find_by_scientific_name('Amphibia').id)
    @order = create(
      :order,
      :taxon_name => create(:taxon_name, :scientific_name => 'Anura'),
      :parent => @klass
    )
    @family = create(
      :family,
      :taxon_name => create(:taxon_name, :scientific_name => 'Hylidae'),
      :parent => @order
    )
    @genus = create(
      :genus,
      :taxon_name => create(:taxon_name, :scientific_name => 'Agalychnis'),
      :parent => @family,
      :data => {:usr_no_std_ref => true}
    )

    create(
     :cites_II_addition,
     :taxon_concept => @genus,
     :effective_at => '2010-06-23'
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
      :taxon_concept => @klass,
      :reference => @ref,
      :data => {:usr_is_std_ref => 't'}
    )

    Sapi::fix_listing_changes
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
