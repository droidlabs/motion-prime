module MotionPrime
  module TableSectionRefreshMixin
    def add_pull_to_refresh(&block)
      screen.automaticallyAdjustsScrollViewInsets = false
      current_inset = self.table_view.contentInset
      current_inset.top = 64#UIApplication.sharedApplication.statusBarFrame.size.height + screen.navigation_controller.navigationBar.size.height
      self.table_view.contentInset = current_inset

      table_view.addPullToRefreshWithActionHandler(block)
      screen.setup table_view.pullToRefreshView, styles: [:base_pull_to_refresh]
    end

    def finish_pull_to_refresh
      reload_data
      table_view.pullToRefreshView.stopAnimating
    end
  end
end