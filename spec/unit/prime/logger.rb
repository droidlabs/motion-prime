describe "Prime.env" do

  before do 
    @logger = Prime::Logger.new
    @logger.stub!(:output) do |message|
      message
    end
  end

  it 'should work' do
    @logger.log("Hello world").should == 'Hello world'
  end

  describe "error level" do
    before { Prime::Logger.level = :error }

    it 'should log errors' do
      @logger.error("message").should == ["message"]
    end

    it 'should not log info' do
      @logger.info("message").should == nil
    end
  end

  describe "info level" do
    before { Prime::Logger.level = :info }

    it 'should log info' do
      @logger.info("message").should == ["message"]
    end

    it 'should not log debug' do
      @logger.debug("message").should == nil
    end
  end

  describe "debug level" do
    before { Prime::Logger.level = :debug }

    it 'should log debug' do
      @logger.debug("message").should == ["message"]
    end

    it 'should not log dealloc' do
      @logger.dealloc_message("message", Prime::Section.new).should == nil
    end
  end
end