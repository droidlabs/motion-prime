module MotionPrime
  class ViewBuilder
    attr_reader :view, :options

    def initialize(klass, options = {})
      @options = Styles.extend_and_normalize_options(options)
      @view = view_for_class(klass, klass, @options)
    end

    def view_for_class(klass, root_klass, options = {})
      if VIEWS_MAP.key?(klass.name)
        VIEWS_MAP[klass.name].call root_klass, options
      else
        view_for_class klass.superclass, root_klass, options
      end
    end

    VIEWS_MAP = {
      'UIView' => Proc.new {|klass, options| klass.alloc.initWithFrame CGRectZero },
      'UIControl' => Proc.new {|klass, options| klass.alloc.init },
      'UIActionSheet' => Proc.new {|klass, options|
        title = options.delete(:title) || ''
        delegate = options.delete(:delegate)
        cancel_button_title = options.delete(:cancel_button_title)
        destructive_button_title = options.delete(:destructive_button_title)
        other_button_titles = options.delete(:other_button_titles)

        klass.alloc.initWithTitle title,
          delegate: delegate,
          cancelButtonTitle: cancel_button_title,
          destructiveButtonTitle: destructive_button_title,
          otherButtonTitles: other_button_titles, nil
      },
      'UIActivityIndicatorView' => Proc.new{|klass, options|
        style = options.delete(:style) || :large.uiactivityindicatorstyle
        klass.alloc.initWithActivityIndicatorStyle style
      },
      'UIButton' => Proc.new{|klass, options|
        is_custom_button = options[:background_image] || options[:title_color]
        default_button_type = is_custom_button ? :custom : :rounded
        button_type = (options.delete(:button_type) || default_button_type).uibuttontype
        klass.buttonWithType button_type
      },
      'UIImageView' => Proc.new{|klass, options|
        image = options.delete(:image)
        highlighted_image = options.delete(:highlighted_image)

        if !image.nil? && !highlighted_image.nil?
          klass.alloc.initWithImage image.uiimage, highlightedImage: highlighted_image.uiimage
        elsif !image.nil?
          klass.alloc.initWithImage image.uiimage
        else
          klass.alloc.initWithFrame CGRectZero
        end
      },
      'UIProgressView' => Proc.new{|klass, options|
        style = options.delete(:style) || UIProgressViewStyleDefault
        klass.alloc.initWithProgressViewStyle style
      },
      'UISegmentedControl' => Proc.new{|klass, options|
        items = options.delete(:items) || []
        klass.alloc.initWithItems items
      },
      'UITableView' => Proc.new{|klass, options|
        style = options.delete(:style) || UITableViewStylePlain
        klass.alloc.initWithFrame CGRectZero, style: style
      },
      'UITableViewCell' => Proc.new{|klass, options|
        style = options.delete(:style) || UITableViewCellStyleDefault
        klass.alloc.initWithStyle style, reuseIdentifier: options.delete(:reuse_identifier)
      },
      'UISearchBar' => Proc.new{|klass, options|
        klass = options[:search_field_background_image] ? UISearchBarCustom : UISearchBar
        search_bar = klass.alloc.init
        search_bar.autoresizingMask = UIViewAutoresizingFlexibleWidth
        search_bar
      },
      'GMSMapView' => Proc.new{|klass, options|
        camera = GMSCameraPosition.cameraWithLatitude(35.689466, longitude: 139.700196, zoom: 15)
        map = GMSMapView.mapWithFrame(CGRectZero, camera: camera)
        map
      }
    }
  end
end