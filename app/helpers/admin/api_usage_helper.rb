module Admin::ApiUsageHelper

  def status_colours
    ['#109618', '#DDDDDD', '#EE3B3B', '#990099', '#dc3912', '#000000']
  end

  def controller_colours
    ['#dc3912', '#990099', '#109618', '#3fb0ac', '#e6af4b']
  end

  # Take the hash necessary for the line graph and replace 200 with 'Successful'
  # and anything else with 'Failed' and return newly constructed hash
  def sanitise_hash_for_line_graph(hash)
    new_hash = {}
    hash.map { |k, v|
      n = k[0] == 200 ? 'Successful' : 'Failed'
      new_hash[[n, k[1]]] = v
    }
    new_hash
  end
end
