# Array parameters are sorted for caching purposes.
module SearchParamSanitiser

  def sanitise_string(s)
    s && s.strip
  end

  def sanitise_upcase_string(s)
    s && s.strip.upcase
  end

  def sanitise_symbol(s, default = nil)
    return nil unless s
    s.is_a?(Symbol) && s || s.is_a?(String) && s.strip.downcase.to_sym || default
  end

  def sanitise_boolean(b, default = nil)
    b && ActiveRecord::ConnectionAdapters::Column.value_to_boolean(b) || default
  end

  def sanitise_positive_integer(i, default = nil)
    new_i =
      if i.is_a?(String)
        tmp = i.to_i
        tmp.to_s == i ? tmp : nil
      else
        i
      end
    new_i && new_i > 0 ? new_i : default
  end

  def sanitise_float(f, default = nil)
    new_f =
      if f.is_a?(String)
        Float(f) rescue nil
      else
        f
      end
    new_f || default
  end

  def sanitise_integer_array(ary)
    new_ary = ary.is_a?(String) ? ary.split(',') : ary
    return [] if new_ary.blank? || !new_ary.is_a?(Array)
    new_ary.map! { |e| sanitise_positive_integer(e) }
    new_ary.compact!
    new_ary.sort!
    new_ary
  end

  def sanitise_doc_ids_array(ary)
    new_ary = ary.is_a?(String) ? ary.split(',') : ary
    return [] if new_ary.blank? || !new_ary.is_a?(Array)
    new_ary.map! { |e| sanitise_positive_integer(e) }
    new_ary.compact!
    new_ary
  end

  def sanitise_string_array(ary)
    new_ary = ary.is_a?(String) ? ary.split(',') : ary
    return [] if new_ary.blank? || !new_ary.is_a?(Array)
    new_ary.sort!
    new_ary
  end

  def sanitise_upcase_string_array(ary)
    new_ary = sanitise_string_array(ary)
    new_ary && new_ary.map!(&:upcase) || []
  end

  def whitelist_param(value, allowed_values, default)
    if value && allowed_values.include?(value)
      value
    else
      default
    end
  end

  def whitelist_param_array(values, allowed_values, defaults)
    if values
      values & allowed_values
    else
      defaults
    end
  end

end
