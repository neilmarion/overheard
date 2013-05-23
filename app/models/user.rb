class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :omniauthable,
         :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation
  attr_accessible :first_name, :last_name, :provider, :uid

  def self.from_omniauth(auth)
    
    where(auth.slice("provider", "uid")).first || create_from_omniauth(auth)
  end 

  def self.create_from_omniauth(auth)
    create! do |user|
      user.provider = auth["provider"]
      user.uid = auth["uid"]
      user.first_name = auth["info"]["first_name"]
      user.last_name = auth["info"]["last_name"]
      user.username = auth["info"]["nickname"]
      user.email = auth["info"]["email"]
      user.password = Devise.friendly_token[0,20]
      if auth['extra']
        if auth['raw_info']
          if auth['education']
            auth['extra']['raw_info']['education'].each do |school|
              if school['type'] == 'College'
                user.concentration = school['concentration'][0]['name'] if school['concentration']
                user.college = school['school']['name'] if school['school']
                break
              end 
            end 
          end 
        end 
      end 
    end 
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
end
