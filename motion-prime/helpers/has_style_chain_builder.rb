module MotionPrime
  module HasStyleChainBuilder
    def build_styles_chain(base_styles, suffixes)
      [*base_styles].uniq.compact.map { |base_style| [*suffixes].uniq.compact.map { |suffix| [base_style, suffix].join('_').to_sym } }.flatten
    end
  end
end