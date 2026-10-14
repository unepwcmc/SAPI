FactoryBot.define do
  # Every mapping row carries the run that wrote it, so most mapping specs need
  # one even when the run itself is beside the point. A file is attached
  # because ImportRun refuses to save without one - there is no such thing as a
  # run of nothing.
  factory :import_run do
    kind { 'mapping_taxa' }

    after(:build) do |run|
      run.file.attach(
        io: StringIO.new("Status,Id\nA,1\n"),
        filename: 'import.csv',
        content_type: 'text/csv'
      )
    end
  end
end
