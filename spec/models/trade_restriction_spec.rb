# == Schema Information
#
# Table name: trade_restrictions
#
#  id                          :integer          not null, primary key
#  is_current                  :boolean          default(TRUE)
#  start_date                  :datetime
#  end_date                    :datetime
#  geo_entity_id               :integer
#  quota                       :float
#  publication_date            :datetime
#  notes                       :text
#  type                        :string(255)
#  unit_id                     :integer
#  taxon_concept_id            :integer
#  public_display              :boolean          default(TRUE)
#  url                         :text
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  start_notification_id       :integer
#  end_notification_id         :integer
#  excluded_taxon_concepts_ids :string
#  original_id                 :integer
#  updated_by_id               :integer
#  created_by_id               :integer
#  internal_notes              :text
#  nomenclature_note_en        :text
#  nomenclature_note_es        :text
#  nomenclature_note_fr        :text
#  applies_to_import           :boolean          default(FALSE), not null
#

require 'spec_helper'

describe TradeRestriction do

  context 'export trade restrictions in csv' do
    before(:all) do
      @unit = create(:unit, :code => "ABC")
      @geo_entity = create(:geo_entity)
    end
    describe 'filter_is_current' do
      before do
        @quota1 = create(:quota, :is_current => true, :unit_id => @unit.id, :geo_entity_id => @geo_entity.id)
        @quota2 = create(:quota, :is_current => false, :unit_id => @unit.id, :geo_entity_id => @geo_entity.id)
      end
      it "should return @quota1 if filter set to current" do
        result = Quota.filter_is_current("current")
        result.should == [@quota1]
      end
      it 'should return both @quota1 and @quota2 if filter set to "all"' do
        result = Quota.filter_is_current("all")
        result.should =~ [@quota1, @quota2]
      end
    end

    describe 'filter_geo_entities' do
      before do
        country_type = create(:geo_entity_type, :name => 'COUNTRY')
        @geo_entity1 = create(:geo_entity, :geo_entity_type_id => country_type.id, :iso_code2 => "LL")
        @geo_entity2 = create(:geo_entity, :geo_entity_type_id => country_type.id, :iso_code2 => "YY")
        @geo_entity3 = create(:geo_entity, :geo_entity_type_id => country_type.id, :iso_code2 => 'ZZ')
        @quota1 = create(:quota, :geo_entity_id => @geo_entity1.id, :unit_id => @unit.id)
        @quota2 = create(:quota, :geo_entity_id => @geo_entity2.id, :unit_id => @unit.id)
        @quota3 = create(:quota, :geo_entity_id => @geo_entity1.id, :unit_id => @unit.id)
        @quota4 = create(:quota, :geo_entity_id => @geo_entity3.id, :unit_id => @unit.id)
      end
      it 'should get all quotas if geo_entities filter not set' do
        result = Quota.filter_geo_entities({})
        result.should =~ [@quota1, @quota2, @quota3, @quota4]
      end
      it 'should return quota1 and quota3 if geo_entities filter set to @geo_entity1' do
        result = Quota.filter_geo_entities({ "geo_entities_ids" => [@geo_entity1.id] })
        result.should =~ [@quota1, @quota3]
      end
      it 'should return quota1, quota3, and quota4 if geo_entities filter set to @geo_entity1 and @geo_entity3' do
        result = Quota.filter_geo_entities({ "geo_entities_ids" => [@geo_entity1.id, @geo_entity3.id] })
        result.should =~ [@quota1, @quota3, @quota4]
      end
    end

    describe 'filter_years' do
      before do
        @geo_entity = create(:geo_entity)
        @quota1 = create(:quota, :start_date => "01/01/2012", :unit_id => @unit.id, :geo_entity_id => @geo_entity.id)
        @quota2 = create(:quota, :start_date => "01/02/2011", :unit_id => @unit.id, :geo_entity_id => @geo_entity.id)
        @quota3 = create(:quota, :start_date => "01/09/2012", :unit_id => @unit.id, :geo_entity_id => @geo_entity.id)
        @quota4 = create(:quota, :start_date => "01/06/2013", :unit_id => @unit.id, :geo_entity_id => @geo_entity.id)
      end
      it 'should get all quotas if years filter not set' do
        result = Quota.filter_years({})
        result.should =~ [@quota1, @quota2, @quota3, @quota4]
      end
      it 'should return quota1 and quota3 if years filter set to 2012' do
        result = Quota.filter_years({ "years" => [2012] })
        result.should =~ [@quota1, @quota3]
      end
      it 'should return quota1, quota3, and quota4 if years filter set to 2012 and 2013' do
        result = Quota.filter_years({ "years" => [2012, 2013] })
        result.should =~ [@quota1, @quota3, @quota4]
      end
    end
  end
end
