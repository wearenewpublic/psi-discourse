# frozen_string_literal: true

# Serializes a PsiSliderVote to JSON with position, post_id, and human-readable label.
class PsiSliderVoteSerializer < ApplicationSerializer
  attributes :position, :post_id, :position_label

  def position_label
    Psi::SLIDER_POSITIONS[object.position]
  end
end
