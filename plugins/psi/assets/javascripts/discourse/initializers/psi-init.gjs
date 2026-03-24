// Plugin initializer: registers slider field serialization for post/topic creation
// and renders the stance badge inline after poster names.
import Component from "@glimmer/component";
import { withPluginApi } from "discourse/lib/plugin-api";
import { SLIDER_POSITIONS } from "../lib/psi-constants";

function initializePsi(api) {
  const siteSettings = api.container.lookup("service:site-settings");

  if (!siteSettings.psi_enabled) {
    return;
  }

  // Serialize slider position on post creation/update
  api.serializeOnCreate("psi_slider_position", "psiSliderPosition");
  api.serializeOnUpdate("psi_slider_position", "psiSliderPosition");

  // Send psi_slider_enabled as a topic_custom_field so the backend saves it
  api.modifyClass("model:post", {
    pluginId: "psi",
    createProperties() {
      const data = this._super(...arguments);
      if (this.psi_slider_enabled !== undefined) {
        data.topic_custom_fields = data.topic_custom_fields || {};
        data.topic_custom_fields.psi_slider_enabled = this.psi_slider_enabled;
      }
      return data;
    },
  });

  // Still serialize psi_slider_enabled onto the post object so createProperties can read it
  api.serializeOnCreate("psi_slider_enabled", "psiSliderEnabled");

  // Render stance badge after the poster name using the __after outlet
  api.renderInOutlet(
    "post-meta-data-poster-name__after",
    class PsiStanceBadge extends Component {
      get position() {
        return this.args.outletArgs?.post?.psi_slider_position;
      }

      get label() {
        return this.position ? SLIDER_POSITIONS[this.position] : null;
      }

      <template>
        {{#if this.label}}
          <div class="psi-stance-badge">{{this.label}}</div>
        {{/if}}
      </template>
    }
  );
}

export default {
  name: "psi-init",
  initialize() {
    withPluginApi(initializePsi);
  },
};
