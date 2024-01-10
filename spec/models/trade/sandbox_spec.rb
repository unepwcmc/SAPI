require 'spec_helper'

describe Trade::Sandbox, :drops_tables => true do
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
  end
  let(:annual_report_upload) {
    aru = build(:annual_report_upload, :trading_country_id => @argentina.id, :point_of_view => 'I')
    aru.save(:validate => false)
    sandbox_klass = Trade::SandboxTemplate.ar_klass(aru.sandbox.table_name)
    sandbox_klass.create(
      :taxon_name => 'Acipenser baerii',
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
    aru
  }
  describe :destroy do
    subject { annual_report_upload.sandbox }
    specify {
      sandbox_klass = Trade::SandboxTemplate.ar_klass(subject.table_name)
      subject.destroy
      ActiveRecord::Base.connection.table_exists?('trade_sandbox_1').should be_falsey
    }
  end

end
