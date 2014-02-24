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
      project = Project.new(title: 'test 1')
      @organization.projects.add(project)
      project = Project.new(title: 'test 2')
      @organization.projects.add(project)
    end

    it "should return all records" do
      @organization.projects.all.count.should == 2
    end
  end

  describe "#find" do
    before do
      @organization = Organization.new
      project = Project.create(title: 'test 1')
      @organization.projects.add(project)
      project = Project.create(title: 'test 2')
      @organization.projects.add(project)
      @organization.save
    end

    it "should return saved records by first hash" do
      @organization.projects.find(title: 'test 1').count.should == 1
    end
  end

  describe "#filter" do
    before do
      @organization = Organization.new
      project = Project.new(title: 'test 1')
      @organization.projects.add(project)
      project = Project.new(title: 'test 2')
      @organization.projects.add(project)
    end

    it "should return saved records by first hash" do
      @organization.projects.filter(title: 'test 1').count.should == 1
    end
  end
end
