# frozen_string_literal: true

module Psi
  module GuardianExtension
    extend ActiveSupport::Concern

    def can_create_psi_topic?
      return true if is_staff?
      return false unless user

      user.in_any_groups?(SiteSetting.psi_topic_creation_allowed_groups_map)
    end
  end
end
