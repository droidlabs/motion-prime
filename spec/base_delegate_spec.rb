describe "base delegate" do

  before { @subject = BaseDelegate.new }

  it 'should call on_load on launch' do
    @subject.mock!(:on_load) do |app, options|
      app.should.be.kind_of(UIApplication)
    end

    @subject.application(UIApplication.sharedApplication, didFinishLaunchingWithOptions: {})
  end
end