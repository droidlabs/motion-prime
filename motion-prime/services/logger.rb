module MotionPrime
  class Logger
    LOGGER_ERROR_LEVEL = 0
    LOGGER_INFO_LEVEL = 1
    LOGGER_DEBUG_LEVEL = 2
    LOGGER_DEALLOC_LEVEL = 3

    class_attribute :level, :dealloc_items

    def initialize
      @default_level = Config.logger.level.nil? ? :info : Config.logger.level
    end

    def error(*args)
      pp("PRIME_ERROR", *args) if LOGGER_ERROR_LEVEL <= current_level
    end

    def info(*args)
      pp("PRIME_INFO", *args) if LOGGER_INFO_LEVEL <= current_level
    end

    def debug(*args)
      pp("PRIME_DEBUG", *args) if LOGGER_DEBUG_LEVEL <= current_level
    end

    def dealloc_message(type, object, *args)
      if LOGGER_DEALLOC_LEVEL <= current_level
        if dealloc_items.include?(type.to_s)
          pp "Deallocating #{type}", object.object_id, object.to_s, *args
        end
      end
    end

    def dealloc_items
      self.class.dealloc_items || []
    end

    def current_level
      current_level = self.class.level || @default_level
      case current_level.to_s
      when 'error'
        LOGGER_ERROR_LEVEL
      when 'info'
        LOGGER_INFO_LEVEL
      when 'debug'
        LOGGER_DEBUG_LEVEL
      when 'dealloc'
        LOGGER_DEALLOC_LEVEL
      else
        2
      end
    end
  end
end