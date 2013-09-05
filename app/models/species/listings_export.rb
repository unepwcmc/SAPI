require 'digest/sha1'
require 'csv'
class Species::ListingsExport
  attr_reader :file_name, :public_file_name

  def initialize(designation, filters)
    @designation = designation
    @filters = filters
    @taxon_concepts_ids = filters[:taxon_concepts_ids]
    @geo_entities_ids = filters[:geo_entities_ids]
    @include_cites = @designation.name == 'EU' && filters[:include_cites] == "true"

    #TODO this can go once we change the way appendix is matched
    #there should be an array of species listing ids in taxon_concepts_mview
    #then we would not need the abbreviations
    @species_listings_ids = if filters[:species_listings_ids]
      SpeciesListing.where(
        :id => filters[:species_listings_ids],
        :designation_id => @designation.id
      ).map(&:abbreviation)
    elsif filters[:appendices]
       SpeciesListing.where(
        :abbreviation => filters[:appendices],
        :designation_id => @designation.id
      ).map(&:abbreviation)   
    end  
  end

  def resource_name
    designation_name = ['cites', 'eu', 'cms'].find{ |d| d == @designation.name.downcase }
    "#{designation_name}_listings"
  end

  def path 
    @path ||= "public/downloads/#{resource_name}/"
  end

  def file_name
    @file_name ||= path + Digest::SHA1.hexdigest(
      @filters.to_hash.symbolize_keys!.sort.to_s
    ) + ".csv"
  end

  def export
    return false unless query.any?
    if !File.file?(file_name)
      to_csv
    end
    ctime = File.ctime(@file_name).strftime('%Y-%m-%d %H:%M')
    @public_file_name = "#{resource_name}_#{ctime}.csv"
    [
      @file_name,
      {:filename => @public_file_name, :type => 'text/csv'}
    ]
  end

  def query
    rel = MTaxonConcept.select(select_columns).without_non_accepted.
    where(
      :taxonomy_id => @designation.taxonomy_id,
      :"#{@designation.name.downcase}_show" => true,
      :rank_name => [Rank::SPECIES, Rank::SUBSPECIES, Rank::VARIETY]
    ).
    where("taxon_concepts_mview.#{@designation.name.downcase}_listing_original != 'NC'").
    joins(
    <<-SQL
      JOIN listing_changes_mview 
      ON listing_changes_mview.taxon_concept_id = taxon_concepts_mview.id
      AND designation_name = '#{@designation.name}'
      AND is_current
      AND change_type_name = 'ADDITION'
      JOIN taxon_concepts_mview original_taxon_concepts_mview
      ON listing_changes_mview.original_taxon_concept_id = original_taxon_concepts_mview.id
      LEFT JOIN taxon_concepts_mview inclusion_taxon_concepts_mview
      ON listing_changes_mview.inclusion_taxon_concept_id = inclusion_taxon_concepts_mview.id
    SQL
    ).
    group(group_columns).
    order('taxon_concepts_mview.taxonomic_position')
    rel = if @geo_entities_ids
      MTaxonConceptFilterByAppendixPopulationQuery.new(
        rel, @species_listings_ids, @geo_entities_ids
      ).relation(@designation.name)
    elsif @species_listings_ids
      MTaxonConceptFilterByAppendixQuery.new(
        rel, @species_listings_ids
      ).relation(@designation.name)
    else
      rel
    end
    if @taxon_concepts_ids
      rel = MTaxonConceptFilterByIdWithDescendants.new(rel, @taxon_concepts_ids).relation
    end
    rel
  end

