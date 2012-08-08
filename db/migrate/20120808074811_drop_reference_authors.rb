class DropReferenceAuthors < ActiveRecord::Migration
  def change
    drop_table :reference_authors
  end
end
