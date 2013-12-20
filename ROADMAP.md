=== 0.5.0
* "id" attribute should always be added to model by default
* fix issue when draw element without table section in parent will not be drawn.
* Ability to pass "locals" while opening screen.
* navigation: true by default for screen initialization.
* separate screen.open_screen to screen.open_child and screen.open_modal.

=== 0.6.0
* add testing framework
* add auth backends to ApiClient: password auth and facebook auth

=== 0.7.0
* add sections/screens/models generator
* add DSL for ViewStyles#setValue conditions
* add auto-symbol-value for Prime::Config.color items