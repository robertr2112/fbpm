# == Schema Information
#
# Table name: weeks
#
#  id          :bigint           not null, primary key
#  state       :integer
#  week_number :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  season_id   :bigint
#
# Indexes
#
#  index_weeks_on_season_id  (season_id)
#
require 'open-uri'
require 'nokogiri'
require 'pp'

class Week < ApplicationRecord

  STATES = { Pend: 0, Open: 1, Closed: 2, Final: 3 }

  before_create do
    self.state = Week::STATES[:Pend]
  end

  belongs_to :season
  has_many   :games, inverse_of: :week, dependent: :destroy

  accepts_nested_attributes_for :games, allow_destroy: true

  validates :state, inclusion:   { in: 0..3 }
  validates :week_number, numericality: { only_integer: true, greater_than: 0,
                                          less_than_or_equal_to: 18}
  validate :gamesValid?

  def setState(state)
    self.state = state
    self.save
  end

  def checkStatePend
    self.state == Week::STATES[:Pend]
  end

  def checkStateOpen
    self.state == Week::STATES[:Open]
  end

  def checkStateClosed
    self.state == Week::STATES[:Closed]
  end

  def checkStateFinal
    self.state == Week::STATES[:Final]
  end

  def open?
    checkStateOpen
  end

  def closed?
    checkStateClosed
  end

  #
  # Find the game for this week from the team index
  #
  def find_game(chosenTeamIndex)
    self.games.each do |game|
      if game.homeTeamIndex == chosenTeamIndex ||
         game.awayTeamIndex == chosenTeamIndex
        return game
      end
    end
    return nil
  end

  #
  # Get the bye teams for the week
  #
  def get_bye_teams
    bye_teams = Array.new
    1.upto(32) do |i|
      if find_game(i) == nil
        bye_teams << i
      end
    end
    return bye_teams
  end

  #
  # Generate NFL schedule for a specified week
  #
  def create_nfl_week(season, nfl_games)
    nfl_games.each do |nfl_game|
      home_team_name  = "%#{nfl_game[:home_team]}%"
      home_team       = Team.where('name LIKE ?', home_team_name).first
      away_team_name  = "%#{nfl_game[:away_team]}%"
      away_team       = Team.where('name LIKE ?', away_team_name).first
      # Create the time string
      if nfl_game[:date] && nfl_game[:time]
        if nfl_game[:date].include? "January"
          year = season.year.to_i + 1
        else
          year = season.year.to_i
        end
        # ***HACK*** Using ESPN website doesn't give the timezone in the protocol.
        # Setting time zone based on week 9 (which is usually when the time changes)
        if self.week_number == 9
          if nfl_game[:date].include? "Thursday"
            nfl_game[:timezone]="CDT"
          else
            nfl_game[:timezone]="CST"
          end
        elsif self.week_number > 9
          nfl_game[:timezone]="CST"
        else
          nfl_game[:timezone]="CDT"
        end

        if nfl_game[:time].include?("TBD")
          # Only do the date and add 05:00 AM to mark it as TBD
          game_date_time = DateTime.parse(nfl_game[:date] \
                         + " " + "05:00 am" + " " + nfl_game[:timezone])
        else
          # Do the date and time
          game_date_time = DateTime.parse(nfl_game[:date] \
                         + " " + nfl_game[:time] + " " + nfl_game[:timezone])
        end
      end

      # If the week has been previously created and is being checked for updates to
      # the date/time
      if game = self.find_game(home_team.id)
        game.game_date = game_date_time
        game.network = nfl_game[:network]
        game.save
      else
        # Game doesn't exist so lets create it.
        game = Game.create(week_id: self.id, awayTeamIndex: away_team.id,
                           homeTeamIndex: home_team.id,
                           game_date: game_date_time,
                           network: nfl_game[:network])
        self.games << game
      end

      # Save changes to the week
      self.save

    end
  end

  #
  # Update the week with the nfl week final scores
  #
  def add_scores_nfl_week(season, nfl_games)

    #cycle through each game
    nfl_games.each do |nfl_game|

      # Get the Team records for this game
      home_team_name  = '%'+nfl_game[:home_team]+'%'
      home_team = Team.where('name LIKE ?', home_team_name).first
      away_team_name  = '%'+nfl_game[:away_team]+'%'
      away_team = Team.where('name LIKE ?', away_team_name).first


      # Check to make sure this NFL game is final
      if nfl_game[:final] == "FINAL"

        # sift through all of the games for the week
        self.games.each do |game|

          # Find the matching game
          if ((game.awayTeamIndex == away_team.id) &&
              (game.homeTeamIndex == home_team.id))

            # Update the scores
            game.awayTeamScore = nfl_game[:away_score]
            game.homeTeamScore = nfl_game[:home_score]
            game.final = true

            game.save

          end
        end #self.games.each
      end # if FINAL
    end # nfl_games.each

    self.save

  end

  #
  # Gets list of teams for the current week's games
  #
  def buildSelectTeams
    select_teams = Array.new
    self.games.each do |game|
      team = Team.find(game.awayTeamIndex)
      select_teams << team
      team = Team.find(game.homeTeamIndex)
      select_teams << team
    end
    return select_teams
  end

  #
  # Get list of winning teams for the current week's games
  #
  def getWinningTeams
    winning_teams = Array.new
    games = self.games
    games.each do |game|
      spread = game.awayTeamScore-game.homeTeamScore
      if spread != 0
        if (spread > 0)
          winning_teams << game.awayTeamIndex
        else
          winning_teams << game.homeTeamIndex
        end
      else
        # in case of a tie add both teams to winning teams
          winning_teams << game.awayTeamIndex
          winning_teams << game.homeTeamIndex
      end
    end
    return winning_teams
  end

  #
  # Validates all of the games checking for duplicate teams
  #
  def gamesValid?
    games_to_check = self.games
    ret_code = true
    games_to_check.each do |current_game|
      # Check to make sure the current_game team isn't the same for both teams
      if current_game.homeTeamIndex == current_game.awayTeamIndex
        errors[:base] << "Week #{self.week_number} has errors:"
        current_game.errors[:homeTeamIndex] << "Home and Away Team can't be the same!"
        ret_code = false
      end
      games = games_to_check = self.games
      games.each do |game|
        # check that the current_game teams are not repeated in the other games
        if current_game != game
          if current_game.homeTeamIndex == game.homeTeamIndex || current_game.homeTeamIndex == game.awayTeamIndex
            errors[:base] << "Week #{self.week_number} has errors:"
            current_game.errors[:homeTeamIndex] << "Team names can't be repeated!"
            ret_code = false
          end
          if current_game.awayTeamIndex == game.awayTeamIndex || current_game.awayTeamIndex == game.homeTeamIndex
            errors[:base] << "Week #{self.week_number} has errors:"
            current_game.errors[:awayTeamIndex] << "Team names can't be repeated!"
            ret_code = false
          end
        end
      end
    end
    return ret_code
  end

  # !!!! Should this be moved to season model ??
  def deleteSafe?(season)
    if  self.checkStatePend  && (season.weeks.order(:week_number).last == self)
      return true
    else
      return false
    end
  end


