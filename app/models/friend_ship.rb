# == Schema Information
#
# Table name: friend_ships
#
#  id         :integer          not null, primary key
#  owner_id   :integer
#  ownee_id   :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class FriendShip < ApplicationRecord
  belongs_to :owner, class_name: Student, foreign_key: :owner_id
  belongs_to :ownee, class_name: Student, foreign_key: :ownee_id
end
