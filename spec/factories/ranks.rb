def attributes_for_rank(name)
  send("attributes_for_#{name.downcase}")
end

def attributes_for_kingdom
  { name: Rank::KINGDOM, taxonomic_position: '1', fixed_order: true }
end

def attributes_for_phylum
  { name: Rank::PHYLUM, taxonomic_position: '2', fixed_order: true }
end

def attributes_for_class
  { name: Rank::CLASS, taxonomic_position: '3', fixed_order: true }
end

def attributes_for_order
  { name: Rank::ORDER, taxonomic_position: '4', fixed_order: false }
end

def attributes_for_family
  { name: Rank::FAMILY, taxonomic_position: '5', fixed_order: false }
end

def attributes_for_subfamily
  { name: Rank::SUBFAMILY, taxonomic_position: '5.1', fixed_order: false }
end

def attributes_for_genus
  { name: Rank::GENUS, taxonomic_position: '6', fixed_order: false }
end

def attributes_for_species
  { name: Rank::SPECIES, taxonomic_position: '7', fixed_order: false }
end

def attributes_for_subspecies
  { name: Rank::SUBSPECIES, taxonomic_position: '7.1', fixed_order: false }
end

def attributes_for_variety
  { name: Rank::VARIETY, taxonomic_position: '7.2', fixed_order: false }
end

FactoryGirl.define do
  factory :rank do
    name {
      [
        Rank::KINGDOM,
        Rank::PHYLUM,
        Rank::CLASS,
        Rank::ORDER,
        Rank::FAMILY,
        Rank::SUBFAMILY,
        Rank::GENUS,
        Rank::SPECIES,
        Rank::SUBSPECIES,
        Rank::VARIETY
      ].sample
    }
    display_name_en { |r| r.name }
    initialize_with { Rank.find_by_name(name) || new(attributes_for_rank(name)) }
  end
end
