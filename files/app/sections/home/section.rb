class HomeSection < Prime::Section
  element :date, text: proc { Time.now.strftime("%A, %B %d") }
end