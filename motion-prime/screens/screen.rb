motion_require '../support/mp_view_controller.rb'
motion_require '../views/layout.rb'
motion_require '../screens/_base_mixin.rb'
motion_require './extensions/_indicators_mixin'
motion_require './extensions/_navigation_bar_mixin'
motion_require '../helpers/has_authorization'
motion_require '../helpers/has_search_bar'
module MotionPrime
  class Screen < MPViewController
    include Layout
    include ScreenBaseMixin

    # extensions
    include ScreenIndicatorsMixin
    include ScreenNavigationBarMixin

    # helpers
    include HasAuthorization
    include HasSearchBar

    extend HasClassFactory

    define_callbacks :render

    def render
    end

    def default_styles
      [:base_screen, self.class_name_without_kvo.underscore.to_sym]
    end

    def will_appear
      @visible = true
      @on_appear_happened ||= {}
      unless @on_appear_happened[view.object_id]
        setup view, styles: default_styles do
          run_callbacks :render { render }
        end
      end
      @on_appear_happened[view.object_id] = true
    end

    def will_disappear
      @visible = false
    end

    def dealloc
      Prime.logger.dealloc_message :screen, self
      # FIXME: calling instance_eval in title method (_base_screen_mixin) instance variables need to be cleared manually
      clear_instance_variables(except: [:_search_bar])
      super
    end

    def visible?
      @visible
    end
  end
end