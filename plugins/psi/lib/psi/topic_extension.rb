# frozen_string_literal: true

# Extends Topic with has_many :psi_slider_votes and the psi_slider_enabled? helper.
module Psi
  module TopicExtension
    extend ActiveSupport::Concern

    prepended { has_many :psi_slider_votes, dependent: :destroy }

    def psi_slider_enabled?
      custom_fields["psi_slider_enabled"] == true || custom_fields["psi_slider_enabled"] == "true"
    end
  end
end
