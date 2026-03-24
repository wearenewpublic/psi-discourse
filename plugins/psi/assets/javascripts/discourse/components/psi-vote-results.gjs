import Component from "@glimmer/component";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { SLIDER_POSITIONS, POSITION_COUNT } from "../lib/psi-constants";
import { i18n } from "discourse-i18n";
import icon from "discourse/helpers/d-icon";

export default class PsiVoteResults extends Component {
  @service currentUser;

  get totalVotes() {
    return this.args.total || 0;
  }

  get bars() {
    const counts = this.args.counts || {};
    const total = this.totalVotes;

    return Array.from({ length: POSITION_COUNT }, (_, i) => {
      const position = i + 1;
      const count = counts[position] || 0;
      const pct = total > 0 ? Math.round((count / total) * 100) : 0;
      return { position, count, pct, label: SLIDER_POSITIONS[position] };
    });
  }

  get maxPct() {
    return Math.max(...this.bars.map((b) => b.pct), 1);
  }

  get userMarkerPosition() {
    const pos = this.args.userVote?.position;
    if (!pos) return null;
    return ((pos - 1) / (POSITION_COUNT - 1)) * 100;
  }

  get responsesText() {
    const count = this.totalVotes;
    return i18n("psi.slider.responses", { count });
  }

  get userPost() {
    return this.args.userVote?.post_id;
  }

  @action
  handleUpdateClick() {
    this.args.onUpdate?.();
  }

  <template>
    <div class="psi-vote-results">
      <div class="psi-vote-results__heading">
        {{this.responsesText}}
      </div>

      <div class="psi-vote-results__chart">
        {{#each this.bars as |bar|}}
          <div class="psi-vote-results__bar-group">
            <span class="psi-vote-results__bar-pct">{{bar.pct}}%</span>
            <div
              class="psi-vote-results__bar psi-vote-results__bar--{{bar.position}}"
              style="height: {{if this.maxPct (mult (div bar.pct this.maxPct) 100) 0}}%"
            ></div>
          </div>
        {{/each}}
      </div>

      <div class="psi-vote-results__track">
        <div class="psi-vote-results__track-line">
          <div class="psi-vote-results__track-dots">
            {{#each this.bars as |bar|}}
              <span class="psi-vote-results__track-dot"></span>
            {{/each}}
          </div>
        </div>

        {{#if this.userMarkerPosition}}
          <div
            class="psi-vote-results__user-marker"
            style="left: {{this.userMarkerPosition}}%"
          >
            {{#if this.currentUser.avatar_template}}
              <img
                src={{this.currentUser.avatar_template}}
                alt={{this.currentUser.username}}
              />
            {{/if}}
          </div>
        {{/if}}
      </div>

      <div class="psi-vote-results__labels">
        <span>Strongly no</span>
        <span>It's complicated</span>
        <span>Strongly yes</span>
      </div>

      {{#if @userResponse}}
        <div class="psi-vote-results__your-response">
          <div class="psi-vote-results__your-response-header">
            <span class="psi-vote-results__your-response-label">
              {{i18n "psi.badge.your_response"}}
            </span>
          </div>
          <div class="psi-vote-results__your-response-excerpt">
            {{@userResponse.excerpt}}
          </div>
          {{#if @userResponse.replyCount}}
            <div class="psi-vote-results__your-response-stats">
              {{@userResponse.replyCount}} replies · {{@userResponse.reactionCount}} reactions
            </div>
          {{/if}}
        </div>
      {{/if}}

      <a
        href
        class="psi-vote-results__update-link"
        {{on "click" this.handleUpdateClick}}
      >
        {{icon "pencil"}}
        {{i18n "psi.slider.update_your_response"}}
      </a>
    </div>
  </template>
}
