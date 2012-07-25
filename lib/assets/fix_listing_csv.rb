[
  'first_pages_cites_with_nc/animals_listing_changes',
  'first_pages_cites/animals_listing_changes',
  'first_pages_cites/plants_listing_changes'
].each do |f_name|
  f = File.open("/home/agnessa/workspace/SAPI/lib/assets/files/#{f_name}.csv",'w')
  File.open("/home/agnessa/workspace/SAPI/lib/assets/files/#{f_name}_original.csv").each do |l|
  #puts l
    el = l.chars.select{|i| i.valid_encoding?}.join.chomp
    if el =~ /^SpcRecID,LegListing,LegDateListed,CtyRecID,LegNotes/
      f << el+"\n"
    elsif el =~ /^(\d+,.+?,.+?,.+?,)(.+)$/m
      p1 = $1
      p2 = $2
      if p1 && p2 && (el.gsub(/\s*NULL\s*/,'') !~ /^\d+,+$/)#ignore empty listings
        m = p2
        el = if m =~ /^NULL,+/
          p1
        elsif m =~ /^(.+?),+$/m
          m_cleaned = m.sub(/,+$/m,'').sub(/^"/m,'').sub(/"$/m,'').gsub(/"/m,'\"')
          p1+"\"#{m_cleaned}\""
        end
        unless el.nil?
          el.gsub!(/\s*NULL\s*/,'')
          f << el+"\n" unless el.gsub(',','').chomp == ''
        end
      end
    else
      puts 'sth gone wrong here'
      puts el
    end
  end
  f.close
end
