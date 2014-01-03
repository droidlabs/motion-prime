describe "Prime::Model Associations" do
   before do
    MotionPrime::Store.connect
  end

  after do
    MotionPrime::Store.shared_store.clear
  end

  describe "#bag" do
    it "adds a attr reader to the class" do
      todo = Todo.create(:title => "Today Tasks")
      todo.items.is_a?(MotionPrime::Bag).should == true
      todo.items.size.should == 0
    end

    it "adds a attr writer to the class that can take an Array" do
      todo = Todo.create(:title => "Today Tasks")
      todo.items = [TodoItem.new(:text => "Hi"), TodoItem.new(:text => "Foo"), TodoItem.new(:text => "Bar")]
      todo.items.is_a?(MotionPrime::Bag).should == true
      todo.items.size.should == 3
    end

    it "adds a writer to the class that can take a Bag" do
      todo = Todo.create(:title => "Today Tasks")
      todo.items = MotionPrime::Bag.bag
      todo.items.is_a?(MotionPrime::Bag).should == true
      todo.items.size.should == 0
    end
  end

  describe "#save" do
    it "save a model also saves associated bags" do
      todo = Todo.create(:title => "Today Tasks")
      todo.items = [TodoItem.new(:text => "Hi"), TodoItem.new(:text => "Foo"), TodoItem.new(:text => "Bar")]
      todo.items.is_a?(MotionPrime::Bag).should == true
      todo.save

      todo = Todo.find(:title => "Today Tasks").first
      todo.should.not.be.nil
      todo.items.is_a?(MotionPrime::Bag).should == true
      todo.items.key.should == todo.items.key
      todo.items.size.should == 3
      todo.items.to_a.each do |item|
        item.is_a?(TodoItem).should.be.true
      end
    end
  end
end
