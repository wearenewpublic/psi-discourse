import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { SLIDER_POSITIONS, POSITION_COUNT } from "../lib/psi-constants";

export default class PsiDiscreteSlider extends Component {
  @tracked dragging = false;
  @tracked hoverPosition = null;

  get thumbPosition() {
    const pos = this.args.selectedPosition || 3;
    return ((pos - 1) / (POSITION_COUNT - 1)) * 100;
  }

  get selectedLabel() {
    const pos = this.args.selectedPosition;
    return pos ? SLIDER_POSITIONS[pos] : null;
  }

  get hasSelection() {
    return !!this.args.selectedPosition;
  }

  positionFromEvent(event) {
    const track = event.currentTarget.closest(".psi-discrete-slider__track-container") ||
      event.currentTarget;
    const rect = track.getBoundingClientRect();
    const x = (event.clientX || event.touches?.[0]?.clientX) - rect.left;
    const pct = Math.max(0, Math.min(1, x / rect.width));
    return Math.round(pct * (POSITION_COUNT - 1)) + 1;
  }

  @action
  handleTrackClick(event) {
    const position = this.positionFromEvent(event);
    this.args.onSelect?.(position);
  }

  @action
  handleMouseDown(event) {
    event.preventDefault();
    this.dragging = true;

    const onMove = (e) => {
      if (!this.dragging) return;
      const track = event.currentTarget.closest(".psi-discrete-slider__track-container");
      if (!track) return;
      const rect = track.getBoundingClientRect();
      const clientX = e.clientX || e.touches?.[0]?.clientX;
      const x = clientX - rect.left;
      const pct = Math.max(0, Math.min(1, x / rect.width));
      const pos = Math.round(pct * (POSITION_COUNT - 1)) + 1;
      this.args.onSelect?.(pos);
    };

    const onUp = () => {
      this.dragging = false;
      document.removeEventListener("mousemove", onMove);
      document.removeEventListener("mouseup", onUp);
      document.removeEventListener("touchmove", onMove);
      document.removeEventListener("touchend", onUp);
    };

    document.addEventListener("mousemove", onMove);
    document.addEventListener("mouseup", onUp);
    document.addEventListener("touchmove", onMove);
    document.addEventListener("touchend", onUp);
  }

  <template>
    <div class="psi-discrete-slider">
      <div class="psi-discrete-slider__label">Slide to respond:</div>

      <div
        class="psi-discrete-slider__track-container"
        role="slider"
        aria-valuemin="1"
        aria-valuemax="5"
        aria-valuenow={{@selectedPosition}}
        aria-label="Opinion slider"
        {{on "click" this.handleTrackClick}}
      >
        <div class="psi-discrete-slider__track">
          <div class="psi-discrete-slider__dots">
            {{#each (Array.from {length: 5})}}
              <span class="psi-discrete-slider__dot"></span>
            {{/each}}
          </div>
        </div>

        <div
          class="psi-discrete-slider__thumb
            {{if this.hasSelection 'psi-discrete-slider__thumb--selected'}}"
          style="left: {{this.thumbPosition}}%"
          {{on "mousedown" this.handleMouseDown}}
          {{on "touchstart" this.handleMouseDown}}
        >
          {{#if @avatarUrl}}
            <img src={{@avatarUrl}} alt="Your avatar" />
          {{/if}}
        </div>
      </div>

      <div class="psi-discrete-slider__labels">
        <span>Strongly no</span>
        <span>It's complicated</span>
        <span>Strongly yes</span>
      </div>

      {{#if this.selectedLabel}}
        <div class="psi-discrete-slider__selected-label">
          {{this.selectedLabel}}
        </div>
        <div style="text-align: center;">
          <span class="psi-discrete-slider__you-badge">You</span>
        </div>
      {{/if}}
    </div>
  </template>
}
