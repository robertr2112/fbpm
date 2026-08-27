require 'rails_helper'
require 'nokogiri'

RSpec.describe 'User signup', type: :system, js: true do
  before do
    # driven_by(:selenium_chrome_headless)
    driven_by(:selenium_chrome_headless_sandboxless)
    # driven_by(:selenium_chrome)
  end

  describe 'signup', js: true do
    before do
      visit new_registrations_path
    end

    # Alias submit for "Create my account"
    let(:submit) { 'Create my account' }

    context 'with no information' do
      scenario 'should not create a user' do
        expect { click_button submit }.not_to change(User, :count)
      end

      context 'after submission' do
        before { click_button submit }

        scenario "page should have title 'Sign up'" do
          expect(page).to have_title('Sign up')
        end
        scenario "should have content 'can't be blank'" do
          expect(page).to have_content('can\'t be blank')
        end
      end
    end

    context 'with invalid information' do
      before do
        fill_in 'user_name',                  with: 'Example User'
        fill_in 'user_user_name',             with: 'User1'
        fill_in 'user_email',                 with: 'user1@example.com'
        fill_in 'user_phone',                 with: '555-123-4567'
        select  'Email',                      from: 'user_contact'
        fill_in 'user_password',              with: 'foobar'
        fill_in 'user_password_confirmation', with: 'foobar'
      end

      context 'with invalid Name' do
        scenario "it should show message Name can't be blank" do
          fill_in 'user_name',                  with: ''
          click_button submit
          expect(page).to have_content('Name can\'t be blank')
        end
      end

      context 'with invalid User Name' do
        scenario "it should show message User name can't be blank" do
          fill_in 'user_user_name',             with: ''
          click_button submit
          expect(page).to have_content('User name can\'t be blank')
        end
      end

      context 'with invalid phone' do
        scenario "it should show message Phone is invalid" do
          fill_in 'user_phone',                 with: '555'
          select  'Text',                       from: 'user_contact'
          click_button submit
          expect(page).to have_content('Phone is invalid')
        end
      end

      context 'with blank phone and contact method text' do
        scenario "it should show message Phone can't be blank" do
          fill_in 'user_phone',                 with: ''
          select  'Text',                       from: 'user_contact'
          click_button submit
          expect(page).to have_content('Phone can\'t be blank')
        end
      end

      context 'with blank phone and contact method both' do
        scenario "it should show message Phone can't be blank" do
          fill_in 'user_phone',                 with: ''
          select  'Both',                       from: 'user_contact'
          click_button submit
          expect(page).to have_content('Phone can\'t be blank')
        end
      end

      context 'with blank Email' do
        scenario "it should show message Email can't be blank" do
          fill_in 'user_email',                 with: ''
          click_button submit
          expect(page).to have_content('Email can\'t be blank and Email is invalid')
        end
      end

      context 'with invalid Email' do
        scenario "it should show message Email is invalid" do
          fill_in 'user_email',                 with: 'user1@'
          click_button submit
          expect(page).to have_content('Email is invalid')
        end
      end

      context 'with blank Password' do
        scenario 'should show Password can\'t be blank' do
          fill_in 'user_password',              with: ''
          fill_in 'user_password_confirmation', with: ''
          click_button submit
          expect(page).to have_content('Password can\'t be blank')
        end
      end

      context 'with <6 character Password' do
        scenario 'should show Password is too short' do
          fill_in 'user_password',              with: '12345'
          fill_in 'user_password_confirmation', with: '12345'
          click_button submit
          expect(page).to have_content('Password is too short (minimum is 6 characters)')
        end
      end

      context 'with invalid Password Confirmation' do
        scenario "should show password confirmation doesn\'t match" do
          fill_in 'user_password',              with: 'foobar'
          fill_in 'user_password_confirmation', with: '123456'
          click_button submit
          expect(page).to have_content('Password confirmation doesn\'t match Password')
        end
      end
    end

    context 'with valid information' do
      before do
        fill_in 'user_name',                  with: 'Example User'
        fill_in 'user_user_name',             with: 'User1'
        fill_in 'user_email',                 with: 'user1@example.com'
        fill_in 'user_phone',                 with: '555-123-4567'
        select  'Text',                       from: 'user_contact'
        fill_in 'user_password',              with: 'foobar'
        fill_in 'user_password_confirmation', with: 'foobar'
      end

      scenario 'should update user count by 1' do
        count = User.count
        click_button submit
        find('h1.pageHeader', text: "Example User")
        expect(User.count).to eq(count + 1)
      end

      scenario 'should send user account activation email' do
        click_button 'Create my account'
        find('h1.pageHeader', text: "Example User")
        expect(page).to have_content("Please check your email to activate your account.")
      end

      context 'after creating the user' do
        before do
          click_button submit
          expect(page).to have_current_path(%r{\A/users/\d+\z})
          expect(page).to have_selector('h1.pageHeader', text: 'Example User')
          expect(page).to have_selector(
            'div.alert.alert-info',
            text: 'Please check your email to activate your account.'
          )
        end
        let(:user) { User.find_by(email: 'user1@example.com') }

        scenario "should have title of the Example User" do
          expect(page).to have_title(user.name)
        end
        scenario 'should show user as not activated and show notice to activate' do
          expect(page).to have_selector('div.alert.alert-info', text: 'Please')
          expect(page).to have_content('look for the email')
          expect(user.activated?).to be false
        end

        context 'and visiting any page before activation' do
          scenario 'should reroute to users path with flash message' do
            visit pools_path
            expect(page).to have_current_path(user_path(user))
            expect(page).to have_selector('div.alert.alert-warning',
                                          text: 'You must activate account before using the site!')
          end
        end

        scenario 'clicking resend_activation button should resend email', js: true do
          find('a.user-name').click
          find('a.user-resend').click
          find('div.alert.alert-success')
          expect(page).to have_selector('div.alert.alert-success',
                                        text: 'Activate account message has been resent')
        end
      end
    end
  end
end
