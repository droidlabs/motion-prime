describe MotionPrime::Section do
  before do
    @screen = BaseScreen.new
  end

  describe "view label" do
    before do
      @section = SampleViewSection.new(screen: @screen)
      @section.create_elements
    end

    describe "size_to_fit option" do
      before do
        @section.element(:description).options.merge!({
          text: '',
          size_to_fit: true
        })
      end

      it "should set zero size" do
        @section.render
        @section.view(:description).bounds.size.width.should.be.zero
        @section.view(:description).bounds.size.height.should.be.zero
      end

      it "should update bounds with text" do
        @section.render
        @section.element(:description).update_with_options(text: 'test')
        @section.view(:description).bounds.size.width.should > 0
        @section.view(:description).bounds.size.height.should > 0
      end
    end

    # describe "`top` with zero `height`" do
    #   before do
    #     @section.element(:description).options.merge!({
    #       top: 20
    #     })
    #   end

    #   it "should set top" do
    #     @section.render
    #     @section.view(:description).origin.y.should == 20
    #   end
    # end
  end

  describe "draw label" do
    before do
      @section = SampleDrawSection.new(screen: @screen)
      @section.create_elements
    end

    describe "size_to_fit option" do
      before do
        @section.element(:description).options.merge!({
          text: '',
          size_to_fit: true
        })
      end

      it "should set zero size" do
        @section.render
        @section.element(:description).size_to_fit_if_needed
        @section.element(:description).computed_options[:width].should.be.zero
        @section.element(:description).computed_options[:height].should.be.zero
      end

      it "should update bounds with text" do
        @section.render
        @section.element(:description).update_with_options(text: 'test')
        @section.element(:description).size_to_fit_if_needed
        @section.element(:description).computed_options[:width].should > 0
        @section.element(:description).computed_options[:height].should > 0
      end
    end

    describe "`top` with zero `height`" do
      before do
        @section.element(:description).options.merge!({
          top: 20
        })
      end

      it "should set top" do
        @section.render
        @section.container_view.bounds = UIScreen.mainScreen.bounds
        @section.element(:description).size_to_fit_if_needed
        @section.element(:description).draw_options[:top_left_corner].y.should == 20
        @section.element(:description).draw_options[:inner_rect].origin.y.should == 20
      end
    end
  end
end