private

  def to_csv
    limit = 5000
    offset = 0
    CSV.open(@file_name, 'wb') do |csv|
      csv << csv_column_headers
      until (records = query.limit(limit).offset(offset)).empty? do
        records.to_a.each do |rec|
          row = taxon_concept_columns.map do |c|
            rec.send(c)
          end
          listing_changes_columns.each do |c|
            row << rec[:"original_taxon_concept_#{c}"]
          end
          csv << row
        end
        offset += limit
      end
    end
  end

  def csv_column_headers
    headers = taxon_concept_columns.map do |c|
      Checklist::ColumnDisplayNameMapping.column_display_name_for(c)
    end
    if @include_cites
      headers << 'CITES' + headers.pop
    end
    headers + ['Party', 'Listed under', 'Full note', '# Full note']
  end

  def taxon_concept_columns
    columns = [
      :id, :kingdom_name, :phylum_name, :class_name, :order_name, :family_name,
      :genus_name, :species_name, :subspecies_name,
      :full_name, :author_year, :rank_name, :"#{@designation.name.downcase}_listing_original"
    ]
    if @include_cites
      columns << :cites_listing_original
    end
    columns
  end

  def select_columns
    (
      taxon_concept_sql_columns.each_with_index.map do |c, idx|
        "#{c} AS #{taxon_concept_columns[idx]}" # alias all
      end <<
      listing_changes_select_columns
    ).join(', ')
  end

  def group_columns
    (
      taxon_concept_sql_columns +
      [original_taxon_concept_group_columns,
      'taxon_concepts_mview.taxonomic_position']
    ).join(',')
  end

  def taxon_concept_sql_columns
    # TODO maybe use a view or sth...
    res = taxon_concept_columns.map{ |c| "taxon_concepts_mview.#{c}" }
    # columns to lowercase
    [
      taxon_concept_columns.index(:species_name),
      taxon_concept_columns.index(:subspecies_name)
    ].each do |idx|
      res[idx] = "LOWER(#{res[idx]})"
    end
    # force NC on blanks
    if idx = taxon_concept_columns.index(:cites_listing_original)
      col = res[idx]
      res[idx] = "CASE WHEN #{col} IS NULL OR LENGTH(#{col}) = 0 THEN 'NC' ELSE #{col} END"
    end
    res
  end

  def listing_changes_columns
    [:party_iso_code, :full_name_with_spp, :full_note_en, :hash_full_note_en]
  end

  def listing_changes_select_columns
    <<-SQL
    ARRAY_TO_STRING(
      ARRAY_AGG(
        DISTINCT listing_changes_mview.party_iso_code
      ),
      ','
    ) AS original_taxon_concept_party_iso_code,
    
    ARRAY_TO_STRING(
      ARRAY_AGG(
        DISTINCT full_name_with_spp(
          COALESCE(inclusion_taxon_concepts_mview.rank_name, original_taxon_concepts_mview.rank_name),
          COALESCE(inclusion_taxon_concepts_mview.full_name, original_taxon_concepts_mview.full_name)
        )
      ),
      ','
    ) 
    AS original_taxon_concept_full_name_with_spp,

    ARRAY_TO_STRING(
      ARRAY_AGG(
        '**' || listing_changes_mview.species_listing_name || '** '
        || CASE 
          WHEN LENGTH(listing_changes_mview.auto_note) > 0 THEN '[' || listing_changes_mview.auto_note || '] ' 
          ELSE '' 
        END 
        || CASE 
          WHEN LENGTH(listing_changes_mview.full_note_en) > 0 THEN strip_tags(listing_changes_mview.full_note_en) 
          ELSE strip_tags(listing_changes_mview.short_note_en) 
        END
        ORDER BY listing_changes_mview.species_listing_name
      ),
      '\n'
    ) AS original_taxon_concept_full_note_en,

    ARRAY_TO_STRING(
      ARRAY_AGG(
        '**' || species_listing_name || '** ' || listing_changes_mview.hash_ann_symbol || ' ' 
        || strip_tags(listing_changes_mview.hash_full_note_en)
        ORDER BY species_listing_name
      ),
      '\n'
    ) AS original_taxon_concept_hash_full_note_en
    SQL
  end

  def original_taxon_concept_group_columns
    <<-SQL
    COALESCE(inclusion_taxon_concepts_mview.full_name, original_taxon_concepts_mview.full_name),
    COALESCE(inclusion_taxon_concepts_mview.spp, original_taxon_concepts_mview.spp)
    SQL
  end
end
