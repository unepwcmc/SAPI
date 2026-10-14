require 'spec_helper'
# caxlsx is require: false - it exists to build .xlsx fixtures, nothing else.
require 'axlsx'

describe Importers::DesignationGeoEntitiesImporter do
  let(:headers) { 'id,iso_code2,name_en,name,is_current,cites,cms' }

  let!(:angola) { geo_entity('Angola', 'AO', GeoEntityType::COUNTRY) }
  let!(:namibia) { geo_entity('Namibia', 'NA', GeoEntityType::COUNTRY) }
  let!(:europe) { geo_entity('Europe', nil, GeoEntityType::REGION) }

  # The three designations this application holds, CITES and EU sharing a
  # taxonomy as they do in production.
  before do
    cites
    eu
    cms_designation
  end

  def geo_entity(name_en, iso_code2, type)
    create(
      :geo_entity, name_en:, iso_code2:,
      geo_entity_type: GeoEntityType.find_by(name: type) || create(:geo_entity_type, name: type)
    )
  end

  def rows_for(*geo_entities_with_values)
    geo_entities_with_values.map do |geo_entity, *values|
      [
        geo_entity.id, geo_entity.iso_code2, geo_entity.name_en, geo_entity.geo_entity_type.name, 't', *values
      ].join(',')
    end.join("\n")
  end

  def import(body, header_row = headers, extension: '.csv', &run)
    run ||= ->(file_path) { described_class.import_all!(file_path:) }
    # Binary, so a test can write a byte that is not valid UTF-8.
    file = Tempfile.new([ 'designation_geo_entities', extension ], binmode: true)
    file.write("#{header_row}\n#{body}\n")
    file.close
    run.call(file.path)
  ensure
    file&.unlink
  end

  # One importer on its own, without import_all! reading the headers for it.
  def import_one(designation, body, header_row = headers)
    import(body, header_row) { |file_path| described_class.new(file_path:, designation:).import! }
  end

  def import_xlsx(rows)
    file = Tempfile.new([ 'designation_geo_entities', '.xlsx' ])
    file.close
    Axlsx::Package.new do |package|
      package.workbook.add_worksheet(name: 'Sheet1') do |sheet|
        rows.each { |row| sheet.add_row row }
      end
    end.serialize(file.path)
    described_class.import_all!(file_path: file.path)
  ensure
    file&.unlink
  end

  def party(designation, geo_entity)
    DesignationGeoEntity.create!(designation:, geo_entity:)
  end

  def memberships
    DesignationGeoEntity.joins(:designation).pluck('designations.name', :geo_entity_id)
  end

  it 'writes a row for every t, in every designation the file has a column for' do
    import(rows_for([ angola, 't', 't' ], [ namibia, 't', 'f' ], [ europe, 'f', 'f' ]))

    expect(memberships).to contain_exactly(
      [ 'CITES', angola.id ], [ 'CITES', namibia.id ], [ 'CMS', angola.id ]
    )
  end

  it 'removes a Party the file now says is not one, or does not mention' do
    party(cites, angola)
    party(cites, europe)

    import(rows_for([ angola, 'f', 'f' ], [ namibia, 't', 'f' ]))

    expect(memberships).to contain_exactly([ 'CITES', namibia.id ])
  end

  it 'keeps the row of a Party it lists again, rather than replacing it' do
    existing = party(cites, angola)

    import(rows_for([ angola, 't', 'f' ]))

    expect(DesignationGeoEntity.pluck(:id)).to eq [ existing.id ]
  end

  it 'leaves a designation with no column exactly as it is' do
    party(eu, angola)

    import(rows_for([ namibia, 't', 'f' ]))

    expect(memberships).to contain_exactly([ 'EU', angola.id ], [ 'CITES', namibia.id ])
  end

  it 'reports which designations it imported and which it left alone' do
    result = import(rows_for([ namibia, 't', 't' ]))

    expect(
      importers: result[:importers].map { |importer| importer.designation.name },
      untouched: result[:untouched].map(&:name)
    ).to eq(importers: %w[CITES CMS], untouched: %w[EU])
  end

  it 'reads a column whatever the spreadsheet made of t and f' do
    import(rows_for([ angola, 'TRUE', 'FALSE' ], [ namibia, ' Yes ', 'no' ]))

    expect(memberships).to contain_exactly([ 'CITES', angola.id ], [ 'CITES', namibia.id ])
  end

  it 'matches a blank ISO code to a geo entity without one' do
    import(rows_for([ europe, 't', 'f' ]))

    expect(memberships).to eq [ [ 'CITES', europe.id ] ]
  end

  it 'reads a .tsv' do
    import(rows_for([ angola, 't', 'f' ]).tr(',', "\t"), headers.tr(',', "\t"), extension: '.tsv')

    expect(memberships).to eq [ [ 'CITES', angola.id ] ]
  end

  it 'reads an .xlsx' do
    import_xlsx(
      [
        headers.split(','),
        [ angola.id, angola.iso_code2, angola.name_en, 'COUNTRY', 't', 'f', 't' ],
        [ europe.id, nil, europe.name_en, 'REGION', 't', 't', 'f' ]
      ]
    )

    expect(memberships).to contain_exactly([ 'CMS', angola.id ], [ 'CITES', europe.id ])
  end

  # How many times a CSV parser checks the whole file while the block runs.
  def count_validations
    validations = 0
    allow(Importer::Parsers::Csv).to receive(:new).and_wrap_original do |new_parser, **options|
      new_parser.call(**options).tap do |parser|
        allow(parser).to receive(:validate_file!).and_wrap_original { |validate| validate.call.tap { validations += 1 } }
      end
    end
    yield
    validations
  end

  it 'validates the file once, however many designations it imports' do
    expect(count_validations { import(rows_for([ angola, 't', 't' ])) }).to eq 1
  end

  describe 'the cached geo entity search' do
    before { allow(GeoEntitySearch).to receive(:increment_cache_iterator) }

    it 'is cleared once the import has committed' do
      import(rows_for([ angola, 't', 't' ]))

      expect(GeoEntitySearch).to have_received(:increment_cache_iterator).at_least(:once)
    end

    context 'when the file is refused' do
      # That `maybe` is refused is covered under 'refusing the file'.
      before do
        import(rows_for([ angola, 't', 'maybe' ]))
      rescue Importer::Base::ImportError
        nil
      end

      it 'is left alone' do
        expect(GeoEntitySearch).not_to have_received(:increment_cache_iterator)
      end
    end
  end

  describe 'one importer run on its own' do
    it 'reads the headers itself' do
      import_one(cms_designation, rows_for([ angola, 't', 't' ]))

      expect(memberships).to eq [ [ 'CMS', angola.id ] ]
    end

    it 'refuses a file with no column for its designation' do
      expect { import_one(eu, rows_for([ angola, 't', 't' ])) }
        .to raise_error(Importer::Base::ImportError, /Missing required headers: eu/)
    end

    it 'refuses a file repeating its column' do
      expect { import_one(cites, rows_for([ angola, 't', 't' ]), 'id,iso_code2,name_en,name,is_current,cites,cites') }
        .to raise_error(Importer::Base::ImportError, /Duplicate header\(s\) in file: cites/)
    end

    it 'refuses a file that is not valid UTF-8' do
      expect { import_one(cites, "#{rows_for([ angola, 't', 't' ])}\n\xFF".b) }
        .to raise_error(Importer::Base::ImportError, /UTF-8/i)
    end
  end

  describe 'refusing the file' do
    before { party(cites, angola) }

    def expect_refused(body, message, header_row = headers, extension: '.csv')
      expect { import(body, header_row, extension:) }.to raise_error(Importer::Base::ImportError, message)
      expect(memberships).to eq [ [ 'CITES', angola.id ] ]
    end

    it 'when no column names a designation' do
      expect_refused(
        rows_for([ namibia, 't' ]), /no column for any designation/, 'id,iso_code2,name_en,name,is_current,ramsar'
      )
    end

    it 'when a header is repeated' do
      expect_refused(
        rows_for([ namibia, 't', 't' ]), /Duplicate header\(s\) in file: cites/, 'id,iso_code2,name_en,name,is_current,cites,cites'
      )
    end

    it 'when a column the check needs is missing' do
      expect_refused("#{namibia.id},NA,Namibia,t,t", /Missing required headers: name$/, 'id,iso_code2,name_en,is_current,cites')
    end

    it 'when the rest of a row describes another geo entity than its id' do
      expect_refused(
        "#{namibia.id},NA,Angola,COUNTRY,t,t,t", /geo entity #{namibia.id} is Namibia \(NA, COUNTRY\), but the file says Angola/
      )
    end

    it 'when it is not valid UTF-8' do
      expect_refused("#{rows_for([ namibia, 't', 't' ])}\n\xFF".b, /UTF-8/i)
    end

    it 'when it has no rows' do
      expect_refused('', /no rows/)
    end

    it 'when it is in a format the importer does not read' do
      expect_refused(rows_for([ namibia, 't', 't' ]), /must have one of these extensions/, headers, extension: '.txt')
    end

    it 'when an id names no geo entity' do
      expect_refused('0,ZZ,Nowhere,COUNTRY,t,t,t', /no geo entity with id 0/)
    end

    it 'when a geo entity appears twice' do
      expect_refused(rows_for([ namibia, 't', 't' ], [ namibia, 'f', 'f' ]), /appears more than once/)
    end

    it 'when a value is neither yes nor no' do
      expect_refused(rows_for([ namibia, '', 't' ]), /not a yes\/no value: ""/)
    end

    it 'when the problem is in a later designation, leaving the earlier one untouched as well' do
      expect_refused(rows_for([ namibia, 't', 'maybe' ]), /not a yes\/no value: "maybe"/)
    end
  end
end
