module PgCopy
  def self.copy_model_to_db(model, column_names = model.column_names)
    connection = model.connection

    copy_to_db(model.table_name, column_names:, connection:)
  end

  ##
  # usage:
  #
  # ```
  # copy_to_db(
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
    connection: ActiveRecord::Base.connection,
    raw_connection: connection.raw_connection,
    pg_copy_encoder: PG::BinaryEncoder::CopyRow.new,
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
end
