module MotionPrime
  module HasStyleChainBuilder
    def build_styles_chain(base_styles, suffixes)
      styles = []
      [*base_styles].each do |base_style|
        [*suffixes].each do |suffix|
          components = []
          styles << [base_style.to_s, suffix.to_s].join('_').to_sym if base_style.present? && suffix.present?
        end
      end
      styles
    end
  end
end