module MotionPrime
  module ScreenIndicatorsMixin
    def show_activity_indicator(render_target = nil, options = {})
      render_target ||= view
      @activity_indicator_view ||= {}
      indicator = @activity_indicator_view[render_target.object_id] ||= begin
        indicator = UIActivityIndicatorView.gray
        render_target.addSubview(indicator)
        indicator
      end

      center = options[:center] || {}
      indicator.center = CGPointMake(center.fetch(:x, render_target.center.x), center.fetch(:y, render_target.center.y))
      indicator.startAnimating
    end

    def hide_activity_indicator(render_target = nil)
      @activity_indicator_view ||= {}
      render_target ||= view
      @activity_indicator_view[render_target.object_id].try(:stopAnimating)
    end

    def show_progress_indicator(text = nil, options = {})
      @_showing_indicator = true
      options[:styles] ||= []
      options[:styles] << :base_progress_indicator
      options[:styles] << :"#{self.class_name_without_kvo.underscore.gsub('_screen', '')}_indicator"
      options[:details_label_text] = text

      if @progress_indicator_view.nil?
        options[:add_to_view] ||= self.view
        @progress_indicator_view = self.progress_hud(options).view
      else
        self.update_options_for(@progress_indicator_view, options.except(:add_to_view))
        @progress_indicator_view.show options.has_key?(:animated) ? options[:animatetd] : true
      end
    end

    def hide_progress_indicator(animated = true)
      @progress_indicator_view.try(:hide, animated)
      @_showing_indicator = false
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