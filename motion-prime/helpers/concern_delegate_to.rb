module MotionPrime
  module ConcernDelegateTo
    def delegate_to(object, *methods)
      methods.each do |method|
        define_method method.to_sym do |*args|
          self.send(object.to_sym).send(method.to_sym, *args)
        end
      end
    end
  end
end