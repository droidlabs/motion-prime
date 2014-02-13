module MotionPrime
  class MapElement < BaseElement
    after_render :remove_watermark
    def view_class
      "MKMapView"
    end

    def remove_watermark
      self.view.subviews.last.removeFromSuperview
    end
  end
end