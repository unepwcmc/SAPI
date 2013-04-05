require 'spec_helper'

describe GeoEntity do
  describe :nodes_and_descendants do
    let(:contains_geo_relationship_type){
      create(:geo_relationship_type, :name => GeoRelationshipType::CONTAINS)
    }
    let(:territory_geo_entity_type){
      create(:geo_entity_type, :name => GeoEntityType::TERRITORY)
    }
    let(:country_geo_entity_type){
      create(:geo_entity_type, :name => GeoEntityType::COUNTRY)
    }
    let(:cites_region_geo_entity_type){
      create(:geo_entity_type, :name => GeoEntityType::CITES_REGION)
    }
    let(:europe){
      create(
        :geo_entity,
        :geo_entity_type => cites_region_geo_entity_type,
        :name => 'Europe'
      )
    }
    let(:poland){
      create(
        :geo_entity,
        :geo_entity_type => country_geo_entity_type,
        :name => 'Poland',
        :iso_code2 => 'PL'
      )
    }
    let(:wolin){
      create(
        :geo_entity,
        :geo_entity_type => territory_geo_entity_type,
        :name => 'Wolin'
      )
    }
    context "Europe should contain Europe, Poland and Wolin" do
      let!(:poland_contains_wolin){
        create(
          :geo_relationship,
          :geo_relationship_type => contains_geo_relationship_type,
          :geo_entity => poland,
          :related_geo_entity => wolin
        )
      }
      let!(:europe_contains_poland){
        create(
          :geo_relationship,
          :geo_relationship_type => contains_geo_relationship_type,
          :geo_entity => europe,
          :related_geo_entity => poland
        )
      }
      subject{ GeoEntity.nodes_and_descendants([europe.id]) }
      specify{ subject.map(&:id).should include(europe.id, poland.id, wolin.id) }
      specify{ subject.size.should == 3 }
    end
  end
end
