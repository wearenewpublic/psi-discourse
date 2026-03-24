# frozen_string_literal: true

# Request specs for the PSI slider API: vote creation, removal, retrieval, and error handling.
RSpec.describe "Psi Slider Endpoints" do
  fab!(:admin)
  fab!(:user)
  fab!(:topic) do
    topic = Fabricate(:topic, user: admin)
    topic.custom_fields["psi_slider_enabled"] = true
    topic.save_custom_fields
    topic
  end
  fab!(:non_slider_topic) { Fabricate(:topic) }

  describe "PUT /psi/vote" do
    it "requires login" do
      put "/psi/vote.json", params: { topic_id: topic.id, position: 3 }
      expect(response.status).to eq(403)
    end

    it "records a vote" do
      sign_in(user)
      put "/psi/vote.json", params: { topic_id: topic.id, position: 4 }

      expect(response.status).to eq(200)
      json = response.parsed_body
      expect(json["vote"]["position"]).to eq(4)
      expect(json["counts"]["4"]).to eq(1)
      expect(json["total"]).to eq(1)
    end

    it "updates an existing vote" do
      sign_in(user)
      put "/psi/vote.json", params: { topic_id: topic.id, position: 2 }
      put "/psi/vote.json", params: { topic_id: topic.id, position: 5 }

      expect(response.status).to eq(200)
      json = response.parsed_body
      expect(json["vote"]["position"]).to eq(5)
      expect(json["total"]).to eq(1)
    end

    it "rejects invalid position" do
      sign_in(user)
      put "/psi/vote.json", params: { topic_id: topic.id, position: 0 }
      expect(response.status).to eq(422)
    end

    it "rejects non-slider topics" do
      sign_in(user)
      put "/psi/vote.json", params: { topic_id: non_slider_topic.id, position: 3 }
      expect(response.status).to eq(404)
    end
  end

  describe "DELETE /psi/vote" do
    it "removes a vote-only vote" do
      sign_in(user)
      PsiSliderVote.create!(topic: topic, user: user, position: 3)

      delete "/psi/vote.json", params: { topic_id: topic.id }

      expect(response.status).to eq(200)
      expect(PsiSliderVote.where(topic_id: topic.id, user_id: user.id).count).to eq(0)
    end

    it "does not remove votes linked to posts" do
      sign_in(user)
      post = Fabricate(:post, topic: topic, user: user)
      PsiSliderVote.create!(topic: topic, user: user, position: 3, post: post)

      delete "/psi/vote.json", params: { topic_id: topic.id }

      expect(response.status).to eq(200)
      expect(PsiSliderVote.where(topic_id: topic.id, user_id: user.id).count).to eq(1)
    end
  end

  describe "GET /psi/votes/:topic_id" do
    fab!(:user_2, :user)

    it "returns vote distribution" do
      PsiSliderVote.create!(topic: topic, user: user, position: 1)
      PsiSliderVote.create!(topic: topic, user: user_2, position: 3)

      get "/psi/votes/#{topic.id}.json"

      expect(response.status).to eq(200)
      json = response.parsed_body
      expect(json["counts"]["1"]).to eq(1)
      expect(json["counts"]["3"]).to eq(1)
      expect(json["total"]).to eq(2)
    end

    it "includes user vote when logged in" do
      sign_in(user)
      PsiSliderVote.create!(topic: topic, user: user, position: 4)

      get "/psi/votes/#{topic.id}.json"

      expect(response.status).to eq(200)
      json = response.parsed_body
      expect(json["vote"]["position"]).to eq(4)
    end

    it "returns 404 for non-slider topics" do
      get "/psi/votes/#{non_slider_topic.id}.json"
      expect(response.status).to eq(404)
    end
  end
end
