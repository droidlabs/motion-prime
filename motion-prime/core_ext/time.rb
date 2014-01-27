class Time
  def to_short_iso8601
    clone.utc.strftime("%Y%m%dT%H%M%SZ")
  end

  def self.short_iso8601(time)
    cached_date_formatter("yyyyMMdd'T'HHmmss'Z'").
      dateFromString(time.gsub(/[\:\-]*/, ''))
  end
end