class User < JSONable
  attr_accessor :name, :email_address, :id

  def initialize(id, name, email)
    @id = id
    @name = name
    @email_address = email
  end
end