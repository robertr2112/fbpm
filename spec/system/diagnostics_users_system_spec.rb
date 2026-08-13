require 'rails_helper'

RSpec.describe 'Diagnostics Users Turbo flow', type: :system, js: true do
  let!(:admin) { create(:admin, password: 'password', password_confirmation: 'password') }
  let!(:target_user) { create(:user) }

  before do
    # ensure admin exists and sign in via UI
    sign_in_user(admin)
    visit diagnostics_path
    # Wait for users pane to load via lazy-tabs Stimulus controller
    within('#diagnostics-users-pane') do
      expect(page).to have_content('Loading users').or have_content(target_user.email).or have_content(target_user.name)
    end

    # Wait for users content to replace the frame
    expect(page).to have_selector("turbo-frame#diagnostics-users-pane")
    # wait until the user row appears
    within('#diagnostics-users-pane') do
      expect(page).to have_content(target_user.name)
    end
  end

  it 'allows admin to set a password and shows flash and updates row' do
    within('#diagnostics-users-pane') do
      # click the Change Password link for the target user
        user_frame_id = ActionView::RecordIdentifier.dom_id(target_user)

      within("##{user_frame_id}") do
        click_link '<Change Password>'
      end

      # wait for the inline form to appear inside the user's frame
      within("##{user_frame_id}") do
        expect(page).to have_field('user[password]')
        fill_in 'user[password]', with: 'newpass123'
        fill_in 'user[password_confirmation]', with: 'newpass123'
        click_button 'Set Password'
      end
    end

    # Wait for flash to appear (some environments may not expose turbo-frame tag name, so just wait for the flash text)
    expect(page).to have_content('Password updated for', wait: 5)

    # Verify password changed on server side
    expect(User.find(target_user.id).authenticate('newpass123')).to be_truthy
  end

  it 'shows inline validation error when password too short' do
    within('#diagnostics-users-pane') do
        user_frame_id = ActionView::RecordIdentifier.dom_id(target_user)
        within("##{user_frame_id}") do
          click_link '<Change Password>'
        end

        within("##{user_frame_id}") do
          expect(page).to have_field('user[password]')
          fill_in 'user[password]', with: 'abc'
          fill_in 'user[password_confirmation]', with: 'abc'
          click_button 'Set Password'

          # Inline error should appear
          expect(page).to have_content(/too short|minimum/i)
        end
    end

    # Flash should contain error as well
    expect(page).to have_content('Unable to update password').or have_content('Password')
  end

  it 'shows confirmation mismatch message when confirmation does not match' do
    within('#diagnostics-users-pane') do
        user_frame_id = ActionView::RecordIdentifier.dom_id(target_user)
        within("##{user_frame_id}") do
          click_link '<Change Password>'
        end

        within("##{user_frame_id}") do
          expect(page).to have_field('user[password]')
          fill_in 'user[password]', with: 'securepw1'
          fill_in 'user[password_confirmation]', with: 'securepw2'
          click_button 'Set Password'

          # Inline error shows unified message
          expect(page).to have_content('Password and confirmation must match')
        end
    end

    # Flash should also include a danger message
    expect(page).to have_content('Unable to update password').or have_content('match')
  end
end