#  private

  # Parse the schedule for specified week from nfl.com. Returns
  # an array of game information(:date, :time, :away_team, :home_team, :network)
  # Scraper Data Points
  #
  # Group of games marker
  #   nfl-o-matchup-group (section)
  #   - Date
  #     d3-o-section-title (h2)
  #   - Game
  #     nfl-c-matchup-strip (div)
  #     -Team info
  #       nfl-c-matchup-strip__team-name (p)
  #       - Visiting team
  #         nfl-c-matchup-strip__team--opponent (div)
  #       - Home team
  #         nfl-c-matchup-strip__team (div)
  #         -Name
  #           nfl-c-matchup-strip__team-fullname (span)
  #     - Game info
  #       nfl-c-matchup-strip__game-info(div)
  #       -Time
  #         nfl-c-matchup-strip__date-time (span)
  #       -Network
  #         nfl-c-matchup-strip__networks (p)
  #
  def get_nfl_sched(weekNum, year)

    # Open the schedule home page
    if Rails.env.production?
      args = ['--no-sandbox', '--disable-dev-shm-usage', '--disable-gpu',
              '--remote-debugging-port=9222']
      browser = Watir::Browser.new :chrome, headless: true, options: {args: args}
    else
      browser = Watir::Browser.new :chrome, headless: true
    end
    url_path = "http://www.nfl.com/schedules/" + year + "/REG" + weekNum.to_s
    browser.goto(url_path)
    js_doc = browser.main(id: "main-content").wait_until(&:present?)
    doc = Nokogiri::HTML(js_doc.inner_html)

    # Get games information
    games = Array.new
    gameNum = 0

    # Get all games for each day and loop through them
    doc.css('section.nfl-o-matchup-group').each do |game_group|

      # Get the date for the games in this group
      game_date = game_group.css('h2.d3-o-section-title').text
      # Get details for each game on that day
      game_group.css('div.nfl-c-matchup-strip').each do |game_details|

        game_period = game_details.css('p.nfl-c-matchup-strip__period').text.strip

        # Get team names
        teams_marker = game_details.css('p.nfl-c-matchup-strip__team-name')
        teams = teams_marker.css('span.nfl-c-matchup-strip__team-fullname').text.strip.split(/\W+/)
        # Get away team
        away_team = teams[0]
        # Get home team
        home_team = teams[1]

        # The NFL has certain games on some weeks marked as TBD because of flex
        # scheduling for those weeks, and they won't be scheduled until later in the
        # season.
        if game_period.include? "TBD"
          game_time = nil
          game_timezone = nil
          game_network = nil
        else
          # Get Game time
          game_time = game_details.css('span.nfl-c-matchup-strip__date-time').text.strip
          game_timezone = game_details.css('span.nfl-c-matchup-strip__date-timezone').text.strip

          # Check if its final, and if it's not then get the network
          if !game_period.include? "FINAL"

            # Get game Network
            game_network = game_details.css('p.nfl-c-matchup-strip__networks').first.text.strip
          end
        end

        games[gameNum] = {:date => game_date, :time => game_time, :timezone => game_timezone,
                     :away_team => away_team, :home_team => home_team, :network => game_network }
        gameNum += 1

      end

    end

    # Close the browser session
    browser.close

    return games
  end

  # Get the final scores for an NFL week
  def get_nfl_scores(weekNum, year)

    # Open the schedule home page
    if Rails.env.production?
      args = ['--no-sandbox', '--disable-dev-shm-usage', '--disable-gpu',
              '--remote-debugging-port=9222']
      browser = Watir::Browser.new :chrome, headless: true, options: {args: args}
    else
      browser = Watir::Browser.new :chrome, headless: true
    end
    url_path = "http://www.nfl.com/schedules/" + year + "/REG" + weekNum.to_s
    browser.goto(url_path)
    js_doc = browser.main(id: "main-content").wait_until(&:present?)
    doc = Nokogiri::HTML(js_doc.inner_html)

    # Get games information
    games = Array.new
    gameNum = 0

    # Get games information
    games = Array.new

    gameNum = 0
    # get games
    doc.css('div.nfl-c-matchup-strip--post-game').each do |game|
      # Get Teams in games
      away_team = game.css('span.nfl-c-matchup-strip__team-fullname')[0].text.strip
      home_team = game.css('span.nfl-c-matchup-strip__team-fullname')[1].text.strip

      # Check if its final
      game_final = game.css('p.nfl-c-matchup-strip__period').text.strip
      if game_final.include? "FINAL"
        # Get add_scores
        game_final = "FINAL"
        away_score = game.css('div.nfl-c-matchup-strip__team-score')[0]['data-score']
        home_score = game.css('div.nfl-c-matchup-strip__team-score')[1]['data-score']
      else
        game_final = nil
        away_score = nil
        home_score = nil
      end

      games[gameNum] = {:away_team => away_team, :away_score => away_score,
                        :home_team => home_team, :home_score => home_score,
                        :final => game_final}

      gameNum += 1

    end

    # Close the browser session
    browser.close

    return games

  end
end
