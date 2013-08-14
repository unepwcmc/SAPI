module ApplicationHelper
  def ancestors_path(taxon_concept)
    Rank.where(
      ["taxonomic_position < ?", taxon_concept.rank.taxonomic_position]
      ).order(:taxonomic_position).map do |r|
      name = taxon_concept.data["#{r.name.downcase}_name"]
      id = taxon_concept.data["#{r.name.downcase}_id"]
      if name && id
        link_to(name, send("admin_taxon_concept_#{controller_name}_url",id), :title => r.name)
      else
        nil
      end
    end.compact.join(' > ').html_safe
  end
end
