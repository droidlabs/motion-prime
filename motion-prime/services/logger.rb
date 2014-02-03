module MotionPrime
  class Logger
    LOGGER_ERROR_LEVEL = 0
    LOGGER_INFO_LEVEL = 1
    LOGGER_DEBUG_LEVEL = 2

    class_attribute :level

    def initialize
      @default_level = Config.logger.level.nil? ? :info : Config.logger.level
    end

    def error(*args)
      pp(*args) if LOGGER_ERROR_LEVEL <= current_level
    end

    def info(*args)
      pp(*args) if LOGGER_INFO_LEVEL <= current_level
    end

    def debug(*args)
      pp(*args) if LOGGER_DEBUG_LEVEL <= current_level
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
      else
        2
      end
    end
  end
end