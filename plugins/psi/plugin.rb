# frozen_string_literal: true

# name: psi
# about: PSI civic engagement features — comment slider, theming, and editorial tools
# version: 0.1.0
# authors: PSI Team
# url: https://github.com/wearenewpublic/psi-discourse

register_asset "stylesheets/common/psi.scss"
register_asset "stylesheets/common/psi-slider.scss"
register_asset "stylesheets/common/psi-vote-results.scss"
register_asset "stylesheets/desktop/psi-desktop.scss", :desktop
register_asset "stylesheets/mobile/psi-mobile.scss", :mobile

register_svg_icon "sliders"
register_svg_icon "pencil"

enabled_site_setting :psi_enabled

module ::Psi
  PLUGIN_NAME = "psi"

  SLIDER_POSITIONS = {
    1 => "Strongly no",
    2 => "No with reservations",
    3 => "It's complicated",
    4 => "Yes with reservations",
    5 => "Strongly yes",
  }.freeze
end

require_relative "lib/psi/engine"

after_initialize do
  require_relative "app/models/psi_slider_vote"
  require_relative "app/controllers/psi/slider_controller"
  require_relative "app/serializers/psi_slider_vote_serializer"
  require_relative "lib/psi/topic_extension"
  require_relative "lib/psi/post_extension"
  require_relative "lib/psi/guardian_extension"

  Discourse::Application.routes.append { mount ::Psi::Engine, at: "/psi" }

  register_topic_custom_field_type("psi_slider_enabled", :boolean)
  topic_view_post_custom_fields_allowlister { ["psi_slider_position"] }

  reloadable_patch do
    Topic.prepend(Psi::TopicExtension)
    Post.prepend(Psi::PostExtension)
    Guardian.prepend(Psi::GuardianExtension)
  end

  # Allow psi_slider_enabled to be set when creating topics
  register_modifier(:topic_custom_fields_allowlist) do |allowlist|
    allowlist | ["psi_slider_enabled"]
  end

  # Serialize slider data onto topics
  add_to_serializer(:topic_view, :psi_slider_enabled) do
    object.topic.custom_fields["psi_slider_enabled"] == true ||
      object.topic.custom_fields["psi_slider_enabled"] == "true"
  end

  add_to_serializer(:topic_view, :psi_slider_vote_counts) do
    return nil unless object.topic.psi_slider_enabled?
    PsiSliderVote.counts_for_topic(object.topic.id)
  end

  add_to_serializer(:topic_view, :psi_slider_total_votes) do
    return 0 unless object.topic.psi_slider_enabled?
    PsiSliderVote.where(topic_id: object.topic.id).count
  end

  add_to_serializer(:topic_view, :psi_slider_user_vote) do
    return nil unless object.topic.psi_slider_enabled?
    return nil unless scope.user
    vote = PsiSliderVote.find_by(topic_id: object.topic.id, user_id: scope.user.id)
    vote ? { position: vote.position, post_id: vote.post_id } : nil
  end

  # Serialize slider position onto individual posts
  add_to_serializer(
    :post,
    :psi_slider_position,
    include_condition: -> { object.topic&.psi_slider_enabled? && !object.is_first_post? },
  ) do
    vote = PsiSliderVote.find_by(topic_id: object.topic_id, user_id: object.user_id)
    vote&.position
  end

  # Hook into post creation to record slider votes
  on(:post_created) do |post, opts, user|
    next unless post.topic&.psi_slider_enabled?
    next if post.is_first_post?
    next if post.reply_to_post_number.present? # Only top-level replies

    position = opts[:psi_slider_position].to_i
    next unless position.between?(1, 5)

    PsiSliderVote.upsert_vote!(
      topic_id: post.topic_id,
      user_id: user.id,
      position: position,
      post_id: post.id,
    )
  end

  # Validate one top-level reply per user on slider topics
  validate(:post, :validate_psi_one_reply) do
    next unless self.topic&.psi_slider_enabled?
    next if self.is_first_post?
    next if self.reply_to_post_number.present? # Nested replies are fine
    next if self.id.present? # Editing existing post is fine

    existing =
      Post
        .where(topic_id: self.topic_id, user_id: self.user_id)
        .where(reply_to_post_number: nil)
        .where.not(post_number: 1)
        .exists?

    if existing
      self.errors.add(:base, I18n.t("psi.errors.one_reply_per_user"))
      false
    else
      true
    end
  end

  # Allow psi_slider_position in post creation params
  register_modifier(:post_create_opts) do |opts, params|
    if params[:psi_slider_position].present?
      opts[:psi_slider_position] = params[:psi_slider_position]
    end
    opts
  end
end
