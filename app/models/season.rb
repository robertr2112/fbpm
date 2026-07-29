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
  before_create do
    self.year ||= Time.now.strftime("%Y")
    self.current_week ||= 1
    self.state ||= Season::STATES[:Pend]
  end

  STATES = { Pend: 0, Open: 1, Closed: 2 }

  has_many :pools, dependent: :delete_all
  has_many :weeks, dependent: :delete_all

  accepts_nested_attributes_for :weeks, allow_destroy: true

  validates :number_of_weeks, inclusion: { in: 1..18 }

  def self.getSeasonYear
    year  = Time.now.strftime("%Y").to_i
    month = Time.now.strftime("%m").to_i
    year -= 1 if (1..2).include?(month)
    year.to_s
  end

  def setState(new_state)
    update_attribute(:state, new_state)
  end

  def isPending?
    state == STATES[:Pend]
  end

  def isOpen?
    state == STATES[:Open]
  end

  def isClosed?
    state == STATES[:Closed]
  end

  def canBeClosed?
    return false if weeks.empty?
    return false if weeks.count != number_of_weeks

    weeks.order(:week_number).each do |week|
      return false unless week.checkStateFinal
    end

    true
  end

  #
  # Return the current_week record for this season
  #
  def getCurrentWeek
    weeks.find_by_week_number(current_week)
  end

  #
  # Determine if it's the last week of the season
  #
  def final_week?(week)
    week.week_number == number_of_weeks
  end

  #
  # Have every pool update their entries. This is called after a week is marked 'final'
  #
  def updatePools
    current = getCurrentWeek
    return unless current

    pools.each do |pool|
      if current.week_number >= pool.starting_week
        pool.updateEntries(current)
      end
    end

    if current_week < number_of_weeks
      update_attribute(:current_week, current_week + 1)
    end
  end
end
