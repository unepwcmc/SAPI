class CreateReviewDetails < ActiveRecord::Migration
  def change
    create_table :review_details do |t|
      t.integer :document_id
      t.integer :review_phase_id
      t.integer :process_stage_id
      t.integer :recommended_category_id

      t.timestamps
    end
    add_foreign_key :review_details, :documents, name: :review_details_document_id_fk,
      column: :document_id
    add_foreign_key :review_details, :document_tags, name: :review_details_review_phase_id_fk,
      column: :review_phase_id
    add_foreign_key :review_details, :document_tags, name: :review_details_process_stage_id_fk,
      column: :process_stage_id
    add_foreign_key :review_details, :document_tags, name: :review_details_recommended_category_id_fk,
      column: :recommended_category_id
  end
end
