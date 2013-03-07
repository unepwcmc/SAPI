shared_context :ranks do
  before(:all) do
    @kingdom = create(
      :rank,
      :name => Rank::KINGDOM, :taxonomic_position => '1', :fixed_order => true
    )
    @phylum = create(
      :rank,
      :name => Rank::PHYLUM, :taxonomic_position => '2', :fixed_order => true
    )
    @klass = create(
      :rank,
      :name => Rank::CLASS, :taxonomic_position => '3', :fixed_order => true
    )
    @order = create(
      :rank,
      :name => Rank::ORDER, :taxonomic_position => '4', :fixed_order => false
    )
    @family = create(
      :rank,
      :name => Rank::FAMILY, :taxonomic_position => '5', :fixed_order => false
    )
    @subfamily = create(
      :rank,
      :name => Rank::SUBFAMILY, :taxonomic_position => '5.1', :fixed_order => false
    )
    @genus = create(
      :rank,
      :name => Rank::GENUS, :taxonomic_position => '6', :fixed_order => false
    )
    @species = create(
      :rank,
      :name => Rank::SPECIES, :taxonomic_position => '7', :fixed_order => false
    )
    @subspecies = create(
      :rank,
      :name => Rank::SUBSPECIES, :taxonomic_position => '7.1', :fixed_order => false
    )
    @variety = create(
      :rank,
      :name => Rank::VARIETY, :taxonomic_position => '7.2', :fixed_order => false
    )
  end
end