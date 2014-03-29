describe "scaffold index" do
  before do
    5.times do |index|
      Task.create(title: "Task #{index}")
    end
    App.delegate.open_screen 'tasks#index'
    @controller = App.delegate.content_controller.childViewControllers.last
  end
  it "should render tasks list" do
    wait 0.3 do
      @controller.has_content?("Task 2").should.be.true
    end
  end
end