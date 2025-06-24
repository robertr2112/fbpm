require 'rails_helper'

RSpec.describe "User pages", type: :system do

  before do
    driven_by(:selenium_chrome_headless)
    #driven_by(:selenium_chrome)
  end

  describe "All Users page", js: true do
    let (:user) { FactoryBot.create(:user) }

    before do
      sign_in user
      visit users_path
      click_link 'All Users'
    end

    after do
      find('a.nav-link', text: user.name).click
      click_link "Log out"
    end

    context "All Users page content" do
      scenario "should have title 'All users'" do 
        expect(page).to have_title('All users | Football Pool Mania')
      end
      scenario "Page should have content 'All users'" do 
        expect(page).to have_content('All users') 
      end
    end

    context "should have pagination content" do

      before(:all) { 30.times { FactoryBot.create(:user) } }
      after(:all)  { User.delete_all }

      scenario "that shows page number links" do
        expect(page).to have_selector('ul.pagination')
      end

      scenario "should list each user" do
        User.paginate(page: 1).first(20).each do |user|
          expect(page).to have_selector('td', text: user.name)
        end
      end
    end
  end

  describe "profile page" do
    let(:user) { FactoryBot.create(:user) }
    before do
      sign_in user
      visit user_path(user)
    end

    scenario "should show Users name on page and title" do
      expect(page).to have_content(user.name)
      expect(page).to have_title(user.name)
    end
  end

  describe "signup page" do

    before { visit signup_path }

    scenario "Should have content 'Sign up'" do 
      expect(page).to have_content('Sign up') 
    end
    scenario "Should have title 'Sign up'" do 
      expect(page).to have_title(full_title('Sign up')) 
    end
  end

  describe "signup" do

    before do
     visit signup_path
    end

    # Alias submit for "Create my account"
    let(:submit) { "Create my account" }

    context "with invalid information" do

      scenario "should not create a user" do
        expect { click_button submit }.not_to change(User, :count)
      end

      context "after submission" do

        before { click_button submit }

        scenario "page should have title 'Sign up'" do 
          expect(page).to have_title('Sign up') 
        end
        scenario "should have content 'can't be blank'" do 
          expect(page).to have_content('can\'t be blank') 
        end
      end
    end

    context "with valid information" do

      before do
        fill_in 'user_name',                  with: "Example User"
        fill_in 'user_user_name',             with: "User1"
        fill_in 'user_email',                 with: "user1@example.com"
        fill_in 'user_phone',                 with: "555-123-4567"
        select "Text", from: 'user_contact'
        fill_in 'user_password',              with: "foobar"
        fill_in 'user_password_confirmation', with: "foobar"
      end
 
      scenario "should update user count by 1" do
        click_button submit
        expect { User.count }.to change(User, :count).by(1)
      end

      scenario "should send user account activation email" do
        expect { click_button submit }.to change(ActionMailer::Base.deliveries, :size).by(1)
      end

      context "after creating the user" do
        before { click_button submit }
        let(:user) { User.find_by(email: 'user1@example.com') }

        scenario "should have title of the 'user.name'" do 
          expect(page).to have_title(user.name) 
        end
        scenario "should show user as not activated and show notice to activate" do
          expect(page).to have_selector('div.alert.alert-info', text: 'Please')
          expect(page).to have_content("look for the email")
          expect(user.activated?).to be false
        end

        context "and visiting any page before activation" do
          scenario "should reroute to users path with flash message" do
            visit pools_path
            expect(page).to have_current_path(user_path(user))
            expect(page).to have_selector('div.alert.alert-warning',
                     text: 'You must activate account before using the site!')
          end
        end

        scenario "clicking resend_activation button should resend email", js: true do
          ActionMailer::Base.deliveries.clear
          click_link(user.name)
          page.find_link("Resend Activation Email").click
          page.find('div.alert.alert-success', text: 'Activate')
          expect(ActionMailer::Base.deliveries.size).to eq 1
          expect(page).to have_selector('div.alert.alert-success',
                   text: 'Activate account message has been resent')
        end

        context "and the user is activated" do
          before do
            #ActionMailer::Base.deliveries.clear
            #click_link(user.name)
            #page.find_link("Resend Activation Email").click
            open_email(user.email) # Allows the current_email method
            #puts current_email
            #current_email.click_link 'Activate user account'
            #visit user_path(user)
          end

          scenario "should show message 'Account activated'" do
            expect(current_email).not_to be(nil)
            expect(current_email).to have_content 'Activate user account'
            #current_email.click_link 'Activate user account'
            expect(page).to have_selector('div.alert.alert-success',
                   text: 'Account activated!')
          end

          scenario "resend_activation should show error message" do
            #click_link(user.name)
            #page.find_link("Resend Activation Email").click
            #open_email(user.email) # Allows the current_email method
            #activate_url = root_url + "users/resend_activation/" + "#{user.id}"
            #visit (activate_url)
            #expect(page).to have_selector('div.alert.alert-warning',
            #       text: 'User account has already been activated!')
            #click_link(user.name)
            #page.find_link("Resend Activation Email").click
            expect(ActionMailer::Base.deliveries.size).to eq 1
            #expect(current_email).not_to be(nil)
          end
          scenario "should be able to visit other pages" do
            visit users_path
            expect(page).to have_current_path(users_path)
          end
        end
      end
    end
  end

  describe "edit" do
    let(:user) { FactoryBot.create(:user) }

    before do
      sign_in(user)
      visit edit_user_path(user)
      #expect(page).to have_title(full_title('Edit user'), wait: 10) 
    end

    context "page content" do
      scenario do
        expect(page).to have_content("Update your profile") 
      end
      scenario do 
        expect(page).to have_title("Edit user | Football Pool Mania") 
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
      end

      scenario do 
        expect(page).to have_title(new_name) 
      end
      scenario do 
        expect(page).to have_selector('div.alert.alert-success') 
      end
      #scenario do  # !!!! This should be in a header test not in Edit
      #  user.reload.name
      #  find('a.nav-link', text: user.name, wait:7).click
      #  expect(page).to have_link('Log out', href: logout_path) 
      #end
      scenario do 
        expect(user.reload.name).to  eq new_name 
      end
      scenario do 
        expect(user.reload.email).to eq new_email 
      end
    end
  end
end
