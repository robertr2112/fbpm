require 'rails_helper'

RSpec.feature "User pages", type: :feature do

  subject { page }

  feature "index" do
    let (:user){
      FactoryBot.create(:user) }

    before do
      sign_in user
      visit users_path
    end

    scenario { should have_title('All users') }
    scenario { should have_content('All users') }

    context "pagination" do

      before(:all) { 30.times { FactoryBot.create(:user) } }
      after(:all)  { User.delete_all }

      scenario "should have page number links" do
        should have_selector('ul.pagination')
      end

      scenario "should list each user" do
        User.paginate(page: 1).first(20).each do |user|
          expect(page).to have_selector('td', text: user.name)
        end
      end
    end

    context "delete links" do
      let (:user2) { FactoryBot.create(:user) }

      scenario "Should not show 'delete' link for any user" do
        expect(page).not_to have_link('delete', href: user_path(user2))
      end

      context "as a supervisor user" do
        let(:supervisor) { FactoryBot.create(:supervisor) }
        before do
          sign_in supervisor
          visit users_path
        end

        scenario "Should show 'delete' link for other users" do
          expect(page).to have_link('delete', href: user_path(user))
        end
        scenario "Should not show 'delete' link for current user" do
          should_not have_link('delete', href: user_path(supervisor))
        end
        scenario "should be able to delete another user" do
          expect do
            click_link('delete', match: :first)
          end.to change(User, :count).by(-1)
        end
      end
    end
  end

  feature "profile page" do
    let(:user) { FactoryBot.create(:user) }
    before do
      sign_in user
      visit user_path(user)
    end

    scenario "should show Users name on page and title" do
      should have_content(user.name)
      should have_title(user.name)
    end
  end

  feature "signup page" do
    before { visit signup_path }

    scenario { should have_content('Sign up') }
    scenario { should have_title(full_title('Sign up')) }
  end

  feature "signup" do

    before do
     visit signup_path
    end

    let(:submit) { "Create my account" }

    context "with invalid information" do
      scenario "should not create a user" do
        expect { click_button submit }.not_to change(User, :count)
      end

      context "after submission" do
        before { click_button submit }

        scenario { should have_title('Sign up') }
        scenario { should have_content('can\'t be blank') }
      end
    end

    context "with valid information" do
      before do
        fill_in 'user_name',                  with: "Example User"
        fill_in 'user_user_name',             with: "User1"
        fill_in 'user_email',                 with: "user1@example.com"
        fill_in 'user_password',              with: "foobar"
        fill_in 'user_password_confirmation', with: "foobar"
      end

      scenario "should update user count by 1" do
        expect { click_button submit }.to change(User, :count).by(1)
      end

      scenario "should send user account activation email" do
        expect { click_button submit }.to change(ActionMailer::Base.deliveries, :size).by(1)
      end

      context "after creating the user" do
        before { click_button submit }
        let(:user) { User.find_by(email: 'user1@example.com') }

        scenario { should have_title(user.name) }
        scenario "should show user as not activated and show notice to activate" do
          should have_selector('div.alert.alert-info', text: 'Please')
          should have_content("look for the email")
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

        scenario "clicking resend_activation button should resend email" do
          ActionMailer::Base.deliveries.clear
          page.find_link("#{user.name}").click
          page.find_link("Resend Activation Email").click
          page.find('div.alert.alert-success', text: 'Activate')
          expect(ActionMailer::Base.deliveries.size).to eq 1
          expect(page).to have_selector('div.alert.alert-success',
                   text: 'Activate account message has been resent')
        end

        context "and the user is activated" do
          before do
            ActionMailer::Base.deliveries.clear
            user.activated = true
            user.save
          end

          scenario "resend_activation should show error message" do
            activate_url = root_url + "users/resend_activation/" + "#{user.id}"
            visit (activate_url)
            expect(ActionMailer::Base.deliveries.size).to eq 0
            expect(page).to have_selector('div.alert.alert-warning',
                   text: 'User account has already been activated!')
          end
          scenario "should be able to visit other pages" do
            visit users_path
            expect(page).to have_current_path(users_path)
          end
        end
      end
    end
  end

  feature "edit" do
    let(:user) { FactoryBot.create(:user) }
    before do
      sign_in(user)
      visit edit_user_path(user)
    end

    context "page" do
      scenario { should have_content("Update your profile") }
      scenario { should have_title("Edit user") }
      scenario { should have_link('Change?', href: 'http://gravatar.com/emails') }
    end

    context "with invalid Name" do
      scenario "it should show message it can't be blank" do
        fill_in 'user_name', with: ""
        click_button "Update Profile"
        should have_content('can\'t be blank')
      end
    end

    context "with invalid Name" do
      scenario "it should show message it can't be blank" do
        fill_in 'user_user_name', with: ""
        click_button "Update Profile"
        should have_content('can\'t be blank')
      end
    end

    context "with invalid Email" do
      scenario "it should show message it can't be blank" do
        fill_in 'user_email', with: ""
        click_button "Update Profile"
        should have_content('can\'t be blank')
      end
    end

    context "with invalid Password" do
      scenario "should show password is too short" do
        fill_in 'user_password', with: "12345"
        click_button "Update Profile"
        should have_content('is too short')
      end
    end

    context "with invalid Password Confirmation" do
      scenario do
        fill_in 'user_password', with: "123456"
        fill_in 'user_password_confirmation', with: "12345"
        click_button "Update Profile"
        should have_content('Password confirmation doesn\'t match Password')
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

      scenario { should have_title(new_name) }
      scenario { should have_selector('div.alert.alert-success') }
      scenario { should have_link('Log out', href: logout_path) }
      specify { expect(user.reload.name).to  eq new_name }
      specify { expect(user.reload.email).to eq new_email }
    end
  end
end
