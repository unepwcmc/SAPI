#Encoding: utf-8
class Checklist
  attr_accessor :taxon_concepts_rel
  def initialize(options)
    @designation = options[:designation] || Designation::CITES

    @taxon_concepts_rel = TaxonConcept.scoped.
      select([:"taxon_concepts.id", :data, :listing, :depth]).
      joins(:designation).
      where('designations.name' => @designation)

    #filter by geo entities
    @geo_options = []
    @geo_options += options[:country_ids] unless options[:country_ids].nil?
    @geo_options += options[:cites_region_ids] unless options[:cites_region_ids].nil?
    unless @geo_options.empty?
      @taxon_concepts_rel = @taxon_concepts_rel.by_geo_entities(@geo_options)
    end
    #filter by species listing
    unless options[:cites_appendices].nil?
      @taxon_concepts_rel = @taxon_concepts_rel.by_cites_appendices(options[:cites_appendices])
    end

    #possible output layouts are:
    #taxonomic (hierarchic, taxonomic order)
    #checklist (flat, alphabetical order)
    @output_layout = options[:output_layout] || :alphabetical
    if @output_layout == :taxonomic
      @taxon_concepts_rel = @taxon_concepts_rel.taxonomic_layout
    else
      @taxon_concepts_rel = @taxon_concepts_rel.alphabetical_layout
    end
    #include common names?
    @taxon_concepts_rel = @taxon_concepts_rel.with_common_names
  end

  def generate
    @taxon_concepts_rel.all
  end

  def pdf
    Prawn::Document.generate("checklist.pdf") do |pdf|
      pdf.text "CITES CHECKLIST", :align => :center, :size => 18
      pdf.move_down 12
      
      pdf.column_box([0, pdf.cursor], :columns => 2, :width => pdf.bounds.width) do
        generate.each do |tc|
          unless tc.full_name.blank?
            pdf.formatted_text [
              {
                :text =>
                  if ['FAMILY','ORDER','CLASS'].include? tc.rank_name
                    tc.full_name.upcase
                  else
                    tc.full_name
                  end + ' ',
                :styles => 
                  if ['SPECIES', 'SUBSPECIES'].include? tc.rank_name
                    [:italic]
                  elsif tc.rank_name == 'GENUS'
                    [:italic, :bold]
                  else
                    [:bold]
                  end
              },
              {:text => tc.current_listing + ' ', :styles => [:bold]},
              {:text => "#{tc.family_name} ".upcase},
              {:text => "(#{tc.class_name}) "},
              {
                :text =>
                  unless tc.english.blank?
                    "(E) #{tc.english} "
                  else
                    ''
                  end
              },
              {
                :text =>
                  unless tc.spanish.blank?
                    "(S) #{tc.spanish} "
                  else
                    ''
                  end
              },
              {
                :text =>
                  unless tc.french.blank?
                    "(F) #{tc.french} "
                  else
                    ''
                  end
              }
            ]
          end
        end

      end
    end
  end

end
