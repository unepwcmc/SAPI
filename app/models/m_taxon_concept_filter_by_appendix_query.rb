class MTaxonConceptFilterByAppendixQuery

  def initialize(relation = MTaxonConcept.scoped, appendix_abbreviations = [])
    @relation = relation
    @appendix_abbreviations_conditions = 
    (['I','II','III'] & appendix_abbreviations).map do |abbr|
      "#{relation.table_name}.cites_#{abbr} = 't'"
    end
  end

  def relation
    @relation.where(@appendix_abbreviations_conditions.join(' OR '))
  end

end