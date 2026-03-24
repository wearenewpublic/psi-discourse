// Composer connector: shows a checkbox to enable the comment slider when creating a new topic (staff only).
import Component from "@glimmer/component";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { i18n } from "discourse-i18n";

export default class PsiSliderToggle extends Component {
  @service currentUser;

  get isCreatingTopic() {
    return this.args.outletArgs?.model?.creatingTopic;
  }

  get canToggle() {
    return this.isCreatingTopic && this.currentUser?.staff;
  }

  get isEnabled() {
    return this.args.outletArgs?.model?.psiSliderEnabled;
  }

  @action
  toggle() {
    const model = this.args.outletArgs?.model;
    if (model) {
      model.set("psiSliderEnabled", !model.psiSliderEnabled);
    }
  }

  <template>
    {{#if this.canToggle}}
      <div class="psi-slider-toggle">
        <label class="psi-slider-toggle__label">
          <input
            type="checkbox"
            checked={{this.isEnabled}}
            {{on "change" this.toggle}}
          />
          <span>{{i18n "psi.composer.enable_slider"}}</span>
        </label>
      </div>
    {{/if}}
  </template>
}
