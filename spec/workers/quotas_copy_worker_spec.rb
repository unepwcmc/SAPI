require 'spec_helper'

describe QuotasCopyWorker do
  let(:taxonomy) {
    create(:taxonomy,
           :name => "CITES_EU")
  }
  let(:geo_entity) {
    create(:geo_entity,
           :name_en => "Portugal")
  }
  let(:taxon_concept) {
    create(:taxon_concept,
          :taxonomy_id => taxonomy.id)
  }
  let!(:quota) {
    create(:quota,
           :start_date => 1.year.ago,
           :end_date => 1.month.ago,
           :geo_entity_id => geo_entity.id,
           :taxon_concept_id => taxon_concept.id,
           :is_current => true,
           :notes => "Le Caviar Quota Forever"
          )
  }

  let(:job_defaults) {
    {
      "from_year" => quota.start_date.year,
      "start_date" => Time.now.strftime("%d/%m/%Y"),
      "end_date" => 1.day.from_now.strftime("%d/%m/%Y"),
      "publication_date" => Time.now.strftime("%d/%m/%Y"),
      "excluded_taxon_concepts_ids" => nil,
      "included_taxon_concepts_ids" => nil,
      "excluded_geo_entities_ids" => nil,
      "included_geo_entities_ids" => nil,
      "from_text" => '',
      "to_text" => '',
      "url" => ''
    }
  }

  describe "Copy single quota, for a given year" do
    before(:each) do
      QuotasCopyWorker.new.perform(job_defaults)
    end
    specify { Quota.count(true).should == 2 }
    specify { Quota.where(:is_current => true).count(true).should == 1 }
    specify { Quota.where(:is_current => false).count(true).should == 1 }
    specify { Quota.where(:is_current => false).first.id.should == quota.id }
  end

  describe "Try to copy quota from wrong year" do
    before(:each) do
      QuotasCopyWorker.new.perform(job_defaults.merge({
        "from_year" => quota.start_date.year + 1
      }))
    end
    specify { Quota.count(true).should == 1 }
    specify { Quota.where(:is_current => true).count(true).should == 1 }
    specify { Quota.where(:is_current => false).count(true).should == 0 }
  end

  describe "Copy quota when there are no current quotas" do
    before(:each) do
      quota.is_current = false
      quota.save
      QuotasCopyWorker.new.perform(job_defaults)
    end
    specify { Quota.count(true).should == 1 }
    specify { Quota.where(:is_current => true).count(true).should == 0 }
    specify { Quota.where(:is_current => false).count(true).should == 1 }
  end

  describe "When multiple quotas copy quota for given country" do
    before(:each) do
      geo_entity2 = create(:geo_entity)
      tc2 = create(:taxon_concept,
                   :taxonomy_id => taxonomy.id)
      @quota2 = create(:quota,
             :start_date => quota.start_date,
             :end_date => quota.end_date,
             :is_current => true,
             :geo_entity_id => geo_entity2.id,
             :taxon_concept_id => tc2.id)
      QuotasCopyWorker.new.perform(job_defaults.merge({
        "included_geo_entities_ids" => [geo_entity.id]
      }))
    end
    specify { Quota.count(true).should == 3 }
    specify { Quota.where(:is_current => true).count(true).should == 2 }
    specify { Quota.where(:is_current => true).map(&:id).should include(@quota2.id) }
    specify { Quota.where(:is_current => false).count(true).should == 1 }
    specify { Quota.where(:is_current => false).first.id.should == quota.id }
  end

  describe "When multiple quotas copy quota for both countries" do
    before(:each) do
      geo_entity2 = create(:geo_entity)
      tc2 = create(:taxon_concept,
                   :taxonomy_id => taxonomy.id)
      @quota2 = create(:quota,
             :start_date => quota.start_date,
             :end_date => quota.end_date,
             :is_current => true,
             :geo_entity_id => geo_entity2.id,
             :taxon_concept_id => tc2.id)
      QuotasCopyWorker.new.perform(job_defaults.merge({
        "included_geo_entities_ids" => [geo_entity.id.to_s, geo_entity2.id.to_s]
      }))
    end
    specify { Quota.count(true).should == 4 }
    specify { Quota.where(:is_current => true).count(true).should == 2 }
    specify { Quota.where(:is_current => false).count(true).should == 2 }
    specify { Quota.where(:is_current => false).map(&:id).should include(quota.id) }
    specify { Quota.where(:is_current => false).map(&:id).should include(@quota2.id) }
  end

  describe "When multiple quotas don't copy quota for given country" do
    before(:each) do
      geo_entity2 = create(:geo_entity)
      tc2 = create(:taxon_concept,
                   :taxonomy_id => taxonomy.id)
      @quota2 = create(:quota,
             :start_date => quota.start_date,
             :end_date => quota.end_date,
             :is_current => true,
             :geo_entity_id => geo_entity2.id,
             :taxon_concept_id => tc2.id)
      QuotasCopyWorker.new.perform(job_defaults.merge({
        "excluded_geo_entities_ids" => [geo_entity2.id.to_s]
      }))
    end
    specify { Quota.count(true).should == 3 }
    specify { Quota.where(:is_current => true).count(true).should == 2 }
    specify { Quota.where(:is_current => true).map(&:id).should include(@quota2.id) }
    specify { Quota.where(:is_current => false).count(true).should == 1 }
    specify { Quota.where(:is_current => false).first.id.should == quota.id }
  end

  describe "When multiple quotas copy quota for given taxon_concept" do
    before(:each) do
      geo_entity2 = create(:geo_entity)
      tc = create(:taxon_concept)
      @quota2 = create(:quota,
             :start_date => quota.start_date,
             :end_date => quota.end_date,
             :is_current => true,
             :geo_entity_id => geo_entity2.id,
             :taxon_concept_id => tc.id)
      QuotasCopyWorker.new.perform(job_defaults.merge({
        "included_taxon_concepts_ids" => quota.taxon_concept_id.to_s
      }))
    end
    specify { Quota.count(true).should == 3 }
    specify { Quota.where(:is_current => true).count(true).should == 2 }
    specify { Quota.where(:is_current => true).map(&:id).should include(@quota2.id) }
    specify { Quota.where(:is_current => false).count(true).should == 1 }
    specify { Quota.where(:is_current => false).map(&:id).should include(quota.id) }
  end

  describe "When multiple quotas copy quota for both taxon_concepts" do
    before(:each) do
      geo_entity2 = create(:geo_entity)
      tc = create(:taxon_concept,
                 :taxonomy_id => taxonomy.id)
      @quota2 = create(:quota,
             :start_date => quota.start_date,
             :end_date => quota.end_date,
             :is_current => true,
             :geo_entity_id => geo_entity2.id,
             :taxon_concept_id => tc.id)
      QuotasCopyWorker.new.perform(job_defaults.merge({
        "included_taxon_concepts_ids" => "#{taxon_concept.id},#{tc.id}"
      }))
    end
    specify { Quota.count(true).should == 4 }
    specify { Quota.where(:is_current => true).count(true).should == 2 }
    specify { Quota.where(:is_current => true).map(&:id).should_not include(@quota2.id) }
    specify { Quota.where(:is_current => false).count(true).should == 2 }
    specify { Quota.where(:is_current => false).map(&:id).should include(quota.id) }
  end

  describe "When multiple quotas don't copy quota for given taxon_concept" do
    before(:each) do
      geo_entity2 = create(:geo_entity)
      tc = create(:taxon_concept, :taxonomy_id => taxonomy.id)
      @quota2 = create(:quota,
             :start_date => quota.start_date,
             :end_date => quota.end_date,
             :is_current => true,
             :geo_entity_id => geo_entity2.id,
             :taxon_concept_id => tc.id)
      QuotasCopyWorker.new.perform(job_defaults.merge({
        "excluded_taxon_concepts_ids" => tc.id.to_s
      }))
    end
    specify { Quota.count(true).should == 3 }
    specify { Quota.where(:is_current => true).count(true).should == 2 }
    specify { Quota.where(:is_current => true).map(&:id).should include(@quota2.id) }
    specify { Quota.where(:is_current => false).count(true).should == 1 }
    specify { Quota.where(:is_current => false).first.id.should == quota.id }
  end

  describe "When text to replace passed, should be replaced" do
    before(:each) do
      geo_entity2 = create(:geo_entity)
      tc = create(:taxon_concept, :taxonomy_id => taxonomy.id)
      @quota2 = create(:quota,
             :start_date => quota.start_date,
             :end_date => quota.end_date,
             :is_current => true,
             :geo_entity_id => geo_entity2.id,
             :taxon_concept_id => tc.id,
             :notes => "Derp di doo wildlife")
      QuotasCopyWorker.new.perform(job_defaults.merge({
        "from_text" => "Caviar Quota Forever",
        "to_text" => "Salmon is my favourite fish"
      }))

    end
    specify { Quota.count(true).should == 4 }
    specify { Quota.where(:is_current => true).count(true).should == 2 }
    specify { Quota.where(:is_current => true).map(&:id).should_not include(@quota2.id) }
    specify { Quota.where(:is_current => true).map(&:id).should_not include(quota.id) }
    specify { Quota.where(:is_current => false).count(true).should == 2 }
    specify { Quota.where(:is_current => true).map(&:notes).should include(@quota2.notes) }
    specify { Quota.where(:is_current => true).map(&:notes).should_not include(quota.notes) }
    specify { Quota.where(:is_current => true).map(&:notes).should include('Le Salmon is my favourite fish') }
  end

  describe "When url passed, should be replaced" do
    before(:each) do
      geo_entity2 = create(:geo_entity)
      tc = create(:taxon_concept, :taxonomy_id => taxonomy.id)
      @quota2 = create(:quota,
             :start_date => quota.start_date,
             :end_date => quota.end_date,
             :is_current => true,
             :geo_entity_id => geo_entity2.id,
             :taxon_concept_id => tc.id,
             :notes => "Derp di doo wildlife")
      QuotasCopyWorker.new.perform(job_defaults.merge({ "url" => 'http://myurl.co.uk' }))
    end
    specify { Quota.count(true).should == 4 }
    specify { Quota.where(:is_current => true).count(true).should == 2 }
    specify { Quota.where(:is_current => true).map(&:id).should_not include(@quota2.id) }
    specify { Quota.where(:is_current => true).map(&:id).should_not include(quota.id) }
    specify { Quota.where(:is_current => false).count(true).should == 2 }
    specify { Quota.where(:is_current => true).map(&:url).should include('http://myurl.co.uk') }
  end
end
