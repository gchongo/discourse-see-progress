import Component from "@glimmer/component";
import { concat } from "@ember/helper";
import { service } from "@ember/service";
import { trustHTML } from "@ember/template";
import dIcon from "discourse/ui-kit/helpers/d-icon";
import { i18n } from "discourse-i18n";
import { requirementsQualify } from "../lib/calculate-stats";
import ProgressBar from "./progress-bar";

export default class RequirementsProgressModal extends Component {
  @service siteSettings;

  get doesQualify() {
    return requirementsQualify(this.args.requirements);
  }

  <template>
    <div class="all-progress-gauges">
      {{#each @requirements as |requirement|}}
        <ProgressBar
          @value={{requirement.value}}
          @total={{requirement.total}}
          @title={{concat "see_tl3_progress." requirement.key}}
          @type={{requirement.type}}
          @id={{requirement.key}}
        />
      {{/each}}
    </div>

    <hr />

    <p class="inline-wrapper tl3-promotion-decision">
      {{#if this.doesQualify}}
        {{! Core blocks promotion whenever a trust level is manually locked }}
        {{#if @is_locked}}
          {{dIcon "lock"}}
          {{i18n "see_tl3_progress.locked_will_not_be_promoted"}}
        {{else}}
          {{dIcon "check"}}
          {{i18n
            "see_tl3_progress.qualifies_for_level"
            target_level=@targetTrustLevel
          }}
          {{i18n "see_tl3_progress.will_be_promoted"}}
        {{/if}}
      {{else}}
        {{dIcon "xmark"}}
        {{i18n
          "see_tl3_progress.does_not_qualify_for_level"
          target_level=@targetTrustLevel
        }}
      {{/if}}
    </p>

    {{#if this.siteSettings.modal_bottom_text}}
      <hr />
      <p>{{trustHTML this.siteSettings.modal_bottom_text}}</p>
    {{/if}}
  </template>
}
