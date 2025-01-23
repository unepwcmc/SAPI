# == Schema Information
#
# Table name: trade_annual_report_uploads
#
#  id                          :integer          not null, primary key
#  auto_reminder_sent_at       :datetime
#  aws_storage_path            :string(255)
#  created_by                  :integer
#  csv_source_file             :text
#  deleted_at                  :datetime
#  epix_created_at             :datetime
#  epix_submitted_at           :datetime
#  epix_updated_at             :datetime
#  force_submit                :boolean          default(FALSE)
#  is_from_web_service         :boolean          default(FALSE)
#  number_of_records_submitted :integer
#  number_of_rows              :integer
#  point_of_view               :string(255)      default("E"), not null
#  sandbox_transferred_at      :datetime
#  submitted_at                :datetime
#  updated_by                  :integer
#  validated_at                :datetime
#  validation_report           :jsonb
#  created_at                  :datetime
#  updated_at                  :datetime
#  created_by_id               :integer
#  deleted_by_id               :integer
#  epix_created_by_id          :integer
#  epix_submitted_by_id        :integer
#  epix_updated_by_id          :integer
#  sandbox_transferred_by_id   :integer
#  submitted_by_id             :integer
#  trading_country_id          :integer          not null
#  updated_by_id               :integer
#
# Indexes
#
#  index_trade_annual_report_uploads_on_created_by          (created_by)
#  index_trade_annual_report_uploads_on_created_by_id       (created_by_id)
#  index_trade_annual_report_uploads_on_trading_country_id  (trading_country_id)
#  index_trade_annual_report_uploads_on_updated_by          (updated_by)
#  index_trade_annual_report_uploads_on_updated_by_id       (updated_by_id)
#
# Foreign Keys
#
#  trade_annual_report_uploads_created_by_fk          (created_by => users.id)
#  trade_annual_report_uploads_created_by_id_fk       (created_by_id => users.id)
#  trade_annual_report_uploads_trading_country_id_fk  (trading_country_id => geo_entities.id)
#  trade_annual_report_uploads_updated_by_fk          (updated_by => users.id)
#  trade_annual_report_uploads_updated_by_id_fk       (updated_by_id => users.id)
#

require 'spec_helper'

describe Trade::AnnualReportUpload, drops_tables: true do
  def exporter_file
    Rack::Test::UploadedFile.new(
      Rails.root.join('spec/support/annual_report_upload_exporter.csv').to_s
    )
  end

  def importer_file
    Rack::Test::UploadedFile.new(
      Rails.root.join('spec/support/annual_report_upload_importer.csv').to_s
    )
  end

  def importer_file_w_blanks
    Rack::Test::UploadedFile.new(
      Rails.root.join('spec/support/annual_report_upload_importer_blanks.csv').to_s
    )
  end

  def invalid_file
    Rack::Test::UploadedFile.new(
      Rails.root.join('spec/support/annual_report_upload_invalid.csv').to_s
    )
  end
  describe :valid? do
    context 'when uploaded file as exporter with exporter column headers' do
      subject do
        build(
          :annual_report_upload,
          point_of_view: 'E',
          csv_source_file: exporter_file
        )
      end
      specify { expect(subject).to be_valid }
    end
    context 'when uploaded file as importer with exporter column headers' do
      subject do
        build(
          :annual_report_upload,
          point_of_view: 'I',
          csv_source_file: exporter_file
        )
      end
      specify { expect(subject).not_to be_valid }
    end
    context 'when uploaded file as importer with importer column headers' do
      subject do
        build(
          :annual_report_upload,
          point_of_view: 'I',
          csv_source_file: importer_file
        )
      end
      specify { expect(subject).to be_valid }
    end
    context 'when uploaded file as exporter with importer column headers' do
      subject do
        build(
          :annual_report_upload,
          point_of_view: 'E',
          csv_source_file: importer_file
        )
      end
      specify { expect(subject).not_to be_valid }
    end
  end

  describe :validation_errors do
    let!(:format_validation_rule) do
      create_year_format_validation
    end
    subject do
      create(
        :annual_report_upload,
        point_of_view: 'I',
        csv_source_file: importer_file
      )
    end
    specify { expect(subject.validation_errors).to be_empty }
  end

  describe :create do
    before(:each) { Trade::CsvSourceFileUploader.enable_processing = true }
    context 'when blank lines in import file' do
      subject do
        create(
          :annual_report_upload,
          point_of_view: 'I',
          csv_source_file: importer_file_w_blanks
        )
      end
      specify do
        sandbox_klass = Trade::SandboxTemplate.ar_klass(subject.sandbox.table_name)
        expect(sandbox_klass.count).to eq(10)
      end
    end
  end

  describe :destroy do
    subject do
      create(
        :annual_report_upload,
        point_of_view: 'I',
        csv_source_file: importer_file
      )
    end
    specify do
      expect(subject.sandbox).to receive(:destroy)
      subject.destroy
    end
  end

  describe :submit do
    before(:each) do
      genus = create_cites_eu_genus(
        taxon_name: create(:taxon_name, scientific_name: 'Acipenser')
      )
      @species = create_cites_eu_species(
        taxon_name: create(:taxon_name, scientific_name: 'baerii'),
        parent_id: genus.id
      )
      create(:term, code: 'CAV')
      create(:unit, code: 'KIL')
      country = create(:geo_entity_type, name: 'COUNTRY')
      @argentina = create(
        :geo_entity,
        geo_entity_type: country,
        name: 'Argentina',
        iso_code2: 'AR'
      )

      @portugal = create(
        :geo_entity,
        geo_entity_type: country,
        name: 'Portugal',
        iso_code2: 'PT'
      )

      @submitter = create(:user, role: User::MANAGER)
    end
    pending 'it calls submission worker' do
      # This has been disabled due to some issues with asynchronous reports submission"
      subject do # aru no primary errors
        aru = build(:annual_report_upload, trading_country_id: @argentina.id, point_of_view: 'I')
        aru.save(validate: false)
        sandbox_klass = Trade::SandboxTemplate.ar_klass(aru.sandbox.table_name)
        sandbox_klass.create(
          taxon_name: 'Acipenser baerii',
          appendix: 'II',
          trading_partner: @portugal.iso_code2,
          term_code: 'CAV',
          unit_code: 'KIL',
          year: '2010',
          quantity: 1,
          import_permit: 'XXX',
          export_permit: 'AAA; BBB'
        )
        create_year_format_validation
        aru
      end
      specify do
        expect { subject.submit(@submitter) }.to change(SubmissionWorker.jobs, :size).by(1)
      end
    end
  end
end
