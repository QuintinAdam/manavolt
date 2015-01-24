# By default Volt generates this User model which inherits from Volt::User,
# you can rename this if you want.
class User < Volt::User
  def index
    self.model = store._users.buffer
  end
end
