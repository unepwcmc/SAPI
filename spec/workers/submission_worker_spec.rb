require 'spec_helper'

PENDING_REASON = "Test disabled because SubmissionWorker was disabled in 2019 (c1da775763)"

class EmailMessageStub
  def deliver
    # noop
  end
end

describe SubmissionWorker do
  before(:each) do
    genus = create_cites_eu_genus(
      :taxon_name => create(:taxon_name, :scientific_name => 'Acipenser')
    )
    @species = create_cites_eu_species(
      :taxon_name => create(:taxon_name, :scientific_name => 'baerii'),
      :parent_id => genus.id
    )
    create(:term, :code => 'CAV')
    create(:unit, :code => 'KIL')
    country = create(:geo_entity_type, :name => 'COUNTRY')
    @argentina = create(:geo_entity,
                        :geo_entity_type => country,
                        :name => 'Argentina',
                        :iso_code2 => 'AR'
                       )

    @portugal = create(:geo_entity,
                       :geo_entity_type => country,
                       :name => 'Portugal',
                       :iso_code2 => 'PT'
                      )
    @submitter = FactoryGirl.create(:user, role: User::MANAGER)
    allow(Trade::ChangelogCsvGenerator).to receive(:call).and_return(Tempfile.new('changelog.csv'))
    expect_any_instance_of(SubmissionWorker).to receive(:upload_on_S3)
    expect_any_instance_of(NotificationMailer).to receive(:mail).and_return(EmailMessageStub.new())
  end
  context "when no primary errors" do
    pending(PENDING_REASON) if PENDING_REASON

    before(:each) do
      @aru = build(:annual_report_upload, :trading_country_id => @argentina.id, :point_of_view => 'I')
      @aru.save(:validate => false)
      sandbox_klass = Trade::SandboxTemplate.ar_klass(@aru.sandbox.table_name)
      sandbox_klass.create(
        :taxon_name => 'Acipenser baerii',
        :appendix => 'II',
        :trading_partner => @portugal.iso_code2,
        :term_code => 'CAV',
        :unit_code => 'KIL',
        :year => '2010',
        :quantity => 1,
        :import_permit => 'XXX',
        :export_permit => 'AAA; BBB'
      )
      create_year_format_validation
    end
    specify {
      expect { SubmissionWorker.new.perform(@aru.id, @submitter.id) }.to change { Trade::Shipment.count }.by(1)
    }
    specify {
      expect { SubmissionWorker.new.perform(@aru.id, @submitter.id) }.to change { Trade::Permit.count }.by(3)
    }
    specify "leading space is stripped" do
      SubmissionWorker.new.perform(@aru.id, @submitter.id)
      expect(Trade::Permit.find_by_number('BBB')).not_to be_nil
    end
    context "when permit previously reported" do
      before(:each) { create(:permit, :number => 'xxx') }
      specify {
        expect { SubmissionWorker.new.perform(@aru.id, @submitter.id) }.to change { Trade::Permit.count }.by(2)
      }
    end
  end
  context "when primary errors present" do
    pending(PENDING_REASON) if PENDING_REASON

    before(:each) do
      @aru = build(:annual_report_upload)
      @aru.save(:validate => false)
      sandbox_klass = Trade::SandboxTemplate.ar_klass(@aru.sandbox.table_name)
      sandbox_klass.create(
        :taxon_name => 'Acipenser baerii',
        :appendix => 'II',
        :term_code => 'CAV',
        :unit_code => 'KIL',
        :year => '10'
      )
      create_year_format_validation
    end
    specify {
      expect { SubmissionWorker.new.perform(@aru.id, @submitter.id) }.not_to change { Trade::Shipment.count }
    }
  end
  context "when reported under a synonym" do
    pending(PENDING_REASON) if PENDING_REASON

    before(:each) do
      @synonym = create_cites_eu_species(
        :name_status => 'S',
        scientific_name: 'Acipenser stenorrhynchus'
      )
      create(:taxon_relationship,
        :taxon_relationship_type_id => synonym_relationship_type.id,
        :taxon_concept => @species,
        :other_taxon_concept => @synonym
      )
      @aru = build(:annual_report_upload, :trading_country_id => @argentina.id, :point_of_view => 'I')
      @aru.save(:validate => false)
      sandbox_klass = Trade::SandboxTemplate.ar_klass(@aru.sandbox.table_name)
      sandbox_klass.create(
        :taxon_name => 'Acipenser stenorrhynchus',
        :appendix => 'II',
        :trading_partner => @portugal.iso_code2,
        :term_code => 'CAV',
        :unit_code => 'KIL',
        :year => '2010',
        :quantity => 1,
        :import_permit => 'XXX',
        :export_permit => 'AAA;BBB'
      )
      create_year_format_validation
    end
    specify {
      expect { SubmissionWorker.new.perform(@aru.id, @submitter.id) }.to change { Trade::Shipment.count }.by(1)
    }
    specify {
      SubmissionWorker.new.perform(@aru.id, @submitter.id)
      expect(Trade::Shipment.first.taxon_concept_id).to eq(@species.id)
    }
    specify {
      SubmissionWorker.new.perform(@aru.id, @submitter.id)
      expect(Trade::Shipment.first.reported_taxon_concept_id).to eq(@synonym.id)
    }
  end
end
