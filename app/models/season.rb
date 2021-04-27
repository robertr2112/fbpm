# == Schema Information
#
# Table name: seasons
#
#  id              :bigint           not null, primary key
#  current_week    :integer
#  nfl_league      :boolean
#  number_of_weeks :integer
#  state           :integer
#  year            :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
class Season < ApplicationRecord

  has_many :weeks, dependent: :delete_all

  accepts_nested_attributes_for :weeks, allow_destroy: true

  STATES = { Pend: 0, Open: 1, Closed: 2 }

  def self.getSeasonYear
    year = Time.now.strftime("%Y").to_i
    month = Time.now.strftime("%m").to_i
    return year.to_s
  end

  def getCurrentWeek
    self.weeks.find_by_week_number(self.current_week)
  end

end
