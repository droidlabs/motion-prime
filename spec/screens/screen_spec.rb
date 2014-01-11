describe MotionPrime::Screen do

  before do
    @screen = BaseScreen.new()
    @screen.will_appear
  end

  it "should render screen on appear" do
    @screen.was_rendered.should == true
  end

  it "should set default title" do
    @screen.title.should == "Base"
  end

  it "should have navigation enabled by default" do
    @screen.wrap_in_navigation?.should == true
  end

  it "#modal? should be false by default" do
    @screen.modal?.should == false
  end

  describe "UIViewController" do

    it "viewDidLoad" do
      @screen.mock!(:view_did_load) { true }
      @screen.viewDidLoad.should == true
    end

    it "viewWillAppear" do
      @screen.mock!(:view_will_appear) { |animated| animated.should == true }
      @screen.viewWillAppear(true)
    end

    it "viewDidAppear" do
      @screen.mock!(:view_did_appear) { |animated| animated.should == true }
      @screen.viewDidAppear(true)
    end

    it "viewWillDisappear" do
      @screen.mock!(:view_will_disappear) { |animated| animated.should == true }
      @screen.viewWillDisappear(true)
    end

    it "viewDidDisappear" do
      @screen.mock!(:view_did_disappear) { |animated| animated.should == true }
      @screen.viewDidDisappear(true)
    end

    it "shouldAutorotateToInterfaceOrientation" do
      @screen.mock!(:should_rotate) { |o| o.should == UIInterfaceOrientationPortrait }
      @screen.shouldAutorotateToInterfaceOrientation(UIInterfaceOrientationPortrait)
    end

    it "shouldAutorotate" do
      @screen.mock!(:should_autorotate) { true }
      @screen.shouldAutorotate.should == true
    end

    it "willRotateToInterfaceOrientation" do
      @screen.mock! :will_rotate do |orientation, duration|
        orientation.should == UIInterfaceOrientationPortrait
        duration.should == 0.5
      end
      @screen.willRotateToInterfaceOrientation(UIInterfaceOrientationPortrait, duration: 0.5)
    end

    it "didRotateFromInterfaceOrientation" do
      @screen.mock!(:on_rotate) { true }
      @screen.didRotateFromInterfaceOrientation(UIInterfaceOrientationPortrait).should == true
    end

  end

  describe "navigation" do
    it "should not have navigation by default" do
      @screen.has_navigation?.should == false
    end
  end
end