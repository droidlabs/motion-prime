module MotionPrime
  class ViewBuilder
    attr_reader :view, :options

    def initialize(klass, options = {})
      @options = Styles.extend_and_normalize_options(options)
      @view = view_for_class(klass, klass, @options)
    end

    def view_for_class(klass, root_klass, options = {})
      if views_map.key?(klass.name)
        views_map[klass.name].call root_klass, options
      else
        view_for_class klass.superclass, root_klass, options
      end
    end

    def views_map
      self.class.views_map
    end

    class << self
      def register(name, &block)
        views_map[name] = block
      end

      def views_map
        @views_map ||= default_views_map
      end

      def default_views_map
        {
          'UIView' => Proc.new {|klass, options| klass.alloc.initWithFrame CGRectZero },
          'UILabel' => Proc.new {|klass, options|
            if options.slice(:line_spacing, :underline, :fragment_color).any?
              options[:attributed_text_options] = {
                text: options.delete(:text),
                line_spacing: options.delete(:line_spacing),
                fragment_color: options.delete(:fragment_color),
                underline: options.delete(:underline)
              }
              [:text_alignment].each do |key|# add keys which must follow after attributed text here
                value = options.delete(key)
                options[key] = value unless value.nil?
              end
            end
            klass.alloc.initWithFrame CGRectZero
          },
          'UIControl' => Proc.new {|klass, options| klass.alloc.init },
          'UISwitch' => Proc.new {|klass, options|
            view = klass.alloc.init
            view.setOn options.delete(:on)
            view
          },
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
            button = klass.buttonWithType button_type
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
            view = klass.alloc.initWithFrame CGRectZero, style: style
            view.tableFooterView = UIView.new
            view
          },
          'UITableViewCell' => Proc.new{|klass, options|
            style = options.delete(:style) || UITableViewCellStyleDefault
            if options[:has_drawn_content]
              options[:background_color] = :clear
              options.delete(:gradient)
            end

            klass.alloc.initWithStyle style, reuseIdentifier: options.delete(:reuse_identifier)
          },
          'MPViewWithSection' => Proc.new{|klass, options|
            if options[:has_drawn_content]
              options[:background_color] = :clear
              options.delete(:gradient)
            end
            klass.alloc.initWithFrame CGRectZero
          },
          'UISearchBar' => Proc.new{|klass, options|
            klass = options[:search_field_background_image] ? MPSearchBarCustom : UISearchBar
            search_bar = klass.alloc.init
            search_bar.autoresizingMask = UIViewAutoresizingFlexibleWidth
            search_bar
          },
          'GMSMapView' => Proc.new{|klass, options|
            camera = GMSCameraPosition.cameraWithLatitude(23.42, longitude: 127.42, zoom: 15)
            GMSMapView.mapWithFrame(CGRectZero, camera: camera)
          },
          'MBProgressHUD' => Proc.new{|klass, options|
            MBProgressHUD.showHUDAddedTo options.delete(:add_to_view), animated: (options.has_key?(:animated) ? options[:animatetd] : true)
          },
          'UIWebView' => Proc.new{|klass, options|
            web_view = klass.alloc.initWithFrame CGRectZero
            if url = options.delete(:url)
              request = NSURLRequest.requestWithURL url.nsurl
              web_view.loadRequest request
            end
            web_view.delegate = options.delete(:delegate)
            web_view
          }
        }
      end
    end
  end
end