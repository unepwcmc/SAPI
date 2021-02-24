# == Schema Information
#
# Table name: geo_entities
#
#  id                 :integer          not null, primary key
#  geo_entity_type_id :integer          not null
#  name_en            :string(255)      not null
#  long_name          :string(255)
#  iso_code2          :string(255)
#  iso_code3          :string(255)
#  legacy_id          :integer
#  legacy_type        :string(255)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  is_current         :boolean          default(TRUE)
#  name_fr            :string(255)
#  name_es            :string(255)
#

require 'spec_helper'

describe GeoEntity do
  describe :nodes_and_descendants do
    let(:europe) {
      create(
        :geo_entity,
        :geo_entity_type => cites_region_geo_entity_type,
        :name => 'Europe'
      )
    }
    let(:poland) {
      create(
        :geo_entity,
        :geo_entity_type => country_geo_entity_type,
        :name => 'Poland',
        :iso_code2 => 'PL'
      )
    }
    let(:wolin) {
      create(
        :geo_entity,
        :geo_entity_type => territory_geo_entity_type,
        :name => 'Wolin'
      )
    }
    context "Europe should contain Europe, Poland and Wolin" do
      let!(:poland_contains_wolin) {
        create(
          :geo_relationship,
          :geo_relationship_type => contains_geo_relationship_type,
          :geo_entity => poland,
          :related_geo_entity => wolin
        )
      }
      let!(:europe_contains_poland) {
        create(
          :geo_relationship,
          :geo_relationship_type => contains_geo_relationship_type,
          :geo_entity => europe,
          :related_geo_entity => poland
        )
      }
      subject { GeoEntity.nodes_and_descendants([europe.id]) }
      specify { subject.map(&:id).should include(europe.id, poland.id, wolin.id) }
      specify { subject.size.should == 3 }
    end
  end
  describe :destroy do
    let(:geo_entity) { create(:geo_entity) }
    context "when no dependent objects attached" do
      specify { geo_entity.destroy.should be_truthy }
    end
    context "when dependent objects attached" do
      context "when distributions" do
        before(:each) { create(:distribution, :geo_entity => geo_entity) }
        specify { geo_entity.destroy.should be_falsey }
      end
      context "when exported shipments" do
        before(:each) { create(:shipment, :exporter => geo_entity) }
        specify { geo_entity.destroy.should be_falsey }
      end
      context "when imported shipments" do
        before(:each) { create(:shipment, :importer => geo_entity) }
        specify { geo_entity.destroy.should be_falsey }
      end
      context "when originated shipments" do
        before(:each) { create(:shipment, :country_of_origin => geo_entity) }
        specify { geo_entity.destroy.should be_falsey }
      end
      context "when connected geo entities" do
        let(:child_geo_entity) { create(:geo_entity) }
        before(:each) do
          create(
            :geo_relationship,
            :geo_relationship_type => contains_geo_relationship_type,
            :geo_entity => geo_entity,
            :related_geo_entity => child_geo_entity
          )
        end
        specify { geo_entity.destroy.should be_falsey }
      end
    end
  end
end
