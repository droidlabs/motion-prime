module MotionPrime
  class NavigationController < UINavigationController
    # Return the main controller.
    def main_controller
      self
    end
    # Return content controller (without sidebar)
    def content_controller
      self
    end
  end
end