module MotionPrime
  module HasNormalizer
    def normalize_options(options, receiver = nil, *args)
      options.each do |key, option|
        options[key] = normalize_object(option, receiver, *args)
      end
    end

    def normalize_object(object, receiver, *args)
      receiver ||= self
      if object.is_a?(Proc)
        receiver.send(:instance_exec, *args, &object)
      elsif object.is_a?(Hash)
        object.inject({}) do |result, (key, nested_object)|
          result.merge(key => normalize_object(nested_object, receiver, *args))
        end
      else
        object
      end
    end
  end
end