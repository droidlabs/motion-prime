# TODO: make it part of Sections
motion_require '../support/mp_cell_with_section'
motion_require '../support/mp_spinner'
module MotionPrime
  module Layout
    def add_view(klass, options = {}, &block)
      options = options.clone
      render_target = options.delete(:render_target)
      parent_view = options.delete(:parent_view) || render_target

      bounds = if view_stack.empty?
        parent_view.try(:bounds) || CGRectZero
      else
        view_stack.last.bounds
      end
      builder = ViewBuilder.new(klass, options)
      options = builder.options.merge(calculate_frame: true, bounds: bounds)
      view = builder.view
      insert_index = options.delete(:at_index)

      if render_target
        options[:bounds] = render_target.bounds
        insert_index ? render_target.insertSubview(view, atIndex: insert_index) : render_target.addSubview(view)
      elsif view_stack.any?
        insert_index ? view_stack.last.insertSubview(view, atIndex: insert_index) : view_stack.last.addSubview(view)
      end

      setup(view, options, &block)
      view.on_added if view.respond_to?(:on_added)

      view
    end

    def setup(view, options = {}, &block)
      ViewStyler.new(view, options.delete(:bounds), options).apply
      view_stack.push(view)
      block.call(view) if block_given?
      view_stack.pop
    end

    def view_stack
      @view_stack ||= []
    end

    def self.included base
      base.class_eval do
        [::UIActionSheet, ::UIActivityIndicatorView, ::UIButton, ::UIDatePicker, ::UIImageView, ::UILabel,
          ::UIPageControl, ::UIPickerView, ::UIProgressView, ::UIScrollView, ::UISearchBar, ::UISegmentedControl,
          ::UISlider, ::UIStepper, ::UISwitch, ::UITabBar, ::UITableView, ::UITableViewCell, ::UITextField, ::UITextView,
          ::UIToolbar, ::UIWebView, ::UINavigationBar, ::MPCellWithSection, ::MBProgressHUD, ::MPSpinner].each do |klass|

          shorthand = "#{klass}"[2..-1].underscore.to_sym

          define_method(shorthand) do |options, &block|
            options[:screen] = self
            element = MotionPrime::BaseElement.factory(shorthand, options)
            element.render({}, &block)
            element
          end
        end
      end
    end
  end
end