  f = File.open("/home/agnessa/workspace/SAPI/lib/assets/files/first_pages_cites_with_nc/_animals_listing_changes.csv",'w')

File.open("/home/agnessa/workspace/SAPI/lib/assets/files/first_pages_cites_with_nc/animals_listing_changes.csv").each do |l|
  #puts l
  el = l.chars.select{|i| i.valid_encoding?}.join.chomp
  if el =~ /\d+,.+?,.+?,.+?(,.+$)/
    m = $1
    #puts m
    if m =~ /^,NULL,+/
      #puts 'NULL'
      el.sub!(m,'')
    elsif m =~ /,(.+?),+\s$/
      #puts 'CONTENT ' + $1
      el.sub!($1,"\"#{$1}\"")
      el.sub!(/,+\s$/,'')
    end
    #puts el
  end
  f << el+"\n"
end
  f.close

