require 'spec_helper'

describe Trade::Shipment do
  describe :create do
    context 'when reporter_type not given' do
      subject { build(:shipment, reporter_type: nil) }
      specify { expect(subject.error_on(:reporter_type).size).to eq(2) }
    end

    context 'when appendix valid' do
      subject { build(:shipment, appendix: 'N') }
      specify { expect(subject).to be_valid }
    end

    context 'when appendix not valid' do
      subject { build(:shipment, appendix: 'I/II') }
      specify { expect(subject.error_on(:appendix).size).to eq(1) }
    end

    context 'when permit numbers given' do
      before(:each) do
        @shipment = create(
          :shipment,
          export_permit_number: 'a',
          import_permit_number: 'b',
          origin_permit_number: 'c',
          ifs_permit_number: 'd'
        )
      end

      context 'when export permit' do
        specify { expect(@shipment.export_permit_number).to eq('A') }
      end

      context 'when import permit' do
        specify { expect(@shipment.import_permit_number).to eq('B') }
      end

      context 'when origin permit' do
        specify { expect(@shipment.origin_permit_number).to eq('C') }
      end

      context 'when IFS permit' do
        specify { expect(@shipment.ifs_permit_number).to eq('D') }
      end
    end
  end

  describe 'secondary validations' do
    before(:each) do
      # an animal
      @genus = create_cites_eu_genus(
        taxon_name: create(:taxon_name, scientific_name: 'Foobarus'),
        parent: create_cites_eu_family(
          parent: create_cites_eu_order(
            parent: cites_eu_amphibia
          )
        )
      )
      @taxon_concept = create_cites_eu_species(
        taxon_name: create(:taxon_name, scientific_name: 'yolocatus'),
        parent: @genus
      )
      @poland = create(
        :geo_entity,
        name_en: 'Poland', iso_code2: 'PL',
        geo_entity_type: country_geo_entity_type
      )
      @argentina = create(
        :geo_entity,
        name_en: 'Argentina', iso_code2: 'AR',
        geo_entity_type: country_geo_entity_type
      )
      @xx = create(
        :geo_entity,
        geo_entity_type: trade_geo_entity_type,
        name: 'Unknown',
        iso_code2: 'XX'
      )
      create(:distribution, taxon_concept: @taxon_concept, geo_entity: @argentina)
      @wild = create(:trade_code, type: 'Source', code: 'W', name_en: 'Wild')
    end

    context 'when species name + appendix + year' do
      before(:each) do
        create_cites_I_addition(
          taxon_concept: @taxon_concept,
          effective_at: '2013-01-01',
          is_current: true
        )
        reg2013 # EU event
        SapiModule::StoredProcedures.rebuild_cites_taxonomy_and_listings
        create_taxon_concept_appendix_year_validation
      end

      context 'invalid' do
        subject do
          create(
            :shipment,
            taxon_concept: @taxon_concept, appendix: 'II', year: 2013
          ).tap(&:validate)
        end
        specify { expect(subject.warnings).not_to be_empty }
      end

      context 'invalid' do
        subject do
          create(
            :shipment,
            taxon_concept: @taxon_concept, appendix: 'N', year: 2013
          ).tap(&:validate)
        end
        specify { expect(subject.warnings).not_to be_empty }
      end

      context 'valid' do
        subject do
          create(
            :shipment,
            taxon_concept: @taxon_concept, appendix: 'I', year: 2013
          ).tap(&:validate)
        end
        specify { expect(subject.warnings).to be_empty }
      end
    end

    context 'when species name + appendix N + year' do
      before(:each) do
        create_eu_B_addition(
          taxon_concept: @taxon_concept,
          effective_at: '2013-01-01',
          event: reg2013,
          is_current: true
        )
        SapiModule::StoredProcedures.rebuild_cites_taxonomy_and_listings
        create_taxon_concept_appendix_year_validation
      end

      context 'valid' do
        subject do
          create(
            :shipment,
            taxon_concept: @taxon_concept, appendix: 'N', year: 2013
          ).tap(&:validate)
        end
        specify { expect(subject.warnings).to be_empty }
      end
    end

    context 'when species name + appendix N + year' do
      before(:each) do
        @taxon_concept = create_cites_eu_species(
          taxon_name: create(:taxon_name, scientific_name: 'nonsignificatus'),
          parent: @genus
        ).tap(&:validate)
        reg2013 # EU event
        SapiModule::StoredProcedures.rebuild_cites_taxonomy_and_listings
        create_taxon_concept_appendix_year_validation
      end

      context 'not CITES listed and not EU listed' do
        subject do
          create(
            :shipment,
            taxon_concept: @taxon_concept, appendix: 'N', year: 2013
          ).tap(&:validate)
        end
        specify { expect(subject.warnings).not_to be_empty }
      end
    end

    context 'when term + unit' do
      before(:each) do
        @cav = create(:term, code: 'CAV')
        @cap = create(:term, code: 'CAP')
        @bag = create(:unit, code: 'BAG')
        @kil = create(:unit, code: 'KIL')
        create(
          :term_trade_codes_pair, term_id: @cav.id, trade_code_id: @kil.id,
          trade_code_type: @kil.type
        )
        create(
          :term_trade_codes_pair, term_id: @cav.id, trade_code_id: nil,
          trade_code_type: @kil.type
        )
        create(
          :term_trade_codes_pair, term_id: @cap.id, trade_code_id: @kil.id,
          trade_code_type: @kil.type
        )
        create_term_unit_validation
      end

      context 'invalid' do
        subject do
          create(
            :shipment,
            term: @cav, unit: @bag
          ).tap(&:validate)
        end
        specify { expect(subject.warnings).not_to be_empty }
      end

      context 'valid' do
        subject do
          create(
            :shipment,
            term: @cav, unit: @kil
          ).tap(&:validate)
        end
        specify { expect(subject.warnings).to be_empty }
      end

      context 'blank unit is valid' do
        subject do
          create(
            :shipment,
            term: @cav, unit: nil
          ).tap(&:validate)
        end
        specify { expect(subject.warnings).to be_empty }
      end

      context 'blank unit is invalid' do
        subject do
          create(
            :shipment,
            term: @cap, unit: nil
          ).tap(&:validate)
        end
        specify { expect(subject.warnings).not_to be_empty }
      end
    end

    context 'when term + purpose' do
      before(:each) do
        @cav = create(:term, code: 'CAV')
        @b = create(:purpose, code: 'B')
        @p = create(:purpose, code: 'P')
        create(
          :term_trade_codes_pair, term_id: @cav.id, trade_code_id: @p.id,
          trade_code_type: @p.type
        )
        create_term_purpose_validation
      end

      context 'invalid' do
        subject do
          create(
            :shipment,
            term: @cav, purpose: @b
          ).tap(&:validate)
        end
        specify { expect(subject.warnings).not_to be_empty }
      end

      context 'valid' do
        subject do
          create(
            :shipment,
            term: @cav, purpose: @p
          ).tap(&:validate)
        end
        specify { expect(subject.warnings).to be_empty }
      end
    end

    context 'when species name + term' do
      before(:each) do
        @cav = create(:term, code: 'CAV')
        @bal = create(:term, code: 'BAL')
        create(
          :trade_taxon_concept_term_pair,
          taxon_concept_id: @taxon_concept.id, term_id: @bal.id
        )
        create_taxon_concept_term_validation
      end

      context 'invalid' do
        subject do
          create(
            :shipment,
            taxon_concept: @taxon_concept, term: @cav
          ).tap(&:validate)
        end
        specify { expect(subject.warnings).not_to be_empty }
      end

      context 'valid' do
        subject do
          create(
            :shipment,
            taxon_concept: @taxon_concept, term: @bal
          )
        end
        specify { expect(subject.warnings).to be_empty }
      end
    end

    context 'when species name + country of origin' do
      before(:each) do
        create_taxon_concept_country_of_origin_validation
      end

      context 'invalid' do
        subject do
          create(
            :shipment,
            source: @wild,
            taxon_concept: @taxon_concept,
            country_of_origin: @poland
          ).tap(&:validate)
        end
        specify { expect(subject.warnings).not_to be_empty }
      end

      context 'valid' do
        subject do
          create(
            :shipment,
            source: @wild,
            taxon_concept: @taxon_concept,
            country_of_origin: @argentina
          ).tap(&:validate)
        end
        specify { expect(subject.warnings).to be_empty }
      end

      context 'blank' do
        subject do
          create(
            :shipment,
            source: @wild,
            taxon_concept: @taxon_concept,
            country_of_origin: nil
          ).tap(&:validate)
        end
        specify { expect(subject.warnings).to be_empty }
      end
    end

    context 'when species name + exporter' do
      before(:each) do
        create_taxon_concept_exporter_validation
      end

      context 'invalid' do
        subject do
          create(
            :shipment,
            source: @wild,
            taxon_concept: @taxon_concept,
            country_of_origin: nil,
            exporter: @poland
          ).tap(&:validate)
        end
        specify { expect(subject.warnings).not_to be_empty }
      end

      context 'valid' do
        subject do
          create(
            :shipment,
            source: @wild,
            taxon_concept: @taxon_concept,
            country_of_origin: nil,
            exporter: @argentina
          ).tap(&:validate)
        end
        specify { expect(subject.warnings).to be_empty }
      end

      context 'valid with XX' do
        subject do
          create(
            :shipment,
            source: @wild,
            taxon_concept: @taxon_concept,
            country_of_origin: nil,
            exporter: @xx
          ).tap(&:validate)
        end
        specify { expect(subject.warnings).to be_empty }
      end
    end

    context 'when exporter + country of origin' do
      before(:each) do
        create_exporter_country_of_origin_validation
      end

      context 'invalid' do
        subject do
          create(
            :shipment,
            taxon_concept: @taxon_concept,
            exporter: @argentina,
            country_of_origin: @argentina
          ).tap(&:validate)
        end
        specify { expect(subject.warnings).not_to be_empty }
      end

      context 'valid' do
        subject do
          create(
            :shipment,
            taxon_concept: @taxon_concept,
            exporter: @poland,
            country_of_origin: @argentina
          ).tap(&:validate)
        end
        specify { expect(subject.warnings).to be_empty }
      end
    end

    context 'when exporter + importer' do
      before(:each) do
        create_exporter_importer_validation
      end

      context 'invalid' do
        subject do
          create(
            :shipment,
            taxon_concept: @taxon_concept,
            importer: @argentina,
            exporter: @argentina
          ).tap(&:validate)
        end
        specify { expect(subject.warnings).not_to be_empty }
      end

      context 'valid' do
        subject do
          create(
            :shipment,
            taxon_concept: @taxon_concept,
            importer: @poland,
            exporter: @argentina
          ).tap(&:validate)
        end
        specify { expect(subject.warnings).to be_empty }
      end
    end

    context 'when species name + source code' do
      before(:each) do
        @artificial = create(:trade_code, type: 'Source', code: 'A', name_en: 'Artificially propagated')
        create_taxon_concept_source_validation
        cites
        reg2013 # EU event
        SapiModule::StoredProcedures.rebuild_cites_taxonomy_and_listings
        @taxon_concept.reload
      end

      context 'invalid' do
        subject do
          create(
            :shipment,
            taxon_concept: @taxon_concept,
            source: @artificial
          ).tap(&:validate)
        end
        specify { expect(subject.warnings).not_to be_empty }
      end

      context 'valid' do
        subject do
          create(
            :shipment,
            taxon_concept: @taxon_concept,
            source: @wild
          ).tap(&:validate)
        end
        specify { expect(subject.warnings).to be_empty }
      end
    end
  end
end
