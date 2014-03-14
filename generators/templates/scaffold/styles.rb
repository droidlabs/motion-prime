Prime::Styles.define :<%= @p_name %> do
  style :cell do
    style :title,
      text_color: :app_base,
      left: 20,
      top: 10,
      width: 280,
      font: :app_base.uifont(16),
      size_to_fit: true
  end
  style :show do
    style :title,
      top: 120,
      left: 0,
      right: 0,
      text_alignment: :center
  end
end
