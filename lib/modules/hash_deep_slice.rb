Hash.class_eval do

  def deep_slice(*allowed_keys)
    sliced = {}
    allowed_keys.each do |allowed_key|
      if allowed_key.is_a?(Hash)
        allowed_key.each do |allowed_subkey, allowed_subkey_values|
          if has_key?(allowed_subkey)
            value = self[allowed_subkey]
            if value.is_a?(Hash)
              sliced[allowed_subkey] = value.deep_slice(*Array.wrap(allowed_subkey_values))
            elsif value.nil?
              sliced[allowed_subkey] = ''
            else
              raise ArgumentError, "can only deep-slice hash values, but value for #{allowed_subkey.inspect} was of type #{value.class.name}"
            end
          end
        end
      else
        if has_key?(allowed_key)
          sliced[allowed_key] = self[allowed_key]
        end
      end
    end
    sliced
  end

end
