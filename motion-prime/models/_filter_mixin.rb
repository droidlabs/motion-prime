module MotionPrime
  module FilterMixin
    def filter_array(data, find_options = {}, sort_options = nil)
      data = data.select do |entity|
        find_options.all? { |field, value| entity.info[field] == value }
      end if find_options.present?

      data.sort! do |a, b|
        left_part = []
        right_part = []

        sort_options[:sort].each do |(k,v)|
          left = a.send(k)
          right = b.send(k)
          if left.class != right.class
            left = left.to_s
            right = right.to_s
          end
          left, right = right, left if v.to_s == 'desc'
          left_part << left
          right_part << right
        end
        left_part <=> right_part
      end if sort_options.try(:[], :sort).present?
      data
    end
  end
end