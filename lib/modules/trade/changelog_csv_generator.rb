require 'csv'
class Trade::ChangelogCsvGenerator

  def self.call(aru, requester)
    data_columns = if aru.reported_by_exporter?
      Trade::SandboxTemplate::EXPORTER_COLUMNS
    else
      Trade::SandboxTemplate::IMPORTER_COLUMNS
    end

    sapi_users = Hash[
      User.select('id, name').all.map{ |u| [u.id, u.name] }
    ]

    tempfile = Tempfile.new(["changelog_sapi_#{aru.id}-", ".csv"], Rails.root.join('tmp'))

    ar_klass = aru.sandbox(true).ar_klass

    CSV.open(tempfile, 'w', headers: true) do |csv|
      csv << ['ID', 'Version', 'OP', 'ChangedAt', 'ChangedBy'] +
        data_columns.map(&:camelize)
      limit = 100
      offset = 0
      query = ar_klass.includes(:versions).limit(limit).offset(offset)
      while query.any?
        query.all.each do |shipment|
          csv << [shipment.id, nil, nil, shipment.created_at, nil] +
            data_columns.map do |dc|
              shipment[dc]
            end

          shipment.versions.each do |version|
            reified = version.reify(dup: true)
            type, id = version.whodunnit && version.whodunnit.split(':')
            id_as_number = id.present? ? id.to_i : type.to_i
            whodunnit = if id_as_number && type == 'Epix'
              'epix'
            elsif id_as_number
              sapi_users && sapi_users[id_as_number] || 'WCMC'
            end
            csv << [
                version.item_id, version.id, version.event, version.created_at, whodunnit
              ] +
              data_columns.map do |dc|
                reified[dc]
              end
          end

          offset += limit
          query = ar_klass.includes(:versions).limit(limit).offset(offset)
        end
      end
    end
    tempfile
  end

end
