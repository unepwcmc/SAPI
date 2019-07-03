namespace :import do

  desc 'Change orchids into accepted name'
  task :orchids_T_to_A => [:environment] do
    byebug
    user_id = User.where('name ILIKE ?', '%luca%').first.id
    CSV.foreach("lib/files/Orchids_T_to_A.csv", headers: true) do |row|
      byebug
      @nomenclature_change = klass.create(status: NomenclatureChange::NEW, created_by_id: user_id, updated_by_id: user_id)
      primary_output(row, user_id)
      if !@nomenclature_change.valid?
        puts "There was a problem with this Taxon Concept #{row[0].strip}"
        next
      end
      processor = klass::Processor.new(@nomenclature_change)
      @summary = processor.summary
      @nomenclature_change.update_attributes(:status => NomenclatureChange::SUBMITTED)
      @nomenclature_change.save
    end
  end
end

def primary_output(row, user)
  byebug
  builder = klass::Constructor.new(@nomenclature_change)
  builder.build_primary_output
  @nomenclature_change.assign_attributes(
    {event_id: Event.where(name: 'CoP18').first.id,
     primary_output_attributes: { taxon_concept_id: row[0].strip,
                                  new_rank_id: Rank.where(name: 'SPECIES').first,
                                  new_parent_id: row[4],
                                  created_by_id: user,
                                  updated_by_id: user }}
    .merge({ :status => 'primary_output' })
  )
  @nomenclature_change.save
end

def klass
  NomenclatureChange::StatusToAccepted
end
