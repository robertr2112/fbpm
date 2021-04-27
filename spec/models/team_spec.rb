# == Schema Information
#
# Table name: teams
#
#  id         :bigint           not null, primary key
#  imagePath  :string
#  name       :string
#  nfl        :boolean
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require 'rails_helper'

RSpec.describe Team, type: :model do

  before(:each) do
    @Team= Team.create(name: "Chicago Bears" , nfl: 1)
  end

  subject {@Team}

  it { should respond_to(:name) }
  it { should respond_to(:nfl) }
  it { should respond_to(:imagePath) }

  it { should be_valid }
end
