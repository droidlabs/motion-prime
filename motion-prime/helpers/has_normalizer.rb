module MotionPrime
  module HasNormalizer
    def normalize_options(options, receiver = nil)
      receiver ||= self
      options.each do |key, option|
        options[key] = if option.is_a?(Proc)
          receiver.send :instance_eval, &option
        else
          option
        end
      end
    end
  end
end