Prime::Styles.define :home do
  style :date,
    text_color: :black,
    top: 100,
    width: 320,
    font: proc { :system.uifont(20) },
    size_to_fit: true,
    left: 20,
end
