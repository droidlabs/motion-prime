module MotionPrime
  module TableSectionRefreshMixin
    def add_pull_to_refresh(&block)
      table_view.addPullToRefreshWithActionHandler(block)
      screen.setup table_view.pullToRefreshView, styles: [:base_pull_to_refresh]
    end

    def finish_pull_to_refresh
      reload_data
      table_view.pullToRefreshView.stopAnimating
    end
  end
end