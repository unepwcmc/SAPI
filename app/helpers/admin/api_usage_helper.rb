module Admin::ApiUsageHelper
  # Take the hash necessary for the line graph and replace 200 with 'Successful'
  # and anything else with 'Failed' and return newly constructed hash
  def sanitise_hash_for_line_graph(hash)
    new_hash = {}
    hash.map { |k,v|
      n = k[0] == 200 ? 'Successful' : 'Failed'
      new_hash[[n, k[1]]] = v
    }
    new_hash
  end
end
