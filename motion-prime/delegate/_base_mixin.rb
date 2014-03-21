module MotionPrime
  module DelegateBaseMixin
    attr_accessor :window

    def application(application, willFinishLaunchingWithOptions:opts)
      MotionPrime::Config.configure!
      MotionPrime::Styles.define!
      Prime.logger.info "Loading Prime application with env: #{Prime.env}"
      application.setStatusBarStyle UIStatusBarStyleLightContent
      application.setStatusBarHidden false
    end

    def application(application, didFinishLaunchingWithOptions:launch_options)
      on_load(application, launch_options)
      true
    end

    def application(application, didRegisterForRemoteNotificationsWithDeviceToken: token)
      on_apn_register_success(application, token)
    end

    def application(application, didFailToRegisterForRemoteNotificationsWithError: error)
      on_apn_register_fail(application, error)
    end

    def on_load(application, launch_options)
    end

    # Return the main controller.
    def main_controller
      window.rootViewController
    end

    # Return content controller (without sidebar)
    def content_controller
      main_controller.content_controller
    end
  end
end