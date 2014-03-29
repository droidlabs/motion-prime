describe "open screen" do
  describe "from app delegate with default options" do
    before do
      App.delegate.open_screen :sample
      @controller = App.delegate.content_controller
    end
    it "should open with navigation by default" do
      @controller.is_a?(UINavigationController).should.be.true
    end

    it "should open screen" do
      @controller.childViewControllers.first.is_a?(SampleScreen).should.be.true
      @controller.childViewControllers.first.visible?.should.be.true
    end
  end

  describe "from app delegate with navigation false" do
    before do
      App.delegate.open_screen :sample, navigation: false
      @controller = App.delegate.window.rootViewController
    end
    it "should open screen" do
      @controller.is_a?(SampleScreen).should.be.true
      @controller.visible?.should.be.true
    end
  end

  describe "from app delegate with action" do
    before do
      App.delegate.open_screen 'tasks#new'
      @controller = App.delegate.content_controller.childViewControllers.last
    end

    it "should open screen with action" do
      @controller.is_a?(TasksScreen).should.be.true
      @controller.title.should == 'New Task'
    end
  end

  describe "from another screen with navigation: true" do
    before do
      @parent_screen = SampleScreen.new(navigation: true)
      @child_screen = SampleScreen.new(navigation: true)

      App.delegate.open_screen @parent_screen
      @parent_screen.open_screen @child_screen
      @controller = App.delegate.content_controller

      # we should call it because will_appear will happen async
      @child_screen.will_appear
      @parent_screen.will_disappear
    end

    it "should open child screen navigational" do
      @controller.childViewControllers.last.should == @child_screen
      @child_screen.visible?.should.be.true
    end

    it "should make parent screen invisible" do
      @parent_screen.visible?.should.be.false
    end
  end
end