module MotionPrime
  module HasStyleOptions
    def extract_font_from(options, prefix = nil)
      options ||= {}
      return options[:font] if options[:font].present?

      name_key = [prefix, 'font_name'].compact.join('_').to_sym
      size_key = [prefix, 'font_size'].compact.join('_').to_sym
      if options.slice(size_key, name_key).any?
        font_name = options[name_key] || :system
        font_size = options[size_key] || 14
        font_name.uifont(font_size)
      end
    end
  end
end
