# frozen_string_literal: true

class PsiSliderVoteSerializer < ApplicationSerializer
  attributes :position, :post_id, :position_label

  def position_label
    Psi::SLIDER_POSITIONS[object.position]
  end
end
