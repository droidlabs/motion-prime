# MotionPrime [![Build Status](https://travis-ci.org/droidlabs/motion-prime.png)](https://travis-ci.org/droidlabs/motion-prime) [![Code Climate](https://codeclimate.com/github/droidlabs/motion-prime.png)](https://codeclimate.com/github/droidlabs/motion-prime) [![Roadchange](https://roadchange.com/droidlabs/motion-prime/badge.png?v1)](https://roadchange.com/droidlabs/motion-prime)

![Prime](https://s3.amazonaws.com/motionprime/logo-1.png)

MotionPrime is yet another framework written on RubyMotion for creating really fast iOS applications.

## Why MotionPrime?

* Performance. MotionPrime designed to improve creating and scrolling performance of table views.
* Simplicity. Creating first MotionPrime application is as simple as creating new RubyOnRails application.

## Getting Started

#### 1. Install MotionPrime:

    $ gem install motion-prime

#### 2a. Create [bootstrap](https://github.com/motionprime/prime_bootstrap) project:

    $ prime bootstrap myapp

#### 2b. OR create empty project:

    $ prime new myapp

#### 3. Run application

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

    section :my_profile
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

* [ECSlidingViewController 2 integration](https://github.com/motionprime/prime_sliding_menu) (Sidebar)
* [RESideMenu integration](https://github.com/motionprime/prime_reside_menu) (Sidebar)
* [Sliding actions support](https://github.com/motionprime/prime_sliding_action)

## Samples

* [Simple to-do app](https://github.com/motionprime/prime_sample_todo)
* [Send mail with attached file](https://github.com/cactis/email_attachment_example)

## Documentation

* [Getting Started](http://prime.droidlabs.pro/)
* [RubyDoc](http://rubydoc.info/gems/motion-prime/)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Thanks for using MotionPrime!

Hope, you'll enjoy MotionPrime!

Cheers, [Droid Labs](http://droidlabs.pro).
