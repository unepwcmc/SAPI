require 'spec_helper'

describe TaxonConcept do
  context 'Falconiformes' do
    include_context 'Falconiformes'

    context 'TAXONOMY' do
      describe :rank_name do
        context 'for Falco hybrid' do
          specify { expect(@hybrid.rank_name).to eq(Rank::GENUS) }
        end
      end
    end

    context 'LISTING' do
      describe :cites_listing do
        context 'for order Falconiformes' do
          specify { expect(@order.cites_listing).to eq('I/II/III/NC') }
        end
        context 'for species Falco araea' do
          specify { expect(@species2_1.cites_listing).to eq('I') }
        end
        context 'for species Falco alopex (H)' do
          specify { expect(@species2_2.cites_listing).to eq('II') }
        end
        context 'for species Gymnogyps californianus' do
          specify { expect(@species1_1.cites_listing).to eq('I') }
        end
        context 'for species Sarcoramphus papa' do
          specify { expect(@species1_2.cites_listing).to eq('III') }
        end
        context 'for species Vultur atratus' do
          specify { expect(@species1_3.cites_listing).to eq('NC') }
        end
      end

      describe :eu_listing do
        context 'for order Falconiformes' do
          specify { expect(@order.eu_listing).to eq('A/B/C/NC') }
        end
        context 'for species Falco araea' do
          specify { expect(@species2_1.eu_listing).to eq('A') }
        end
        context 'for species Falco alopex (H)' do
          specify { expect(@species2_2.eu_listing).to eq('B') }
        end
        context 'for species Gymnogyps californianus' do
          specify { expect(@species1_1.eu_listing).to eq('A') }
        end
        context 'for species Sarcoramphus papa' do
          specify { expect(@species1_2.eu_listing).to eq('C') }
        end
        context 'for species Vultur atratus' do
          specify { expect(@species1_3.eu_listing).to eq('NC') }
        end
      end

      describe :cites_status do
        context 'for genus Vultur' do
          specify { expect(@genus1_3.cites_status).to eq('EXCLUDED') }
        end
        context 'for species Vultur atratus' do
          specify { expect(@species1_3.cites_status).to eq('EXCLUDED') }
        end
      end

      describe :cites_listed do
        context 'for order Falconiformes' do
          specify { expect(@order.cites_listed).to be_truthy }
        end
        context 'for family Falconidae (inclusion in higher taxa listing)' do
          specify { expect(@family2.cites_listed).to eq(false) }
        end
        context 'for genus Falco' do
          specify { expect(@genus2_1.cites_listed).to eq(false) }
        end
        context 'for species Falco araea' do
          specify { expect(@species2_1.cites_listed).to be_truthy }
        end
        context 'for species Falco alopex' do
          specify { expect(@species2_2.cites_listed).to eq(false) }
        end
        context 'for species Vultur atratus' do
          specify { expect(@species1_3.cites_listed).to be_blank }
        end
        context 'for subspecies Falco peregrinus peregrinus' do
          specify { expect(@subspecies2_3_1.cites_listed).to eq(false) }
        end
      end

      describe :eu_listed do
        context 'for order Falconiformes' do
          specify { expect(@order.eu_listed).to be_truthy }
        end
        context 'for family Falconidae (inclusion in higher taxa listing)' do
          specify { expect(@family2.eu_listed).to eq(false) }
        end
        context 'for genus Falco' do
          specify { expect(@genus2_1.eu_listed).to eq(false) }
        end
        context 'for species Falco araea' do
          specify { expect(@species2_1.eu_listed).to be_truthy }
        end
        context 'for species Falco alopex' do
          specify { expect(@species2_2.eu_listed).to eq(false) }
        end
        context 'for species Vultur atratus' do
          specify { expect(@species1_3.eu_listed).to be_blank }
        end
        context 'for subspecies Falco peregrinus peregrinus' do
          specify { expect(@subspecies2_3_1.eu_listed).to eq(false) }
        end
      end

      describe :cites_show do
        context 'for order Falconiformes' do
          specify { expect(@order.cites_show).to be_truthy }
        end
        context 'for family Falconidae' do
          specify { expect(@family2.cites_show).to be_truthy }
        end
        context 'for Falco hybrid' do
          specify { expect(@hybrid.cites_show).to be_falsey }
        end
      end

      describe :show_in_checklist_ac do
        context 'for subspecies Falco peregrinus peregrinus' do
          specify { expect(@subspecies2_3_1_ac.show_in_checklist_ac).to be_falsey }
        end
      end

      describe :show_in_species_plus_ac do
        context 'for subspecies Falco peregrinus peregrinus' do
          specify { expect(@subspecies2_3_1_ac.show_in_species_plus_ac).to be_truthy }
        end
      end
    end
  end
end
