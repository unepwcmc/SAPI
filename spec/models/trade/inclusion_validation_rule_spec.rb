# == Schema Information
#
# Table name: trade_validation_rules
#
#  id                :integer          not null, primary key
#  valid_values_view :string(255)
#  type              :string(255)      not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  format_re         :string(255)
#  run_order         :integer          not null
#  column_names      :string(255)
#  is_primary        :boolean          default(TRUE), not null
#  scope             :hstore
#  is_strict         :boolean          default(FALSE), not null
#

require 'spec_helper'

describe Trade::InclusionValidationRule, :drops_tables => true do
  let(:annual_report_upload) {
    annual_report = build(
      :annual_report_upload,
      :point_of_view => 'E'
    )
    annual_report.save(:validate => false)
    annual_report
  }
  let(:sandbox_klass) {
    Trade::SandboxTemplate.ar_klass(annual_report_upload.sandbox.table_name)
  }
  let(:canis_lupus) {
    create_cites_eu_species(
      taxon_name: create(:taxon_name, scientific_name: 'lupus'),
      parent: create_cites_eu_genus(
        :taxon_name => create(:taxon_name, scientific_name: 'Canis')
      )
    )
  }

  describe :matching_records_for_aru_and_error do
    let(:validation_rule) {
      create_taxon_concept_validation
    }
    before(:each) do
      @shipment1 = sandbox_klass.create(
        taxon_name: canis_lupus.full_name
      )
      @shipment2 = sandbox_klass.create(
        taxon_name: 'Caniis lupus'
      )
      @validation_error = create(
        :validation_error,
        annual_report_upload_id: annual_report_upload.id,
        validation_rule_id: validation_rule.id,
        matching_criteria: "{\"taxon_name\": \"Caniis lupus\"}",
        is_ignored: false,
        is_primary: true,
        error_message: "taxon_name Caniis lupus is invalid",
        error_count: 1
      )
      Sapi::StoredProcedures.rebuild_cites_taxonomy_and_listings
      validation_rule.refresh_errors_if_needed(annual_report_upload)
    end
    specify {
      expect(
        validation_rule.matching_records_for_aru_and_error(
          annual_report_upload,
          @validation_error
        )
      ).to eq([@shipment2])
    }
  end

  describe :refresh_errors_if_needed do
    let(:validation_rule) {
      create_taxon_concept_validation
    }
    before(:each) do
      @shipment1 = sandbox_klass.create(
        taxon_name: canis_lupus.full_name
      )
      @shipment2 = sandbox_klass.create(
        taxon_name: 'Caniis lupus'
      )
      @shipment3 = sandbox_klass.create(
        taxon_name: 'Caniis lupus'
      )
      @validation_error = create(
        :validation_error,
        annual_report_upload_id: annual_report_upload.id,
        validation_rule_id: validation_rule.id,
        matching_criteria: "{\"taxon_name\": \"Caniis lupus\"}",
        is_ignored: false,
        is_primary: true,
        error_message: "taxon_name Caniis lupus is invalid",
        error_count: 2
      )
      Sapi::StoredProcedures.rebuild_cites_taxonomy_and_listings
      validation_rule.refresh_errors_if_needed(annual_report_upload)
    end

    context "when no updates" do
      specify do
        expect {
          validation_rule.refresh_errors_if_needed(annual_report_upload)
        }.not_to change { Trade::ValidationError.count }
      end
    end

    context "when updates and error fixed for all records" do
      specify "error record is destroyed" do
        Timecop.travel(Time.now + 1)
        @shipment2.update_attributes(taxon_name: 'Canis lupus')
        @shipment3.update_attributes(taxon_name: 'Canis lupus')
        expect {
          validation_rule.refresh_errors_if_needed(annual_report_upload)
        }.to change { Trade::ValidationError.count }.by(-1)
      end
    end

    context "when updates and error fixed for some records" do
      specify "error record is updated to reflect new error_count" do
        Timecop.travel(Time.now + 1)
        @shipment2.update_attributes(taxon_name: 'Canis lupus')
        expect {
          validation_rule.refresh_errors_if_needed(annual_report_upload)
        }.to change { @validation_error.reload.error_count }.by(-1)
      end
    end

  end

  describe :validation_errors_for_aru do
    context 'species name may have extra whitespace between name segments' do
      before(:each) do
        genus = create_cites_eu_genus(
          :taxon_name => create(:taxon_name, :scientific_name => 'Acipenser')
        )
        create_cites_eu_species(
          :taxon_name => create(:taxon_name, :scientific_name => 'baerii'),
          :parent => genus
        )
      end
      subject {
        create_taxon_concept_validation
      }
      specify {
        subject.refresh_errors_if_needed(annual_report_upload)
        subject.validation_errors_for_aru(annual_report_upload).should be_empty
      }
    end
    context 'trading partner should be a valid iso code' do
      before(:each) do
        sandbox_klass.create(:trading_partner => 'Neverland')
        sandbox_klass.create(:trading_partner => '')
        sandbox_klass.create(:trading_partner => nil)
      end
      let!(:france) {
        create(
          :geo_entity,
          :geo_entity_type => country_geo_entity_type,
          :name => 'France',
          :iso_code2 => 'FR'
        )
      }
      subject {
        create(
          :inclusion_validation_rule,
          :column_names => ['trading_partner'],
          :valid_values_view => 'valid_trading_partner_view',
          :is_strict => true
        )
      }
      specify {
        subject.refresh_errors_if_needed(annual_report_upload)
        subject.validation_errors_for_aru(annual_report_upload).size.should == 1
      }
    end
    context 'term can only be paired with unit as defined by term_trade_codes_pairs table' do
      before do
        cap = create(:term, :code => "CAP")
        cav = create(:term, :code => "CAV")
        create(:unit, :code => "BAG")
        kil = create(:unit, :code => "KIL")
        create(:term_trade_codes_pair, :term_id => cav.id, :trade_code_id => kil.id,
              :trade_code_type => kil.type)
        create(:term_trade_codes_pair, :term_id => cav.id, :trade_code_id => nil,
              :trade_code_type => kil.type)
        create(:term_trade_codes_pair, :term_id => cap.id, :trade_code_id => kil.id,
              :trade_code_type => kil.type)
        sandbox_klass.create(:term_code => 'CAV', :unit_code => 'KIL')
        sandbox_klass.create(:term_code => 'CAV', :unit_code => '')
      end
      context "when invalid combination" do
        before(:each) do
          sandbox_klass.create(:term_code => 'CAP', :unit_code => 'BAG')
        end
        subject {
          create_term_unit_validation
        }
        specify {
          subject.refresh_errors_if_needed(annual_report_upload)
          subject.validation_errors_for_aru(annual_report_upload).size.should == 1
        }
      end
      context "when required unit blank" do
        before(:each) do
          sandbox_klass.create(:term_code => 'CAP', :unit_code => '')
        end
        subject {
          create_term_unit_validation
        }
        specify {
          subject.refresh_errors_if_needed(annual_report_upload)
          subject.validation_errors_for_aru(annual_report_upload).size.should == 1
        }
      end
    end
    context 'term can only be paired with purpose as defined by term_trade_codes_pairs table' do
      before do
        cav = create(:term, :code => "CAV")
        create(:purpose, :code => "B")
        purpose = create(:purpose, :code => "P")
        create(:term_trade_codes_pair, :term_id => cav.id, :trade_code_id => purpose.id,
              :trade_code_type => purpose.type)
        sandbox_klass.create(:term_code => 'CAV', :purpose_code => 'B')
        sandbox_klass.create(:term_code => 'CAV', :purpose_code => 'P')
        sandbox_klass.create(:term_code => 'CAV', :purpose_code => '')
      end
      subject {
        create_term_purpose_validation
      }
      specify {
        subject.refresh_errors_if_needed(annual_report_upload)
        subject.validation_errors_for_aru(annual_report_upload).size.should == 2
      }
    end
    context 'taxon_concept_id can only be paired with term as defined by trade_taxon_concept_term_pairs table' do
      before do
        @genus = create_cites_eu_genus
        cav = create(:term, :code => "CAV")
        create(:term, :code => "BAL")
        @pair = create(:trade_taxon_concept_term_pair, :term_id => cav.id, :taxon_concept_id => @genus.id)
      end
      subject {
        create_taxon_concept_term_validation
      }
      context "when accepted name" do
        before(:each) do
          @species = create_cites_eu_species(:parent => @genus)
          sandbox_klass.create(:term_code => 'CAV', :taxon_name => @species.full_name)
          sandbox_klass.create(:term_code => 'BAL', :taxon_name => @species.full_name)
        end
        specify {
          subject.refresh_errors_if_needed(annual_report_upload)
          subject.validation_errors_for_aru(annual_report_upload).size.should == 1
        }
      end
      context "when hybrid" do
        before(:each) do
          @hybrid = create_cites_eu_species(:parent => @genus, :name_status => 'H')
          create(
            :taxon_relationship,
            :taxon_concept => @genus,
            :other_taxon_concept => @hybrid,
            :taxon_relationship_type => hybrid_relationship_type
          )
          sandbox_klass.create(:term_code => 'CAV', :taxon_name => @hybrid.full_name)
          sandbox_klass.create(:term_code => 'BAL', :taxon_name => @hybrid.full_name)
        end
        specify {
          subject.refresh_errors_if_needed(annual_report_upload)
          subject.validation_errors_for_aru(annual_report_upload).size.should == 1
        }
      end
    end
  end
end
