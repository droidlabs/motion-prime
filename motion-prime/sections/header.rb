module MotionPrime
  class HeaderSection < Section
    include Prime::CellSectionMixin

    before_initialize :prepare_header_options

    def prepare_header_options
      @cell_type = :header
    end
  end
end