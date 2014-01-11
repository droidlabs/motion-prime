# MotionPrime [![Build Status](https://travis-ci.org/droidlabs/motion-prime.png)](https://travis-ci.org/droidlabs/motion-prime) [![Code Climate](https://codeclimate.com/github/droidlabs/motion-prime.png)](https://codeclimate.com/github/droidlabs/motion-prime) [![Roadchange](http://roadchange.com/droidlabs/motion-prime/badge.png)](http://roadchange.com/droidlabs/motion-prime) 

![Prime](https://s3-us-west-2.amazonaws.com/webmate/assets/prime.jpg)

MotionPrime is yet another framework written on RubyMotion for creating really fast iOS applications.

## Getting Started

### 1. Install MotionPrime:

    $ gem install motion-prime

### 2. Create MotionPrime project:

    $ prime new myapp

### 3. Setup application
  
    $ bundle install
    $ rake pod:install

### 4. Run application

    $ rake

## Hello World (Sample)

```ruby
  # app/app_delegate.rb
  class AppDelegate < Prime::BaseAppDelegate
    def on_load(app, options)
      open_screen :main
    end
  end

  # app/screens/main_screen.rb
  class MainScreen < Prime::Screen
    title 'Main screen'

    def render
      @main_section = MyProfileSection.new(model: User.first)
      @main_section.render(to: self)
    end
  end

  # app/sections/my_profile.rb
  class MyProfileSection < Prime::Section
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

## Extensions

* [ECSlidingViewController 2 integration](https://github.com/droidlabs/prime_sliding_menu) (Sidebar)
* [RESideMenu integration](https://github.com/droidlabs/prime_reside_menu) (Sidebar)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Documentation

We are using [Docco](http://jashkenas.github.io/docco/) to generate documentation.

Please install the tool and run this to update documentation:

```
$ cd doc && docco code/*.rb
```

## Thanks for using MotionPrime!

Hope, you'll enjoy MotionPrime!

Cheers, [Droid Labs](http://droidlabs.pro).
