module MotionPrime
  module HasNormalizer
    def normalize_options(unordered_options, receiver = nil, order = nil)
      options = if order
        Hash[unordered_options.sort_by { |k,v| order.index(k.to_s).to_i }]
      else
        unordered_options
      end

      options.each do |key, option|
        unordered_options[key] = normalize_object(option, receiver)
      end
    end

    def normalize_object(object, receiver = nil)
      receiver ||= self
      if object.is_a?(Proc)
        normalize_value(object, receiver)
      elsif object.is_a?(Hash)
        object.inject({}) do |result, (key, nested_object)|
          result.merge(key => normalize_object(nested_object, receiver))
        end
      else
        object
      end
    end

    def normalize_value(object, receiver)
      if element?
        receiver.send(:instance_exec, section || screen, self, &object)
      else
        receiver.send(:instance_exec, self, &object)
      end
    rescue => e
      if element?
        Prime.logger.error "Can't normalize: ", self.class.name, self.name, section.try(:name)
      else
        Prime.logger.error "Can't normalize: ", self.class.name, self.name, @table.try(:class).try(:name)
      end
      raise e
    end

    def element?
      self.is_a?(BaseElement)
    end
  end
end