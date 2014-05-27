describe MotionPrime::FrameCalculatorMixin do
  before do
    @parent_bounds = CGRectMake(0,0,0,0)
    @parent_bounds.size.width = 300
    @parent_bounds.size.height = 200
    @subject = MotionPrime::FrameCalculatorMixin.new
  end

  it "should set width and height" do
    result = @subject.calculate_frame_for(@parent_bounds, width: 200, height: 100)
    result.size.width.should == 200
    result.size.height.should == 100
  end

  it "should use parent size if size not set" do
    result = @subject.calculate_frame_for(@parent_bounds, {})
    result.size.width.should == 300
    result.size.height.should == 200
  end

  it "should calculate size based on left/right" do
    result = @subject.calculate_frame_for(@parent_bounds, {left: 10, right: 10, top: 10, bottom: 10})
    result.size.width.should == 280
    result.size.height.should == 180
    result.origin.x.should == 10
    result.origin.y.should == 10
  end

  it "should calculate left based on width and right" do
    result = @subject.calculate_frame_for(@parent_bounds, {right: 10, width: 200})
    result.origin.x.should == 90 #300 - 200 - 10
  end

  it "should calculate top based on height and bottom" do
    result = @subject.calculate_frame_for(@parent_bounds, {bottom: 10, height: 100})
    result.origin.y.should == 90 #300 - 200 - 10
  end
end