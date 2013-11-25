motion_require '../support/dm_view_controller.rb'
motion_require '../views/layout.rb'
motion_require '../screens/_base_mixin.rb'
motion_require '../helpers/has_authorization'
motion_require '../helpers/has_search_bar'
module MotionPrime
  class BaseScreen < DMViewController
    include Layout
    include ScreenBaseMixin
    include HasAuthorization
    include HasSearchBar

    def render
    end

    def default_styles
      [:base_screen, self.class_name_without_kvo.underscore.to_sym]
    end

    def on_load
      setup view, styles: default_styles do
        render
      end
    end
  end
end