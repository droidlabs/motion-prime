describe "Model Finder" do
  before do
    MotionPrime::Store.connect
    @store = MotionPrime::Store.shared_store

    user = stub_user("Bob", 10, Time.now)
    user.save

    user2 = stub_user("Amy", 11, Time.now)
    user2.save

    user3 = stub_user("Carl", 4, Time.now)
    user3.save
  end

  after do
    @store.clear
  end

  describe "::find" do
    it "search object traditional way: supply key, operator and value" do
      users = User.find(:name, NSFEqualTo, "Bob")
      users.should.not.be.nil
      users.is_a?(Array).should.be.true

      user = users.first
      user.should.not.be.nil
      user.name.should.be == "Bob"
      user.age.should.be == 10
    end

    it "search object with simple hash" do
      user = User.find(:name => "Carl").first
      user.name.should.be == "Carl"
      user.age.should.be == 4
    end

    it "search object with simple hash with two class" do
      Car.create(:name => "Carl")
      users = User.find(:name => "Carl")
      users.size.should.be == 1
      user = users.first
      user.name.should.be == "Carl"
      user.age.should.be == 4
    end

    it "search object with array (OR)" do
      users = User.find(:name => ["Carl", "Amy"])
      users.size.should == 2

      users.collect(&:name).include?("Carl").should == true
      users.collect(&:name).include?("Amy").should == true
      users.collect(&:name).include?("Bob").should == false
    end

    it "search object with multiple parameters" do
      stub_user("Ronald", 18, Time.now).save
      stub_user("Ronald", 29, Time.now).save
      stub_user("Ronald", 36, Time.now).save
      stub_user("Ronald", 39, Time.now).save
      stub_user("Ronald", 49, Time.now).save
      stub_user("Ronald", 59, Time.now).save

      users = User.find(:name => { NSFEqualTo => "Ronald" }, :age => { NSFGreaterThan => 50 })
      users.size.should == 1
      user = users.first
      user.name.should.be == "Ronald"
      user.age.should.be == 59

      users = User.find(:name => { NSFEqualTo => "Ronald" }, :age => { NSFLessThan => 30 })
      users.size.should == 2
      user = users.first
      user.name.should.be == "Ronald"
    end

    it "sort search results" do
      stub_user("Alan", 39, Time.now).save
      stub_user("Cat", 29, Time.now).save
      stub_user("Dan", 36, Time.now).save
      stub_user("Ted", 18, Time.now).save
      stub_user("Zidd", 59, Time.now).save
      stub_user("Sarah", 49, Time.now).save

      users = User.find({:age => { NSFGreaterThan => 1 }}, {:sort => {:age => :asc}})
      users.size.should == 9
      user = users.first
      user.name.should.be == "Carl"
      user.age.should.be == 4
      user = users.last
      user.name.should.be == "Zidd"
      user.age.should.be == 59

      users = User.find({:age => { NSFGreaterThan => 1 }}, {:sort => {:age => 'DESC'}})
      users.size.should == 9
      user = users.last
      user.name.should.be == "Carl"
      user.age.should.be == 4
      user = users.first
      user.name.should.be == "Zidd"
      user.age.should.be == 59
    end

    it "find object" do
      users = User.find(:name, NSFEqualTo, "Bob")
      users.size.should == 1

      user = users.first
      user.name.should == "Bob"
      user.class.should == User
    end

    it "find object with quote" do
      stub_user("Bob'd", 49, Time.now).save

      users = User.find(:name, NSFEqualTo, "Bob'd")
      users.size.should == 1

      user = users.first
      user.name.should == "Bob'd"
      user.class.should == User
    end

    it "only return objects of the class" do
      car = Car.create(:name => "Honda")
      Car.find.size.should == 1
      Car.find.first.key.should == car.key
    end
  end

  describe "::find_by_key" do
    it "should return object by key" do
      name = "Julien"
      age = 32
      created_at = Time.now
      user = stub_user("Julien", 32, Time.now)
      user.save
      user2 = User.find_by_key(user.key)
      user2.should.not.be.nil
      user2.key.should == user.key
      user2.name.should == user.name
      user2.age.should == user.age
    end

    it "should not find object by inexists key" do
      User.find_by_key("invalid-key").should.be.nil
    end
  end

  describe "::all" do
    it "find all objects" do
      User.count.should == 3
      users = User.all
      users.size.should == 3
    end

    it "find all objects, sorted" do
      stub_user("Alan", 39, Time.now).save
      stub_user("Cat", 29, Time.now).save
      stub_user("Dan", 36, Time.now).save
      stub_user("Ted", 18, Time.now).save
      stub_user("Zidd", 59, Time.now).save
      stub_user("Sarah", 49, Time.now).save

      User.count.should == 9
      users = User.all({:sort => {:age => :asc}})
      users.size.should == 9
      users.first.name.should == "Carl"
    end

    it "only return objects of the class" do
      car = Car.create(:name => "Honda")
      Car.count.should == 1
      Car.all.size.should == 1
      Car.all.first.key.should == car.key
    end

    it "only return objects of the class" do
      car = Car.create(:name => "Honda")
      Car.find_keys.size.should == 1
      Car.find_keys.first.should == car.key
    end
  end
end