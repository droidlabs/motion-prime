# TODO: make it part of Sections
module MotionPrime
  module Layout
    def setup(view, options = {}, &block)
      ViewStyler.new(view, options.delete(:bounds), options).apply
      view_stack.push(view)
      block.call(view) if block_given?
      view_stack.pop
    end

    def add_view(klass, options = {}, &block)
      bounds = if view_stack.empty?
        options.delete(:parent_view).try(:bounds) || CGRectZero
      else
        view_stack.last.bounds
      end
      builder = ViewBuilder.new(klass, options)
      options = builder.options.merge(calculate_frame: true, bounds: bounds)
      view = builder.view
      view_stack.last.addSubview(view) unless view_stack.empty?
      setup(view, options, &block)
      view.on_added if view.respond_to?(:on_added)

      view
    end

    def view_stack
      @view_stack ||= []
    end

    def self.included base
      base.class_eval do
        [::UIActionSheet, ::UIActivityIndicatorView, ::UIButton, ::UIDatePicker, ::UIImageView, ::UILabel,
          ::UIPageControl, ::UIPickerView, ::UIProgressView, ::UIScrollView, ::UISearchBar, ::UISegmentedControl,
          ::UISlider, ::UIStepper, ::UISwitch, ::UITabBar, ::UITableView, ::UITableViewCell, ::UITextField, ::UITextView,
          ::UIToolbar, ::UIWebView].each do |klass|

          shorthand = "#{klass}"[2..-1].underscore.to_sym

          define_method(shorthand) do |options, &block|
            element = MotionPrime::BaseElement.factory(shorthand, options)
            element.render(to: self, &block)
            element
          end
        end
      end
    end
  end
end