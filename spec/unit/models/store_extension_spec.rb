describe "Prime::Model Store Extension" do
  before do
    MotionPrime::Store.connect
    @store = MotionPrime::Store.shared_store
    @store.clear
  end

  after do
    @store.clear
  end

  it "should open and close store" do
    @store.open
    @store.closed?.should.be.false

    @store.close
    @store.closed?.should.be.true

    @store.open
    @store.closed?.should.be.false
  end

  it "should add, delete objects and count them" do
    obj1 = Organization.new
    obj1.name = "Cat"
    obj2 = Organization.new
    obj2.name = "Dog"
    obj3 = Organization.new
    obj3.name = "Cow"
    obj4 = Organization.new
    obj4.name = "Duck"

    @store << obj1
    @store << [obj2, obj3]
    @store += obj4

    @store.save
    Organization.count.should == 4

    @store.delete(obj1)
    Organization.count.should == 3

    @store.delete_keys([obj2.key])
    Organization.count.should == 2

    @store.clear
    Organization.count.should == 0
  end

  it "should discard unsave changes" do
    @store.save_interval = 1000 # must use save_interval= to set auto save interval first
    @store.engine.synchronousMode = SynchronousModeFull

    Organization.count.should == 0
    obj1 = Organization.new
    obj1.name = "Cat"
    obj2 = Organization.new
    obj2.name = "Dog"

    @store << [obj1, obj2]
    @store.changed?.should.be.true
    @store.discard
    @store.changed?.should.be.false
    Organization.count.should == 0
    @store.save_interval = 1
  end

  it "should create a transaction and commit" do
    @store.transaction do |the_store|
      Organization.count.should == 0
      obj1 = Organization.new
      obj1.name = "Cat"
      obj1.save

      obj2 = Organization.new
      obj2.name = "Dog"
      obj2.save
      Organization.count.should == 2
    end
    @store.save
    Organization.count.should == 2
  end

  it "should create a transaction and rollback when fail" do
    begin
      @store.transaction do |the_store|
        Organization.count.should == 0
        obj1 = Organization.new
        obj1.name = "Cat"
        obj1.save

        obj2 = Organization.new
        obj2.name = "Dog"
        obj2.save
        Organization.count.should == 2
        raise "error"
      end
    rescue
    end
    @store.save
    Organization.count.should == 0
  end

  it "should save in batch" do
    @store.save_interval = 1000

    Organization.count.should == 0
    obj1 = Organization.new
    obj1.name = "Cat"
    @store << obj1

    obj2 = Organization.new
    obj2.name = "Dog"
    @store << obj2
    @store.save

    Organization.count.should == 2
  end

end