module SearchableRelation
  extend ActiveSupport::Concern

  class_methods do
    def search(query, searched_column_names = searchable_text_columns)
      ilike_search(query, searched_column_names)
    end

    ##
    # SomeModel.ilike_search('foo', [:name, :description_en])
    # equivalent to
    # SomeModel.where(%{"name" ilike '%foo%' OR description_en ilike '%foo%'})
    def ilike_search(
      query, searched_column_names = searchable_text_columns
    )
      return all if query.blank?

      where(
        searched_column_names.map do |column_name|
          arel_table[column_name.to_s].matches(
            "%#{sanitize_sql_like(query)}%"
          ).to_sql
        end.join(' OR ')
      )
    end

    def searchable_text_columns
      columns.select do |c|
        [ :text, :string ].include? c.type
      end.map(&:name)
    end
  end
end
