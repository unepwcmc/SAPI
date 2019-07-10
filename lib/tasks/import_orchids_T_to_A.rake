require Rails.root.join('lib/tasks/helpers_for_import.rb')
namespace :import do

  desc 'Change orchids into accepted name (usage: rake import:orchids_T_to_A[path/to/file,user_id,event_id])'
  task :orchids_T_to_A , [:file, :user_id, :event_id] => [:environment] do |t, args|
    user_id = args[:user_id]
    event_id = args[:event_id]
    CSV.foreach(args[:file], headers: true) do |row|
      @nomenclature_change = klass.create(status: NomenclatureChange::NEW, created_by_id: user_id, updated_by_id: user_id)
      primary_output(row, user_id, event_id)
      unless @nomenclature_change.valid?
        puts "There was a problem with this Taxon Concept #{row['ID'].strip}"
        next
      end
      @nomenclature_change.update_attributes(:status => NomenclatureChange::SUBMITTED)
    end
  end
end

def primary_output(row, user, event)
  builder = klass::Constructor.new(@nomenclature_change)
  builder.build_primary_output
  @nomenclature_change.assign_attributes(
    {event_id: event,
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
