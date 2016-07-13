# == Schema Information
#
# Table name: trade_shipments
#
#  id                            :integer          not null, primary key
#  source_id                     :integer
#  unit_id                       :integer
#  purpose_id                    :integer
#  term_id                       :integer          not null
#  quantity                      :decimal(, )      not null
#  appendix                      :string(255)      not null
#  trade_annual_report_upload_id :integer
#  exporter_id                   :integer          not null
#  importer_id                   :integer          not null
#  country_of_origin_id          :integer
#  reported_by_exporter          :boolean          default(TRUE), not null
#  taxon_concept_id              :integer          not null
#  year                          :integer          not null
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#  sandbox_id                    :integer
#  reported_taxon_concept_id     :integer
#  import_permit_number          :text
#  export_permit_number          :text
#  origin_permit_number          :text
#  legacy_shipment_number        :integer
#  import_permits_ids            :string
#  export_permits_ids            :string
#  origin_permits_ids            :string
#  updated_by_id                 :integer
#  created_by_id                 :integer
#

require 'spec_helper'

describe Trade::Shipment do

  describe :create do
    context "when reporter_type not given" do
      subject { build(:shipment, :reporter_type => nil) }
      specify { subject.should have(2).error_on(:reporter_type) }
    end
    context "when appendix valid" do
      subject { build(:shipment, :appendix => 'N') }
      specify { subject.should be_valid }
    end
    context "when appendix not valid" do
      subject { build(:shipment, :appendix => 'I/II') }
      specify { subject.should have(1).error_on(:appendix) }
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
        specify { @shipment.export_permit_number.should == 'A' }
      end
      context "when import permit" do
        specify { @shipment.import_permit_number.should == 'B' }
      end
      context "when origin permit" do
        specify { @shipment.origin_permit_number.should == 'C' }
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
        Sapi::StoredProcedures.rebuild_cites_taxonomy_and_listings
        create_taxon_concept_appendix_year_validation
      end
      context "invalid" do
        subject {
          create(
            :shipment,
            :taxon_concept => @taxon_concept, :appendix => 'II', :year => 2013
          )
        }
        specify { subject.warnings.should_not be_empty }
      end
      context "invalid" do
        subject {
          create(
            :shipment,
            :taxon_concept => @taxon_concept, :appendix => 'N', :year => 2013
          )
        }
        specify { subject.warnings.should_not be_empty }
      end
      context "valid" do
        subject {
          create(
            :shipment,
            :taxon_concept => @taxon_concept, :appendix => 'I', :year => 2013
          )
        }
        specify { subject.warnings.should be_empty }
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
        Sapi::StoredProcedures.rebuild_cites_taxonomy_and_listings
        create_taxon_concept_appendix_year_validation
      end
      context "valid" do
        subject {
          create(
            :shipment,
            :taxon_concept => @taxon_concept, :appendix => 'N', :year => 2013
          )
        }
        specify { subject.warnings.should be_empty }
      end
    end

    context "when species name + appendix N + year" do
      before(:each) do
        @taxon_concept = create_cites_eu_species(
          :taxon_name => create(:taxon_name, :scientific_name => 'nonsignificatus'),
          :parent => @genus
        )
        reg2013 # EU event
        Sapi::StoredProcedures.rebuild_cites_taxonomy_and_listings
        create_taxon_concept_appendix_year_validation
      end
      context "not CITES listed and not EU listed" do
        subject {
          create(
            :shipment,
            :taxon_concept => @taxon_concept, :appendix => 'N', :year => 2013
          )
        }
        specify { subject.warnings.should_not be_empty }
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
        specify { subject.warnings.should_not be_empty }
      end
      context "valid" do
        subject {
          create(
            :shipment,
            :term => @cav, :unit => @kil
          )
        }
        specify { subject.warnings.should be_empty }
      end
      context "blank unit is valid" do
        subject {
          create(
            :shipment,
            :term => @cav, :unit => nil
          )
        }
        specify { subject.warnings.should be_empty }
      end
      context "blank unit is invalid" do
        subject {
          create(
            :shipment,
            :term => @cap, :unit => nil
          )
        }
        specify { subject.warnings.should_not be_empty }
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
        specify { subject.warnings.should_not be_empty }
      end
      context "valid" do
        subject {
          create(
            :shipment,
            :term => @cav, :purpose => @p
          )
        }
        specify { subject.warnings.should be_empty }
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
        specify { subject.warnings.should_not be_empty }
      end
      context "valid" do
        subject {
          create(
            :shipment,
            :taxon_concept => @taxon_concept, :term => @bal
          )
        }
        specify { subject.warnings.should be_empty }
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
        specify { subject.warnings.should_not be_empty }
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
        specify { subject.warnings.should be_empty }
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
        specify { subject.warnings.should be_empty }
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
        specify { subject.warnings.should_not be_empty }
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
        specify { subject.warnings.should be_empty }
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
        specify { subject.warnings.should be_empty }
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
        specify { subject.warnings.should_not be_empty }
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
        specify { subject.warnings.should be_empty }
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
        specify { subject.warnings.should_not be_empty }
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
        specify { subject.warnings.should be_empty }
      end
    end
    context "when species name + source code" do
      before(:each) do
        @artificial = create(:trade_code, :type => 'Source', :code => 'A', :name_en => 'Artificially propagated')
        create_taxon_concept_source_validation
        cites
        reg2013 # EU event
        Sapi::StoredProcedures.rebuild_cites_taxonomy_and_listings
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
        specify { subject.warnings.should_not be_empty }
      end
      context "valid" do
        subject {
          create(
            :shipment,
            :taxon_concept => @taxon_concept,
            :source => @wild
          )
        }
        specify { subject.warnings.should be_empty }
      end
    end
  end

end
