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
  let(:canada) {
    create(
      :geo_entity,
      :geo_entity_type => country_geo_entity_type,
      :name => 'Canada',
      :iso_code2 => 'CA'
    )
  }
  let(:argentina) {
    create(
      :geo_entity,
      :geo_entity_type => country_geo_entity_type,
      :name => 'Argentina',
      :iso_code2 => 'AR'
    )
  }
  let(:xx) {
    create(
      :geo_entity,
      :geo_entity_type => trade_geo_entity_type,
      :name => 'Unknown',
      :iso_code2 => 'XX'
    )
  }
  before(:each) do
    genus = create_cites_eu_genus(
      :taxon_name => create(:taxon_name, :scientific_name => 'Pecari')
    )
    @species = create_cites_eu_species(
      :taxon_name => create(:taxon_name, :scientific_name => 'Tajacu'),
      :parent => genus
    )
    create(
      :distribution,
      :taxon_concept => @species,
      :geo_entity => argentina
    )
  end
  describe :validation_errors_for_aru do
    context "when W source and country of origin blank and exporter doesn't match distribution (E)" do
      before(:each) do
        @aru = build(:annual_report_upload, :point_of_view => 'E', :trading_country_id => canada.id)
        @aru.save(:validate => false)
        sandbox_klass = Trade::SandboxTemplate.ar_klass(@aru.sandbox.table_name)
        sandbox_klass.create(
          :taxon_name => 'Pecari tajacu', :source_code => 'W', :country_of_origin => nil
        )
        sandbox_klass.create(
          :taxon_name => 'Pecari tajacu', :source_code => 'W', :country_of_origin => argentina.iso_code2
        )
      end
      subject {
        create_taxon_concept_exporter_validation
      }
      specify {
        subject.refresh_errors_if_needed(@aru)
        subject.validation_errors_for_aru(@aru).size.should == 1
      }
    end
    context "when W source and country of origin blank and exporter doesn't match distribution (I)" do
      before(:each) do
        @aru = build(:annual_report_upload, :point_of_view => 'I', :trading_country_id => argentina.id)
        @aru.save(:validate => false)
        sandbox_klass = Trade::SandboxTemplate.ar_klass(@aru.sandbox.table_name)
        sandbox_klass.create(
          :taxon_name => 'Pecari tajacu', :source_code => 'W',
          :trading_partner => canada.iso_code2, :country_of_origin => nil
        )
        sandbox_klass.create(
          :taxon_name => 'Pecari tajacu', :source_code => 'W',
          :trading_partner => canada.iso_code2,
          :country_of_origin => argentina.iso_code2
        )
      end
      subject {
        create_taxon_concept_exporter_validation
      }
      specify {
        subject.refresh_errors_if_needed(@aru)
        subject.validation_errors_for_aru(@aru).size.should == 1
      }
    end
    context "when W source and country XX" do
      before(:each) do
        @aru = build(:annual_report_upload, :point_of_view => 'I', :trading_country_id => argentina.id)
        @aru.save(:validate => false)
        sandbox_klass = Trade::SandboxTemplate.ar_klass(@aru.sandbox.table_name)
        sandbox_klass.create(
          :taxon_name => 'Pecari tajacu', :source_code => 'W',
          :trading_partner => xx.iso_code2, :country_of_origin => nil
        )
        sandbox_klass.create(
          :taxon_name => 'Pecari tajacu', :source_code => 'W',
          :trading_partner => xx.iso_code2,
          :country_of_origin => argentina.iso_code2
        )
      end
      subject {
        create_taxon_concept_exporter_validation
      }
      specify {
        subject.refresh_errors_if_needed(@aru)
        subject.validation_errors_for_aru(@aru).should be_empty
      }
    end
    context "when W source and country doesn't match distribution of higher taxa" do
      before(:each) do
        @aru = build(:annual_report_upload, :point_of_view => 'I', :trading_country_id => argentina.id)
        @aru.save(:validate => false)
        sandbox_klass = Trade::SandboxTemplate.ar_klass(@aru.sandbox.table_name)
        sandbox_klass.create(
          :taxon_name => 'Pecari', :source_code => 'W',
          :trading_partner => canada.iso_code2, :country_of_origin => nil
        )
        sandbox_klass.create(
          :taxon_name => 'Pecari', :source_code => 'W',
          :trading_partner => canada.iso_code2,
          :country_of_origin => canada.iso_code2
        )
      end
      subject {
        create_taxon_concept_exporter_validation
      }
      specify {
        subject.refresh_errors_if_needed(@aru)
        subject.validation_errors_for_aru(@aru).should be_empty
      }
    end
    context "when invalid scope specified" do
      before(:each) do
        @aru = build(:annual_report_upload, :point_of_view => 'E', :trading_country_id => canada.id)
        @aru.save(:validate => false)
        sandbox_klass = Trade::SandboxTemplate.ar_klass(@aru.sandbox.table_name)
        sandbox_klass.create(
          :taxon_name => 'Pecari tajacu', :source_code => 'W', :country_of_origin => argentina.iso_code2
        )
      end
      subject {
        create_taxon_concept_exporter_validation
      }
      specify {
        expect { subject.validation_errors_for_aru(@aru) }.to_not raise_error
      }
    end
  end
end
