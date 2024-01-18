# TODO: May need to remove this file when upgrade Rails.
# https://github.com/rails/arel/pull/470
# Backport Arel 8.0.0 code to 6.0.4, to fix eq(nil) generate `= NULL` instead of `IS NULL`.
# https://github.com/rails/arel/blob/d6af2090b16f7d061aa43913d610c6fada58b7e2/lib/arel/nodes/casted.rb#L27

module Arel
  module Nodes
    class Quoted < Arel::Nodes::Unary # :nodoc:
      alias :val :value # <-- Backport
      def nil?; val.nil?; end # <-- Backport
    end
  end
end
