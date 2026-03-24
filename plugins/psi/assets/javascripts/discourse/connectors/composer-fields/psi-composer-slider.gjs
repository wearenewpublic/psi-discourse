// Composer connector: embeds the discrete slider inside the reply composer
// when the user is replying to a slider-enabled topic.
// Uses a local @tracked property for reactivity since the Ember classic model
// doesn't trigger Glimmer re-renders.
import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { service } from "@ember/service";
import PsiDiscreteSlider from "../../components/psi-discrete-slider";

export default class PsiComposerSlider extends Component {
  @service currentUser;

  @tracked localPosition = null;

  get model() {
    return this.args.outletArgs?.model;
  }

  get isReplyToSliderTopic() {
    const model = this.model;
    if (!model) return false;
    return (
      model.replyingToTopic &&
      !model.replyToPostNumber &&
      model.topic?.psi_slider_enabled
    );
  }

  get selectedPosition() {
    return this.localPosition;
  }

  @action
  onSelect(position) {
    this.localPosition = position;
    if (this.model) {
      this.model.set("psiSliderPosition", position);
    }
  }

  <template>
    {{#if this.isReplyToSliderTopic}}
      <div class="psi-composer-slider">
        <div class="psi-composer-slider__label">
          Your position:
        </div>
        <PsiDiscreteSlider
          @selectedPosition={{this.selectedPosition}}
          @onSelect={{this.onSelect}}
        />
      </div>
    {{/if}}
  </template>
}
