require 'rails_helper'

RSpec.describe "Static pages", type: :system do

  before do
    driven_by(:selenium_chrome_headless)
  end

  subject { page }

  feature "When visiting the login page" do
    let (:user){ FactoryBot.create(:user) }

    scenario "with invalid login information" do
      visit(login_path)
      should have_title('Log in')
      fill_in 'signin_email',    with: user.email.upcase
      fill_in 'signin_password', with: "badpassword"
      click_button 'signin_button'
      should have_title('Log in')
      expect(page).to have_text("Invalid email/password combination.")
    end

    scenario "with valid login information" do
      visit(login_path)
      should have_title('Log in')
      fill_in 'signin_email',    with: user.email.upcase
      fill_in 'signin_password', with: user.password
      click_button 'signin_button'
      expect(should have_title(full_title(user.name)))
    end
  end
end
