=== 1.0.4
* Multiple bug fixes
* Model#save will be performed on main thread (now you can fetch models in thread)
* Improved support for UIPageViewController

=== 1.0.3
* Fixed issue with overriding background color
* Improved support for UIPageViewController

=== 1.0.2
* Fix regression for UIButton builder

=== 1.0.1
* bug fixes
* support iOS 8
* start adding PageView support

=== 1.0.0
* Stable release

=== 0.9.9.2
* bug fixes

=== 0.9.9.1
* BREAKING CHANGE: width/height value have more priority than right/bottom
* BREAKING CHANGE: all methods starting with "table" in table section renamed to start with "collection"
* bug: content_vertical_alignment conflicts with padding.
* bug: content_vertical_alignment has not ideal centering.

=== 0.9.9
* BREAKING CHANGE: table delegate methods in table section does not accept collection_view as first param.
  See https://github.com/droidlabs/motion-prime/commit/c8f7b2e4fd1665a45309585484ac211381854f62
* Bug fixes

=== 0.9.8
* Ability to fetch one record / all records from server using Model.fetch(id) or Model.fetch_all
* Bug fixes

=== 0.9.7
* BREAKING CHANGE: screen#set_options renamed to screen#set_options_for.
* BREAKING CHANGE: section#reload_section renamed to section#hard_reload_section. in common cases use section#reload.
* BREAKING CHANGE: form#reload_cell_section renamed to form#hard_reload_cell_section. in common cases use form#reload_cell_sections.
* BREAKING CHANGE: table#reset_data renamed to table#reset_collection_data

=== 0.9.6
* BREAKING CHANGE: proc for form field option will be executed in context of form, not field.
* BREAKING CHANGE: screen#setup renamed to screen#set_options.

=== 0.9.5
* Ability to set wrapper for sections in screen.
* Screen refresh reloads all sections in screen.
* Fix overriding title color of button in nav bar.
* Better support for edge inset attributes.

=== 0.9.4
* Ability to render multiple sections inside screen action.

=== 0.9.3
* Small refactor required for working prime_awesome

=== 0.9.2
* Updated scaffold and added deleting items.
* Ability to reload base section.

=== 0.9.1
* Set correct navigation button title color by default.

=== 0.9.0
* Added generators for model/screen/table.
* Added scaffold generator.
* Added ability to open screen with action.

=== 0.8.13
* Fix issue with deallocating screen if no sidebar is used.
* motion_require now works inside application.

=== 0.8.11 - 0.8.12
* Ability to send block to after_render/before_render
* Added ability to get all form field values via `field_values`
* Ability to automatically set models saved_at/created_at using `timestamp_attributes`.

=== 0.8.10
* Added font_name/font_size options support.

=== 0.8.9
* Update form default styles.

=== 0.8.8
* Improve model inspection.

=== 0.8.7
* Refactored and improved model attributes convertion.
* Refactored and improved model#dirty.
* Added auto-generating model id by default.

=== 0.8.6
* Ability to pass :after_render to form field.
* Ability to append data to collection on sync.
* Bug fixes.

=== 0.8.5
* Table header improvements.
* Fix bug: header section draw elements doesn't work

=== 0.8.3 - 0.8.4
* Ability to pass UIButton to set_navigation_left_button/set_navigation_right_button
* Bug fixes

=== 0.8.2
* bug fixes.
* added #clone method for Model.
* added #filter method for association collection.
* memory leak fixes.

=== 0.8.1
* renamed submit element in submit field to button element.
* renamed date_picker element in date_picker field to input element.
* improved model associations.
* bug fixes.

=== 0.8.0
* Simpler syntax for using fonts. See prime_bootstrap.
* All style things moved from default prime template to bootstrap template.
* Removed root :title option support for submit field.
* Use field name as label text by default.
* Bug fixes.

=== 0.7.2
* Added simpler syntax for rendering sections in screen. E.g. section :my_profile.
* Bug fixes.

