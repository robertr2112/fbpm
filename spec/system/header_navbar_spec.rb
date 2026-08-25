require 'rails_helper'

RSpec.describe 'Header navbar', type: :system do
  it 'renders the brand and sign-in form for logged-out users' do
    visit root_path

    expect(page).to have_css('#main_navbar')
    expect(page).to have_link('Football Pool Mania', href: root_path)
    expect(page).to have_css('.navbar-toggler[aria-label="Toggle navigation"]')
    expect(page).to have_field('login_email')
    expect(page).to have_field('login_password')
    expect(page).to have_button('Sign in')
  end

  it 'renders the authenticated user navigation for logged-in users' do
    user = create(:user)
    sign_in_user(user)

    expect(page).to have_link('Home', href: root_path)
    expect(page).to have_link('All Users', href: users_path)
    expect(page).to have_css('a.user-name', text: user.name)
  end
end
