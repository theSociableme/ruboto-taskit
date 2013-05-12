class Task < JSONable
  attr_accessor :id, :name, :description, :completed, :user_id

  def initialize(id, name, description)
    @id = id
    @name = name
    @description = description
    @completed = false
  end
end