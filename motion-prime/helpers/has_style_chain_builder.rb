module MotionPrime
  module HasStyleChainBuilder
    def build_styles_chain(base_styles, suffixes)
      [*base_styles].map do |base_style|
        [*suffixes].map do |suffix| 
          [base_style.to_s, suffix.to_s].join('_').to_sym
        end
      end.flatten.compact.uniq
    end
  end
end