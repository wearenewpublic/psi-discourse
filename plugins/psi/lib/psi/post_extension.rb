# frozen_string_literal: true

# Extends Post with a has_one :psi_slider_vote association (nullified on post deletion).
module Psi
  module PostExtension
    extend ActiveSupport::Concern

    prepended do
      has_one :psi_slider_vote, foreign_key: :post_id, dependent: :nullify
    end
  end
end
