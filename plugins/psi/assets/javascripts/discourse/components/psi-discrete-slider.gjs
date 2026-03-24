import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { htmlSafe } from "@ember/template";
import concatClass from "discourse/helpers/concat-class";
import { SLIDER_POSITIONS, POSITION_COUNT } from "../lib/psi-constants";

function range(n) {
  return Array.from({ length: n }, (_, i) => i);
}

export default class PsiDiscreteSlider extends Component {
  @tracked dragging = false;

  dots = range(5);

  get thumbPosition() {
    const pos = this.args.selectedPosition || 3;
    return ((pos - 1) / (POSITION_COUNT - 1)) * 100;
  }

  get thumbStyle() {
    return htmlSafe(`left: ${this.thumbPosition}%`);
  }

  get selectedLabel() {
    const pos = this.args.selectedPosition;
    return pos ? SLIDER_POSITIONS[pos] : null;
  }

  get hasSelection() {
    return !!this.args.selectedPosition;
  }

  @action
  handleTrackClick(event) {
    const track = event.currentTarget;
    const rect = track.getBoundingClientRect();
    const x = event.clientX - rect.left;
    const pct = Math.max(0, Math.min(1, x / rect.width));
    const position = Math.round(pct * (POSITION_COUNT - 1)) + 1;
    this.args.onSelect?.(position);
  }

  @action
  handleMouseDown(event) {
    event.preventDefault();
    this.dragging = true;
    const trackEl = event.currentTarget.parentElement;

    const onMove = (e) => {
      if (!this.dragging || !trackEl) return;
      const rect = trackEl.getBoundingClientRect();
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
            {{#each this.dots as |dot|}}
              <span class="psi-discrete-slider__dot"></span>
            {{/each}}
          </div>
        </div>

        <div
          class={{concatClass
            "psi-discrete-slider__thumb"
            (if this.hasSelection "psi-discrete-slider__thumb--selected")
          }}
          style={{this.thumbStyle}}
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
