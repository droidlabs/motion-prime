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