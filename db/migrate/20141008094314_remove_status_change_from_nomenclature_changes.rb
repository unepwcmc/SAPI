class RemoveStatusChangeFromNomenclatureChanges < ActiveRecord::Migration
  def up
    execute <<-SQL
      WITH status_changes AS (
        SELECT * FROM nomenclature_changes
        WHERE type = 'NomenclatureChange::StatusChange'
      ), inputs AS (
        SELECT inputs.*
        FROM nomenclature_change_inputs inputs
        JOIN status_changes
        ON status_changes.id = inputs.nomenclature_change_id
      ), outputs AS (
        SELECT outputs.*
        FROM nomenclature_change_outputs outputs
        JOIN status_changes
        ON status_changes.id = outputs.nomenclature_change_id
      ), reassignments AS (
        SELECT reassignments.*
        FROM nomenclature_change_reassignments reassignments
        JOIN inputs ON inputs.id = reassignments.nomenclature_change_input_id
      ), reassignment_targets AS (
        SELECT reassignment_targets.*
        FROM nomenclature_change_reassignment_targets reassignment_targets
        JOIN reassignments
        ON reassignments.id = reassignment_targets.nomenclature_change_reassignment_id
      ), output_reassignment_targets AS (
        SELECT reassignment_targets.*
        FROM nomenclature_change_reassignment_targets reassignment_targets
        JOIN outputs
        ON outputs.id = reassignment_targets.nomenclature_change_output_id
      ), deleted_reassignment_targets AS (
        DELETE FROM nomenclature_change_reassignment_targets
        USING reassignment_targets
        WHERE reassignment_targets.id = nomenclature_change_reassignment_targets.id
      ), deleted_output_reassignment_targets AS (
        DELETE FROM nomenclature_change_reassignment_targets
        USING output_reassignment_targets
        WHERE output_reassignment_targets.id = nomenclature_change_reassignment_targets.id
      ), deleted_reassignments AS (
        DELETE FROM nomenclature_change_reassignments
        USING reassignments
        WHERE reassignments.id = nomenclature_change_reassignments.id
      ), deleted_inputs AS (
        DELETE FROM nomenclature_change_inputs
        USING inputs
        WHERE inputs.id = nomenclature_change_inputs.id
      ), deleted_outputs AS (
        DELETE FROM nomenclature_change_outputs
        USING outputs
        WHERE outputs.id = nomenclature_change_outputs.id
      )
      DELETE FROM nomenclature_changes
      USING status_changes
      WHERE status_changes.id = nomenclature_changes.id;
    SQL
  end

  def down
  end
end
