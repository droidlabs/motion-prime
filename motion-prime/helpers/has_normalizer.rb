module MotionPrime
  module HasNormalizer
    def normalize_options(unordered_options, receiver = nil, order = nil, keys = nil)
      options = if order
        Hash[unordered_options.sort_by { |k,v| order.index(k.to_s).to_i }]
      else
        unordered_options
      end

      filtered_options = keys.nil? ? options : options.slice(*keys)
      filtered_options.keys.each do |key|
        @_key_chain = [key] if Prime.env.development?
        unordered_options[key] = normalize_object(filtered_options[key], receiver)
      end
      unordered_options
    end

    def normalize_object(object, receiver = nil)
      receiver ||= self
      if object.is_a?(Proc)
        normalize_value(object, receiver)
      elsif object.is_a?(Hash)
        object.inject({}) do |result, (key, nested_object)|
          if Prime.env.development?
            # FIXME: malloc
            @_key_chain ||= []
            @_key_chain << key
          end
          result.merge(key => normalize_object(object[key], receiver))
        end
      else
        object
      end
    end

    def normalize_value(object, receiver = nil)
      receiver ||= self
      if element?
        receiver.send(:instance_exec, section || screen, self, &object)
      else
        receiver.send(:instance_exec, self, &object)
      end
    rescue => e
      Prime.logger.error "Can't normalize: ", *debug_info, @_key_chain
      raise e
    end

    def element?
      self.is_a?(BaseElement)
    end

    def debug_info
      if element?
        [self.class.name, self.name, section.try(:name)]
      elsif self.is_a?(Section)
        [self.class.name, self.name, @collection_section.try(:class).try(:name)]
      else
        [self.class.name]
      end
    end
  end
end