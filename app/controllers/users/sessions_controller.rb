class Users::SessionsController < Devise::SessionsController
  protect_from_forgery except: :destroy
  
  def destroy
    super
  end
end