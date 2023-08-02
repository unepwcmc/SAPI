namespace :export do
  desc 'Export nomenclature notes for Species'
  task :nomenclature_notes => :environment do
    FILENAME = "tmp/nomenclature_#{Date.today.to_s}.csv".freeze
    COLUMN_NAMES = %w(id name nomenclature_note internal_nomenclature_note).freeze

    CSV.open(FILENAME, 'w') do |csv|
      csv << COLUMN_NAMES
      TaxonConcept.where(rank_id: 8).select(:id, :full_name, :nomenclature_note_en, :internal_nomenclature_note).order(:id).each do |note|
        csv << note.attributes.values
      end
    end
  end
end
