describe "Prime.env" do

  before do 
    ENV['PRIME_ENV'] = 'staging'
  end

  it 'to_s should return string' do
    Prime.env.to_s.is_a?(String).should.be.true
  end

  it 'should be comparable with string' do
    (Prime.env == 'staging').should.be.true
    (Prime.env == 'test').should.be.false
  end

  it 'should respond to question mark' do
    Prime.env.staging?.should.be.true
    Prime.env.test?.should.be.false
  end
end