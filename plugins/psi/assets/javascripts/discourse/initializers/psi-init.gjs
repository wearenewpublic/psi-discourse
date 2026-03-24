import Component from "@glimmer/component";
import { withPluginApi } from "discourse/lib/plugin-api";
import { SLIDER_POSITIONS } from "../lib/psi-constants";

function initializePsi(api) {
  const siteSettings = api.container.lookup("service:site-settings");

  if (!siteSettings.psi_enabled) {
    return;
  }

  // Serialize slider fields on post/topic creation
  api.serializeOnCreate("psi_slider_position", "psiSliderPosition");
  api.serializeOnUpdate("psi_slider_position", "psiSliderPosition");
  api.serializeOnCreate("psi_slider_enabled", "psiSliderEnabled");

  // Render stance badge after poster name on posts
  api.renderInOutlet(
    "post-meta-data-poster-name",
    class PsiStanceBadgeOutlet extends Component {
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

  // Add body class when PSI is enabled
  api.registerValueTransformer("topic-list-class", ({ value }) => {
    value.push("psi-enabled");
    return value;
  });
}

export default {
  name: "psi-init",
  initialize() {
    withPluginApi(initializePsi);
  },
};
