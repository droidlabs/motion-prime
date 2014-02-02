=== 0.8.0
* handle and fix memory leaks for UITabbarController
* deprecate root level :title option for submit field
* rename submit element in submit field to button element
* rename date_picker element in date_picker field to input element
* add more and better default options for fields

=== 0.9.0
* bug: if mp label do not have text and was set as hidden, it should unhide after setting text
* add cleanup for section events
* add dsl for push notifications
* add some extensions/middleware system, at least for networking.
* create "display_network_error" extension.
* add different templates. some templates should be more like final app.

=== 1.0.0
* add sections/screens/models generator

=== 1.1.0
* add computed_options.get(), this will allow to make sure that options is computed.
* add testing framework
* add DSL for ViewStyles#setValue conditions