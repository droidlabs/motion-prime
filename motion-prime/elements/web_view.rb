module MotionPrime
  class WebViewElement < BaseElement    
    def view_class
      "UIWebView"
    end

    def dealloc
      view.try(:setDelegate, nil)
      super
    end
  end
end