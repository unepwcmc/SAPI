require 'spec_helper'

describe Trade::Shipment do

  describe :create do
    context "when reporter_type not given" do
      subject { build(:shipment, :reporter_type => nil) }
      specify { subject.should have(2).error_on(:reporter_type) }
    end
  end

  describe "secondary validations" do


    before(:each) do
      genus = create_cites_eu_genus(
        :taxon_name => create(:taxon_name, :scientific_name => 'Foobarus')
      )
      @taxon_concept = create_cites_eu_species(
        :taxon_name => create(:taxon_name, :scientific_name => 'yolocatus'),
        :parent => genus
      )
      country = create(:geo_entity_type, :name => GeoEntityType::COUNTRY)
      @poland = create(:geo_entity,
        :name_en => 'Poland', :iso_code2 => 'PL',
        :geo_entity_type => country
      )
      @argentina = create(:geo_entity,
        :name_en => 'Argentina', :iso_code2 => 'AR',
        :geo_entity_type => country
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
        Sapi.rebuild
        create_species_name_appendix_year_validation
      end
      context "invalid" do
        subject{
          create(
            :shipment,
            :taxon_concept => @taxon_concept, :appendix => 'II', :year => 2013
          )
        }
        specify{ subject.warnings.should_not be_empty }
      end
      context "valid" do
        subject{
          create(
            :shipment,
            :taxon_concept => @taxon_concept, :appendix => 'I', :year => 2013
          )
        }
        specify{ subject.warnings.should be_empty }
      end
    end
    context "when term + unit" do
      before(:each) do
        @cav = create(:term, :code => "CAV")
        @bag = create(:unit, :code => "BAG")
        @kil = create(:unit, :code => "KIL")
        create(:term_trade_codes_pair, :term_id => @cav.id, :trade_code_id => @kil.id,
            :trade_code_type => @kil.type)
        create_term_unit_validation
      end
      context "invalid" do
        subject{
          create(
            :shipment,
            :term => @cav, :unit => @bag
          )
        }
        specify { subject.warnings.should_not be_empty }
      end
      context "valid" do
        subject{
          create(
            :shipment,
            :term => @cav, :unit => @kil
          )
        }
        specify { subject.warnings.should be_empty }
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
        subject{
          create(
            :shipment,
            :term => @cav, :purpose => @b
          )
        }
        specify { subject.warnings.should_not be_empty }
      end
      context "valid" do
        subject{
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
        create_species_name_term_validation
      end
      context "invalid" do
        subject{
          create(
            :shipment,
            :taxon_concept => @taxon_concept, :term => @cav
          )
        }
        specify { subject.warnings.should_not be_empty }
      end
      context "valid" do
        subject{
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
        create_species_name_country_of_origin_validation
      end
      context "invalid" do
        subject{
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
        subject{
          create(
            :shipment,
            :source => @wild,
            :taxon_concept => @taxon_concept,
            :country_of_origin => @argentina
          )
        }
        specify { subject.warnings.should be_empty }
      end
    end
    context "when species name + exporter" do
      before(:each) do
        create_species_name_exporter_validation
      end
      context "invalid" do
        subject{
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
        subject{
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
    end
    context "when exporter + country of origin" do
      before(:each) do
        create_exporter_country_of_origin_validation
      end
      context "invalid" do
        subject{
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
        subject{
          create(
            :shipment,
            :taxon_concept => @taxon_concept,
            :exporter => @poland,
            :country_of_origin => @argentina
          )
        }
        specify { puts subject.warnings.inspect; subject.warnings.should be_empty }
      end
    end
    context "when exporter + importer" do
      before(:each) do
        create_exporter_importer_validation
      end
      context "invalid" do
        subject{
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
        subject{
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
        @wild = create(:trade_code, :type => 'Source', :code => 'A', :name_en => 'Artificially propagated')
        create_taxon_concept_source_validation
      end
      context "invalid" do
        subject{
          create(
            :shipment,
            :taxon_concept => @taxon_concept,
            :source => @artificial
          )
        }
        specify { subject.warnings.should_not be_empty }
      end
      context "valid" do
        subject{
          create(
            :shipment,
            :taxon_concept => @taxon_concept,
            :taxon_concept => @taxon_concept,
            :source => @wild
          )
        }
        specify { subject.warnings.should be_empty }
      end
    end
  end

end