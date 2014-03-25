module MotionPrime
  module ScreenIndicatorsMixin
    def show_activity_indicator
      if @activity_indicator_view.nil?
        @activity_indicator_view = UIActivityIndicatorView.gray
        @activity_indicator_view.center = CGPointMake(view.center.x, view.center.y)
        view.addSubview @activity_indicator_view
      end
      @activity_indicator_view.startAnimating
    end

    def hide_activity_indicator
      return unless @activity_indicator_view
      @activity_indicator_view.stopAnimating
    end

    def show_progress_indicator(text = nil, options = {})
      options[:styles] ||= []
      options[:styles] << :base_progress_indicator
      options[:styles] << :"#{self.class_name_without_kvo.underscore.gsub('_screen', '')}_indicator"
      options[:details_label_text] = text

      if @progress_indicator_view.nil?
        options[:add_to_view] ||= self.view
        @progress_indicator_view = self.progress_hud(options).view
      else
        self.set_options(@progress_indicator_view, options.except(:add_to_view))
        @progress_indicator_view.show options.has_key?(:animated) ? options[:animatetd] : true
      end
    end

    def hide_progress_indicator(animated = true)
      @progress_indicator_view.try(:hide, animated)
    end

    def show_notice(message, time = 1.0, type = :notice)
      hud_type = case type.to_s
      when 'alert' then MBAlertViewHUDTypeExclamationMark
      else MBAlertViewHUDTypeCheckmark
      end

      unless time === false
        MBHUDView.hudWithBody(message, type: hud_type, hidesAfter: time, show: true)
      end
    end

    def show_spinner(message = nil)
      if message.present?
        spinner_message_element.set_text(message)
        spinner_message_element.show
      end
      spinner_element.show
      spinner_element.view.init_animation
    end

    def hide_spinner
      spinner_element.hide
      spinner_message_element.hide
    end

    private

      def spinner_element
        @_spinner_element ||= self.spinner({
          styles: base_styles_for('spinner'),
          hidden: true})
      end

      def spinner_message_element
        @_spinner_message_element ||= self.label({
          styles: base_styles_for('spinner_message'),
          text: '',
          hidden: true})
      end

      def base_styles_for(name)
        ([:base] + default_styles).map { |base| :"#{base}_#{name}" }
      end
  end
end