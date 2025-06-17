module PgCopy
  def self.copy_model_to_db(model, column_names = model.column_names)
    connection = model.connection

    copy_to_db(model.table_name, column_names:, connection:)
  end

  ##
  # usage:
  #
  # ```
  # PgCopy.copy_to_db(
  #   'temp_names', column_names: ['taxon_id', 'name']
  # ) do |raw_connection|
  #   CSV.foreach(
  #     import_args[:csv], **csv_options
  #   ) do |csv_row|
  #     row_hash = csv_row.to_h
  #
  #     raw_connection.put_copy_data(
  #       [row_hash['taxon_id', row_hash['name']]
  #     )
  #   end
  # end
  # ```
  def self.copy_to_db(
    table_name,
    column_names: nil,
    column_types: nil,
    connection: ActiveRecord::Base.connection,
    raw_connection: connection.raw_connection,
    pg_copy_encoder:
      if column_types.present? && column_names.present?
        PG::BinaryEncoder::CopyRow.new(
          type_map: PG::TypeMapByColumn.new(
            column_types.map do |column_type|
              class_by_column_type = encoder_class_by_column_type
              class_by_column_type[column_type || :text] || class_by_column_type[:text]
            end.map(&:new)
          )
        )
      else
        PG::BinaryEncoder::CopyRow.new
      end,
    table_expr:
      if column_names.present?
        quoted_table_name = connection.quote_table_name(table_name)

        column_names_quoted = column_names.map do |name|
          connection.quote_column_name name
        end.join(', ')

        "#{quoted_table_name} (#{column_names_quoted})"
      else
        connection.quote_table_name(table_name)
      end,
    sql_copy_from_stdin: %{COPY #{table_expr} FROM STDIN WITH (FORMAT binary)}
  )
    Rails.logger.debug sql_copy_from_stdin

    writer = ->(arr) { raw_connection.put_copy_data(arr, pg_copy_encoder) }

    raw_connection.copy_data sql_copy_from_stdin, pg_copy_encoder do
      yield(writer, column_names) if block_given?
    end
  end

  ##
  # usage:
  #
  # ```
  # PgCopy.copy_to_csv_file(
  #   'SELECT * FROM ranks',
  #   'ranks.csv',
  #   delimiter: ';',
  #   encoding: 'Windows-1252'
  # )
  # ```
  def self.copy_to_csv_file(
    query, file_name, **kwargs
  )
    File.open(file_name, mode: 'w', encoding: kwargs[:encoding]) do |io|
      self.copy_to_csv(query, io:, **kwargs)
    end
  end

  def self.realias_query(
    query,
    column_names: nil,
    column_aliases: column_names,
    column_mappings: column_names&.zip(column_aliases)
  )
    if column_aliases
      query_sql =
        if query.respond_to? :to_sql
          query.to_sql
        else
          query
        end

      column_aliases_sql = column_aliases.map do |column_alias|
        ActiveRecord::Base.connection.quote_column_name(column_alias)
      end.join(', ')

      "SELECT * FROM (#{query_sql}) AS cte (#{column_aliases_sql})"
    else
      select_array =
        column_mappings&.map do |alias_pair|
          quoted_alias = ActiveRecord::Base.connection.quote_column_name(
            alias_pair[1]
          )

          "#{alias_pair[0]} AS #{quoted_alias}"
        end

      if !select_array
        query
      elsif query.respond_to? :select
        query.select(*select_array)
      else
        "SELECT #{select_array.join(', ')} FROM (#{query}) AS cte"
      end
    end
  end

  def self.copy_to_csv(
    query,
    io: nil,
    connection: ActiveRecord::Base.connection,
    raw_connection: connection.raw_connection,
    encoding: 'UTF-8',
    ruby_encoding: encoding,
    delimiter: ',',
    header: true,
    query_sql:
      if query.respond_to? :to_sql
        query.to_sql
      else
        query.to_s
      end,
    sql_copy_to_stdout:
      unless [ ',', ';' ].include? delimiter
        raise StandardError ('Delimiter must be comma or semicolon')
      else
        %{
          COPY (#{query_sql}) TO STDOUT WITH (
            FORMAT csv,
            #{header ? 'HEADER,' : ''}
            DELIMITER #{connection.quote(delimiter)},
            ENCODING #{connection.quote(encoding)}
          )
        }
      end
  )
    Rails.logger.debug sql_copy_to_stdout

    raw_connection.copy_data sql_copy_to_stdout do
      while row = raw_connection.get_copy_data
        to_write =
          if block_given?
            yield row.force_encoding(ruby_encoding)
          else
            row.force_encoding(ruby_encoding)
          end

        io&.write to_write
      end
    end
  end

  def self.encoder_class_by_column_type
    {
      string: PG::BinaryEncoder::String,
      text: PG::BinaryEncoder::String,
      integer: PG::BinaryEncoder::Int4,
      float: PG::BinaryEncoder::Float4,
      boolean: PG::BinaryEncoder::Boolean,
      datetime: PG::BinaryEncoder::Date
    }
  end
end
