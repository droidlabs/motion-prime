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