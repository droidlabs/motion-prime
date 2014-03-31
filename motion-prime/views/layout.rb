# TODO: make it part of Sections
motion_require '../support/mp_cell_with_section'
motion_require '../support/mp_spinner'
module MotionPrime
  module Layout
    def add_view(klass, options = {}, &block)
      options = options.clone
      render_target = options.delete(:render_target)
      parent_view = options.delete(:parent_view) || render_target

      parent_bounds = if view_stack.empty?
        parent_view.try(:bounds) || CGRectZero
      else
        view_stack.last.bounds
      end
      builder = ViewBuilder.new(klass, options)
      options = builder.options.merge(calculate_frame: true, parent_bounds: parent_bounds)
      view = builder.view
      insert_index = options.delete(:at_index)

      set_options_for(view, options, &block)
      if superview = render_target || view_stack.last
        insert_index ? superview.insertSubview(view, atIndex: insert_index) : superview.addSubview(view)
      end
      view.on_added if view.respond_to?(:on_added)
      view
    end

    def set_options_for(view, options = {}, &block)
      ViewStyler.new(view, options.delete(:parent_bounds), options).apply
      view_stack.push(view)
      block.call(view) if block_given?
      view_stack.pop
    end
    alias_method :update_options_for, :set_options_for

    def setup(view, options = {}, &block)
      puts "DEPRECATION: screen#setup is deprecated, please use screen#set_options_for instead"
      set_options_for(view, options, &block)
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