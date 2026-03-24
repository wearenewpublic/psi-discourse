# frozen_string_literal: true

# Stores a user's slider vote (position 1-5) on a topic, optionally linked to a post.
# One vote per user per topic; provides aggregation helpers for vote distribution.
class PsiSliderVote < ActiveRecord::Base
  belongs_to :topic
  belongs_to :user
  belongs_to :post, optional: true

  validates :position, inclusion: { in: 1..5 }
  validates :user_id, uniqueness: { scope: :topic_id }

  def self.counts_for_topic(topic_id)
    where(topic_id: topic_id)
      .group(:position)
      .count
      .then { |counts| (1..5).map { |pos| [pos, counts[pos] || 0] }.to_h }
  end

  def self.upsert_vote!(topic_id:, user_id:, position:, post_id: nil)
    vote = find_or_initialize_by(topic_id: topic_id, user_id: user_id)
    vote.position = position
    vote.post_id = post_id if post_id
    vote.save!
    vote
  end

  def position_label
    Psi::SLIDER_POSITIONS[position]
  end
end
