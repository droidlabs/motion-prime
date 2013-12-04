module MotionPrime
  module HasStyleChainBuilder
    def build_styles_chain(base_styles, suffixes)
      [*base_styles].compact.map(&:to_s).uniq.map { |base_style| [*suffixes].compact.map(&:to_s).uniq.map { |suffix| [base_style, suffix].join('_').to_sym } }.flatten
    end
  end
end