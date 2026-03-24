# frozen_string_literal: true

module Psi
  module TopicExtension
    extend ActiveSupport::Concern

    prepended do
      has_many :psi_slider_votes, dependent: :destroy
    end

    def psi_slider_enabled?
      custom_fields["psi_slider_enabled"] == true ||
        custom_fields["psi_slider_enabled"] == "true"
    end
  end
end
