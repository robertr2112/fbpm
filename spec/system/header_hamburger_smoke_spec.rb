require 'rails_helper'

RSpec.describe 'Header hamburger smoke', type: :system, js: true do
  after do
    page.driver.browser.manage.window.resize_to(1920, 1080)
  end

  it 'opens the collapsed navigation when the toggle is clicked' do
    page.driver.browser.manage.window.resize_to(375, 812)
    visit root_path

    menu = find('#navbar-list-2', visible: :all)
    expect(page).to have_css('.navbar-toggler', visible: true)
    expect(menu[:class]).not_to include('show')

    find('.navbar-toggler').click

    expect(page).to have_css('#navbar-list-2.show', visible: :all)
  end
end
