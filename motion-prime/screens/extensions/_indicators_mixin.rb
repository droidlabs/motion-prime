module MotionPrime
  module ScreenIndicatorsMixin
    def show_activity_indicator
      if @activity_indicator_view.nil?
        @activity_indicator_view = UIActivityIndicatorView.gray
        @activity_indicator_view.center = CGPointMake(view.center.x, view.center.y - 50)
        view.addSubview @activity_indicator_view
      end
      @activity_indicator_view.startAnimating
    end

    def hide_activity_indicator
      return unless @activity_indicator_view
      @activity_indicator_view.stopAnimating
    end

    def show_notice(message, time = 1.0, type = :notice)
      hud_type = case type.to_s
      when 'alert' then MBAlertViewHUDTypeExclamationMark
      else MBAlertViewHUDTypeCheckmark
      end
      MBHUDView.hudWithBody message,
        type: hud_type, hidesAfter: time, show: true
    end
  end
end