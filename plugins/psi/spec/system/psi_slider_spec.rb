# frozen_string_literal: true

# System tests for the PSI slider: visibility, voting flow, bar chart, one-reply enforcement, and stance badges.
RSpec.describe "PSI Comment Slider", type: :system do
  fab!(:admin)
  fab!(:user)
  fab!(:user_2, :user)
  fab!(:user_3, :user)
  fab!(:category)
  fab!(:topic) do
    topic = Fabricate(:topic, category: category, user: admin)
    topic.custom_fields["psi_slider_enabled"] = true
    topic.save_custom_fields
    Fabricate(:post, topic: topic, user: admin, raw: "Is Europe prepared for an aging population?")
    topic
  end
  fab!(:non_slider_topic) { Fabricate(:topic, category: category) }

  let(:psi_topic_page) { PageObjects::Pages::PsiTopic.new }

  before { SiteSetting.psi_enabled = true }

  describe "slider visibility" do
    it "shows slider on slider-enabled topics" do
      sign_in(user)
      psi_topic_page.visit_topic(topic)

      expect(psi_topic_page).to have_slider_widget
      expect(psi_topic_page).to have_discrete_slider
    end

    it "does not show slider on non-slider topics" do
      sign_in(user)
      psi_topic_page.visit_topic(non_slider_topic)

      expect(psi_topic_page).to have_no_slider_widget
    end
  end

  describe "voting flow" do
    it "allows selecting a position and shows the label" do
      sign_in(user)
      psi_topic_page.visit_topic(topic)
      psi_topic_page.click_slider_position(4)

      expect(psi_topic_page).to have_selected_label("Yes with reservations")
    end

    it "shows bar chart after submitting a vote-only" do
      sign_in(user)
      psi_topic_page.visit_topic(topic)
      psi_topic_page.click_slider_position(5)
      psi_topic_page.click_skip_and_submit_vote

      expect(psi_topic_page).to have_vote_results
      expect(psi_topic_page).to have_bar_chart
      expect(psi_topic_page).to have_responses_heading("1 response")
    end
  end

  describe "vote distribution" do
    before do
      PsiSliderVote.create!(topic: topic, user: user, position: 1)
      PsiSliderVote.create!(topic: topic, user: user_2, position: 3)
      PsiSliderVote.create!(topic: topic, user: user_3, position: 3)
    end

    it "shows correct percentages in bar chart" do
      sign_in(user)
      psi_topic_page.visit_topic(topic)

      expect(psi_topic_page).to have_vote_results
      expect(psi_topic_page.bar_percentage(1)).to eq("33%")
      expect(psi_topic_page.bar_percentage(3)).to eq("67%")
    end
  end

  describe "one reply per user" do
    it "prevents a second top-level reply" do
      sign_in(user)

      # Create first top-level reply
      Fabricate(:post, topic: topic, user: user, raw: "My first response")
      PsiSliderVote.create!(topic: topic, user: user, position: 4, post: topic.posts.last)

      # Trying to create a second top-level reply should fail
      post =
        PostCreator.new(
          user,
          topic_id: topic.id,
          raw: "My second response attempt",
        ).create

      expect(post.errors[:base]).to include(
        I18n.t("psi.errors.one_reply_per_user"),
      )
    end

    it "allows nested replies" do
      sign_in(user)
      first_reply = Fabricate(:post, topic: topic, user: user, raw: "My response")

      # Nested reply to someone else should work
      nested_post =
        PostCreator.new(
          user,
          topic_id: topic.id,
          raw: "I agree with your point!",
          reply_to_post_number: first_reply.post_number,
        ).create

      expect(nested_post.errors).to be_empty
      expect(nested_post).to be_persisted
    end
  end

  describe "stance badges" do
    before do
      reply = Fabricate(:post, topic: topic, user: user, raw: "My thoughts on this")
      PsiSliderVote.create!(topic: topic, user: user, position: 5, post: reply)
    end

    it "shows stance badge on posts with a vote" do
      sign_in(user_2)
      psi_topic_page.visit_topic(topic)

      expect(psi_topic_page).to have_stance_badge("Strongly yes")
    end
  end
end