=== 0.7.1
* fix memory leaks for UITabbarController
* Improved logger.
* Better support for attributed text.
* Fix default vertical align for draw labels.

=== 0.7.0
* Added Model.find(1) syntax support where 1 is :id attribute.
* Migrate to AFMotion.

=== 0.6.0
* Fix executable.
* Stable release.

=== 0.5.7
* Improve store save.
* Improve model dirty.
* Support time attribute for model.

=== 0.5.6
* sending "title" in options is not supported now. use dsl with Proc for that.
* ability to open root screen with animation.
* refactored screens navigation.

=== 0.5.5
* improve association fetch speed and login.
* "delete" method is not supported for model collection now, use delete_all.

=== 0.5.4
* ApiClient#authenticate returns full data and status instead of only token.
* Made table cell more configuralble.

=== 0.5.3
* bug fixes.
* improve form fields.
* memory fixes.
* add selected image support for tab bar items.

=== 0.5.2
* fix bugs.

=== 0.5.1
* configurations and style definitions runs in correct order.

=== 0.5.0
* renamed Prime::BaseModel to Prime::Model.
* renamed Prime::BaseScreen to Prime::Screen.
* renamed Prime::BaseSection to Prime::Section.
* Model: sync/sync! separated to update/update! and fetch/fetch!
* Model: `fetch_associations` option on fetch renamed to `associations` option.
* Model: `update_from_response` option on update renamed to `save_response` option.
* Screen: `navigation: true` by default for screen initialization.
* Model.new with invalid parameter will not raise exception by default now.
* "id" attribute always being added to model by default now.
* screen.open_screen do not support root screen opening now. use app_delegate.open_screen for that.
* added shorter syntax for opening screens.
* fix rendering draw section without table.

=== 0.4.4
* Added Prime.env support
* Added Prime.root support
* Fix memory leak issues

=== 0.4.3
* Speed improvements
* Rename dm_ views to mp_
* Upgrade sugarcube
* Render screen on appear instead of on load

=== 0.4.2
* Bug fixes
* Added web view element support

=== 0.4.1
* Bug fixes
* Added custom progress view indicator
* Tab bar screens support image/title options now

=== 0.4.0
* Big refactoring and speed improvements.
* Use BaseSection both for draw and base elements.

=== 0.3.3
* Screen tab bar support

=== 0.3.2
* Refactor screens
* Fix paddings for draw sections
* Draw label now supports corner radius

=== 0.3.1
* Added universal AppDelegate#open_screen method for opening screens.
* Old AppDelegate#open_screen method renamed to AppDelegate#open_content_screen
* Ability to add inherited styles
* Update project template
* Small refactoring

=== 0.3.0
* Added iOS 7 support
* Added command line tools
* Many bug fixes

=== 0.2.1
* Bug fixes

=== 0.2.0
* MP::BaseModel improvements
* Added ability to observe form field errors
* Use MP::Config for style configurations

=== 0.1.7
* MP::BaseModel#fetch_associations now supports callback option
* MP::LabelDrawElement now supports `size_to_fit` option

=== 0.1.6
* Section container options now support proc values

=== 0.1.5
* MP::FormSection#on_edit renamed to on_input_edit
* MP::FormSection#on_input_change callback added
* MP::FormSection#on_input_return callback added, hides keyboard by default
* MP::FormSection#keyboard_will_show callback added
* MP::FormSection#keyboard_will_hide callback added
* MP::TableSection#on_appear callback added

=== 0.1.4 (Breaking changes)
* MotionPrime::BaseModel#sync_with_url renamed to fetch_with_url
* MotionPrime::BaseModel#sync_with_attributes renamed to fetch_with_attributes
* MotionPrime::BaseModel#sync_association renamed to fetch_association
* MotionPrime::BaseModel#sync_attributes renamed to updatable_attributes

=== 0.1.3
* added google map element support
* fixes for tabbed section

=== 0.1.2
* added tabbed section
* draw image element now supports layer. e.g. you can pass layer: {corner_radius: 50} now.
* draw label element now supports multiline.
* all draw elements now support hidden option