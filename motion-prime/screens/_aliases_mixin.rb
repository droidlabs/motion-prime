module MotionPrime
  module ScreenAliasesMixin
    def view_did_load; end
    def view_will_appear(animated)
      self.will_appear
    end
    def will_appear; end

    def view_did_appear(animated)
      self.on_appear
    end
    def on_appear; end

    def view_will_disappear(animated)
      self.will_disappear
    end
    def will_disappear; end

    def view_did_disappear(animated)
      self.on_disappear
    end
    def on_disappear; end

    def will_rotate(orientation, duration); end

    def should_autorotate
      true
    end

    def on_rotate; end;

    def on_load; end
  end
end