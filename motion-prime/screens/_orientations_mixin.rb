module MotionPrime
  module ScreenOrientationsMixin
    def should_rotate(orientation)
      case orientation
      when UIInterfaceOrientationPortrait
        return supported_orientation?("UIInterfaceOrientationPortrait")
      when UIInterfaceOrientationLandscapeLeft
        return supported_orientation?("UIInterfaceOrientationLandscapeLeft")
      when UIInterfaceOrientationLandscapeRight
        return supported_orientation?("UIInterfaceOrientationLandscapeRight")
      when UIInterfaceOrientationPortraitUpsideDown
        return supported_orientation?("UIInterfaceOrientationPortraitUpsideDown")
      else
        false
      end
    end

    def supported_orientation?(orientation)
      NSBundle.mainBundle.infoDictionary["UISupportedInterfaceOrientations"].include?(orientation)
    end

    def supported_orientations
      ors = 0
      NSBundle.mainBundle.infoDictionary["UISupportedInterfaceOrientations"].each do |ori|
        case ori
        when "UIInterfaceOrientationPortrait"
          ors |= UIInterfaceOrientationMaskPortrait
        when "UIInterfaceOrientationLandscapeLeft"
          ors |= UIInterfaceOrientationMaskLandscapeLeft
        when "UIInterfaceOrientationLandscapeRight"
          ors |= UIInterfaceOrientationMaskLandscapeRight
        when "UIInterfaceOrientationPortraitUpsideDown"
          ors |= UIInterfaceOrientationMaskPortraitUpsideDown
        end
      end
      ors
    end
  end
end