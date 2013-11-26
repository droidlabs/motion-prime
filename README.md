# MotionPrime [![Build Status](https://travis-ci.org/droidlabs/motion-prime.png)](https://travis-ci.org/droidlabs/motion-prime)

![Prime](https://s3-us-west-2.amazonaws.com/webmate/assets/prime.jpg)

MotionPrime is yet another framework written on RubyMotion.

The main feature of MotionPrime is one more layer on UI elements: Section.
"Section" is something like "Partial" in Ruby On Rails, but it's smarter and will help you build application UI.

## Getting Started

### 1. Create MotionPrime project:

    $ prime new myapp

### 2. Setup application

    # edit Rakefile

### 3. Run application

    $ rake

## Hello World (Sample)

```ruby
  # app/app_delegate.rb
  class AppDelegate < Prime::BaseAppDelegate
    def on_load(app, options)
      open_root_screen MainScreen.new
    end
  end

  # app/screens/main_screen.rb
  class MainScreen < Prime::BaseScreen
    title 'Main screen'

    def render
      @main_section = MyProfileSection.new(model: User.first)
      @main_section.render(to: self)
    end
  end

  # app/sections/my_profile.rb
  class MyProfileSection < Prime::BaseSection
    element :title, text: "Hello World"
    element :avatar, image: "images/avatar.png", type: :image
  end

  # app/styles/my_profile.rb
  Prime::Styles.define :my_profile do
    style :title,
      width: 300, height: 20, color: :black,
      top: 10, left: 5, background_color: :white

    style :avatar,
      width: 90, height: 90, top: 40, left: 5
  end
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Thanks for using MotionPrime!

Hope, you'll enjoy MotionPrime!

Cheers, [Droid Labs](http://droidlabs.pro).
