describe "Prime::Model Store" do
  before do
    MotionPrime::Store.disconnect
  end

  after do
    File.delete(documents_path + "/nano.db") rescue nil
  end

  it "create :memory store" do
    MotionPrime::Store.disconnect
    store = MotionPrime::Store.create :memory
    store.filePath.should == ":memory:"
  end

  it "create :persistent store" do
    path = documents_path + "/nano.db"
    store = MotionPrime::Store.create :persistent, path
    store.filePath.should == path

    path = documents_path + "/nano.db"
    store = MotionPrime::Store.create :file, path
    store.filePath.should == path
  end

  it "create :temp store" do
    store = MotionPrime::Store.create :temp
    store.filePath.should == ""

    store = MotionPrime::Store.create :temporary
    store.filePath.should == ""
  end

  it "should use shared_store if a model has no store defined" do
    Organization.store = nil
    MotionPrime::Store.connect
    Organization.store.should.not.be.nil
    MotionPrime::Store.shared_store.should.not.be.nil
    Organization.store.should == MotionPrime::Store.shared_store

    Organization.store = MotionPrime::Store.create :temp
    Organization.store.should.not == MotionPrime::Store.shared_store
  end

  it "should enable and disable debug mode" do
    MotionPrime::Store.debug = true
    @store = MotionPrime::Store.create
    MotionPrime::Store.debug = false
    @store.should.not.be.nil
  end
end