require 'rails_helper'
require 'nokogiri'

RSpec.describe 'User signup', type: :system, js: true do
  before do
    # driven_by(:selenium_chrome_headless)
    driven_by(:selenium_chrome_headless_sandboxless)
    # driven_by(:selenium_chrome)
    # host = Capybara.current_session.server.host
    # port = Capybara.current_session.server.port
    # ActionMailer::Base.default_url_options = { host: host, port: port }
  end

  # after do
  #  ActionMailer::Base.default_url_options = {} # Reset to avoid affecting other tests
  # end

  describe 'signup', js: true do
    before do
      visit signup_path
    end

    # Alias submit for "Create my account"
    let(:submit) { 'Create my account' }

    context 'with invalid information' do
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

    context 'with valid information' do
      before do
        fill_in 'user_name',                  with: 'Example User'
        fill_in 'user_user_name',             with: 'User1'
        fill_in 'user_email',                 with: 'user1@example.com'
        fill_in 'user_phone',                 with: '555-123-4567'
        select 'Text', from: 'user_contact'
        fill_in 'user_password',              with: 'foobar'
        fill_in 'user_password_confirmation', with: 'foobar'
      end

      scenario 'should update user count by 1' do
        Capybara.using_wait_time(5) do
          expect { click_button submit }.to change(User, :count).by(1)
        end
      end

      scenario 'should send user account activation email' do
        Capybara.using_wait_time(5) do
          expect { click_button submit }.to change(ActionMailer::Base.deliveries, :size).by(1)
        end
      end

      context 'after creating the user' do
        before do
          click_button submit
          find('div.alert.alert-info')
        end
        let(:user) { User.find_by(email: 'user1@example.com') }

        scenario "should have title of the 'user.name'" do
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
          ActionMailer::Base.deliveries.clear
          find('a.user-name').hover
          find('a.user-resend').click
          find('div.alert.alert-success')
          expect(ActionMailer::Base.deliveries.size).to eq 1
          expect(page).to have_selector('div.alert.alert-success',
                                        text: 'Activate account message has been resent')
        end

        context 'and the user is activated' do
          before do
            ActionMailer::Base.deliveries.clear
            find('a.user-name').hover
            find('a.user-resend').click
            find('div.alert.alert-success')
          end

          scenario "should show message 'Account activated'" do
            email = ActionMailer::Base.deliveries.last
            html_body = email.html_part.body.to_s
            document = Nokogiri::HTML(html_body)
            target_link = document.at("a:contains('Activate user account')")
            link_url = target_link['href']
            visit link_url
            expect(page).to have_selector('div.alert.alert-success',
                                          text: 'Account activated!')
          end

          scenario 'after activation then resend_activation should not be visible' do
            email = ActionMailer::Base.deliveries.last
            html_body = email.html_part.body.to_s
            document = Nokogiri::HTML(html_body)
            target_link = document.at("a:contains('Activate user account')")
            link_url = target_link['href']
            visit link_url
            find('a.user-name').hover
            expect(page).not_to have_selector('a.user-resend')
          end
        end
      end
    end
  end
end
