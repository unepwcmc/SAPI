require 'spec_helper'

describe Trade::Sandbox do
    def importer_file
      Rack::Test::UploadedFile.new(
        File.join(Rails.root, 'spec', 'support', 'annual_report_upload_importer.csv')
      )
    end
    let(:annual_report_upload){
      genus = create_cites_eu_genus(:taxon_name => create(:taxon_name, :scientific_name => 'Acipenser'))
      create_cites_eu_species(:taxon_name => create(:taxon_name, :scientific_name => 'baerii'), :parent_id => genus.id)
      create(
        :annual_report_upload,
        :point_of_view => 'I',
        :csv_source_file => importer_file
      )
    }
    describe :destroy do
      subject { annual_report_upload.sandbox }
      specify {
        table_name = subject.table_name; subject.destroy
        Trade::SandboxTemplate.select('*').from(table_name).should raise_exception
      }
    end

    describe :submit_shipments do
      subject { annual_report_upload.sandbox }
      specify {
        subject.submit_shipments
        Trade::SandboxTemplate.ar_klass(subject.table_name).count.should == Trade::Shipment.count
      }
    end
end
