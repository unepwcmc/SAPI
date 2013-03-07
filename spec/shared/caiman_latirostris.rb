#Encoding: utf-8
shared_context "Caiman latirostris" do
  before(:all) do
    @klass = create(
      :class,
      :taxon_name => create(:taxon_name, :scientific_name => 'Reptilia')
    )
    @order = create(
      :order,
      :taxon_name => create(:taxon_name, :scientific_name => 'Crocodylia'),
      :parent => @klass
    )
    @family = create(
      :family,
      :taxon_name => create(:taxon_name, :scientific_name => 'Alligatoridae'),
      :parent => @order
    )
    @genus = create(
      :genus,
      :taxon_name => create(:taxon_name, :scientific_name => 'Caiman'),
      :parent => @family
    )
    @species = create(
      :species,
      :taxon_name => create(:taxon_name, :scientific_name => 'Latirostris'),
      :parent => @genus,
      :name_status => 'A'
    )
    @genus1 = create(
      :genus,
      :taxon_name => create(:taxon_name, :scientific_name => 'Alligator'),
      :parent => @family
    )
    @species1 = create(
      :species,
      :full_name => 'Alligator cynocephalus',
      :parent => @genus1,
      :name_status => 'S'
    )

    create(
      :has_synonym,
      :taxon_concept => @species,
      :other_taxon_concept => @species1
    )

    @ref = create(
      :reference,
      :title => 'Schildkröte, Krokodile, Brückenechsen',
      :author => 'Wermuth, H. & Mertens, R.',
      :year => 1996
    )

    create(
      :taxon_concept_reference,
      :taxon_concept => @species,
      :reference => @ref,
      :data => {:usr_is_std_ref => 't'}
    )

    argentina = create(
      :country,
      :name => 'Argentina',
      :iso_code2 => 'AR'
    )
    create(
      :cites_II_addition,
      :taxon_concept => @order,
      :effective_at => '1977-02-04',
      :is_current => true
    )
    create(
     :cites_I_addition,
     :taxon_concept => @species,
     :effective_at => '1975-07-01',
     :is_current => true
    )
    a1 = create(
      :annotation,
      :full_note_en => 'Population of AR; included in CROCODYLIA spp.',
      :display_in_index => true
    )
    l1 = create(
     :cites_II_addition,
     :taxon_concept => @species,
     :annotation_id => a1.id,
     :effective_at => '1997-09-18',
     :is_current => true
    )
    create(
      :listing_distribution,
      :geo_entity => argentina,
      :listing_change => l1,
      :is_party => false
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