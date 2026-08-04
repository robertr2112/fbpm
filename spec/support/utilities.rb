module AuthenticationHelper
  def sign_in_user(user)
    visit new_session_path
    find('#signin_email').set(user.email)
    find('#signin_password').set(user.password)
    find('#signin_button').click
    find('h1.pageHeader', text: user.name)
  end

  def sign_out_user(user)
    visit user_path(user)
    find('h1.pageHeader', text: /#{Regexp.escape(user.name)}/)
    if has_css?('.navbar-toggler', visible: true)
      find('.navbar-toggler').click
    end
    find('a.user-name').click
    # The following line is needed because the click on the link
    # doesn't work in headless mode, so we use execute_script to click the link
    # instead of find('#user-logout').click
    logout_link = find('#user-logout', visible: false)

    page.execute_script("arguments[0].click();", logout_link)
    # execute_script("document.getElementById('user-logout').click();")
    find('h1.pageHeader', text: 'Sign in')
  end

  #  Here are the support routines to test out pools

  def build_survivor_context
    season = FactoryBot.create(:season_with_weeks_and_games, num_weeks: 3, num_games: 3)
    season.update!(current_week: 1)
    season.weeks.update_all(state: Week::STATES[:Pend])
    add_season_games_scores(season)
    users  = setup_pool_with_users_and_entries(season, 5, 1)
    pool   = users[0].pools.first
    pool.update!(pool_done: false)
    [ season, users, pool ]
  end

  # add scores for all games and all weeks in the season, where all home teams win (for simplicity)
  # for each week, but leave current week as 1 and don't mark any weeks as final
  def add_season_games_scores(season)
    season.weeks.each do |week|
      week.games.each do |game|
        game.update!(homeTeamScore: 21, awayTeamScore: 10)
        game.save
      end
    end
  end

  # will setup a pool with num_users number of users and num_entries number of
  # entries per user in entered season
  def setup_pool_with_users_and_entries(season, num_users, num_entries)
    users = []
    users[0] = FactoryBot.create(:user_with_pool_and_entry, season: season)
    pool = users[0].pools.first
    1.upto(num_users - 1) do |n|
      users[n] = FactoryBot.create(:user_with_pool_and_entry, season: season, pool: pool)
    end

    # If you truly want multiple entries per user, add them explicitly here
    if num_entries > 1
      users.each do |user|
        (num_entries - 1).times do
          pool.entries.create!(
            name: pool.getEntryName(user),
            user_id: user.id,
            survivorStatusIn: true
          )
        end
      end
    end

    users
  end

  #
  # This routine is used to make specified picks/forgot to picks for a given week, and
  # then finalize the week and update the pool with the results.  It takes a number of
  # arguments:
  #             season          - This is the current season under test
  #             pool            - The pool under test
  #             users           - Array of users in the pool
  #             numUsersCorrect - The number of users to pick correctly for this week
  #             numUsersForgot  - The number of users to have forget to pick for this week
  #
  def pool_update_survivor_users(season, pool, users, numUsersCorrect, numUsersForgot)
    week = season.getCurrentWeek
    correct_count = 1
    forgot_count = 1
    users.each do |user|
      # Get entry for this user
      entry = pool.entries.where(user_id: user.id)[0]

      # Skip the first numUsersForgot users as those who forgot to pick
      if forgot_count <= numUsersForgot
        forgot_count  += 1
        next
      # Next mark the users for numUsersCorrect number of correct users, the rest will
      # be incorrect
      else
        if entry.survivorStatusIn

          used_team_indices = entry.game_picks.pluck(:chosenTeamIndex)

          # All home teams this week
          home_teams = week.games.map(&:homeTeamIndex)

          # All away teams this week
          away_teams = week.games.map(&:awayTeamIndex)

          if correct_count <= numUsersCorrect
            # Must pick an unused HOME team
            team_index = home_teams.find { |t| !used_team_indices.include?(t) }
          else
            # Must pick an unused AWAY team
            team_index = away_teams.find { |t| !used_team_indices.include?(t) }
          end

          new_pick = entry.picks.build(week_id: week.id, week_number: week.week_number)
          new_game_pick = new_pick.game_picks.build(chosenTeamIndex: team_index)
          new_pick.save
          new_game_pick.save
        end

        forgot_count  += 1
        correct_count += 1
      end
    end
    week.setState(Week::STATES[:Final])

    # Call season.updatePools instead of directly calling pool.updateEntries directly so
    # we can share code with the tests that are testing out multiple week behavior.  This
    # routine just calls pool.updateEntries and updates the current week of the season.  We
    # could do that separately in test code but it seems uncessary.
    #
    season.updatePools
    pool.reload
  end

  def numberRemainingSurvivorEntries(pool)
    num_entries = 0
    pool.entries.each do |entry|
      num_entries += 1 if entry.survivorStatusIn
    end
    num_entries
  end
end
