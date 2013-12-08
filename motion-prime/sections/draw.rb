module MotionPrime
  class DrawSection < BaseSection
    # MotionPrime::DrawSection is container for Elements.
    # Unlike BaseSection, DrawSection renders elements using drawRect, instead of creating subviews
    # NOTE: only image and label elements are supported at this moment

    # == Basic Sample
    # class MySection < MotionPrime::DrawSection
    #   element :title, text: "Hello World"
    #   element :avatar, type: :image, image: 'defaults/avatar.jpg'
    # end
    #

    def hide
      container_view.hidden = true
    end

    def show
      container_view.hidden = false
    end
  end
end