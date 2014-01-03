describe MotionPrime::Model do

  before do
    @json_string = <<-EOS
    {
      "id": 1,
      "full_name": "Bruce Lee",
      "age": 23,
      "gender": "male"
    }
EOS
  end

  describe "parse" do
    
    before do
      @json_data = Prime::JSON.parse(@json_string)
    end

    it "doesn't crash when data is nil" do
      Proc.new { Prime::JSON.parse(nil) }.should.not.raise Exception
    end

    it "returns a mutable object" do
      Proc.new { @json_data[:blah] = 123 }.should.not.raise Exception
    end

    it "should convert a top object into a Ruby hash" do
      obj = @json_data
      obj.class.should == Hash
      obj.keys.size.should == 4
    end

    it "should properly convert integers values" do
      @json_data["id"].is_a?(Integer).should == true
    end

    it "should properly convert string values" do
      @json_data["full_name"].is_a?(String).should == true
    end

    it "should convert an array into a Ruby array" do
      obj = Prime::JSON.parse("[1,2,3]")
      obj.class.should == Array
      obj.size.should == 3
    end
  end

  describe "generate" do
    before do
      @json_data = { 
         foo: 'bar', 
         'bar' => 'baz', 
         baz: 123, 
         foobar: [1,2,3], 
         foobaz: {'a' => 1, 'b' => 2} 
      }
    end

    it "should generate from a hash" do
      json = Prime::JSON.generate(@json_data)
      json.class == String
      json.should == "{\"foo\":\"bar\",\"bar\":\"baz\",\"baz\":123,\"foobar\":[1,2,3],\"foobaz\":{\"a\":1,\"b\":2}}"
    end

    it "should encode and decode and object losslessly" do
      json = Prime::JSON.generate(@json_data)
      obj = Prime::JSON.parse(json)
      
      obj["foo"].should == 'bar'
      obj["bar"].should == 'baz'
      obj["baz"].should == 123
      obj["foobar"].should == [1,2,3]  
      obj["foobaz"].should == {"a" => 1, "b" => 2}

      obj.keys.map(&:to_s).sort.should == @json_data.keys.map(&:to_s).sort
    end

    it "should parametrize date/time objects" do
      time = Time.new(2010, 10, 10)
      Prime::JSON.generate(time: time).match('2010-10-10 00:00:00').should.not.be.nil
      Prime::JSON.generate(time: time.to_date).match('2010-10-10').should.not.be.nil
    end
  end

end

