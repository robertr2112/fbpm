# == Schema Information
#
# Table name: pools
#
#  id              :bigint           not null, primary key
#  allowMulti      :boolean          default(FALSE)
#  isPublic        :boolean          default(TRUE)
#  name            :string
#  password_digest :string
#  poolType        :integer
#  pool_done       :boolean          default(FALSE)
#  starting_week   :integer          default(1)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  season_id       :bigint
#
# Indexes
#
#  index_pools_on_season_id  (season_id)
#

class Pool < ApplicationRecord
  POOL_TYPES = { PickEm: 0, PickEmSpread: 1, Survivor: 2, SUP: 3 }

  has_many   :pool_memberships, dependent: :destroy
  has_many   :users, through: :pool_memberships
  has_many   :entries, dependent: :delete_all
  belongs_to :season

  # Make sure protected fields aren't updated after a week has been created on the pool
  validate :checkUpdateFields, on: :update

  attr_accessor :password

  validates :name,
            presence:   true,
            length:     { maximum: 30 },
            uniqueness: { case_sensitive: false }
  validates :poolType, inclusion: { in: 0..3 }
  validates :allowMulti, inclusion: { in: [ true, false ] }
  validates :isPublic,   inclusion: { in: [ true, false ] }

  POOL_INVITE_MSG = "From Football Pool Mania: You're invited to join a survivor pool! \
  Click the attached link (login or create a new account) to join the pool! (If creating \
  a new account you will need to click the link again after authenticating your account to join)"

  #
  # Class helpers for pool types
  #
  def self.typeSUP?(type)
    type == POOL_TYPES[:SUP]
  end

  def self.typePickEm?(type)
    type == POOL_TYPES[:PickEm]
  end

  def self.typePickEmSpread?(type)
    type == POOL_TYPES[:PickEmSpread]
  end

  def self.typeSurvivor?(type)
    type == POOL_TYPES[:Survivor]
  end

  #
  # Instance helpers for pool types
  #
  def typeSUP?
    poolType == POOL_TYPES[:SUP]
  end

  def typePickEm?
    poolType == POOL_TYPES[:PickEm]
  end

  def typePickEmSpread?
    poolType == POOL_TYPES[:PickEmSpread]
  end

  def typeSurvivor?
    poolType == POOL_TYPES[:Survivor]
  end

  #
  # Build Pool invite email message
  #
  def buildPoolInviteMsg
    return Pool::POOL_INVITE_MSG if typeSurvivor?
    nil
  end

  #
  # Used to determine if the listed user is a member in the pool
  #
  def isMember?(user)
    pool_memberships.find_by_user_id(user.id)
  end

  #
  # Used to determine if the listed user is the owner of the pool.
  #
  def isOwner?(user)
    membership = pool_memberships.find_by_user_id(user.id)
    membership&.owner
  end

  def getOwner
    membership = pool_memberships.find_by_owner(true)
    User.find(membership.user_id)
  end

  #
  # This is used to determine if users can join/leave the pool.  Once the pool is no longer open then
  # users cannot join or leave the pool.
  #
  def isOpen?
    s = season
    return false unless s

    first_week = s.weeks.find_by_week_number(starting_week)
    if typeSurvivor?
      if first_week && (first_week.checkStateClosed || first_week.checkStateFinal)
        false
      else
        true
      end
    else
      true
    end
  end

  #
  # Used to set/remove ownership of the pool from the listed user
  #
  def setOwner(user, flag)
    membership = pool_memberships.find_by_user_id(user.id)
    if membership
      membership.owner = flag
      membership.save
    end
  end

  #
  #  Adds the listed user to the pool
  #
  def addUser(user)
    # Add user to the pool and save
    user.pools << self
    setOwner(user, false)
    user.save
    # Create an entry in the pool for this user
    entry_name = getEntryName(user)
    entries.create(name: entry_name, user_id: user.id)
  end

  #
  # Removes the listed user from the pool
  #
  def removeUser(user)
    removeEntries(user)
    membership = pool_memberships.find_by_user_id(user.id)
    membership&.destroy
  end

  #
  # Removes all memberships from the pool
  #
  def remove_memberships
    users.each do |user|
      membership = pool_memberships.find_by_user_id(user.id)
      membership&.destroy
    end
  end

  #
  # Used to get a default entry name for a user.  The default is <first name><Last name first Initial>
  # for the first entry and then adds _<entry number>
  #
  def getEntryName(user)
    user_entries  = entries.where(user_id: user.id)
    user_nickname = user.user_name
    if user_entries && user_entries.count > 0
      user_nickname = "#{user_nickname}_#{user_entries.count}"
    end
    user_nickname
  end

  #
  # This routine is used to update the survivor status and SUP total points for those pools
  # for each entry.  It is called after a week is marked final.
  def updateEntries(current_week)
    if typeSurvivor?
      unless pool_done
        # Update all entries survivorStatus
        updateSurvivor(current_week)
        # Check to see if their is a winner and mark pool done if there is a winner
        haveSurvivorWinner?
      end
    elsif typeSUP?
      updateSUP(current_week)
    elsif typePickEm?
      updatePickEm(current_week)
    elsif typePickEmSpread?
      updatePickEmSpread(current_week)
    end
  end

  #
  # Used to remove all entries for a user from the pool.  It is called when a user leaves
  # the pool
  def removeEntries(user)
    Entry.where(pool_id: id, user_id: user.id).each do |entry|
      entry.recurse_delete
    end
  end

  #
  # Determine if their are winners to the pool. If there are then return the entry.id's
  # of the winner(s). Returns FALSE if there are no winners yet.
  #
  def haveSurvivorWinner?
    getSurvivorWinner
  end

  def getSurvivorWinner
    s            = season
    current_week = getCurrentWeek
    entries_rel  = self.entries.where(survivorStatusIn: true)
    if pool_done
      return entries_rel
    elsif entries_rel.count == 0
      update_attribute(:pool_done, true)
      return determineSurvivorWinners
    elsif (current_week.week_number == s.number_of_weeks) &&
          current_week.checkStateFinal
      update_attribute(:pool_done, true)
      return entries_rel
    elsif entries_rel.count == 1 &&
          (current_week.week_number >= starting_week) &&
          current_week.checkStateFinal
      update_attribute(:pool_done, true)
      return entries_rel
    end

    false
  end

  #
  # Used to get the current week.  It calls season.getCurrentWeek.
  def getCurrentWeek
    season.getCurrentWeek
  end

  private

  def pool_valid?
    poolType != Pool::POOL_TYPES[:Survivor]
  end

  def checkUpdateFields
    unless isOpen?
      if (changed & [ "poolType", "allowMulti" ]).any?
        errors.add(:poolType, "You cannot change the Pool attributes after the first week has completed!")
      end
    end
  end

  #
  #  This finds winners if they all happened to get knocked out the same week.
  #
  def determineSurvivorWinners
    # Find all picks from season.week_number - 1 and self.id (not sure easiest way to do it.)
    s            = season
    current_week = s.getCurrentWeek
    if current_week.week_number == starting_week
      # If it's the first week then return all entries
      winners = entries.to_a
    else
      # If it's not the first week then determine everyone who picked correctly the previous
      # week and return those entries
      previous_week = s.weeks.find_by_week_number(current_week.week_number - 1)
      winners       = []

      winning_teams = previous_week.getWinningTeams
      entries.each do |entry|
        picks = entry.picks.where(week_number: previous_week.week_number)
        next if picks.empty?

        picks.each do |pick|
          pick.game_picks.each do |game_pick|
            if winning_teams.include?(game_pick.chosenTeamIndex)
              winners << entry
              break
            end
          end
        end
      end
    end
    # Now that we have determined the survivor winners let's mark the
    # SurvivorStatusIn back to true so getSurvivorWinner can return
    # the correct winners without calling this routine again.
    winners.each do |entry|
      entry.update_attribute(:survivorStatusIn, true)
    end

    winners
  end

  #
  # Updates the survivor status of each surviving entry in the pool
  #
  def updateSurvivor(current_week)
    knocked_out_entries = []
    winning_teams       = current_week.getWinningTeams
    self.entries.each do |entry|
      next unless entry.survivorStatusIn

      # Get picks for the current week
      picks = entry.picks.where(week_number: current_week.week_number)

      # If user forgot to pick → knocked out
      if picks.empty?
        knocked_out_entries << entry
        next
      end

      # Otherwise check if any pick matches a winning team
      found_team = false
      picks.each do |pick|
        pick.game_picks.each do |game_pick|
          if winning_teams.include?(game_pick.chosenTeamIndex)
            found_team = true
            break
          end
        end
        break if found_team
      end

      # Knock out if no winning pick found
      knocked_out_entries << entry unless found_team
    end
    # Apply knockouts
    knocked_out_entries.each do |entry|
      entry.update_attribute(:survivorStatusIn, false)
      entry.save
    end

    true
  end

  def updateSUP(current_week); end
  def updatePickEm(current_week); end
  def updatePickEmSpread(current_week); end
end
