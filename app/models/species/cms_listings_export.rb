require 'digest/sha1'
require 'csv'
class Species::CmsListingsExport < Species::ListingsExport

  private

  def csv_column_headers
    ['Id', 'Phylum', 'Class', 'Order', 'Family', 'Genus', 'ScientificName', 
    'Author', 'Rank', 'Listing', 'ListedUnder', 'Date', 'Note']
  end

  def taxon_concept_columns
    [
      :id, :phylum_name, :class_name, :order_name, :family_name, :genus_name,
      :full_name, :author_year, :rank_name, :cms_listing_original
    ]
  end

  def taxon_concept_sql_columns
    taxon_concept_columns.map{ |c| "taxon_concepts_mview.#{c}" }
  end

  def listing_changes_columns
    [:full_name_with_spp, :effective_at, :full_note_en]
  end

  def listing_changes_select_columns
    <<-SQL  
    ARRAY_TO_STRING(
      ARRAY_AGG(
        DISTINCT full_name_with_spp(original_taxon_concepts_mview.rank_name, original_taxon_concepts_mview.full_name)
      ),
      ','
    ) 
    AS original_taxon_concept_full_name_with_spp,

    ARRAY_TO_STRING(
      ARRAY_AGG(
        '**' || listing_changes_mview.species_listing_name || '** '
        || listing_changes_mview.effective_at
        ORDER BY listing_changes_mview.species_listing_name
      ),
      '\n'
    ) AS original_taxon_concept_effective_at,

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
    ) AS original_taxon_concept_full_note_en
    SQL
  end

  def original_taxon_concept_group_columns
    <<-SQL
    original_taxon_concepts_mview.full_name,
    original_taxon_concepts_mview.spp
    SQL
  end
end
