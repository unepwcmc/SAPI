#Encoding: utf-8
shared_context 'Varanidae' do
  before(:all) do
    @klass = TaxonConcept.find_by_taxon_name_id(TaxonName.find_by_scientific_name('Reptilia').id)
    @order = create(
      :order,
      :taxon_name => create(:taxon_name, :scientific_name => 'Sauria'),
      :parent => @klass
    )
    @family = create(
      :family,
      :taxon_name => create(:taxon_name, :scientific_name => 'Varanidae'),
      :parent => @order
    )
    @genus = create(
      :genus,
      :taxon_name => create(:taxon_name, :scientific_name => 'Varanus'),
      :parent => @family
    )
    @species1 = create(
      :species,
      :taxon_name => create(:taxon_name, :scientific_name => 'Bengalensis'),
      :parent => @genus
    )
    @species2 = create(
      :species,
      :taxon_name => create(:taxon_name, :scientific_name => 'Bushi'),
      :parent => @genus
    )

    create(
     :cites_II_addition,
     :taxon_concept => @genus,
     :effective_at => '1975-07-01'
    )
    create(
     :cites_I_addition,
     :taxon_concept => @species1,
     :effective_at => '1975-07-01'
    )

    @ref1 = create(
      :reference,
      :author => 'Böhme, W.',
      :title =>
        'Checklist of the living monitor lizards of the world (family Varanidae)',
      :year => 2003
    )
    @ref2 = create(
      :reference,
      :author => 'Aplin, K. P., Fitch, A. J. & King, D. J.',
      :title =>
        'A new species of Varanus Merrem (Squamata: Varanidae) from the Pilbara
        region of Western Australia, with observations on sexual dimorphism in
        closely related species.',
      :year => 2006
    )

    create(
      :taxon_concept_reference,
      :taxon_concept => @family,
      :reference => @ref1,
      :data => {:usr_is_std_ref => 't'}
    )
    create(
      :taxon_concept_reference,
      :taxon_concept => @species2,
      :reference => @ref2,
      :data => {:usr_is_std_ref => 't'}
    )

    Sapi::fix_listing_changes
    Sapi::rebuild
    self.instance_variables.each do |t|
      self.instance_variable_get(t).reload
    end
  end
end
