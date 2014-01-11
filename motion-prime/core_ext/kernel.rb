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
    ivars = self.instance_variables.clone
    ivars.each do |ivar|
      next if Array.wrap(options[:except]).include?(ivar[1..-1])
      self.instance_variable_set(ivar, nil)
    end
  end
end