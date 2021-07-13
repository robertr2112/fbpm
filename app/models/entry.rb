# == Schema Information
#
# Table name: entries
#
#  id               :bigint           not null, primary key
#  name             :string
#  supTotalPoints   :integer          default(0)
#  survivorStatusIn :boolean          default(TRUE)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  pool_id          :integer
#  user_id          :integer
#
# Indexes
#
#  index_entries_on_pool_id  (pool_id)
#  index_entries_on_user_id  (user_id)
#

class Entry < ApplicationRecord
  belongs_to :pool
  belongs_to :user
  has_many   :picks, dependent: :delete_all

  def entryStatusGood?
    if self.survivorStatusIn
      return true
    else
      return false
    end
  end

  def madePicks?(week)
    picks = self.picks.where(week_id: week.id)
    picks.each do |pick|
      if (pick.entry_id == self.id && pick.week_number == week.week_number)
        return true
      end
    end
    return false
  end

end
