class Kernel
  def pp(*attrs)
    NSLog([*attrs].map(&:inspect).join(' ') + ' ' + self.class.to_s)
  end

  def class_name_without_kvo
    self.class.name.gsub(/^NSKVONotifying_/, '')
  end
end