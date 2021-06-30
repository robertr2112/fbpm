require 'rails_helper'

RSpec.feature "Authentication", type: :feature do

  subject { page }

  context "signin page" do
    before { visit login_path }

    context "with invalid information" do
      before { click_button 'signin_button' }

      scenario { should have_title('Log in') }
      scenario { should have_selector('div.alert.alert-danger', text: 'Invalid') }

      context "after visiting another page" do
        before { click_link 'Football Pool Mania' }
        scenario { should_not have_selector('div.alert.alert-danger') }
      end
    end

    context "with valid information" do
      let(:user) { FactoryBot.create(:user) }
      before do
        fill_in 'signin_email',    with: user.email.upcase
        fill_in 'signin_password', with: user.password
        click_button 'signin_button'
      end

      scenario { should have_title(user.name) }
      scenario { should have_link('All Users',   href: users_path) }
      scenario { should have_link('Profile',     href: user_path(user)) }
      scenario { should have_link('Settings',    href: edit_user_path(user)) }
      scenario { should have_link('Log out',     href: logout_path) }
      scenario { should_not have_link('Log in',  href: login_path) }

      context "followed by signout" do
        before { click_link "Log out" }
        scenario { should have_link('Log in') }
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
        scenario "should get the log in page" do
          expect(page).to have_title('Log in')
          expect(current_path).to eq login_path
        end

        context "after logging in" do
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
          scenario { should have_title('Log in') }
        end

        context "submitting to the update action" do
          before { patch user_path(user) }
          specify { expect(response).to redirect_to(login_path) }
          it { should_not have_selector('div.alert.alert-notice', text: 'Need to be logged in') }
        end

        context "visiting the user index" do
          before { visit users_path }
          scenario { should have_title('Log in') }
        end
      end
    end

    context "as wrong user" do
      let(:user) { FactoryBot.create(:user) }
      let(:wrong_user) { FactoryBot.create(:user, email: "wrong@example.com") }
      before { sign_in user, no_capybara: true }

      context "When visiting Users#edit page" do
        before { visit edit_user_path(wrong_user) }
        scenario { should_not have_title(full_title('Edit user')) }
      end

      context "submitting a PATCH request to the Users#update action" do
        it "should redirect to login page" do
          patch user_path(wrong_user)
          expect(response).to redirect_to(login_path)
        end
      end
    end

    context "as non-admin user" do
      let(:user) { FactoryBot.create(:user) }
      let(:non_admin) { FactoryBot.create(:user) }

      before { sign_in non_admin, no_capybara: true }

      context "submitting a DELETE request to the Users#destroy action" do
        before { delete user_path(user) }
        specify { expect(response).to redirect_to(root_path) }
      end
    end
  end
end
