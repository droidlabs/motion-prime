require 'rubygems'
require 'thor'
require 'active_support/core_ext'
class MotionPrime::Generator < Thor
  include Thor::Actions

  def self.source_root
    File.dirname(__FILE__) + '/templates'
  end

  class << self
    def factory(resource)
      case resource.to_sym
      when :screen
        require_relative './screen_generator'
        MotionPrime::ScreenGenerator.new
      when :model
        require_relative './model_generator'
        MotionPrime::ModelGenerator.new
      when :table
        require_relative './table_generator'
        MotionPrime::TableGenerator.new
      when :scaffold
        require_relative './scaffold_generator'
        MotionPrime::ScaffoldGenerator.new
      end
    end
  end
end