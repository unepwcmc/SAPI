module ApplicationHelper
  def ancestors_path(taxon_concept)
    Rank.where(
      ["taxonomic_position < ?", taxon_concept.rank.taxonomic_position]
      ).order(:taxonomic_position).map do |r|
      name = taxon_concept.data["#{r.name.downcase}_name"]
      id = taxon_concept.data["#{r.name.downcase}_id"]
      if name && id
        link_to(name, edit_admin_taxon_concept_url(id), :title => r.name)
      else
        nil
      end
    end.compact.join(' > ').html_safe
  end
end
