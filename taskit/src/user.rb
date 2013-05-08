class User
  attr_accessor :name, :email_address

  def initialize(name, email)
    @name = name
    @email_address = email
  end
end