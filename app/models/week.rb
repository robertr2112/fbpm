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

require "open-uri"
require "nokogiri"
require "pp"

class Week < ApplicationRecord
  STATES = { Pend: 0, Open: 1, Closed: 2, Final: 3 }

  before_create do
    self.state = Week::STATES[:Pend]
  end

  belongs_to :season
  has_many   :games, inverse_of: :week, dependent: :destroy

  accepts_nested_attributes_for :games, allow_destroy: true

  validates :state, inclusion: { in: 0..3 }
  validates :week_number, numericality: { only_integer: true, greater_than: 0,
                                          less_than_or_equal_to: 18 }
  validate :gamesValid?

  def setState(state)
    self.state = state
    save
  end

  def checkStatePend
    state == Week::STATES[:Pend]
  end

  def checkStateOpen
    state == Week::STATES[:Open]
  end

  def checkStateClosed
    state == Week::STATES[:Closed]
  end

  def checkStateFinal
    state == Week::STATES[:Final]
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
    games.each do |game|
      return game if game.homeTeamIndex == chosenTeamIndex ||
                     game.awayTeamIndex == chosenTeamIndex
    end
    nil
  end

  #
  # Get the bye teams for the week
  #
  def get_bye_teams
    bye_teams = []
    1.upto(32) do |i|
      bye_teams << i if find_game(i).nil?
    end
    bye_teams
  end

  #
  # Generate NFL schedule for a specified week
  #
  def create_nfl_week(season, nfl_games)
    nfl_games.each do |nfl_game|
      home_team_name  = "%#{nfl_game[:home_team]}%"
      home_team       = Team.where("name LIKE ?", home_team_name).first
      away_team_name  = "%#{nfl_game[:away_team]}%"
      away_team       = Team.where("name LIKE ?", away_team_name).first

      # If the date isn't set because of a flex week then create the nfl_date
      # string from the previous weeks games and add 7 days. And add 1 to the year
      # because the flex week is always (currently) in the next year.
      # ESPN sets the date to "Date/Time TBD - Flex Games"
      if nfl_game[:date] && nfl_game[:date].include?("TBD")
        # Create datetime object with year 1900 and 0600 CDT
        game_date_time = DateTime.new(1900, 10, 10, 5, 0, 0, "-06:00")
      else
        if nfl_game[:date]
          # Need to update the year when we hit January
          year = if nfl_game[:date].include?("January")
                   season.year.to_i + 1
          else
                   season.year.to_i
          end
        end
        #
        # Setup timezone
        #
        # ***HACK*** Using ESPN website doesn't give the timezone in the protocol.
        # Setting time zone based on week 9 (which is usually when the time changes)
        if week_number == 9
          if nfl_game[:date].include?("Thursday")
            nfl_game[:timezone] = "CDT"
          else
            nfl_game[:timezone] = "CST"
          end
        elsif week_number > 9
          nfl_game[:timezone] = "CST"
        else
          nfl_game[:timezone] = "CDT"
        end

        # Set game time to 0500 CST else build the datetime from the JSON nfl_game info
        if nfl_game[:time]
          if nfl_game[:time].include?("TBD")
            # Only do the date and add 05:00 AM to mark it as TBD
            game_date_time = DateTime.parse(
              nfl_game[:date] + " " + "05:00 am" + " " + "CST"
            )
          else
            # Do the date and time
            game_date_time = DateTime.parse(
              nfl_game[:date] + " " + nfl_game[:time] + " " + nfl_game[:timezone]
            )
          end
        end
      end

      # If the week has been previously created and is being checked for updates to
      # the date/time
      if (game = find_game(home_team.id))
        game.game_date = game_date_time
        game.network   = nfl_game[:network]
        game.save
      else
        # Game doesn't exist so lets create it.
        game = Game.create(
          week_id:       id,
          awayTeamIndex: away_team.id,
          homeTeamIndex: home_team.id,
          game_date:     game_date_time,
          network:       nfl_game[:network]
        )
        games << game
      end

      # Save changes to the week
      save
    end
  end

  #
  # Update the week with the nfl week final scores
  #
  def add_scores_nfl_week(season, nfl_games)
    # cycle through each game
    nfl_games.each do |nfl_game|
      # Get the Team records for this game
      home_team_name = "%#{nfl_game[:home_team]}%"
      home_team      = Team.where("name LIKE ?", home_team_name).first
      away_team_name = "%#{nfl_game[:away_team]}%"
      away_team      = Team.where("name LIKE ?", away_team_name).first


      # Check to make sure this NFL game is final
      if nfl_game[:final] == "FINAL"

        # sift through all of the games for the week
        games.each do |game|
          # Find the matching game
          if game.awayTeamIndex == away_team.id &&
             game.homeTeamIndex == home_team.id

            # Update the scores
            game.awayTeamScore = nfl_game[:away_score]
            game.homeTeamScore = nfl_game[:home_score]
            game.final         = true

            game.save

          end
        end # self.games.each
      end # if FINAL
    end # nfl_games.each

    save
  end

  #
  # Gets list of teams for the current week's games
  #
  def buildSelectTeams
    select_teams = []
    games.each do |game|
      team = Team.find(game.awayTeamIndex)
      select_teams << team
      team = Team.find(game.homeTeamIndex)
      select_teams << team
    end
    select_teams
  end

  #
  # Get list of winning teams for the current week's games
  #
  def getWinningTeams
    winning_teams = []
    games.each do |game|
      spread = game.awayTeamScore - game.homeTeamScore
      if spread != 0
        if spread > 0
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
    winning_teams
  end

  #
  # Validates all of the games checking for duplicate teams
  #
  def gamesValid?
    games_to_check = games
    ret_code       = true

    games_to_check.each do |current_game|
      # Check to make sure the current_game team isn't the same for both teams
      if current_game.homeTeamIndex == current_game.awayTeamIndex
        errors.add(:base, "Week #{week_number} has errors:")
        current_game.errors.add(:homeTeamIndex, "Home and Away Team can't be the same!")
        ret_code = false
      end

      games.each do |game|
        # check that the current_game teams are not repeated in the other games
        next if current_game == game

        if current_game.homeTeamIndex == game.homeTeamIndex ||
           current_game.homeTeamIndex == game.awayTeamIndex
          errors.add(:base, "Week #{week_number} has errors:")
          current_game.errors.add(:homeTeamIndex, "Team names can't be repeated!")
          ret_code = false
        end

        if current_game.awayTeamIndex == game.awayTeamIndex ||
           current_game.awayTeamIndex == game.homeTeamIndex
          errors.add(:base, "Week #{week_number} has errors:")
          current_game.errors.add(:awayTeamIndex, "Team names can't be repeated!")
          ret_code = false
        end
      end
    end
    ret_code
  end

  # !!!! Should this be moved to season model ??
  def deleteSafe?(season)
    checkStatePend && (season.weeks.order(:week_number).last == self)
  end
end
