# frozen_string_literal: true

# API controller for slider vote operations: cast, remove, and retrieve votes.
# Mounted at /psi via Psi::Engine.
module Psi
  class SliderController < ::ApplicationController
    requires_plugin Psi::PLUGIN_NAME

    before_action :ensure_logged_in, except: [:votes]

    def vote
      topic_id = params.require(:topic_id)
      position = params.require(:position).to_i

      topic = Topic.find(topic_id)
      guardian.ensure_can_see!(topic)

      unless topic.psi_slider_enabled?
        return render_json_error(I18n.t("psi.errors.not_slider_topic"), status: 404)
      end

      unless position.between?(1, 5)
        return render_json_error(I18n.t("psi.errors.invalid_position"), status: 422)
      end

      vote =
        PsiSliderVote.upsert_vote!(topic_id: topic.id, user_id: current_user.id, position: position)

      render json: {
               vote: {
                 position: vote.position,
                 post_id: vote.post_id,
               },
               counts: PsiSliderVote.counts_for_topic(topic.id),
               total: PsiSliderVote.where(topic_id: topic.id).count,
             }
    end

    def remove_vote
      topic_id = params.require(:topic_id)
      topic = Topic.find(topic_id)
      guardian.ensure_can_see!(topic)

      PsiSliderVote.where(topic_id: topic.id, user_id: current_user.id, post_id: nil).destroy_all

      render json: {
               counts: PsiSliderVote.counts_for_topic(topic.id),
               total: PsiSliderVote.where(topic_id: topic.id).count,
             }
    end

    def votes
      topic_id = params.require(:topic_id)
      topic = Topic.find(topic_id)
      guardian.ensure_can_see!(topic)

      unless topic.psi_slider_enabled?
        return render_json_error(I18n.t("psi.errors.not_slider_topic"), status: 404)
      end

      result = {
        counts: PsiSliderVote.counts_for_topic(topic.id),
        total: PsiSliderVote.where(topic_id: topic.id).count,
      }

      if current_user
        vote = PsiSliderVote.find_by(topic_id: topic.id, user_id: current_user.id)
        result[:vote] = vote ? { position: vote.position, post_id: vote.post_id } : nil
      end

      render json: result
    end
  end
end
