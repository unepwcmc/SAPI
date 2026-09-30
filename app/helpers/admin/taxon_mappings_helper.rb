module Admin::TaxonMappingsHelper
  # What an upload was aimed at. A taxa file names one taxonomy; a match file
  # names two, and which of them the file called d1 is not worth showing - the
  # rows are written in both directions either way.
  def import_target(import)
    near = import.importable
    far = MatchableTaxonomy.find_by(id: import.params['foreign_matchable_taxonomy_id'])

    return near.to_s if far.nil?

    # A literal character rather than &harr;, so a code someone typed into the
    # taxonomy form is still escaped on the way out.
    "#{near} ↔ #{far}"
  end

  # How many rows the upload left behind. Read from the logs rather than a
  # column: the importer already records what it wrote, and Mapping::FileImport
  # appends what survived - which differs whenever matches are collapsed.
  def import_rows(import)
    entry = import.logs.reverse.find { |e| e.key?('retained') || e.key?('written') }

    return nil if entry.nil?

    entry['retained'] || entry['written']
  end

  # Rendered for the browser to restyle: the app has no time_zone set, so Rails
  # writes UTC, and whoever uploaded the file was not necessarily in it. The
  # machine-readable value carries the offset and the JavaScript in
  # admin/taxon_mapping_upload rewrites the text in the reader's own zone. With
  # no JavaScript the UTC rendering stands, which is why it says so.
  def local_time(time)
    return '&mdash;'.html_safe if time.nil?

    tag.time(
      "#{time.utc.to_fs(:long)} UTC",
      datetime: time.utc.iso8601, data: { local_time: true }
    )
  end

  def import_label_class(import)
    case import.status
    when Import::DONE then 'label-success'
    when Import::FAILED then 'label-important'
    when Import::RUNNING then 'label-info'
    else ''
    end
  end

  # Only the row-level problems. The summary entry a successful run ends with is
  # not one, and a warning did not stop anything.
  def import_errors(import)
    import.logs.select { |entry| entry['level'] == 'error' }
  end
end
