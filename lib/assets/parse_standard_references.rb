[
  'standard_nomenclature_fauna',
  'standard_nomenclature_flora'
].each do |f_name|
  f = File.open("/home/agnessa/workspace/SAPI/lib/assets/#{f_name}.csv",'w')
  f << "Author, Year, Title, Scope\n"
  File.open("/home/agnessa/workspace/SAPI/lib/assets/#{f_name}.txt").each do |l|
    if l =~ /(.+)\((\d{4})\):(.+?)\[(.+?)\]/m
      #puts "--- AUTHOR: #{$1} YEAR: #{$2} TITLE + PUBLISHER: #{$3} SCOPE: #{$4}"
      row = [$1, $2, $3]
      scope = $4
      scope = scope.sub(/^as a guideline when making reference to the names of species of /, '').
        sub(/^for /,'').split(' and ').join(';')
      row = (row << scope).map{|i| "\"#{i}\""}
      f << "#{row.join(',')}\n"
    else
      puts "WRONG"
      puts "### #{l}"
    end
    #puts "### #{l}"
  end
  f.close
end