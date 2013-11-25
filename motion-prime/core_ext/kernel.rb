class Kernel
  def class_name_without_kvo
    self.class.name.gsub(/^NSKVONotifying_/, '')
  end
end