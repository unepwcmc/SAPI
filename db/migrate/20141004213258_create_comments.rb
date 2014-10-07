class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.integer :commentable_id
      t.string :commentable_type
      t.string :comment_type
      t.text :note
      t.integer :created_by_id
      t.integer :updated_by_id

      t.timestamps
    end
    add_foreign_key :comments, :users, name: 'comments_created_by_id_fk',
      column: 'created_by_id'
    add_foreign_key :comments, :users, name: 'comments_updated_by_id_fk',
      column: 'updated_by_id'
    add_index 'comments', [
      'commentable_id', 'commentable_type', 'comment_type'
    ], name: 'index_comments_on_commentable_and_comment_type'
  end
end
