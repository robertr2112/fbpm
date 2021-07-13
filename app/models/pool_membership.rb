# == Schema Information
#
# Table name: pool_memberships
#
#  id         :bigint           not null, primary key
#  owner      :boolean          default(FALSE), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  pool_id    :integer
#  user_id    :integer
#

class PoolMembership < ApplicationRecord

  belongs_to :user
  belongs_to :pool

end
