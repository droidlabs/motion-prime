class SampleViewSection < Prime::Section
  element :description, text: "Lorem Ipsum", as: :view
end
class SampleDrawSection < Prime::Section
  element :description, text: "Lorem Ipsum", as: :draw
end
class SampleSection < Prime::Section
  element :description, text: "Lorem Ipsum"
end