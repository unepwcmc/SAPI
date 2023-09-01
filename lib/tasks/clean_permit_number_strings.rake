namespace :clean_permit_number_strings do
  desc 'Replaces commas with semicolons and removes empty values in trade shipment export permit numbers'
  task :export_permits => :environment do
    puts 'cleaning export permit numbers'
    errors = []
    Trade::Shipment.where("export_permit_number IS NOT NULL AND export_permit_number ILIKE '%,%'").find_each do |shipment|
      begin
        new_export_permit_number = shipment.export_permit_number.split(',').map {|number| number.to_s.blank? ? nil : number.strip }.compact.join(';')
        shipment.export_permit_number = new_export_permit_number
        shipment.ignore_warnings = true
        shipment.save!
      rescue StandardError => e
        shipment.errors.full_messages.each do |message|
          errors << { id: shipment.id, error: message }
        end
      end
    end
    if errors.any?
      puts "completed with #{errors.length} errors"
      puts errors
    else
      puts 'export permit number cleaning complete'
    end
  end

  desc 'Replaces commas with semicolons and removes empty values in trade shipment origin permit numbers'
  task :origin_permits => :environment do
    puts 'cleaning origin permit numbers'
    errors = []
    Trade::Shipment.where("origin_permit_number IS NOT NULL AND origin_permit_number ILIKE '%,%'").find_each do |shipment|
      begin
        new_origin_permit_number = shipment.origin_permit_number.split(',').map {|number| number.to_s.blank? ? nil : number.strip }.compact.join(';')
        shipment.origin_permit_number = new_origin_permit_number
        shipment.ignore_warnings = true
        shipment.save!
      rescue StandardError => e
        if shipment.errors.any?
          shipment.errors.full_messages.each do |message|
            errors << { id: shipment.id, error: message }
          end
        else
          errors << { id: shipment.id, error: e }
        end
      end
    end
    if errors.any?
      puts "completed with #{errors.length} errors"
      puts errors
    else
      puts 'origin permit number cleaning complete'
    end
  end

  desc 'Replaces commas with semicolons and removes empty values in trade shipment import permit numbers'
  task :import_permits => :environment do
    puts 'cleaning import permit numbers'
    errors = []
    Trade::Shipment.where("import_permit_number IS NOT NULL AND import_permit_number ILIKE '%,%'").find_each do |shipment|
      begin
        new_import_permit_number = shipment.import_permit_number.split(',').map {|number| number.to_s.blank? ? nil : number.strip }.compact.join(';')
        shipment.import_permit_number = new_import_permit_number
        shipment.ignore_warnings = true 
        shipment.save!
      rescue StandardError => e
        shipment.errors.full_messages.each do |message|
          errors << { id: shipment.id, error: message }
        end
      end
    end
    if errors.any?
      puts "completed with #{errors.length} errors"
      puts errors
    else
      puts 'import permit number cleaning complete'
    end
  end
end
