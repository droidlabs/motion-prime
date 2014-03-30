module MotionPrime
  class Logger
    LOGGER_ERROR_LEVEL = 0
    LOGGER_INFO_LEVEL = 1
    LOGGER_DEBUG_LEVEL = 2
    LOGGER_DEALLOC_LEVEL = 3

    COLORS = {
      red:    [ "\e[0;31m", "\e[0m" ],
      green:  [ "\e[0;32m", "\e[0m" ],
      yellow: [ "\e[0;33m", "\e[0m" ],
      blue:   [ "\e[0;34m", "\e[0m" ],
      none:   [ "", ""]
    }

    class_attribute :level, :dealloc_items
    attr_accessor :disabled

    def initialize
      @default_level = Config.logger.level.nil? ? :info : Config.logger.level
      @disabled = false
    end

    # Log message, colorized if using simulator.
    # @param message [Array<String>, String] Message or array of messages to log.
    # @param color [Symbol] Color of message: red, green, yellow, blue.
    # @return message [Array<String>, String] Logged message
    def log(objects, label = '', color = :none)
      message = "#{label || 'PRIME_LOG'} : " + Array.wrap(objects).map(&:inspect).join(',')
      if Device.simulator?
        color_parts = COLORS[color] || COLORS[:none]
        output(color_parts.first + message + color_parts.last)
      else
        output(message)
      end
      objects
    end

    # Output message, using "puts" for simulator and NSLog for Device.
    # @param message [String] Message or array of messages to output.
    # @return message [Array<String>, String] Message
    def output(message)
      return if disabled
      if Device.simulator?
        puts(message)
      else
        NSLog(message)
      end
      message
    end

    def error(*args)
      log(args, "PRIME_ERROR", :red) if LOGGER_ERROR_LEVEL <= current_level
    end

    def info(*args)
      log(args, "PRIME_INFO", :green) if LOGGER_INFO_LEVEL <= current_level
    end

    def debug(*args)
      log(args, "PRIME_DEBUG", :yellow) if LOGGER_DEBUG_LEVEL <= current_level
    end

    def dealloc_message(type, object, *args)
      if LOGGER_DEALLOC_LEVEL <= current_level
        if dealloc_items.include?(type.to_s)
          log([object.object_id, object.to_s] + args, "DEALLOC #{type}", :yellow)
        end
      end
    end

    private
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