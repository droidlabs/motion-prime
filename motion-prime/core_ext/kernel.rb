class Kernel
  def pp(*attrs)
    NSLog([*attrs].map(&:inspect).join(' '))
  end

  def class_name_without_kvo
    self.class.name.gsub(/^NSKVONotifying_/, '')
  end

  def weak_ref
    WeakRef.new(self)
  end

  def strong_ref
    self
  end

  def clear_instance_variables(options = {})
    ivars = self.instance_variables
    excluded_ivars = Array.wrap(options[:except]).map(&:to_s)
    clear_block = proc { |ivar|
      next if excluded_ivars.include?(ivar[1..-1])
      self.instance_variable_set(ivar, nil)
    }.weak!
    ivars.each(&clear_block)
  end
end