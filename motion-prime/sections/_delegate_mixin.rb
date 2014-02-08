module MotionPrime
  module DelegateMixin
    def delegated_by(view)
      @delegated_views ||= []
      @delegated_views << view
    end

    def clear_delegated
      Array.wrap(@delegated_views).each { |view| view.setDelegate(nil) }
    end
  end
end