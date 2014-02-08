=== 0.8.0
* add cell preload for reverse scrolling table.
* deprecate root level :title option for submit field
* rename submit element in submit field to button element
* rename date_picker element in date_picker field to input element
* add more and better default options for fields
* Rename model to data in sections.

=== 0.9.0
* bug: if mp label do not have text and was set as hidden, it should unhide after setting text
* bug: size_to_fit works incorrect with relative width.
* add cleanup for section events
* add dsl for push notifications
* add some extensions/middleware system, at least for networking.
* create "display_network_error" extension.
* add different templates. some templates should be more like final app.
* add size_to_fit support for images.

=== 1.0.0
* add sections/screens/models generator

=== 1.1.0
* add computed_options.get(), this will allow to make sure that options is computed.
* add testing framework
* add DSL for ViewStyles#setValue conditions
* bug: bind_keyboard_close breaks bind_guesture
* add clone to models to prevent problems when bag_key is overrided