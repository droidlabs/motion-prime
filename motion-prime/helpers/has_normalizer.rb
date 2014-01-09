module MotionPrime
  module HasNormalizer
    def normalize_options(options, receiver = nil)
      options.each do |key, option|
        options[key] = normalize_object(option, receiver)
      end
    end

    def normalize_object(object, receiver)
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