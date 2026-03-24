// Draggable 5-position discrete slider for selecting an opinion stance.
// Supports mouse and touch gestures, snaps to positions, and pulses when idle.
import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { htmlSafe } from "@ember/template";
import concatClass from "discourse/helpers/concat-class";
import { SLIDER_POSITIONS, POSITION_COUNT } from "../lib/psi-constants";

export default class PsiDiscreteSlider extends Component {
  @tracked isDragging = false;
  @tracked dragPct = null; // Raw percentage 0-100 during drag

  dots = [0, 1, 2, 3, 4];

  get selectedPosition() {
    return this.args.selectedPosition ?? null;
  }

  // During drag, show the nearest snap position for the label
  get activePosition() {
    if (this.dragPct !== null) {
      return this.pctToPosition(this.dragPct);
    }
    return this.selectedPosition;
  }

  get thumbPositionPct() {
    if (this.isDragging && this.dragPct !== null) {
      return this.dragPct; // Smooth — raw percentage
    }
    if (this.selectedPosition !== null) {
      return ((this.selectedPosition - 1) / (POSITION_COUNT - 1)) * 100;
    }
    return 50; // Default center
  }

  get thumbStyle() {
    return htmlSafe(`left: ${this.thumbPositionPct}%`);
  }

  get selectedLabel() {
    const pos = this.activePosition;
    return pos ? SLIDER_POSITIONS[pos] : null;
  }

  get hasSelection() {
    return this.selectedPosition !== null || this.dragPct !== null;
  }

  get showPulse() {
    return !this.hasSelection && !this.isDragging;
  }

  pctToPosition(pct) {
    const raw = (pct / 100) * (POSITION_COUNT - 1) + 1;
    return Math.max(1, Math.min(5, Math.round(raw)));
  }

  clientXToPct(clientX, trackEl) {
    const rect = trackEl.getBoundingClientRect();
    const x = clientX - rect.left;
    return Math.max(0, Math.min(100, (x / rect.width) * 100));
  }

  @action
  handleTrackClick(event) {
    const trackEl = event.currentTarget;
    const pct = this.clientXToPct(event.clientX, trackEl);
    const position = this.pctToPosition(pct);
    this.dragPct = null;
    this.args.onSelect?.(position);
  }

  @action
  handleThumbDown(event) {
    event.preventDefault();
    event.stopPropagation();
    this.isDragging = true;

    const trackEl = event.currentTarget.closest(
      ".psi-discrete-slider__track-container"
    );

    const onMove = (e) => {
      const clientX = e.clientX ?? e.touches?.[0]?.clientX;
      if (clientX == null || !trackEl) return;
      this.dragPct = this.clientXToPct(clientX, trackEl);
    };

    const onUp = () => {
      this.isDragging = false;
      if (this.dragPct !== null) {
        const position = this.pctToPosition(this.dragPct);
        this.dragPct = null;
        this.args.onSelect?.(position);
      }
      document.removeEventListener("mousemove", onMove);
      document.removeEventListener("mouseup", onUp);
      document.removeEventListener("touchmove", onMove);
      document.removeEventListener("touchend", onUp);
    };

    document.addEventListener("mousemove", onMove);
    document.addEventListener("mouseup", onUp);
    document.addEventListener("touchmove", onMove, { passive: true });
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
        aria-valuenow={{this.activePosition}}
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
            (if this.isDragging "psi-discrete-slider__thumb--dragging")
            (if this.showPulse "psi-discrete-slider__thumb--pulse")
          }}
          style={{this.thumbStyle}}
          {{on "mousedown" this.handleThumbDown}}
          {{on "touchstart" this.handleThumbDown}}
        >
          {{! Tooltip above thumb showing the snap position label }}
          {{#if this.selectedLabel}}
            <div class="psi-discrete-slider__tooltip">
              {{this.selectedLabel}}
            </div>
            <div class="psi-discrete-slider__you-badge-float">You</div>
          {{/if}}
        </div>
      </div>

      <div class="psi-discrete-slider__labels">
        <span>Strongly no</span>
        <span>It's complicated</span>
        <span>Strongly yes</span>
      </div>
    </div>
  </template>
}
