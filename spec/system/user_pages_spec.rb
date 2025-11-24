require 'rails_helper'
require 'nokogiri'

RSpec.describe 'User pages', type: :system do
  before do
    # driven_by(:selenium_chrome_headless)
    driven_by(:selenium_chrome_headless_sandboxless)
    # driven_by(:selenium_chrome)
  end

  describe 'All Users page', js: true do
    let(:user) { FactoryBot.create(:user) }

    before do
      sign_in user
      visit users_path
      click_link 'All Users'
    end

    after do
      find('a.user-name').hover
      find('a.user-logout').click
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
        User.paginate(page: 1).first(20).each do |user|
          expect(page).to have_selector('td', text: user.name)
        end
      end
    end
  end

  describe 'profile page' do
    let(:user) { FactoryBot.create(:user) }
    before do
      sign_in user
      visit user_path(user)
    end

    scenario 'should show Users name on page and title' do
      expect(page).to have_content(user.name)
      expect(page).to have_title(user.name)
    end
  end

  describe 'signup page' do
    before { visit signup_path }

    scenario "Should have content 'Sign up'" do
      expect(page).to have_content('Sign up')
    end
    scenario "Should have title 'Sign up'" do
      expect(page).to have_title(full_title('Sign up'))
    end
  end
end
