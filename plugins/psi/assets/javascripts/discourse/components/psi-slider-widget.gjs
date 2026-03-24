// Main slider widget shown above topic posts. Orchestrates the voting flow:
// displays the slider for new votes, submits via AJAX, then shows vote results.
import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import PsiDiscreteSlider from "./psi-discrete-slider";
import PsiVoteResults from "./psi-vote-results";
import { i18n } from "discourse-i18n";

export default class PsiSliderWidget extends Component {
  @service currentUser;
  @service composer;
  @service router;
  @tracked selectedPosition = null;
  @tracked hasVoted = false;
  @tracked voteCounts = {};
  @tracked totalVotes = 0;
  @tracked userVote = null;
  @tracked submitting = false;

  constructor() {
    super(...arguments);
    this.loadVoteData();
  }

  get topic() {
    return this.args.outletArgs?.model;
  }

  get sliderEnabled() {
    return this.topic?.psi_slider_enabled;
  }

  get avatarUrl() {
    if (!this.currentUser?.avatar_template) return null;
    return this.currentUser.avatar_template.replace("{size}", "48");
  }

  get userResponse() {
    if (!this.userVote?.post_id) return null;
    const post = this.topic?.postStream?.posts?.find(
      (p) => p.id === this.userVote.post_id
    );
    if (!post) return null;
    return {
      excerpt: post.cooked?.replace(/<[^>]*>/g, "").slice(0, 200),
      replyCount: post.reply_count || 0,
      reactionCount: post.like_count || 0,
    };
  }

  loadVoteData() {
    if (!this.sliderEnabled || !this.topic) return;

    // Load from serialized topic data
    const topic = this.topic;
    this.voteCounts = topic.psi_slider_vote_counts || {};
    this.totalVotes = topic.psi_slider_total_votes || 0;
    this.userVote = topic.psi_slider_user_vote || null;

    if (this.userVote) {
      this.hasVoted = true;
      this.selectedPosition = this.userVote.position;
    }
  }

  @action
  onSliderSelect(position) {
    this.selectedPosition = position;
  }

  requireLogin() {
    if (!this.currentUser) {
      this.router.transitionTo("login");
      return true;
    }
    return false;
  }

  @action
  async submitVoteOnly() {
    if (this.requireLogin()) return;
    if (!this.selectedPosition || this.submitting) return;
    this.submitting = true;

    try {
      const result = await ajax("/psi/vote", {
        type: "PUT",
        data: {
          topic_id: this.topic.id,
          position: this.selectedPosition,
        },
      });

      this.voteCounts = result.counts;
      this.totalVotes = result.total;
      this.userVote = result.vote;
      this.hasVoted = true;
    } catch (e) {
      popupAjaxError(e);
    } finally {
      this.submitting = false;
    }
  }

  @action
  openComposer() {
    if (this.requireLogin()) return;
    if (!this.selectedPosition) return;

    this.composer.open({
      action: "reply",
      topic: this.topic,
      draftKey: this.topic.draft_key,
      psiSliderPosition: this.selectedPosition,
    });
  }

  @action
  handleUpdate() {
    if (this.userVote?.post_id) {
      // Navigate to the user's post for editing
      const postNumber = this.topic?.postStream?.posts?.find(
        (p) => p.id === this.userVote.post_id
      )?.post_number;

      if (postNumber) {
        this.router.transitionTo("topic.fromParamsNear", this.topic.slug, this.topic.id, postNumber);
      }
    } else {
      // Reset to slider mode to update vote-only
      this.hasVoted = false;
    }
  }

  <template>
    {{#if this.sliderEnabled}}
      <div class="psi-slider-widget">
        {{#if this.hasVoted}}
          <PsiVoteResults
            @counts={{this.voteCounts}}
            @total={{this.totalVotes}}
            @userVote={{this.userVote}}
            @userResponse={{this.userResponse}}
            @onUpdate={{this.handleUpdate}}
          />
        {{else}}
          <PsiDiscreteSlider
            @selectedPosition={{this.selectedPosition}}
            @onSelect={{this.onSliderSelect}}
          />

          {{#if this.selectedPosition}}
            <div class="psi-discrete-slider__actions">
              <button
                class="psi-discrete-slider__share-thoughts"
                type="button"
                {{on "click" this.openComposer}}
              >
                <span>{{i18n "psi.slider.share_your_thoughts"}}</span>
                <span>✏️</span>
              </button>

              <button
                class="psi-discrete-slider__skip-vote"
                type="button"
                disabled={{this.submitting}}
                {{on "click" this.submitVoteOnly}}
              >
                {{i18n "psi.slider.skip_and_submit_vote"}}
              </button>
            </div>
          {{/if}}
        {{/if}}
      </div>
    {{/if}}
  </template>
}
