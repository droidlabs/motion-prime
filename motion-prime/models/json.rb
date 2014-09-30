module MotionPrime
  class JsonParseError < StandardError; end

  class JSON
    PARAMETRIZE_CLASSES = [Time, Date]

    # Parses a string or data object and converts it in data structure.
    #
    # @param [String, NSData] str_data the string or data to convert.
    # @raise [JsonParseError] If the parsing of the passed string/data isn't valid.
    # @return [Hash, Array, NilClass] the converted data structure, nil if the incoming string isn't valid.
    def self.parse(str_data, &block)
      return nil unless str_data
      data = str_data.respond_to?(:to_data) ? str_data.to_data : str_data
      data = data.dataUsingEncoding(NSUTF8StringEncoding)
      opts = NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves | NSJSONReadingAllowFragments
      error = Pointer.new(:id)
      obj = NSJSONSerialization.JSONObjectWithData(data, options: opts, error: error)
      raise JsonParseError, error[0].description if error[0]
      obj
    end

    # Generates a string from data structure.
    #
    # @param [String, Fixnum, Array, Hash, Nil] obj the object to serialize.
    # @param [Boolean] parametrize option to parametrize data before serialization.
    # @return [String] the serialized data json.
    def self.generate(obj, parametrize = true)
      if parametrize && obj.is_a?(Hash)
        obj.each do |key, value|
          obj[key] = value.to_s if PARAMETRIZE_CLASSES.include?(value.class)
        end
      end
      if parametrize && obj.is_a?(Array)
        obj.map! do |value|
          PARAMETRIZE_CLASSES.include?(value.class) ? value.to_s : value
        end
      end
      data = NSJSONSerialization.dataWithJSONObject(obj, options: 0, error: nil)
      data.to_str
    end
  end
end