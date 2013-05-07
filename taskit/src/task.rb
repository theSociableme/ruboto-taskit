class Task
  attr_accessor :description, :completed

  def initialize(description)
    @description = description
    @completed = false
  end
end