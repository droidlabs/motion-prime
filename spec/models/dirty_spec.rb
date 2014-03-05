describe MotionPrime::Model do
  before do
    MotionPrime::Store.connect
    @store = MotionPrime::Store.shared_store
  end

  after do
    @store.clear
  end

  describe "has_changed?" do
    before do
      @user = stub_user("Bob", 10, Time.now)
      @user.save
    end

    it "should be false after save" do
      puts @user.changed_attributes
      @user.has_changed?.should.be.false
    end

    it "should be true after attribute change" do
      @user.name = "Smith"
      @user.has_changed?.should.be.true
    end

    it "should be false after reload" do
      @user.name = "Smith"
      @user.reload
      @user.has_changed?.should.be.false
      @user.name.should == "Bob"
    end
  end
end
