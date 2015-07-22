require Rails.root.join('lib/tasks/elibrary/importable.rb')

class Elibrary::UsersImporter
  include Elibrary::Importable

  def initialize(file_name)
    @file_name = file_name
  end

  def table_name; :"elibrary_users_import"; end

  def columns_with_type
    [
      ['LoweredUserName', 'TEXT'],
      ['LoweredEmail', 'TEXT'],
      ['RoleName', 'TEXT'],
      ['CreateDate', 'TEXT'],
      ['LastLoginDate', 'TEXT']
    ]
  end

  def run_preparatory_queries
    # delete public viewers
    ActiveRecord::Base.connection.execute("DELETE FROM #{table_name} WHERE RoleName = 'Public Viewer'")

    # only keep 1 highest priority role per user
    sql = <<-SQL
      WITH users_with_roles AS (
        SELECT *,
          ROW_NUMBER() OVER (
            PARTITION BY LoweredUserName
            ORDER BY CASE
              WHEN RoleName = 'Administrator' THEN 1
              WHEN RoleName = 'Data Contributor' THEN 2
              WHEN RoleName = 'Full Viewer' THEN 3
            END
          )
        FROM elibrary_users_import
      )
      DELETE FROM #{table_name} t
      USING users_with_roles
      WHERE t.LoweredUserNAme = users_with_roles.LoweredUserName
      AND t.RoleName = users_with_roles.RoleName
      AND row_number > 1
    SQL
    ActiveRecord::Base.connection.execute(sql)
  end

  def run_queries
    sql = <<-SQL
      WITH rows_to_insert AS (
        #{rows_to_insert_sql}
      )
      INSERT INTO "users" (email, name, role, geo_entity_id, created_at, updated_at)
        SELECT
        email,
        name,
        splus_role,
        splus_geo_entity_id,
        NOW(),
        NOW()
      FROM rows_to_insert
    SQL
    ActiveRecord::Base.connection.execute(sql)
  end

  def all_rows_sql
    sql = <<-SQL
      SELECT
        LoweredEmail,
        COALESCE(
          INITCAP(name_ary[1]) || ' ' || INITCAP(name_ary[2]),
          LoweredUserName
        ) AS name,
        splus_role,
        geo_entities.id AS splus_geo_entity_id
      FROM (
        SELECT
          LoweredUserName,
          LoweredEmail,
          REGEXP_SPLIT_TO_ARRAY(
            SUBSTRING(LoweredEmail FROM '(.+)@.+'),
            '[\._]'
          ) AS name_ary,
          UPPER(BTRIM(SUBSTRING(LoweredEmail FROM '.+\.(.+)$'))) AS iso_code2,
          CASE
            WHEN RoleName = 'Administrator' THEN 'admin'
            WHEN RoleName = 'Data Contributor' THEN 'default'
            ELSE 'elibrary'
          END AS splus_role
        FROM #{table_name}
      ) t
      LEFT JOIN geo_entities
      ON CASE
      WHEN UPPER(t.iso_code2) = 'UK'
        OR t.LoweredEmail LIKE '%@unep-wcmc.org'
        OR t.LoweredEmail LIKE '%@kew.org'
      THEN UPPER(BTRIM(geo_entities.iso_code2)) = 'GB'
      ELSE UPPER(BTRIM(geo_entities.iso_code2)) = UPPER(BTRIM(t.iso_code2))
      END
    SQL
  end

  def rows_to_insert_sql
    sql = <<-SQL
      SELECT
        email,
        name,
        splus_role,
        splus_geo_entity_id
      FROM (
        SELECT UPPER(BTRIM(LoweredEmail)) AS email
        FROM #{table_name}
        EXCEPT
        SELECT UPPER(BTRIM(email)) FROM users
      ) new_emails
      JOIN (#{all_rows_sql}) tt
      ON UPPER(BTRIM(new_emails.email)) = UPPER(BTRIM(tt.LoweredEmail))
    SQL
  end

  def print_pre_import_stats
    print_users_breakdown
    print_query_counts
  end

  def print_post_import_stats
    print_users_breakdown
  end

  def print_users_breakdown
    puts "#{Time.now} There are #{User.count} users in total"
    User.group(:role).order(:role).count.each do |role, count|
      puts "\t #{role} #{count}"
    end
  end

end
