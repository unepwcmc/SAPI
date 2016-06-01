module ApplicationHelper

  def speciesplus_taxon_concept_id_url(taxon_concept_id)
    speciesplus_taxon_concept_url(TaxonConcept.find_by_id(taxon_concept_id))
  end

  def speciesplus_taxon_concept_url(taxon_concept)
    return nil unless taxon_concept
    if [Rank::SPECIES, Rank::SUBSPECIES].include?(taxon_concept.rank.name)
      "/species#/taxon_concepts/#{taxon_concept.id}/legal"
    else
      taxonomy = taxon_concept.taxonomy.name.downcase
      "/species#/taxon_concepts?taxonomy=#{taxonomy}&taxon_concept_query=#{taxon_concept.full_name}"
    end
  end

  def error_message_for(field)
    return "" if resource.errors[field].empty? && field != :password_confirmation
    message =
      if field == :password_confirmation
        field = :password
        resource.errors.messages[:password].select do |message|
          message.include? "confirmation"
        end
      elsif field == :password
        resource.errors.messages[:password].select do |message|
          !message.include? "confirmation"
        end
      else
        resource.errors.messages[field]
      end.first
    return "" unless message
    message = message.sub("confirmation", "")
    to_html "#{field.to_s.humanize.capitalize} #{message}"
  end

  def to_html(message)
    content_tag :div, content_tag(:p, message, class: "error-message"), class: "error-box"
  end

  def error_message_header
    return "" if resource.errors.count <= 0
    message = I18n.t("errors.messages.not_saved",
                      :count => resource.errors.count,
                      :resource => resource.class.model_name.human.downcase)

    content_tag :div, content_tag(:i, "", class: "fa fa-exclamation-triangle") + message, class: "error-header"
  end

end
