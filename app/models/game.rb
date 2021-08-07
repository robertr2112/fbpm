# == Schema Information
#
# Table name: games
#
#  id            :bigint           not null, primary key
#  awayTeamIndex :integer
#  awayTeamScore :integer          default(0)
#  game_date     :datetime
#  homeTeamIndex :integer
#  homeTeamScore :integer          default(0)
#  network       :string
#  spread        :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  week_id       :integer
#
class Game < ApplicationRecord

  before_create do
    self.homeTeamScore = 0
    self.awayTeamScore = 0
    self.spread = 0
  end

  belongs_to :week

  validates :homeTeamIndex, inclusion: { :in => 0..100 }
  validates :awayTeamIndex, inclusion: { :in => 0..100 }

  # determine if <teamIndex> was the winner of the game
  def wonGame?(teamIndex)

    score_spread = self.awayTeamScore - self.homeTeamScore
    if score_spread != 0
      if score_spread < 0
        winTeamIndex = self.homeTeamIndex
      else
        winTeamIndex = self.awayTeamIndex
      end
      teamIndex == winTeamIndex
    else
      # The case of a tie return true because both teams won
      if teamIndex == self.homeTeamIndex || teamIndex == self.awayTeamIndex
        return true
      else
        return false
      end
    end
  end

  # Determine if the game has already started
  def game_started?
    cur_time = Time.zone.now
    if cur_time.dst?
      game_date = self.game_date
    else
      game_date = self.game_date + 1.hour
    end

    if cur_time > game_date
      return true
    end

    return false
  end
end
