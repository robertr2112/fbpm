# == Schema Information
#
# Table name: game_picks
#
#  id              :bigint           not null, primary key
#  chosenTeamIndex :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  game_pick_id    :integer
#  pick_id         :bigint
#
# Indexes
#
#  index_game_picks_on_pick_id  (pick_id)
#

class GamePick < ApplicationRecord

  belongs_to :pick
  
  validates :chosenTeamIndex, presence: true

end
