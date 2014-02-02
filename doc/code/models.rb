# ** What is a Model? **
#
# "Model" will help you to store any information in database and sync this information with server.

# ** Create a model. **
#
# Just inherit it from `Prime::Model`.

class Event < Prime::Model
end

# ** Add some attributes to model. **
#
# E.g. we want event to have title and description.

class Event < Prime::Model
  attribute :title
  attribute :description
end

# ** Create some item. **
#
# This event will be saved to database and accessible after restart of application.

event = Event.create(
  title: 'MotionPrime release.',
  description: 'Check out new features.'
)

# ** Retrieve all events **

Event.all

# ** Next **
#
# [Read more about Tables](tables.html)