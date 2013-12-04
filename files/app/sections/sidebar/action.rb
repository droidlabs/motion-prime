class SidebarActionSection < Prime::BaseCellSection
  container height: 43
  element :title, text: proc { model[:title] }
  element :arrow, type: :image
end