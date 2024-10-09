# == Schema Information
#
# Table name: ranks
#
#  id                 :integer          not null, primary key
#  display_name_en    :text             not null
#  display_name_es    :text
#  display_name_fr    :text
#  fixed_order        :boolean          default(FALSE), not null
#  name               :string(255)      not null
#  taxonomic_position :string(255)      default("0"), not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

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

FactoryBot.define do
  factory :rank do
    name do
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
    end
    display_name_en { |r| r.name }
    initialize_with { Rank.find_by(name: name) || new(attributes_for_rank(name)) }
  end
end
