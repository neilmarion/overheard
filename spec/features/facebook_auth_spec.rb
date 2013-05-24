require 'spec_helper'

describe "Authorization through Facebook" do
  describe "signup (first-time sign in)" do
    it "succeeds signing up through facebook" do
      visit root_path
      expect{
        click_link I18n.t('general.sign_in_with_facebook') 
      }.to change(User, :count).by 1
      page.should have_link "Sign out"
    end
  end

  describe "signin" do
    it "through facebook" do
      expect{
        user = FactoryGirl.create(:user_facebook, 
          uid: OmniAuth.config.mock_auth[:facebook]['uid'],
          first_name: OmniAuth.config.mock_auth[:facebook]['info']['first_name'],
          last_name: OmniAuth.config.mock_auth[:facebook]['info']['last_name'])
      }.to change(User, :count).by 1

      expect{
        visit root_path
        click_link I18n.t('general.sign_in_with_facebook') 
        page.should have_link "Sign out"
      }.to_not change(User, :count)
    end   
  end
end
