require Rails.root.join('lib/tasks/helpers_for_import.rb')
namespace :import do

  desc 'Change orchids into accepted name (usage: rake import:orchids_T_to_A[path/to/file])'
  task :orchids_T_to_A , 10.times.map { |i| "file_#{i}".to_sym } => [:environment] do |t, args|
    user_id = User.where('name ILIKE ?', '%luca%').first.id
    files = files_from_args(t, args)
    files.each do |file|
      CSV.foreach(file, headers: true) do |row|
        @nomenclature_change = klass.create(status: NomenclatureChange::NEW, created_by_id: user_id, updated_by_id: user_id)
        primary_output(row, user_id)
        if !@nomenclature_change.valid?
          puts "There was a problem with this Taxon Concept #{row['ID'].strip}"
          next
        end
        processor = klass::Processor.new(@nomenclature_change)
        @summary = processor.summary
        @nomenclature_change.update_attributes(:status => NomenclatureChange::SUBMITTED)
        @nomenclature_change.save
      end
    end
  end
end

def primary_output(row, user)
  builder = klass::Constructor.new(@nomenclature_change)
  builder.build_primary_output
  @nomenclature_change.assign_attributes(
    {event_id: Event.where(name: 'CoP18').first.id,
     primary_output_attributes: { taxon_concept_id: row['ID'].strip,
                                  new_rank_id: Rank.where(name: 'SPECIES').first,
                                  new_parent_id: row['ParentID'],
                                  created_by_id: user,
                                  updated_by_id: user }}
    .merge({ :status => 'primary_output' })
  )
  @nomenclature_change.save
end

def klass
  NomenclatureChange::StatusToAccepted
end
