# == Schema Information
#
# Table name: trade_shipments
#
#  id                            :integer          not null, primary key
#  appendix                      :string(255)      not null
#  epix_created_at               :datetime
#  epix_updated_at               :datetime
#  export_permit_number          :text
#  export_permits_ids            :integer          is an Array
#  import_permit_number          :text
#  import_permits_ids            :integer          is an Array
#  legacy_shipment_number        :integer
#  origin_permit_number          :text
#  origin_permits_ids            :integer          is an Array
#  quantity                      :decimal(, )      not null
#  reported_by_exporter          :boolean          default(TRUE), not null
#  year                          :integer          not null
#  created_at                    :datetime
#  updated_at                    :datetime
#  country_of_origin_id          :integer
#  created_by_id                 :integer
#  epix_created_by_id            :integer
#  epix_updated_by_id            :integer
#  exporter_id                   :integer          not null
#  importer_id                   :integer          not null
#  purpose_id                    :integer
#  reported_taxon_concept_id     :integer
#  sandbox_id                    :integer
#  source_id                     :integer
#  taxon_concept_id              :integer          not null
#  term_id                       :integer          not null
#  trade_annual_report_upload_id :integer
#  unit_id                       :integer
#  updated_by_id                 :integer
#
# Indexes
#
#  index_trade_shipments_on_appendix                         (appendix)
#  index_trade_shipments_on_country_of_origin_id             (country_of_origin_id)
#  index_trade_shipments_on_created_by_id_and_updated_by_id  (created_by_id,updated_by_id)
#  index_trade_shipments_on_export_permits_ids               (export_permits_ids) USING gin
#  index_trade_shipments_on_exporter_id                      (exporter_id)
#  index_trade_shipments_on_import_permits_ids               (import_permits_ids) USING gin
#  index_trade_shipments_on_importer_id                      (importer_id)
#  index_trade_shipments_on_origin_permits_ids               (origin_permits_ids) USING gin
#  index_trade_shipments_on_purpose_id                       (purpose_id)
#  index_trade_shipments_on_quantity                         (quantity)
#  index_trade_shipments_on_reported_taxon_concept_id        (reported_taxon_concept_id)
#  index_trade_shipments_on_sandbox_id                       (sandbox_id)
#  index_trade_shipments_on_source_id                        (source_id)
#  index_trade_shipments_on_taxon_concept_id                 (taxon_concept_id)
#  index_trade_shipments_on_term_id                          (term_id)
#  index_trade_shipments_on_unit_id                          (unit_id)
#  index_trade_shipments_on_year                             (year)
#  index_trade_shipments_on_year_exporter_id                 (year,exporter_id)
#  index_trade_shipments_on_year_importer_id                 (year,importer_id)
#
# Foreign Keys
#
#  trade_shipments_country_of_origin_id_fk           (country_of_origin_id => geo_entities.id)
#  trade_shipments_created_by_id_fk                  (created_by_id => users.id)
#  trade_shipments_exporter_id_fk                    (exporter_id => geo_entities.id)
#  trade_shipments_importer_id_fk                    (importer_id => geo_entities.id)
#  trade_shipments_purpose_id_fk                     (purpose_id => trade_codes.id)
#  trade_shipments_reported_taxon_concept_id_fk      (reported_taxon_concept_id => taxon_concepts.id)
#  trade_shipments_source_id_fk                      (source_id => trade_codes.id)
#  trade_shipments_taxon_concept_id_fk               (taxon_concept_id => taxon_concepts.id)
#  trade_shipments_term_id_fk                        (term_id => trade_codes.id)
#  trade_shipments_trade_annual_report_upload_id_fk  (trade_annual_report_upload_id => trade_annual_report_uploads.id)
#  trade_shipments_unit_id_fk                        (unit_id => trade_codes.id)
#  trade_shipments_updated_by_id_fk                  (updated_by_id => users.id)
#

require 'spec_helper'

