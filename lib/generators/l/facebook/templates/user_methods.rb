  def likes?(id)
    self.graph.get_connections('me', "likes/#{id}").length > 0
  rescue
    false
  end

  def self.find_for_facebook_oauth(access_token, signed_in_resource=nil)
    data = access_token.extra.raw_info
    if (user = signed_in_resource || self.where(:email => data.email).first).blank?
      user = self.new(email: data.email, 
                      password: Devise.friendly_token[0,20]) 
      user.save!(:validate => false)

      user.set_role = :facebook
    end
    
    user.update_attributes(fbid: data.id, first_name: data.first_name, last_name: data.last_name)
    user.authentications.find_or_create_by_uid_and_token(data.id, :token => access_token['credentials']['token'])

    user
  end

  def graph
    @graph ||= Koala::Facebook.API.new(authentications.last.token)
  end

