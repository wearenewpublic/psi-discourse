# frozen_string_literal: true

RSpec.describe PsiSliderVote do
  fab!(:user)
  fab!(:topic)

  describe "validations" do
    it "validates position is between 1 and 5" do
      vote = PsiSliderVote.new(topic: topic, user: user, position: 0)
      expect(vote).not_to be_valid

      vote.position = 6
      expect(vote).not_to be_valid

      vote.position = 3
      expect(vote).to be_valid
    end

    it "validates uniqueness of user per topic" do
      PsiSliderVote.create!(topic: topic, user: user, position: 3)
      duplicate = PsiSliderVote.new(topic: topic, user: user, position: 4)
      expect(duplicate).not_to be_valid
    end
  end

  describe ".counts_for_topic" do
    fab!(:user_2, :user)
    fab!(:user_3, :user)

    it "returns counts for all 5 positions" do
      PsiSliderVote.create!(topic: topic, user: user, position: 1)
      PsiSliderVote.create!(topic: topic, user: user_2, position: 3)
      PsiSliderVote.create!(topic: topic, user: user_3, position: 3)

      counts = PsiSliderVote.counts_for_topic(topic.id)

      expect(counts).to eq({ 1 => 1, 2 => 0, 3 => 2, 4 => 0, 5 => 0 })
    end

    it "returns all zeros when no votes" do
      counts = PsiSliderVote.counts_for_topic(topic.id)
      expect(counts).to eq({ 1 => 0, 2 => 0, 3 => 0, 4 => 0, 5 => 0 })
    end
  end

  describe ".upsert_vote!" do
    it "creates a new vote" do
      vote = PsiSliderVote.upsert_vote!(topic_id: topic.id, user_id: user.id, position: 4)
      expect(vote.position).to eq(4)
      expect(vote).to be_persisted
    end

    it "updates an existing vote" do
      PsiSliderVote.upsert_vote!(topic_id: topic.id, user_id: user.id, position: 2)
      vote = PsiSliderVote.upsert_vote!(topic_id: topic.id, user_id: user.id, position: 5)

      expect(vote.position).to eq(5)
      expect(PsiSliderVote.where(topic_id: topic.id, user_id: user.id).count).to eq(1)
    end

    it "links to a post when provided" do
      post = Fabricate(:post, topic: topic, user: user)
      vote = PsiSliderVote.upsert_vote!(
        topic_id: topic.id,
        user_id: user.id,
        position: 3,
        post_id: post.id,
      )

      expect(vote.post_id).to eq(post.id)
    end
  end

  describe "#position_label" do
    it "returns the correct label" do
      vote = PsiSliderVote.new(position: 1)
      expect(vote.position_label).to eq("Strongly no")

      vote.position = 5
      expect(vote.position_label).to eq("Strongly yes")
    end
  end
end
