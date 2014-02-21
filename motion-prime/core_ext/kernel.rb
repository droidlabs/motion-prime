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

  def allocate_strong_references(key = nil)
    unless self.respond_to?(:strong_references)
      Prime.logger.debug "User must define `strong_references` in `#{self.class.name}`"
      return false
    end

    refs = Array.wrap(self.strong_references).compact
    unless refs.present?
      Prime.logger.debug "`strong_references` are empty for `#{self.class.name}`"
      return false
    end

    @_strong_references ||= {}
    key ||= [@_strong_references.count, Time.now.to_i].join('_')
    @_strong_references[key] = refs.map(&:strong_ref)
    key
  end

  def release_strong_references(key = nil)
    unless self.respond_to?(:strong_references)
      Prime.logger.debug "User must define `strong_references` in `#{self.class.name}`"
      return false
    end
    key ||= @_strong_references.keys.last
    @_strong_references.delete(key)
    key
  end

  def allocated_references_released?
    unless self.respond_to?(:strong_references)
      Prime.logger.debug "User must define `strong_references` in `#{self.class.name}`"
      return false
    end
    @_strong_references.all? { |key, ref| @_strong_references.count; ref.retainCount == @_strong_references.count }
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