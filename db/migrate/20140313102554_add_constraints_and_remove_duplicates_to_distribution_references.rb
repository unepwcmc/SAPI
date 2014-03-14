class AddConstraintsAndRemoveDuplicatesToDistributionReferences < ActiveRecord::Migration
  def up
    sql = <<-SQL
      DELETE FROM distribution_references
      USING distribution_references dr
      WHERE distribution_references.distribution_id = dr.distribution_id
        AND distribution_references.reference_id = dr.reference_id
        AND distribution_references.id < dr.id;

      UPDATE distribution_references
      SET created_at = '13/11/2013'
      WHERE created_at IS NULL;

      UPDATE distribution_references
      SET updated_at = '13/11/2013'
      WHERE updated_at IS NULL;
    SQL
    ActiveRecord::Base.connection.execute(sql)
    change_column :distribution_references, :updated_at, :datetime, :null => false
    change_column :distribution_references, :created_at, :datetime, :null => false
    add_index :distribution_references, [:distribution_id, :reference_id], :unique => true, :name => :index_distribution_refs_on_distribution_id_reference_id
  end

  def down
    remove_index :distribution_references, :name => :index_distribution_refs_on_distribution_id_reference_id
    change_column :distribution_references, :updated_at, :datetime, :null => true
    change_column :distribution_references, :created_at, :datetime, :null => true
  end
end
