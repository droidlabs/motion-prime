class Kernel
  def pp(*attrs)
    puts [*attrs].map(&:inspect).join(' ')
  end

  def class_name_without_kvo
    self.class.name.gsub(/^NSKVONotifying_/, '')
  end
end