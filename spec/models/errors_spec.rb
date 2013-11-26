describe "Model Errors" do
  before do
    MotionPrime::Store.connect
    @user = stub_user("Bob", 10, Time.now)
  end

  describe "#errors" do
    it "should be blank on initialize" do
      @user.errors.blank?.should == true
    end

    it "should not be blank after adding error" do
      @user.errors.add(:name, 'bar')
      @user.errors.blank?.should == false
    end

    it "should not present after reset" do
      @user.errors.add(:name, 'bar')
      @user.errors.present?.should == true
      @user.errors.reset
      @user.errors.present?.should == false
    end

    it "should be convertable to string" do
      @user.errors.add(:name, 'bar')
      @user.errors.to_s.match(/bar/).should != nil
    end
  end
end