class User < MotionPrime::Model
  attributes :name, :age, :created_at
end

class Plane < MotionPrime::Model
  attributes :name, :age
end

class Listing < MotionPrime::Model
  attribute :name
end

class Todo < MotionPrime::Model
  attribute :title
  bag :items
end

class TodoItem < MotionPrime::Model
  attribute :completed
  attribute :text
end

class Page < MotionPrime::Model
  attribute :text
  attribute :index
end

class Animal < MotionPrime::Model
  attribute :name
end

class Autobot < MotionPrime::Model
  attribute :name
end

class Organization < MotionPrime::Model
  attribute :name
  has_many :projects
end

class Project < MotionPrime::Model
  attribute :title
end

module CustomModule; end
class CustomModule::Car < MotionPrime::Model
  attribute :name
  attribute :created_at
end
Car = CustomModule::Car

def stub_user(name, age, created_at, id = nil)
  user = User.new
  user.id = id || 1
  user.name = name
  user.age  = age
  user.created_at = created_at
  user
end

def documents_path
  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true)[0]
end