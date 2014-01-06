module MotionPrime
  module HasStyleChainBuilder
    def build_styles_chain(base_styles, suffixes)
      styles = []
      [*base_styles].each do |base_style|
        [*suffixes].each do |suffix|
          components = []
          # don't use present? here, it's slower, while this method should be very fast
          if base_style && base_style != '' && suffix && suffix != ''
            styles << [base_style.to_s, suffix.to_s].join('_').to_sym
          end
        end
      end
      styles
    end
  end
end