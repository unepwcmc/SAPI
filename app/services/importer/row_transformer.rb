# Importer::Base's cast pipeline - turns a raw value into the properly-typed value to
# write, and validates that every declared derived_attributes/resolve_belongs_to
# attribute can actually produce one. See README.md's Casting section for rationale.
#
# `host:` is used for exactly one thing: `host.respond_to?("cast_#{attribute}", true)`/
# `host.send(...)`, because `cast_<attribute>` is frozen to be defined directly on the
# importer subclass, with bare-`self` access to `raw_header_value`/`raw_value_for`/
# `rich_text_header_value`/`file_format` - none of that can move here without breaking
# the subclass-facing API. `logger:` is used for Importer::Logger#error on a cast
# failure, matching what a caller sees today exactly.
#
# ImportError is referenced as Importer::Base::ImportError (fully qualified) - a bare
# constant here resolves via this class's own lexical nesting, not Importer::Base's.
class Importer::RowTransformer
  # Excludes literal `false` from counting as blank - ActiveSupport's Object#blank?
  # considers `false` itself blank, which would otherwise turn a real boolean false
  # into nil. Shared with Importer::Base#import!'s own blank-row detection.
  def self.considered_blank?(value)
    value.blank? && value != false
  end

  def initialize(importer_class:, target_model:, required_headers:, derived_attributes:, belongs_to_lookups:, host:, logger:)
    @importer_class = importer_class
    @target_model = target_model
    @required_headers = required_headers
    @derived_attributes = derived_attributes
    @belongs_to_lookups = belongs_to_lookups
    @host = host
    @logger = logger
    # Per-run, not per-batch - a resolve_belongs_to lookup stays valid for as long as
    # this importer isn't writing to the model it looked up.
    @belongs_to_lookup_cache = {}
  end

  # A derived attribute has no source column, so its cast_<attribute> override is the
  # only thing that can produce its value - required at config time, since a missing or
  # misspelled cast_ method would otherwise silently write NULL on every row.
  #
  # Declaring the same attribute both in required_headers and derived_attributes is
  # rejected: one says the value comes from a column, the other that it does not.
  #
  # respond_to?(..., true) matches #resolve_cast's own dispatch, so a private cast_
  # method is just as valid here as it is there.
  #
  # Everything a `resolve_belongs_to` declaration needs in order to mean anything,
  # checked before a single row is read too: the attribute must be mapped in
  # required_headers (there's a source value to resolve), the foreign key must belong
  # to a real belongs_to on target_model (never guessed from the attribute's name), `by`
  # must be a real column on the associated model, and no cast_<attribute> may exist for
  # the same attribute (one or the other decides the value, not both).
  def validate!
    @derived_attributes.each do |attribute|
      if @required_headers.value?(attribute)
        raise ArgumentError,
          "#{@importer_class}: '#{attribute}' is declared in derived_attributes and also mapped in " \
          'required_headers - an attribute either has a source column or it does not'
      end

      next if @host.respond_to?("cast_#{attribute}", true)

      raise ArgumentError,
        "#{@importer_class}: derived attribute '#{attribute}' has no cast_#{attribute} method to " \
        'produce its value - it has no source column to fall back on, so every row would ' \
        'silently be written with NULL for it'
    end

    @belongs_to_lookups.each do |attribute, key_column|
      unless @required_headers.value?(attribute)
        raise ArgumentError,
          "#{@importer_class}: resolve_belongs_to :#{attribute} needs '#{attribute}' mapped in " \
          'required_headers - it resolves a value read from a source column, so there is ' \
          'nothing to resolve without one'
      end

      if @host.respond_to?("cast_#{attribute}", true)
        raise ArgumentError,
          "#{@importer_class}: '#{attribute}' has both a resolve_belongs_to declaration and a " \
          "cast_#{attribute} method - one or the other decides how that column becomes its value"
      end

      reflection = belongs_to_reflection_for(attribute)

      unless reflection
        raise ArgumentError,
          "#{@importer_class}: resolve_belongs_to :#{attribute} needs a belongs_to on " \
          "#{@target_model} whose foreign key is '#{attribute}' - that association is what " \
          'says which model to look the value up in'
      end

      next if reflection.klass.column_names.include?(key_column.to_s)

      raise ArgumentError,
        "#{@importer_class}: resolve_belongs_to :#{attribute}, by: :#{key_column} - " \
        "'#{key_column}' is not a column on #{reflection.klass}"
    end
  end

  # A blank primary key is omitted entirely, not set to nil - an explicit nil would
  # violate the column's NOT NULL constraint, so omitting it lets the database's own
  # default/sequence assign it instead. Holds regardless of allow_primary_key_write - a
  # blank primary key is never a caller-supplied value to protect against.
  #
  # derived_attributes are cast after mapped ones (with nil as their raw value, since
  # there's no column for them to come from) so a derived attribute's own cast_ method
  # can read a mapped column's raw value via raw_value_for.
  def build_attributes(row, line_number, primary_key_attribute:)
    pk = primary_key_attribute

    attrs =
      @required_headers.each_with_object({}) do |(header, attribute), acc|
        raw_value = row[header.to_s.strip]

        next if attribute.to_s == pk.to_s && raw_value.blank?

        acc[attribute] = resolve_cast(attribute, raw_value, line_number)
      end

    @derived_attributes.each do |attribute|
      value = resolve_cast(attribute, nil, line_number)

      next if attribute.to_s == pk.to_s && value.blank?

      attrs[attribute] = value
    end

    attrs
  end

  private

  # Dispatches to a subclass's `cast_<attribute>` override, then a resolve_belongs_to
  # declaration for that attribute, else the type-based default. A subclass method must
  # never itself be named `cast_<anything>` - that namespace is reserved for
  # column-name overrides. raw_value arrives already stripped (see the parsers' own row
  # Hash building).
  def resolve_cast(attribute, raw_value, line_number)
    key_column = @belongs_to_lookups[attribute.to_sym]

    if @host.respond_to?("cast_#{attribute}", true)
      @host.send("cast_#{attribute}", raw_value)
    elsif key_column
      resolve_belongs_to_id(attribute, key_column, raw_value)
    else
      default_cast(attribute, raw_value)
    end
  rescue StandardError => e
    @logger.error(row: line_number, column: attribute.to_s, message: e.message)
    raise Importer::Base::ImportError, "Line #{line_number}, column '#{attribute}': #{e.message}"
  end

  # Resolves a source file's own reference (UID, code, acronym) to this DB's foreign key.
  # See Importer::Concerns::Config#resolve_belongs_to for the declaration.
  #
  # - A present but unmatched value raises (naming model/column/value) rather than
  #   returning nil, which a NOT NULL column would report as an opaque DB error and a
  #   nullable one wouldn't report at all. Caught and reported by resolve_cast above -
  #   this aborts the run even under `on_failure :skip`, same as any other cast failure.
  # - A blank value resolves to nil - a missing parent is the file's business, decided by
  #   the column's own constraint/validation.
  # - Cached per (attribute, value) for the whole run to avoid one query per row.
  # - raw_value is passed to `where` as-is so ActiveRecord casts it via the key column's
  #   own type.
  # - Uses `reflection.association_primary_key`, not a hardcoded `:id`, since a belongs_to
  #   can override its own `primary_key:`.
  def resolve_belongs_to_id(attribute, key_column, raw_value)
    return nil if self.class.considered_blank?(raw_value)

    reflection = belongs_to_reflection_for(attribute)
    klass = reflection.klass
    association_primary_key = reflection.association_primary_key

    value = (@belongs_to_lookup_cache[[ attribute, raw_value ]] ||=
               klass.where(key_column => raw_value).pick(association_primary_key))

    return value if value

    raise "no #{klass} found with #{key_column}: #{raw_value.inspect}"
  end

  # target_model's belongs_to reflection whose foreign key is this attribute - not
  # inferred by stripping `_id`, so a differently-named association or `foreign_key:`
  # override still resolves. Guaranteed to exist by #validate!.
  def belongs_to_reflection_for(attribute)
    @target_model.reflect_on_all_associations(:belongs_to)
      .find { |reflection| reflection.foreign_key.to_s == attribute.to_s }
  end

  # An Excel cell's native type is used as-is when it already matches the target
  # attribute's type; otherwise it's stringified and parsed the same strict way as CSV.
  #
  # No :decimal entry: default_cast below returns via cast_decimal before reaching this
  # for a :decimal-typed attribute, so an entry here would be dead code. :float (a real
  # `float`/`double precision` column, not decimal) still goes through this normally.
  NATIVE_TYPE_MATCHERS = {
    integer: ->(value) { value.is_a?(Integer) },
    float: ->(value) { value.is_a?(Numeric) },
    date: ->(value) { value.is_a?(Date) },
    datetime: ->(value) { value.is_a?(Date) },
    boolean: ->(value) { value.is_a?(TrueClass) || value.is_a?(FalseClass) }
  }.freeze

  # Every branch returns a correctly-typed value or raises - no catch-all pass-through
  # for an unsupported column type (jsonb, array, enum, PostGIS geometry). cast_<attribute>
  # is the escape hatch for a subclass that needs one of these types.
  #
  # `type.nil?` is excluded from that raise: a nil type means a virtual/writer-method
  # attribute (no real column), which is out of scope for this pipeline - its writer
  # method handles its own parsing.
  def default_cast(attribute, raw_value)
    return nil if self.class.considered_blank?(raw_value)

    type_metadata = @target_model.type_for_attribute(attribute.to_s)
    type = type_metadata.type

    return cast_decimal(type_metadata, raw_value) if type == :decimal
    return raw_value if native_type_match?(type, raw_value)

    string_value = stringify(raw_value)

    case type
    when :integer then parse_integer(string_value)
    when :float then parse_decimal(string_value)
    when :date then parse_date(string_value)
    when :datetime then parse_datetime(string_value)
    when :boolean then parse_boolean(string_value)
    when :string, :text then string_value
    when nil then raw_value
    else raise "no default cast for :#{type} - define cast_#{attribute} to handle it explicitly"
    end
  end

  def native_type_match?(type, raw_value)
    matcher = NATIVE_TYPE_MATCHERS[type]
    matcher ? matcher.call(raw_value) : false
  end

  # Enforces a :decimal column's own `scale` here rather than leaving it to
  # ActiveRecord::Type::Decimal#cast, which rounds silently with no error - the exact
  # silent data loss this pipeline exists to prevent. `type_metadata.scale` is nil for
  # an unscaled decimal column, so this never raises for one.
  def cast_decimal(type_metadata, raw_value)
    value = raw_value.is_a?(Numeric) ? BigDecimal(raw_value.to_s) : parse_decimal(stringify(raw_value))

    scale = type_metadata.scale
    return value if scale.nil? || value.round(scale) == value

    raise "#{raw_value.inspect} has more decimal places than this column's scale of " \
          "#{scale} allows - would silently lose precision if written (rounds to #{value.round(scale)})"
  end

  def stringify(value)
    value.is_a?(String) ? value : value.to_s
  end

  # Base 10 explicitly, never Integer()'s default: without it Ruby applies its own
  # literal prefix rules to the string, which is wrong twice over for source-file data.
  # "010" parses as octal 8 - silent corruption, exactly what this pipeline exists to
  # prevent - while "08"/"09" raise as invalid octal despite being ordinary zero-padded
  # decimals, and "0x1F"/"0b11" are silently accepted as 31/3. Zero-padded numeric codes
  # (reference numbers, country codes) are common in CSV/Excel exports.
  #
  # Safe to pass a base here because default_cast always calls stringify first, so this
  # only ever receives a String - Integer(5, 10) would raise "base specified for non
  # string value" and be misreported as an invalid integer.
  def parse_integer(raw_value)
    Integer(raw_value, 10)
  rescue ArgumentError
    raise "invalid integer: #{raw_value.inspect}"
  end

  def parse_decimal(raw_value)
    BigDecimal(raw_value)
  rescue ArgumentError
    raise "invalid decimal: #{raw_value.inspect}"
  end

  def parse_date(raw_value)
    Date.parse(raw_value)
  rescue ArgumentError
    raise "invalid date: #{raw_value.inspect}"
  end

  # Can't reuse parse_date - Date.parse silently drops any time-of-day. DateTime.parse
  # (not Time.zone.parse) is deliberate: Time.zone.parse returns nil, not an error, for
  # unparseable input; DateTime.parse raises Date::Error (a subclass of ArgumentError,
  # caught below).
  def parse_datetime(raw_value)
    DateTime.parse(raw_value)
  rescue ArgumentError
    raise "invalid datetime: #{raw_value.inspect}"
  end

  TRUE_VALUES = %w[true t yes y 1].freeze
  FALSE_VALUES = %w[false f no n 0].freeze

  def parse_boolean(raw_value)
    value = raw_value.downcase

    return true if TRUE_VALUES.include?(value)
    return false if FALSE_VALUES.include?(value)

    raise "invalid boolean: #{raw_value.inspect}"
  end
end
