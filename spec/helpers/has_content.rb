class MotionPrime::BaseElement
  def has_content?(content)
    text = computed_options[:text] || computed_options[:title] || ''
    !!text.match(content)
  end
end
class MotionPrime::Section
  def has_content?(content)
    self.elements.values.any? do |element|
      element.has_content?(content)
    end
  end
end
class MotionPrime::TableSection
  def has_content?(content)
    data.any? do |section|
      section.has_content?(content)
    end
  end
end
class MotionPrime::Screen
  def has_content?(content)
    main_section.has_content?(content)
  end
end