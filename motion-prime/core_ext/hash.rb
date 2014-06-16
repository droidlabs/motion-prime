def diff(other)
  dup.
    delete_if { |k, v| other[k] == v }.
    merge!(other.dup.delete_if { |k, v| has_key?(k) })
end