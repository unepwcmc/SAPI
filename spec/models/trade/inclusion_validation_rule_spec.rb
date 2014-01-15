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
#

require 'spec_helper'

describe Trade::InclusionValidationRule, :drops_tables => true do
  let(:annual_report_upload){
    annual_report = build(
      :annual_report_upload,
      :point_of_view => 'E'
    )
    annual_report.save(:validate => false)
    annual_report
  }
  let(:sandbox_klass){
    Trade::SandboxTemplate.ar_klass(annual_report_upload.sandbox.table_name)
  }
  describe :validation_errors do
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
      subject{
        create(
          :inclusion_validation_rule,
          :column_names => ['species_name'],
          :valid_values_view => 'valid_species_name_view'
        )
      }
      specify{
        subject.validation_errors(annual_report_upload).should be_empty
      }
    end
    context 'trading partner should be a valid iso code' do
      before(:each) do
        sandbox_klass.create(:trading_partner => 'Neverland')
        sandbox_klass.create(:trading_partner => '')
        sandbox_klass.create(:trading_partner => nil)
      end
      let(:country){
        create(:geo_entity_type, :name => GeoEntityType::COUNTRY)
      }
      let!(:france){
        create(
          :geo_entity,
          :geo_entity_type => country,
          :name => 'France',
          :iso_code2 => 'FR'
        )
      }
      subject{
        create(
          :inclusion_validation_rule,
          :column_names => ['trading_partner'],
          :valid_values_view => 'valid_trading_partner_view'
        )
      }
      specify{
        subject.validation_errors(annual_report_upload).size.should == 1
      }
      specify{
        ve = subject.validation_errors(annual_report_upload).first
        ve.error_selector.should == {'trading_partner' => 'NEVERLAND'}
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
        subject{
          create(
            :inclusion_validation_rule,
            :column_names => ['term_code', 'unit_code'],
            :valid_values_view => 'valid_term_unit_view'
          )
        }
        specify{
          subject.validation_errors(annual_report_upload).size.should == 1
        }
        specify{
          ve = subject.validation_errors(annual_report_upload).first
          ve.error_selector.should == {'term_code' => 'CAP', 'unit_code' => 'BAG'}
        }
      end
      context "when required unit blank" do
        before(:each) do
          sandbox_klass.create(:term_code => 'CAP', :unit_code => '')
        end
        subject{
          create(
            :inclusion_validation_rule,
            :column_names => ['term_code', 'unit_code'],
            :valid_values_view => 'valid_term_unit_view'
          )
        }
        specify{
          subject.validation_errors(annual_report_upload).size.should == 1
        }
        specify{
          ve = subject.validation_errors(annual_report_upload).first
          ve.error_selector.should == {'term_code' => 'CAP', 'unit_code' => nil}
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
      subject{
        create(
          :inclusion_validation_rule,
          :column_names => ['term_code', 'purpose_code'],
          :valid_values_view => 'valid_term_purpose_view'
        )
      }
      specify{
        subject.validation_errors(annual_report_upload).size.should == 2
      }
      specify{
        ve = subject.validation_errors(annual_report_upload).first
        ve.error_selector.should == {'term_code' => 'CAV', 'purpose_code' => 'B'}
      }
    end
    context 'taxon_concept species_name can only be paired with term as defined by trade_taxon_concept_term_pairs table' do
      before do
        cav = create(:term, :code => "CAV")
        create(:term, :code => "BAL")
        @pair = create(:trade_taxon_concept_term_pair, :term_id => cav.id)
        sandbox_klass.create(:term_code => 'CAV', :species_name => @pair.taxon_concept.full_name)
        sandbox_klass.create(:term_code => 'BAL', :species_name => @pair.taxon_concept.full_name)
      end
      subject{
        create(
          :inclusion_validation_rule,
          :column_names => ['species_name', 'term_code'],
          :valid_values_view => 'valid_taxon_concept_term_view'
        )
      }
      specify{
        subject.validation_errors(annual_report_upload).size.should == 1
      }
      specify{
        ve = subject.validation_errors(annual_report_upload).first
        ve.error_selector.should == {'term_code' => 'BAL', 'species_name' => @pair.taxon_concept.full_name}
      }
    end
  end
end
