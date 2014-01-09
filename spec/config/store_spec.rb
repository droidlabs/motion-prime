describe MotionPrime::Config do
  before { @config = MotionPrime::Config.new }

  describe "[]" do
    before { @config = MotionPrime::Config.new(foo: "bar") }

    it "returns the value if there is one" do
      @config[:foo].should == "bar"
      @config["foo"].should == "bar"
    end

    it "returns a new Configatron::Store object if there is no value" do
      @config[:unknown].is_a?(MotionPrime::Config).should == true
      @config["unknown"].is_a?(MotionPrime::Config).should == true
    end
  end

  describe "[]=" do
    it "sets the value" do
      @config[:foo] = "bar"
      @config[:foo].should ==  "bar"
      @config["foo"].should ==  "bar"

      @config[:baz] = "bazzy"
      @config[:baz].should ==  "bazzy"
      @config["baz"].should ==  "bazzy"
    end
  end

  describe "nil?" do
    it "returns true if there is no value set" do
      @config.foo.nil?.should == true
      @config.foo = "bar"
      @config.foo.nil?.should == false
    end
  end


  describe ":key_name?" do
    it "returns true if there is value and it's not false" do
      @config.foo = true
      @config.foo?.should == true
    end

    it "returns false if there is value and it's false" do
      @config.foo = false
      @config.foo?.should == false
    end

    it "returns false if there is no value" do
      @config.foo?.should == false
    end
  end

  describe "class methods" do
    it "should allow to set value for class" do
      MotionPrime::Config.foo.nil?.should == true
      MotionPrime::Config.foo = "bar"
      MotionPrime::Config.foo.should == "bar"
    end
  end

  describe "has_key?" do
    it "returns true if there is a key" do
      @config.has_key?(:foo).should == false
      @config.foo = "bar"
      @config.has_key?(:foo).should == true
    end

    it "returns false if the key is a MotionPrime::Config" do
      @config.has_key?(:foo).should == false
      @config.foo = MotionPrime::Config.new
      @config.has_key?(:foo).should == false
    end
  end

  describe "configuring with a block" do
    before do
      @config.a.b = 'B'
    end

    it "yields the store to configure" do
      @config.a do |a|
        a.c = 'C'
      end
      @config.a.b.should == 'B'
      @config.a.c.should == 'C'
    end
  end
end