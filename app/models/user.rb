class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :omniauthable,
         :trackable, :validatable

  # Setup accessible (or protected) attributes for your model

  def self.from_omniauth(auth)
    
    where(auth.slice("provider", "uid")).first || create_from_omniauth(auth)
  end 

  def self.create_from_omniauth(auth)
    raw_parameters = { 
      :provider => auth["provider"],
      :uid => auth["uid"],
      :first_name => auth["info"]["first_name"],
      :last_name => auth["info"]["last_name"],
      :username => auth["info"]["nickname"],
      :email => auth["info"]["email"],
      :password => Devise.friendly_token[0,20]
    }

    parameters = ActionController::Parameters.new(raw_parameters)
    user = create(parameters.permit(:provider, :uid, :first_name, :last_name,
                                        :username, :email, :password))
    user
  end 

  def self.new_with_session(params, session)
    if session["devise.user_attributes"]
      new(session["devise.user_attributes"], without_protection: true) do |user|
        user.attributes = params
        user.valid?
      end 
    else
      super
    end 
  end

  def name
    "#{first_name} #{last_name}"
  end 
end
