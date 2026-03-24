import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { service } from "@ember/service";
import PsiDiscreteSlider from "../../components/psi-discrete-slider";
import { i18n } from "discourse-i18n";

export default class PsiComposerSlider extends Component {
  @service currentUser;

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
    return this.model?.psiSliderPosition;
  }

  get avatarUrl() {
    if (!this.currentUser?.avatar_template) return null;
    return this.currentUser.avatar_template.replace("{size}", "48");
  }

  @action
  onSelect(position) {
    if (this.model) {
      this.model.set("psiSliderPosition", position);
    }
  }

  <template>
    {{#if this.isReplyToSliderTopic}}
      <div class="psi-composer-slider">
        <div class="psi-composer-slider__label">
          {{i18n "psi.composer.slider_label"}}
        </div>
        <PsiDiscreteSlider
          @selectedPosition={{this.selectedPosition}}
          @onSelect={{this.onSelect}}
          @avatarUrl={{this.avatarUrl}}
        />
      </div>
    {{/if}}
  </template>
}
