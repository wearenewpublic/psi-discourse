// Displays vote results as a bar chart with percentages, user position marker,
// optional response excerpt, and an "Update your response" link.
import Component from "@glimmer/component";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { trustHTML } from "@ember/template";
import icon from "discourse/helpers/d-icon";
import { i18n } from "discourse-i18n";
import { POSITION_COUNT, SLIDER_POSITIONS } from "../lib/psi-constants";

export default class PsiVoteResults extends Component {
  get totalVotes() {
    return this.args.total || 0;
  }

  get bars() {
    const counts = this.args.counts || {};
    const total = this.totalVotes;
    const maxCount = Math.max(...Object.values(counts), 1);

    return Array.from({ length: POSITION_COUNT }, (_, i) => {
      const position = i + 1;
      const count = counts[position] || 0;
      const pct = total > 0 ? Math.round((count / total) * 100) : 0;
      const heightPct = maxCount > 0 ? Math.round((count / maxCount) * 100) : 0;
      return {
        position,
        count,
        pct,
        label: SLIDER_POSITIONS[position],
        barStyle: trustHTML(`height: ${heightPct}%`),
        barClass: `psi-vote-results__bar psi-vote-results__bar--${position}`,
      };
    });
  }

  get userMarkerStyle() {
    const pos = this.args.userVote?.position;
    if (!pos) {
      return null;
    }
    const pct = ((pos - 1) / (POSITION_COUNT - 1)) * 100;
    return trustHTML(`left: ${pct}%`);
  }

  get hasUserMarker() {
    return !!this.args.userVote?.position;
  }

  get responsesText() {
    const count = this.totalVotes;
    return i18n("psi.slider.responses", { count });
  }

  @action
  handleUpdateClick(event) {
    event.preventDefault();
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
            <div class={{bar.barClass}} style={{bar.barStyle}}></div>
          </div>
        {{/each}}
      </div>

      <div class="psi-vote-results__track">
        <div class="psi-vote-results__track-line">
          <div class="psi-vote-results__track-dots">
            {{#each this.bars}}
              <span class="psi-vote-results__track-dot"></span>
            {{/each}}
          </div>
        </div>

        {{#if this.hasUserMarker}}
          <div
            class="psi-vote-results__user-marker"
            style={{this.userMarkerStyle}}
          >
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
              Your response
            </span>
          </div>
          <div class="psi-vote-results__your-response-excerpt">
            {{@userResponse.excerpt}}
          </div>
        </div>
      {{/if}}

      <a
        href="#"
        class="psi-vote-results__update-link"
        {{on "click" this.handleUpdateClick}}
      >
        {{icon "pencil"}}
        Update your response
      </a>
    </div>
  </template>
}
