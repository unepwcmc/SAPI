namespace :db do
  namespace :common_names do
    desc 'Deletes detached common names'
    task :cleanup => :environment do
      Rails.logger.warn "### rake db:common_names:cleanup"
      objects_to_delete = CommonName.
        joins('LEFT JOIN taxon_commons tc ON tc.common_name_id = common_names.id').
        where('tc.id IS NULL')
      Rails.logger.warn "Going to delete #{objects_to_delete.count} common names"
      sql = <<-SQL
        WITH objects_to_delete AS (
          #{objects_to_delete.to_sql}
        )
        DELETE FROM common_names
        USING objects_to_delete
        WHERE common_names.id = objects_to_delete.id
      SQL
      ActiveRecord::Base.connection.execute sql
    end
  end
  namespace :taxon_names do
    desc 'Deletes detached taxon names'
    task :cleanup => :environment do
      Rails.logger.warn "### rake db:taxon_names:cleanup"
      objects_to_delete = TaxonName.
        joins('LEFT JOIN taxon_concepts tc ON tc.taxon_name_id = taxon_names.id').
        where('tc.id IS NULL')
      Rails.logger.warn "Going to delete #{objects_to_delete.count} taxon names"
      sql = <<-SQL
        WITH objects_to_delete AS (
          #{objects_to_delete.to_sql}
        )
        DELETE FROM taxon_names
        USING objects_to_delete
        WHERE taxon_names.id = objects_to_delete.id
      SQL
      ActiveRecord::Base.connection.execute sql
    end
  end
end
