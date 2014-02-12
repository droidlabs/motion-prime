module MotionPrime
  class StaticFieldSection < Section
    include CellSectionMixin

    def form
      table
    end
  end
end
