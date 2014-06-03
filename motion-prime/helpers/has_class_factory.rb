# These things required because camelize/constantize/classify methods are very slow
module MotionPrime
  module HasClassFactory
    def class_factory(name, is_mp_class = false)
      if is_mp_class
        value = Prime.class_factory_cache["motion_prime/#{name}"]
        return value if value
        class_name = camelize_factory(name)

        return nil unless MotionPrime.const_defined?(class_name)
        class_name = "MotionPrime::#{class_name}"
        name = "motion_prime/#{name}"
      else
        value = Prime.class_factory_cache[name]
        return value if value
        class_name = camelize_factory(name)
      end
      Prime.class_factory_cache[name] = class_name.constantize
    end

    def camelize_factory(name)
      value = Prime.camelize_factory_cache[name]
      return value if value
      Prime.camelize_factory_cache[name] = name.camelize
    end

    def underscore_factory(name)
      value = Prime.underscore_factory_cache[name]
      return value if value
      Prime.underscore_factory_cache[name] = name.underscore
    end

    def low_camelize_factory(name)
      value = Prime.low_camelize_factory_cache[name]
      return value if value
      Prime.low_camelize_factory_cache[name] = name.camelize(:lower)
    end
  end
end