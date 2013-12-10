class SidebarActionSection < Prime::BaseSection
  container height: 43
  element :title, text: proc { model[:title] }
  element :arrow, type: :image
end