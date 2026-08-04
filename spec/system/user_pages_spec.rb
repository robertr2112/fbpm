require 'rails_helper'
require 'nokogiri'

RSpec.describe 'User pages', type: :system do
  before do
    driven_by(:selenium_chrome_headless_sandboxless)
    # driven_by(:selenium_chrome)
  end

  describe 'All Users page', js: true do
    let(:user) { FactoryBot.create(:user) }

    before do
      sign_in_user user
      visit users_path
      click_link 'All Users'
    end

    after do
      sign_out_user user
    end

    context 'All Users page content' do
      scenario "should have title 'All users'" do
        expect(page).to have_title('All users | Football Pool Mania')
      end
      scenario "Page should have content 'All users'" do
        expect(page).to have_content('All users')
      end
    end

    context 'should have pagination content' do
      before(:all) { 30.times { FactoryBot.create(:user) } }
      after(:all)  { User.delete_all }

      scenario 'that shows page number links' do
        expect(page).to have_selector('ul.pagination')
      end

      scenario 'should list each user' do
        # The limit(10) is dependent on the default per_page
        # value in the pagy gem, which is 10
        User.where(activated: true).limit(10).each do |user|
          expect(page).to have_link(user.name, href: user_path(user))
        end
      end
    end
  end

  describe 'profile page' do
    let(:user) { FactoryBot.create(:user) }
    before do
      sign_in_user user
      visit user_path(user)
    end

    scenario 'should show Users name on page and title' do
      expect(page).to have_content(user.name)
      expect(page).to have_title(user.name)
    end
  end

  describe 'signup page' do
    before { visit new_registrations_path }

    scenario "Should have content 'Sign up'" do
      expect(page).to have_content('Sign up')
    end
    scenario "Should have title 'Sign up'" do
      expect(page).to have_title(full_title('Sign up'))
    end
  end
end
