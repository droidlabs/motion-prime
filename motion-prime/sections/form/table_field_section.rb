motion_require '../table.rb'
module MotionPrime
  class TableFieldSection < TableSection
    include CellSection
    attr_accessor :delegate, :form
    after_render :on_render

    def initialize(options = {})
      @form = options.delete(:form)
      @delegate = options.delete(:delegate) || form
      super
    end

    def on_render
      add_pull_to_refresh do
        model.sync! do
          finish_pull_to_refresh
        end
      end if @options[:pull_to_refresh] && model.present?
    end

    def render_table
      @styles ||= []
      @styles += [
        :"#{form.name}_table",
        :"#{form.name}_#{name}_table"]
      super
    end

    def on_click(table, index)
      section = data[index.row]
      delegate.send("#{name}_selected", section) if delegate.respond_to?("#{name}_selected")
    end

    def self.delegate_method(method_name)
      define_method method_name do |*args|
        delegate.send("#{name}_#{method_name}", *args) if delegate.respond_to?("#{name}_#{method_name}")
      end
    end

    def tableView(table, viewForFooterInSection: section)
      method_name = :"#{name}_footer_view_for_section"
      delegate.respond_to?(method_name) ? delegate.send(method_name) : nil
    end
    def tableView(table, heightForFooterInSection: section)
      method_name = :"#{name}_footer_height_for_section"
      delegate.respond_to?(method_name) ? delegate.send(method_name) : 0
    end

    delegate_method :table_data
    delegate_method :container_height
  end
end