describe Trade::Shipment do

  describe :create do
    context "when reporter_type not given" do
      subject { build(:shipment, :reporter_type => nil) }
      specify { expect(subject.error_on(:reporter_type).size).to eq(2) }
    end
    context "when appendix valid" do
      subject { build(:shipment, :appendix => 'N') }
      specify { expect(subject).to be_valid }
    end
    context "when appendix not valid" do
      subject { build(:shipment, :appendix => 'I/II') }
      specify { expect(subject.error_on(:appendix).size).to eq(1) }
    end
    context "when permit numbers given" do
      before(:each) do
        @shipment = create(:shipment,
          :export_permit_number => 'a',
          :import_permit_number => 'b',
          :origin_permit_number => 'c'
        )
      end
      context "when export permit" do
        specify { expect(@shipment.export_permit_number).to eq('A') }
      end
      context "when import permit" do
        specify { expect(@shipment.import_permit_number).to eq('B') }
      end
      context "when origin permit" do
        specify { expect(@shipment.origin_permit_number).to eq('C') }
      end
    end
  end

  describe "secondary validations" do

    before(:each) do
      # an animal
      @genus = create_cites_eu_genus(
        :taxon_name => create(:taxon_name, :scientific_name => 'Foobarus'),
        :parent => create_cites_eu_family(
          :parent => create_cites_eu_order(
            :parent => cites_eu_amphibia
          )
        )
      )
      @taxon_concept = create_cites_eu_species(
        :taxon_name => create(:taxon_name, :scientific_name => 'yolocatus'),
        :parent => @genus
      )
      @poland = create(:geo_entity,
        :name_en => 'Poland', :iso_code2 => 'PL',
        :geo_entity_type => country_geo_entity_type
      )
      @argentina = create(:geo_entity,
        :name_en => 'Argentina', :iso_code2 => 'AR',
        :geo_entity_type => country_geo_entity_type
      )
      @xx = create(
        :geo_entity,
        :geo_entity_type => trade_geo_entity_type,
        :name => 'Unknown',
        :iso_code2 => 'XX'
      )
      create(:distribution, :taxon_concept => @taxon_concept, :geo_entity => @argentina)
      @wild = create(:trade_code, :type => 'Source', :code => 'W', :name_en => 'Wild')
    end

    context "when species name + appendix + year" do
      before(:each) do
        create_cites_I_addition(
          :taxon_concept => @taxon_concept,
          :effective_at => '2013-01-01',
          :is_current => true
        )
        reg2013 # EU event
        SapiModule::StoredProcedures.rebuild_cites_taxonomy_and_listings
        create_taxon_concept_appendix_year_validation
      end
      context "invalid" do
        subject {
          create(
            :shipment,
            :taxon_concept => @taxon_concept, :appendix => 'II', :year => 2013
          )
        }
        specify { expect(subject.warnings).not_to be_empty }
      end
      context "invalid" do
        subject {
          create(
            :shipment,
            :taxon_concept => @taxon_concept, :appendix => 'N', :year => 2013
          )
        }
        specify { expect(subject.warnings).not_to be_empty }
      end
      context "valid" do
        subject {
          create(
            :shipment,
            :taxon_concept => @taxon_concept, :appendix => 'I', :year => 2013
          )
        }
        specify { expect(subject.warnings).to be_empty }
      end
    end

    context "when species name + appendix N + year" do
      before(:each) do
        create_eu_B_addition(
          :taxon_concept => @taxon_concept,
          :effective_at => '2013-01-01',
          :event => reg2013,
          :is_current => true
        )
        SapiModule::StoredProcedures.rebuild_cites_taxonomy_and_listings
        create_taxon_concept_appendix_year_validation
      end
      context "valid" do
        subject {
          create(
            :shipment,
            :taxon_concept => @taxon_concept, :appendix => 'N', :year => 2013
          )
        }
        specify { expect(subject.warnings).to be_empty }
      end
    end

    context "when species name + appendix N + year" do
      before(:each) do
        @taxon_concept = create_cites_eu_species(
          :taxon_name => create(:taxon_name, :scientific_name => 'nonsignificatus'),
          :parent => @genus
        )
        reg2013 # EU event
        SapiModule::StoredProcedures.rebuild_cites_taxonomy_and_listings
        create_taxon_concept_appendix_year_validation
      end
      context "not CITES listed and not EU listed" do
        subject {
          create(
            :shipment,
            :taxon_concept => @taxon_concept, :appendix => 'N', :year => 2013
          )
        }
        specify { expect(subject.warnings).not_to be_empty }
      end
    end

    context "when term + unit" do
      before(:each) do
        @cav = create(:term, :code => "CAV")
        @cap = create(:term, :code => "CAP")
        @bag = create(:unit, :code => "BAG")
        @kil = create(:unit, :code => "KIL")
        create(:term_trade_codes_pair, :term_id => @cav.id, :trade_code_id => @kil.id,
            :trade_code_type => @kil.type)
        create(:term_trade_codes_pair, :term_id => @cav.id, :trade_code_id => nil,
            :trade_code_type => @kil.type)
        create(:term_trade_codes_pair, :term_id => @cap.id, :trade_code_id => @kil.id,
            :trade_code_type => @kil.type)
        create_term_unit_validation
      end
      context "invalid" do
        subject {
          create(
            :shipment,
            :term => @cav, :unit => @bag
          )
        }
        specify { expect(subject.warnings).not_to be_empty }
      end
      context "valid" do
        subject {
          create(
            :shipment,
            :term => @cav, :unit => @kil
          )
        }
        specify { expect(subject.warnings).to be_empty }
      end
      context "blank unit is valid" do
        subject {
          create(
            :shipment,
            :term => @cav, :unit => nil
          )
        }
        specify { expect(subject.warnings).to be_empty }
      end
      context "blank unit is invalid" do
        subject {
          create(
            :shipment,
            :term => @cap, :unit => nil
          )
        }
        specify { expect(subject.warnings).not_to be_empty }
      end
    end
    context "when term + purpose" do
      before(:each) do
        @cav = create(:term, :code => "CAV")
        @b = create(:purpose, :code => "B")
        @p = create(:purpose, :code => "P")
        create(:term_trade_codes_pair, :term_id => @cav.id, :trade_code_id => @p.id,
          :trade_code_type => @p.type)
        create_term_purpose_validation
      end
      context "invalid" do
        subject {
          create(
            :shipment,
            :term => @cav, :purpose => @b
          )
        }
        specify { expect(subject.warnings).not_to be_empty }
      end
      context "valid" do
        subject {
          create(
            :shipment,
            :term => @cav, :purpose => @p
          )
        }
        specify { expect(subject.warnings).to be_empty }
      end
    end
    context "when species name + term" do
      before(:each) do
        @cav = create(:term, :code => "CAV")
        @bal = create(:term, :code => "BAL")
        create(:trade_taxon_concept_term_pair,
          :taxon_concept_id => @taxon_concept.id, :term_id => @bal.id
        )
        create_taxon_concept_term_validation
      end
      context "invalid" do
        subject {
          create(
            :shipment,
            :taxon_concept => @taxon_concept, :term => @cav
          )
        }
        specify { expect(subject.warnings).not_to be_empty }
      end
      context "valid" do
        subject {
          create(
            :shipment,
            :taxon_concept => @taxon_concept, :term => @bal
          )
        }
        specify { expect(subject.warnings).to be_empty }
      end
    end
    context "when species name + country of origin" do
      before(:each) do
        create_taxon_concept_country_of_origin_validation
      end
      context "invalid" do
        subject {
          create(
            :shipment,
            :source => @wild,
            :taxon_concept => @taxon_concept,
            :country_of_origin => @poland
          )
        }
        specify { expect(subject.warnings).not_to be_empty }
      end
      context "valid" do
        subject {
          create(
            :shipment,
            :source => @wild,
            :taxon_concept => @taxon_concept,
            :country_of_origin => @argentina
          )
        }
        specify { expect(subject.warnings).to be_empty }
      end
      context "blank" do
        subject {
          create(
            :shipment,
            :source => @wild,
            :taxon_concept => @taxon_concept,
            :country_of_origin => nil
          )
        }
        specify { expect(subject.warnings).to be_empty }
      end
    end
    context "when species name + exporter" do
      before(:each) do
        create_taxon_concept_exporter_validation
      end
      context "invalid" do
        subject {
          create(
            :shipment,
            :source => @wild,
            :taxon_concept => @taxon_concept,
            :country_of_origin => nil,
            :exporter => @poland
          )
        }
        specify { expect(subject.warnings).not_to be_empty }
      end
      context "valid" do
        subject {
          create(
            :shipment,
            :source => @wild,
            :taxon_concept => @taxon_concept,
            :country_of_origin => nil,
            :exporter => @argentina
          )
        }
        specify { expect(subject.warnings).to be_empty }
      end
      context "valid with XX" do
        subject {
          create(
            :shipment,
            :source => @wild,
            :taxon_concept => @taxon_concept,
            :country_of_origin => nil,
            :exporter => @xx
          )
        }
        specify { expect(subject.warnings).to be_empty }
      end
    end
    context "when exporter + country of origin" do
      before(:each) do
        create_exporter_country_of_origin_validation
      end
      context "invalid" do
        subject {
          create(
            :shipment,
            :taxon_concept => @taxon_concept,
            :exporter => @argentina,
            :country_of_origin => @argentina
          )
        }
        specify { expect(subject.warnings).not_to be_empty }
      end
      context "valid" do
        subject {
          create(
            :shipment,
            :taxon_concept => @taxon_concept,
            :exporter => @poland,
            :country_of_origin => @argentina
          )
        }
        specify { expect(subject.warnings).to be_empty }
      end
    end
    context "when exporter + importer" do
      before(:each) do
        create_exporter_importer_validation
      end
      context "invalid" do
        subject {
          create(
            :shipment,
            :taxon_concept => @taxon_concept,
            :importer => @argentina,
            :exporter => @argentina
          )
        }
        specify { expect(subject.warnings).not_to be_empty }
      end
      context "valid" do
        subject {
          create(
            :shipment,
            :taxon_concept => @taxon_concept,
            :importer => @poland,
            :exporter => @argentina
          )
        }
        specify { expect(subject.warnings).to be_empty }
      end
    end
    context "when species name + source code" do
      before(:each) do
        @artificial = create(:trade_code, :type => 'Source', :code => 'A', :name_en => 'Artificially propagated')
        create_taxon_concept_source_validation
        cites
        reg2013 # EU event
        SapiModule::StoredProcedures.rebuild_cites_taxonomy_and_listings
        @taxon_concept.reload
      end
      context "invalid" do
        subject {
          create(
            :shipment,
            :taxon_concept => @taxon_concept,
            :source => @artificial
          )
        }
        specify { expect(subject.warnings).not_to be_empty }
      end
      context "valid" do
        subject {
          create(
            :shipment,
            :taxon_concept => @taxon_concept,
            :source => @wild
          )
        }
        specify { expect(subject.warnings).to be_empty }
      end
    end
  end

end
