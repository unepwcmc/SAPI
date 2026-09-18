# A mixin for Importer::Parsers::ExcelX's Nokogiri::XML::SAX::Document subclasses
# (MergedCellsHandler, RichTextExtractor, SharedStringsHandler, StylesHandler), making
# every `case name when 'foo'` dispatch immune to XML namespace prefixing.
#
# Nokogiri's default `start_element_namespace` rejoins an element's prefix onto its local
# name before delegating to `start_element` (`name = [prefix, name].compact.join(":")`).
# A default-namespaced workbook (no prefix - what caxlsx and every real .xlsx here uses)
# is unaffected, but a prefixed one (`<x:row>`) would silently deliver `"x:row"` to
# handlers matching only plain names, bypassing them with no error.
#
# Included once here rather than fixed per handler - also normalizes `attrs`, an Array of
# Nokogiri::XML::SAX::Parser::Attribute objects here vs plain [key, value] tuples in
# `start_element`'s own `attrs`.
module Importer::Parsers::ExcelX::XmlNamespaceAgnostic
  def start_element_namespace(name, attrs = [], prefix = nil, uri = nil, ns = [])
    start_element(name, attrs.map { |attr| [ attr.localname, attr.value ] })
  end

  def end_element_namespace(name, prefix = nil, uri = nil)
    end_element(name)
  end
end
