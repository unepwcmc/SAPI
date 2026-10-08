# The result of resolving a `unique_by` declaration against target_model's real indexes
# (Importer::Loaders::UniqueByResolver) - what every loader that can look up an existing
# record by natural key needs to know about that key.
#
# `class X < Struct.new(...)`, not `X = Struct.new(...) do ... end` - verified directly
# that a bare constant assignment (`NONE = ...`) inside a Struct.new block resolves its
# lexical scope to wherever the block was written (here, the top level), not the struct
# itself, so `NONE` would silently become a global constant instead of
# UniqueByConfig::NONE. The `class ... < Struct.new(...)` form doesn't have this gotcha.
class Importer::Loaders::UniqueByConfig < Struct.new(:columns, :nulls_not_distinct, :index_predicate, keyword_init: true)
  # unique_by wasn't declared at all - a loader still needs something to check against
  # rather than nil-guarding every call site.
  NONE = new(columns: [].freeze, nulls_not_distinct: false, index_predicate: nil).freeze
end
