class User < MotionPrime::Model
  attributes :name, :age, :birthday
  timestamp_attributes
end
class Plane < MotionPrime::Model
  attributes :name, :age
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

class Organization < MotionPrime::Model
  attribute :name
  has_many :projects
end

class Project < MotionPrime::Model
  attribute :title
end

class Autobot < MotionPrime::Model
  attribute :name
  attribute :uid, type: :integer
  attribute :release_at, type: :time
  attribute :strength, type: :float
end

module CustomModule; end
class CustomModule::Car < MotionPrime::Model
  attribute :name
  attribute :created_at
end
Car = CustomModule::Car

def stub_user(name, age, birthday, id = nil)
  user = User.new
  user.id = id || 1
  user.name = name
  user.age  = age
  user.birthday = birthday
  user
end

def documents_path
  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true)[0]
end