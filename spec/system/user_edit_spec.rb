require 'rails_helper'

RSpec.describe "Edit page", type: :system do
  before do
    # driven_by(:selenium_chrome_headless)
    driven_by(:selenium_chrome)
  end
  describe "edit" do
    let(:user) { FactoryBot.create(:user) }

    before do
      sign_in(user)
      visit edit_user_path(user)
      find('h1.pageHeader', text: 'Update your profile')
    end

    context "page content" do
      scenario do
        expect(page).to have_content("Update your profile")
      end
      scenario do
        expect(page).to have_title(full_title("Edit user"))
      end
      scenario do
        expect(page).to have_link('Change?', href: 'http://gravatar.com/emails')
      end
    end

    context "with invalid Name" do
      scenario "it should show message it can't be blank" do
        fill_in 'user_name', with: ""
        click_button "Update Profile"
        expect(page).to have_content('can\'t be blank')
      end
    end

    context "with invalid Name" do
      scenario "it should show message it can't be blank" do
        fill_in 'user_user_name', with: ""
        click_button "Update Profile"
        expect(page).to have_content('can\'t be blank')
      end
    end

    context "with invalid Email" do
      scenario "it should show message it can't be blank" do
        fill_in 'user_email', with: ""
        click_button "Update Profile"
        expect(page).to have_content('can\'t be blank')
      end
    end

    context "with invalid Password" do
      scenario "should show password is too short" do
        fill_in 'user_password', with: "12345"
        click_button "Update Profile"
        expect(page).to have_content('is too short')
      end
    end

    context "with invalid Password Confirmation" do
      scenario "should show password confirmation doesn\'t match" do
        fill_in 'user_password', with: "123456"
        fill_in 'user_password_confirmation', with: "12345"
        click_button "Update Profile"
        expect(page).to have_content('Password confirmation doesn\'t match Password')
      end
    end

    context "with valid information" do
      let(:new_name)  { "New Name" }
      let(:new_user_name)  { "Name1" }
      let(:new_email) { "new@example.com" }

      before do
        fill_in 'user_name',                  with: new_name
        fill_in 'user_user_name',             with: new_user_name
        fill_in 'user_email',                 with: new_email
        fill_in 'user_password',              with: user.password
        fill_in 'user_password_confirmation', with: user.password
        click_button "Update Profile"
        find('div.alert.alert-success', text: "Profile updated")
      end

      scenario "expect page to have_title 'New Name | Football Pool Mania'" do
        expect(page).to have_title(full_title(new_name))
      end

      scenario "expect page to have_selector 'div.alert.alert-success'" do
        expect(page).to have_selector('div.alert.alert-success')
      end

      scenario do  # !!!! This should be in a header test not in Edit
        user.reload
        find('a.user-name').hover
        expect(page).to have_link('Log out', href: logout_path)
      end

      scenario "expect user name to be 'New Name'" do
        user.reload
        expect(user.name).to eq new_name
      end

      scenario "Expect user email to be 'new@example.com'" do
        user.reload
        expect(user.email).to eq new_email
      end
    end
  end
end
