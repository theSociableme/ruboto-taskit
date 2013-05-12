class Task < JSONable
  attr_accessor :id, :name, :details, :completed, :user_id

  def initialize(id, name, description, user_id)
    @id = id
    @name = name
    @details = description
    @completed = false
    @user_id = user_id
  end
end