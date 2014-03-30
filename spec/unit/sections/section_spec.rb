describe MotionPrime::Section do

  describe "general" do
    before do
      @section = SampleSection.new(screen: @screen)
    end

    describe "#name" do
      it "should use class name by default" do
        @section.name.should == 'sample'
      end

      it "should use given name" do
        section = SampleSection.new(name: 'my_section')
        section.name.should == 'my_section'
      end
    end
  end

  describe "base section" do
    before do
      @screen = BaseScreen.new
      @section = SampleViewSection.new(screen: @screen)
      @section.render
    end

    describe "#element" do
      it "should return element by name" do
        @section.element(:description).is_a?(MotionPrime::BaseElement).should.be.true
      end
    end

    describe "#view" do
      it "should return view by element name" do
        @section.view(:description).is_a?(MPLabel).should.be.true
      end
    end
  end

  describe "draw section" do
    before do
      @screen = BaseScreen.new
      @section = SampleDrawSection.new(screen: @screen)
      @section.render
    end

    describe "#element" do
      it "should return element by name" do
        @section.element(:description).is_a?(MotionPrime::DrawElement).should.be.true
      end
    end

    describe "#view" do
      it "should return container view by element name" do
        @section.view(:description).is_a?(MPViewWithSection).should.be.true
      end
    end
  end
end