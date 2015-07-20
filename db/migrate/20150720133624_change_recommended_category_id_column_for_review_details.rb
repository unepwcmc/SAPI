class ChangeRecommendedCategoryIdColumnForReviewDetails < ActiveRecord::Migration
  def up
    remove_foreign_key :review_details, name: "review_details_recommended_category_id_fk"
    rename_column :review_details, :recommended_category_id, :recommended_category
    change_column :review_details, :recommended_category, :text
  end

  def down
    execute 'ALTER TABLE review_details ALTER COLUMN recommended_category TYPE integer USING (recommended_category::integer)'
    rename_column :review_details, :recommended_category, :recommended_category_id
    add_foreign_key :review_details, :document_tags, column: "recommended_category_id", name: "review_details_recommended_category_id_fk"
  end
end
