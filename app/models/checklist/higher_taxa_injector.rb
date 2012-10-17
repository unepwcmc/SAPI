class Checklist::HigherTaxaInjector
  def initialize(taxon_concepts_rel)
    @taxon_concepts_rel = taxon_concepts_rel
  end

  def run
    res = []
    @taxon_concepts_rel.each_with_index do |tc, i|
      res += higher_taxa_headers(
        (i > 0 ? @taxon_concepts_rel[i-1] : nil),
        tc,
        false #just immediate parent
      )
      res << tc
    end
    res
  end

  #returns array of HigherTaxaItems that need to be inserted
  #between prev_item and curr_item in the taxonomic layout
  def higher_taxa_headers(prev_item, curr_item, all = true)
    ranks = ['PHYLUM', 'CLASS', 'ORDER', 'FAMILY', 'GENUS', 'SPECIES']
    header_ranks = 4 #use only this many from the ranks table for headers
    res = []
    # puts tc.full_name
    prev_path = (prev_item.nil? ? '' : prev_item.taxonomic_position)
    curr_path = curr_item.taxonomic_position
    return res unless prev_path && curr_path
    prev_path_segments = prev_path.split('.')
    curr_path_segments = curr_path.split('.')
    common_segments = 0
    for j in 0..prev_path_segments.length-1
      if curr_path_segments[j] == prev_path_segments[j]
        common_segments += 1
      else
        break
      end
    end
    # puts prev_path
    # puts curr_path
    # puts "common segments: #{common_segments}"
    missing_segments = unless prev_path.blank?
      if prev_path_segments.length < curr_path_segments.length
        prev_path_segments.length - common_segments
      else
        curr_path_segments.length - common_segments
      end
    else
      curr_path_segments.length - 1
    end
    # puts "missing segments: #{missing_segments}"
    if missing_segments > 1
      rank_idx = ranks.index(curr_item.rank_name)
      rank_idx = (ranks.length - 1) if rank_idx.nil?
      lower_bound = (ranks.length - missing_segments)
      higher_bound = (rank_idx > header_ranks - 1 ? header_ranks - 1 : rank_idx)
      higher_bound.downto lower_bound do |k|
        # puts ranks[k]
        # puts tc.send("#{ranks[k].downcase}_name")
        hti_properties = {
          'id' => curr_item.send("#{ranks[k].downcase}_id"),
          'rank_name' => ranks[k],
          'full_name' => curr_item.send("#{ranks[k].downcase}_name")
        }
        #copy ancestor ranks
        k.downto 0 do |l|
          ancestor_rank = ranks[l].downcase
          hti_properties["#{ancestor_rank}_name"] = curr_item.send("#{ancestor_rank}_name")
          hti_properties["#{ancestor_rank}_id"] = curr_item.send("#{ancestor_rank}_id")
        end
        hti = Checklist::HigherTaxaItem.new(hti_properties)
        res << hti
        break unless all
      end
    end
    res
  end

end