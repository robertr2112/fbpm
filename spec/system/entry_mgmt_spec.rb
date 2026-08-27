require 'rails_helper'
RSpec.describe 'Entry Management', type: :system do
  before do
    driven_by(:selenium_chrome_headless_sandboxless)
    # driven_by(:selenium_chrome)
  end

  feature 'create', js: true do
    before do
      given_that_a_season_has_been_created
    end

    scenario 'A user entry is created when the user creates a pool' do
      and_I_am_a_logged_in_user
      when_I_create_a_pool
      then_an_entry_should_be_created
    end

    scenario 'A user entry is created when the user joins a pool' do
      and_another_user_creates_a_pool
      and_I_am_a_logged_in_user
      when_I_join_the_pool
      then_an_entry_should_be_created
    end
  end

  feature 'update', js: true do
    before do
      given_that_a_season_has_been_created
      and_I_am_a_logged_in_user
      and_I_have_created_a_pool
    end

    scenario 'Can update the entry name' do
      when_I_update_the_entry_name
      then_the_new_entry_name_should_be_shown
    end
  end

  feature 'delete', js: true do
    before do
      given_that_a_season_has_been_created
      and_another_user_creates_a_pool
      and_I_am_a_logged_in_user
      and_I_join_the_pool
    end

    scenario 'the entry is deleted when the user leaves the pool' do
      when_I_leave_the_pool
      then_the_entry_should_be_deleted
    end
  end

  ### Given Definitions ###

  def given_that_a_season_has_been_created
    @admin_user = FactoryBot.create(:admin)
    sign_in_user @admin_user
    @season = FactoryBot.create(:season_with_weeks_and_games, num_weeks: 4, num_games: 4)
    @season.setState(Season::STATES[:Open])
    sign_out_user @admin_user
  end

  ### And Definitions ###

  def and_I_am_a_logged_in_user
    @user =  FactoryBot.create(:user)
    sign_in_user @user
  end

  def and_another_user_creates_a_pool
    @user2 =  FactoryBot.create(:user)
    sign_in_user @user2
    visit new_pool_path
    find('h1.pageHeader', text: 'Create New Pool')
    fill_in 'pool_name', with: 'Test Pool'
    click_button 'Create pool'
    expect(page).to have_text("Pool 'Test Pool' was created successfully!")
    @pool = Pool.find_by_name('Test Pool')
    sign_out_user @user2
  end

  def and_I_have_created_a_pool
    when_I_create_a_pool
  end

  def and_I_join_the_pool
    when_I_join_the_pool
  end

  ### When Definitions ###

  def when_I_create_a_pool
    visit new_pool_path
    find('h1.pageHeader', text: 'Create New Pool')
    fill_in 'pool_name', with: 'Test Pool'
    click_button 'Create pool'
    expect(page).to have_text("Pool 'Test Pool' was created successfully!")
    @pool = Pool.find_by_name('Test Pool')
  end

  def when_I_join_the_pool
    visit pool_path(@pool)
    click_link 'Join', href: join_path(@pool.id)
    # Wait for the join action to complete and show confirmation flash/redirect
    expect(page).to have_text("Successfully added to Pool")
  end

  def when_I_leave_the_pool
    visit pool_path(@pool)
    find_link('Pool Management').click
    find_link("#{@pool.name}").click
    click_link 'Leave Pool'
  end

  def when_I_update_the_entry_name
    find_link('Pool Management').click
    find_link("#{@pool.name}").click
    entry_name = @user.user_name
    find('a.dropdown-item', text: "#{entry_name}").click
    click_link 'Edit entry'
    @new_entry_name = "New Entry Name"
    fill_in 'entry_name', with: "#{@new_entry_name}"
    click_button 'Save changes'
  end

  ### Then Definitions ###

  def then_an_entry_should_be_created
    visit user_path(@user)
    entry_name = @user.user_name
    expect(page).to have_text(entry_name)
  end

  def then_the_new_entry_name_should_be_shown
    visit user_path(@user)
    expect(page).to have_text("#{@new_entry_name}")
  end

  def then_the_entry_should_be_deleted
    visit user_path(@user)
    entry_name = @user.user_name
    expect(page).to_not have_text(entry_name)
  end
end
