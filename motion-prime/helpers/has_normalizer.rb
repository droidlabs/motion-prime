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
        receiver.send(:instance_exec, self, &object)
      elsif object.is_a?(Hash)
        object.inject({}) do |result, (key, nested_object)|
          result.merge(key => normalize_object(nested_object, receiver))
        end
      else
        object
      end
    end
  end
end