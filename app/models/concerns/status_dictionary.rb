module StatusDictionary

  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods

    def build_steps(*steps)
      statuses = ([:new, :submitted, :closed] + steps).map(&:to_s)
      const_set(:STEPS, steps)
      build_basic_dictionary(*statuses)
      define_singleton_method :status_dict do
        statuses
      end
      steps.each do |status|
        define_dynamic_status_check(status)
        define_dynamic_status_or_submitting_check(status)
      end
    end

    protected

    def define_dynamic_status_check(status)
      class_eval <<-RUBY
        # def inputs?
        #   status == self.INPUTS
        # end
        def #{status}?
          status == self.class::#{status.upcase}
        end
      RUBY
    end

    def define_dynamic_status_or_submitting_check(status)
      class_eval <<-RUBY
        # def inputs_or_submitting?
        #   status == self.INPUTS || submitting?
        # end
        def #{status}_or_submitting?
          status == self.class::#{status.upcase} || submitting?
        end
      RUBY
    end

  end
end
