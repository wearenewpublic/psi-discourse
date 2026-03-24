// Displays a small badge showing a user's slider stance label next to their post.
import Component from "@glimmer/component";
import { SLIDER_POSITIONS } from "../lib/psi-constants";

export default class PsiStanceBadge extends Component {
  get position() {
    return this.args.outletArgs?.post?.psi_slider_position;
  }

  get label() {
    return this.position ? SLIDER_POSITIONS[this.position] : null;
  }

  get isVisible() {
    return !!this.label;
  }

  <template>
    {{#if this.isVisible}}
      <span class="psi-stance-badge">{{this.label}}</span>
    {{/if}}
  </template>
}
