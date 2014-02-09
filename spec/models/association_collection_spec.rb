describe "Prime::AssociationCollection" do
   before do
    MotionPrime::Store.connect
  end

  after do
    MotionPrime::Store.shared_store.clear
  end

  describe "#new" do
    before do
      @organization = Organization.new
      @project = @organization.projects.new(title: 'test')
    end

    it "should instanciate model with given attributes" do
      @project.title.should == 'test'
    end

    it "should add model to association collection" do
      @organization.projects.include?(@project).should.be.true
    end
  end

  describe "#add" do
    before do
      @organization = Organization.new
      @project = Project.new(title: 'test')
      @organization.projects.add(@project)
    end

    it "should add model to association collection" do
      @organization.projects.include?(@project).should.be.true
    end
  end

  describe "#all" do
    before do
      @organization = Organization.new
      puts "count 1: #{@organization.projects.count}"
      project = Project.new(title: 'test 1')
      @organization.projects.add(project)
      puts "count 2: #{@organization.projects.count}"
      project = Project.new(title: 'test 2')
      @organization.projects.add(project)
      puts "count 3: #{@organization.projects.count}"
    end

    it "should return all records by default" do
      @organization.projects.all.count.should == 2
    end

    it "should return filter records by first hash" do
      @organization.projects.all(title: 'test 1').count.should == 1
    end
  end
end
