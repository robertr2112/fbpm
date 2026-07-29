# == Schema Information
#
# Table name: pools
#
#  id              :bigint           not null, primary key
#  allowMulti      :boolean          default(FALSE)
#  isPublic        :boolean          default(TRUE)
#  name            :string
#  password_digest :string
#  pool_done       :boolean          default(FALSE)
#  pool_type       :integer          default("survivor")
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
  enum :pool_type, {
    pick_em: 0,
    pick_em_spread: 1,
    survivor: 2
  }

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
  validates :allowMulti, inclusion: { in: [ true, false ] }
  validates :isPublic,   inclusion: { in: [ true, false ] }

  POOL_INVITE_MSG = "From Football Pool Mania: You're invited to join a survivor pool! \
  Click the attached link (login or create a new account) to join the pool! (If creating \
  a new account you will need to click the link again after authenticating your account to join)"

  # Helper for building the form
  def self.pool_type_options
    pool_types.keys.map { |k| [ k.humanize, k ] }
  end

  #
  # Build Pool invite email message
  #
  def buildPoolInviteMsg
    return Pool::POOL_INVITE_MSG if self.survivor?
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
    if survivor?
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
  def updateEntries(week)
    case pool_type.to_sym
    when :survivor

      unless pool_done
        # Check all entries that made a pick correctly (or forgot to make pick)
        survivors = evaluate_week_results(week)

        # Knock out all entries that didn't survive
        apply_survivor_status(week, survivors)

        # Check to see if the pool is finished. Either have a winner or end of
        # the season.
        finalize_pool_if_needed(week, survivors)
      end

    when :pick_em
    when :pick_em_spread
      raise "Pool type not implemented yet: #{pool_type}"
    else
      raise "Unknown pool type: #{pool_type}"
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
  # Determine if there is a winner(s) to the pool. If there are then return the entry.id's
  # of the winner(s). Returns false if there are no winners yet.
  #
  def getSurvivorWinner
    # Returns the winner(s) if the pool is done
    return false unless pool_done?
    entries.where(survivorStatusIn: true)
  end

  #
  # Used to get the current week.  It calls season.getCurrentWeek.
  def getCurrentWeek
    season.getCurrentWeek
  end

  private

  def checkUpdateFields
    unless isOpen?
      if (changed & [ "pool_type", "allowMulti" ]).any?
        errors.add(:pool_type, "You cannot change the Pool attributes after the first week has completed!")
      end
    end
  end

  #
  # Survivor State Machine
  #

  # --------------------------
  # Evaluate weekly results
  # --------------------------
  def evaluate_week_results(week)
    winning_teams = week.getWinningTeams

    entries.includes(picks: :game_picks).select do |entry|
      # Survivor rule: must have a pick for this week
      weekly_picks = entry.picks.where(week_number: week.week_number)
      next false if weekly_picks.empty?

      # Survives if ANY pick matches a winning team
      weekly_picks.any? do |pick|
        pick.game_picks.any? { |gp| winning_teams.include?(gp.chosenTeamIndex) }
      end
    end
  end

  # ---------------------
  # Apply survivor status
  # ---------------------
  def apply_survivor_status(week, survivors)
    survivor_ids = survivors.map(&:id)

    entries.find_each do |entry|
      entry.update_column(:survivorStatusIn, survivor_ids.include?(entry.id))
    end
  end

  # -----------------------
  # Finalize pool if needed
  # -----------------------
  def finalize_pool_if_needed(week, survivors)
    if survivors.empty?
      # Everyone knocked out → if week one return all entries otherwise previous week's survivors win
      winners =
      if week.week_number == 1
        # Everyone knocked out in the first week → all entries are winners
        apply_survivor_status(week, entries)
        entries.to_a
      else
        # Everyone knocked out later → last week's survivors win
        previous_week = week.season.weeks.find_by(week_number: week.week_number - 1)
        entries = previous_week ? evaluate_week_results(previous_week) : []
        apply_survivor_status(week, entries)
        entries.to_a
      end
      update_column(:pool_done, true)
      return winners
    end

    if season.final_week?(week) && week.checkStateFinal
      # Final week → survivors are winners
      update_column(:pool_done, true)
      return survivors
    end

    if survivors.count == 1
      # Final week → survivors are winners
      update_column(:pool_done, true)
      return survivors
    end

    # Not done yet
    nil
  end

  def updateSUP(current_week); end
  def updatePickEm(current_week); end
  def updatePickEmSpread(current_week); end
end
