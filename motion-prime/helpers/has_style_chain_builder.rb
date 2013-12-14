module MotionPrime
  module HasStyleChainBuilder
    def build_styles_chain(base_styles, suffixes)
      styles = []
      [*base_styles].each do |base_style|
        [*suffixes].each do |suffix|
          components = []
          components << base_style.to_s if base_style.present?
          components << suffix.to_s if suffix.present?
          styles << components.join('_').to_sym if components.present?
        end
      end
      styles
    end
  end
end