require 'rails_helper'

RSpec.describe "Authentication", type: :system do
  subject { page }

  context "signin page" do
    before { visit new_session_path }

    scenario { should have_title(full_title('Sign in')) }
    scenario { should have_selector('h1', text: 'Sign in') }

    context "with invalid password" do
      let(:user) { FactoryBot.create(:user) }
      scenario do
        fill_in 'signin_email',    with: user.email
        fill_in 'signin_password', with: "badpass"
        click_button 'signin_button'
        should have_selector('div.alert.alert-danger', text: 'Try another email address or password')
      end
    end

    context "with invalid email" do
      let(:user) { FactoryBot.create(:user) }
      scenario do
        fill_in 'signin_email',    with: "bademail@example.com"
        fill_in 'signin_password', with: user.password
        click_button 'signin_button'
        should have_selector('div.alert.alert-danger', text: 'Try another email address or password')
      end
    end

    #   context "after visiting another page" do
    #     before { click_link 'Football Pool Mania' }
    #     scenario { should_not have_selector('div.alert.alert-error') }
    #   end

    context "with valid information" do
      let(:user) { FactoryBot.create(:user) }
      before do
        fill_in 'signin_email',    with: user.email.upcase
        fill_in 'signin_password', with: user.password
        click_button 'signin_button'
      end

      scenario { should have_title(user.name) }
      scenario { should have_link('All Users',   href: users_path) }
      scenario "Should have sub-link 'Profile' under user name link", js: true do
        click_link(user.name)
        should have_link('Profile',     href: user_path(user))
      end
      scenario "Should have sub-link 'Settings' under user name link", js: true do
        click_link(user.name)
        should have_link('Settings',    href: edit_user_path(user))
      end
      scenario "Should have sub-link 'Sign out' under <user name> link", js: true do
        click_link(user.name)
        should have_link('Sign out',     href: session_path)
      end
      scenario { should_not have_link('Sign in',  href: new_session_path) }

      context "followed by signout" do
        before do
          click_link(user.name)
          click_link "Sign out"
        end
        scenario { should have_selector('h1', text: 'Sign in') }
      end
    end
  end

  feature "authorization", type: :request do
    context "for non-logged-in users" do
      let(:user) { FactoryBot.create(:user) }

      context "when attempting to visit a protected page" do
        before do
          visit edit_user_path(user)
          end
        scenario "should get the Sign in page" do
          expect(page).to have_title('Sign in')
          expect(current_path).to eq new_session_path
        end

        context "after sign in" do
          before do
            visit edit_user_path(user)
            fill_in 'signin_email',    with: user.email.upcase
            fill_in 'signin_password', with: user.password
            click_button 'signin_button'
          end

          scenario "should render the desired protected page" do
            expect(page).to have_title('Edit user')
          end
        end
      end

      context "in the Users controller" do
        context "visiting the edit page" do
          before { visit edit_user_path(user) }
          scenario { should have_title('Sign in') }
        end

        context "submitting to the update action" do
          before { patch user_path(user) }
          specify { expect(response).to redirect_to(new_session_path) }
          it { should_not have_selector('div.alert.alert-notice', text: 'Need to be logged in') }
        end

        context "visiting the user index" do
          before { visit users_path }
          scenario { should have_title('Sign in') }
        end
      end
    end

    context "as wrong user" do
      let(:user) { FactoryBot.create(:user) }
      let(:wrong_user) { FactoryBot.create(:user, email: "wrong@example.com") }
      before { sign_in_as user }

      context "When visiting Users#edit page" do
        before { visit edit_user_path(wrong_user) }
        scenario { should_not have_title(full_title('Edit user')) }
      end

      context "submitting a PATCH request to the Users#update action" do
        it "should redirect to Signin page" do
          patch user_path(wrong_user)
          expect(response).to redirect_to(root_path)
        end
      end
    end

    context "as non-admin user" do
      let(:user) { FactoryBot.create(:user) }
      let(:non_admin) { FactoryBot.create(:user) }

      context "submitting a DELETE request to the Users#destroy action" do
        specify do
          sign_in_as non_admin
          delete user_path(user)
          expect(response).to redirect_to(root_path)
        end
      end
    end
  end
end
