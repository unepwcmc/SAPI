[
  'first_pages_cites_with_nc/animals_distributions',
  'first_pages_cites/animals_distributions',
  'first_pages_cites/plants_distributions'
].each do |f_name|
  f = File.open("/home/agnessa/workspace/SAPI/lib/assets/files/#{f_name}.csv",'w')
  File.open("/home/agnessa/workspace/SAPI/lib/assets/files/#{f_name}_original.csv").each do |l|
  #puts l
    el = l.chars.select{|i| i.valid_encoding?}.join.chomp
    if el =~ /^SpcRecID,CtyRecID,CtyShort/
      f << el+"\n"
    elsif el =~ /^(\d+,\d+,)(.+)$/m
      p1 = $1
      p2 = $2
      if p1 && p2 && (el.gsub(/\s*NULL\s*/,'') !~ /^\d+,+$/)#ignore empty records
        m = p2
        m_cleaned = m.sub(/,+$/m,'').sub(/^"/m,'').sub(/"$/m,'').gsub(/"/m,'\"')
        el = p1+"\"#{m_cleaned}\""
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
