module Dictionary

  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    # builds a set of constants like: KEY = 'KEY'
    # as well as a method self.dict that returns all of those constants' values
    def build_dictionary(*keys)
      # keys.each do |key|
      #   const_set key.to_s.upcase, key.to_s.upcase
      # end
      # define_singleton_method("dict") { keys.map{|k| k.to_s.upcase } }
      build_basic_dictionary(*keys) { |key| key.to_s.upcase }
    end

    def build_basic_dictionary(*keys)
      keys.each do |key|
        const_set key.to_s.upcase,
        if block_given?
          yield(key)
        else
          key
        end
      end
      define_singleton_method("dict") { keys.map { |k| k.to_s.upcase } }
    end
  end
end
