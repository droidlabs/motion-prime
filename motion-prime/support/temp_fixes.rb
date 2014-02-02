# TODO: remove after fixing strange issue with attr reader
MotionSupport::Callbacks::CallbackChain.class_eval do
  def config
    @config
  end
end