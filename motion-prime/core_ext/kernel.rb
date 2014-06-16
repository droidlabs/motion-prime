class Kernel
  def benchmark(key, &block)
    if Prime.env.development?
      t = Time.now
      result = block.call
      time = Time.now - t
      MotionPrime.benchmark_data[key] ||= {}
      MotionPrime.benchmark_data[key][:count] ||= 0
      MotionPrime.benchmark_data[key][:total] ||= 0
      MotionPrime.benchmark_data[key][:count] += 1
      MotionPrime.benchmark_data[key][:total] += time
      result
    else
      block.call
    end
  end

  def pp(*attrs)
    attrs = [*attrs]
    results = attrs.map.with_index do |entity, i|
      if entity.is_a?(Hash)
        "#{"\n" unless attrs[i-1].is_a?(Hash)}#{inspect_hash(entity)}\n"
      else
        entity.inspect
      end
    end
    NSLog(results.compact.join(' '))
    attrs
  end

  def inspect_hash(hash, depth = 0)
    return '{}' if hash.blank?
    res = hash.map.with_index do |(key, value), i|
      k = "#{'  '*depth}#{i.zero? ? '{' : ' '}#{key.inspect}=>"
      pair = if value.is_a?(Hash)
        "#{k}\n#{inspect_hash(value, depth + 1)}"
      else
        [k, value.inspect].join
      end
      if i == hash.count-1
        pair + '}'
      else
        pair + ",\n"
      end
    end
    res.join
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
    @_strong_references.try(:delete, key)
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