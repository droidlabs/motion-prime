describe MotionPrime::FilterMixin do
  before do
    @subject = MotionPrime::FilterMixin.new
  end

  def data
    model_stub = Struct.new(:info, :id) # :id is used for sorting
    data_array.map do |item|
      model_stub.new(item, item[:id])
    end
  end

  def data_array
    [{id: 4, name: 'iPhone'}, {id: 5, name: 'MacBook'}]
  end

  it "should filter array by inclusion" do
    @subject.filter_array(data, {id: %w[4 5]}).count.should.equal 2
  end

  it "should find a single record (case sensitive)" do
    @subject.filter_array(data, {id: 4, name: 'iPhone'}).count.should.equal 1
  end

  it "order filtered records" do
    result = @subject.filter_array(data, {id: %w[4 5]}, sort: {id: :desc})
    result.first[:id].should.equal 5
  end
end