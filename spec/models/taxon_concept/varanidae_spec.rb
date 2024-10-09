require 'spec_helper'

describe TaxonConcept do
  context 'Varanidae' do
    include_context 'Varanidae'

    context 'REFERENCES' do
      describe :cites_accepted do
        context 'for species Varanus bengalensis' do
          specify { expect(@species1.cites_accepted).to be_truthy }
        end
      end
      describe :standard_taxon_concept_references do
        context 'for order Sauria' do
          specify { expect(@order.taxon_concept.standard_taxon_concept_references).to be_empty }
        end
        context 'for family Varanidae' do
          specify { expect(@family.taxon_concept.standard_taxon_concept_references.map(&:reference_id)).to include @ref1.id }
        end
        context 'for species Varanus bengalensis' do
          specify { expect(@species1.taxon_concept.standard_taxon_concept_references.map(&:reference_id)).to include @ref1.id }
        end
        context 'for species Varanus bushi' do
          specify { expect(@species2.taxon_concept.standard_taxon_concept_references.map(&:reference_id)).to include @ref1.id }
          specify { expect(@species2.taxon_concept.standard_taxon_concept_references.map(&:reference_id)).to include @ref2.id }
        end
      end
    end
    context 'LISTING' do
      describe :cites_listing do
        context 'for genus Varanus' do
          specify { expect(@genus.cites_listing).to eq('I/II') }
        end
        context 'for species Varanus bengalensis' do
          specify { expect(@species1.cites_listing).to eq('I') }
        end
      end

      describe :eu_listing do
        context 'for genus Varanus' do
          specify { expect(@genus.eu_listing).to eq('A/B') }
        end
        context 'for species Varanus bengalensis' do
          specify { expect(@species1.eu_listing).to eq('A') }
        end
      end

      describe :cites_listed do
        context 'for family Varanidae' do
          specify { expect(@family.cites_listed).to eq(false) }
        end
        context 'for genus Varanus' do
          specify { expect(@genus.cites_listed).to be_truthy }
        end
        context 'for species Varanus bengalensis' do
          specify { expect(@species1.cites_listed).to be_truthy }
        end
      end

      describe :eu_listed do
        context 'for family Varanidae' do
          specify { expect(@family.eu_listed).to eq(false) }
        end
        context 'for genus Varanus' do
          specify { expect(@genus.eu_listed).to be_truthy }
        end
        context 'for species Varanus bengalensis' do
          specify { expect(@species1.eu_listed).to be_truthy }
        end
      end
    end
  end
end
