import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { concat } from "@ember/helper";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { trustHTML } from "@ember/template";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import { and, eq, gte, lt, or } from "discourse/truth-helpers";
import DButton from "discourse/ui-kit/d-button";
import DConditionalLoadingSpinner from "discourse/ui-kit/d-conditional-loading-spinner";
import DModal from "discourse/ui-kit/d-modal";
import dIcon from "discourse/ui-kit/helpers/d-icon";
import { i18n } from "discourse-i18n";
import Tl3ProgressModal from "../../components/tl3-progress-modal";
import {
  diffLess,
  diffMore,
  doesQualify,
  percentageDone,
  stepsDone,
} from "../../lib/calculate-stats";

export default class Tl3ProgressButton extends Component {
  static shouldRender(args, helper) {
    const user = args.user;

    if (!helper.currentUser) {
      return false;
    }
    if (user.trust_level !== 2 && user.trust_level !== 3) {
      return false;
    }
    return (
      helper.currentUser.staff ||
      user.isCurrent ||
      ((helper.siteSettings.show_warning_when_tl3_requirements_low
        ? user.trust_level === 3
        : user.trust_level === 2) &&
        !user.staff)
    );
  }

  @service siteSettings;
  @service session;

  @tracked modalShowing = false;
  @tracked stats;
  @tracked lockedStatus;
  @tracked stats_loading = true;
  @tracked is_locked_loading = true;

  constructor() {
    super(...arguments);
    this.getUserStats();
    this.getIsLocked();
  }

  async getUserStats() {
    try {
      const data = await ajax(
        `/u/${this.args.user.username}/tl3-progress.json`
      );
      this.stats = data.stats_progress;
      this.stats_loading = false;
    } catch (e) {
      popupAjaxError(e);
    }
  }

  async getIsLocked() {
    if (!this.siteSettings.show_locked_at_trust_level) {
      this.lockedStatus = {
        is_locked: false,
        locked_at_trust_level: null,
      };
      this.is_locked_loading = false;
      return;
    }
    try {
      const data = await ajax(`/u/${this.args.user.username}/is-locked.json`);
      this.lockedStatus = data;
      this.is_locked_loading = false;
    } catch (e) {
      popupAjaxError(e);
    }
  }

  get percentageDone() {
    return percentageDone(this.stats);
  }

  get doesQualify() {
    return doesQualify(this.stats);
  }

  get stepsDone() {
    return stepsDone(this.stats);
  }

  get progressDoneText() {
    return i18n("see_tl3_progress.progress_done", {
      steps_completed: this.stepsDone,
      percentage_done: this.percentageDone,
    });
  }

  get showClosestStat() {
    return (
      this.siteSettings.show_verbose_tl3_progress &&
      this.args.user.trust_level === 2 &&
      this.stepsDone < 14
    );
  }

  get closestStatText() {
    const closestStatObj = diffLess(this.stats);
    return i18n("see_tl3_progress.closest_stat", {
      stat_name: i18n(`see_tl3_progress.${closestStatObj.key}`),
      stat_left_to_next: closestStatObj.left,
    });
  }

  @action
  toggleModalState() {
    this.modalShowing = !this.modalShowing;
  }

  get barsFilledOrEmpty() {
    let state = [];
    for (let i = 0; i < 14; i++) {
      if (i < this.stepsDone) {
        state.push(
          `background-color: ${this.session.defaultColorSchemeIsDark || this.session.darkModeAvailable ? this.siteSettings.progress_bar_color_dark : this.siteSettings.progress_bar_color_light}; width: 100%;`
        );
      } else {
        state.push(false);
      }
    }

    return state;
  }

  get barBg() {
    return `background-color: ${this.session.defaultColorSchemeIsDark || this.session.darkModeAvailable ? this.siteSettings.progress_bar_background_color_dark : this.siteSettings.progress_bar_background_color_light}`;
  }

  get showAboutToLoseTl3() {
    return (
      !this.stats.on_grace_period &&
      this.siteSettings.show_warning_when_tl3_requirements_low &&
      this.args.user.trust_level === 3
    );
  }

  get closestStatToLoseText() {
    const closestStatObj = diffMore(this.stats, this.siteSettings);
    return i18n("see_tl3_progress.closest_stat_to_lose", {
      stat_name: i18n(
        closestStatObj.key === "days_visited" // days_visited uses its own plugin-defined locale
          ? "see_tl3_progress.days_visited"
          : `see_tl3_progress.${closestStatObj.key}`
      ),
      stat_left: closestStatObj.left,
    });
  }

  get mutedTopicsAndPostsText() {
    const num_topics = this.stats.num_topics_in_muted_categories;
    const num_posts = this.stats.num_posts_in_muted_categories;

    const topics_text = i18n(
      `see_tl3_progress.muted_topics_count.${num_topics === 1 ? "one" : "other"}`,
      {
        num_topics: this.stats.num_topics_in_muted_categories,
      }
    );

    const posts_text = i18n(
      `see_tl3_progress.muted_posts_count.${num_posts === 1 ? "one" : "other"}`,
      {
        num_topics: this.stats.num_posts_in_muted_categories,
      }
    );

    return i18n("see_tl3_progress.has_muted_topics_posts_warning", {
      muted_topics_count: topics_text,
      muted_posts_count: posts_text,
    });
  }

  <template>
    {{#if (or this.stats_loading this.is_locked_loading)}}
      <DConditionalLoadingSpinner
        @condition={{or this.stats_loading this.is_locked_loading}}
      />
    {{else}}
      <h3>{{i18n
          (if
            (eq this.stats.time_period 1)
            "see_tl3_progress.modal_title.one"
            "see_tl3_progress.modal_title.other"
          )
          num_days=this.stats.time_period
        }}</h3>
      {{#if (eq @user.trust_level 2)}}
        <div class="segmented-bars">
          {{#each this.barsFilledOrEmpty as |state|}}
            <div class="segmented-bar" style={{trustHTML this.barBg}}>
              {{#if state}}
                <div class="segmented-bar-fill" style={{trustHTML state}}></div>
              {{else}}
                <div class="segmented-bar-fill"></div>
              {{/if}}
            </div>
          {{/each}}
        </div>
        <p>
          {{this.progressDoneText}}
        </p>
      {{/if}}

      {{#if this.showClosestStat}}
        <div id="closest-stat-text" class="inline-wrapper">{{dIcon "forward"}}
          {{this.closestStatText}}
        </div>
      {{/if}}
      {{#if
        (and
          this.siteSettings.show_warning_when_user_has_muted_topics_and_posts
          (or
            (gte this.stats.num_topics_in_muted_categories 1)
            (gte this.stats.num_posts_in_muted_categories 1)
          )
          (eq @user.trust_level 2)
          (lt this.stepsDone 14)
        )
      }}
        <div>
          {{dIcon "triangle-exclamation"}}
          {{this.mutedTopicsAndPostsText}}
          <a href={{concat "/u/" @user.username "/preferences/tracking"}}>
            {{i18n "see_tl3_progress.muted_categories_link_text"}}
          </a>
        </div>
      {{/if}}
      {{#if this.showAboutToLoseTl3}}
        <div id="closest-stat-to-lose-text" class="inline-wrapper">{{dIcon
            "triangle-exclamation"
          }}
          {{this.closestStatToLoseText}}
        </div>
      {{/if}}

      {{#if
        (and
          this.siteSettings.show_verbose_tl3_progress
          (or (eq @user.trust_level 2) (eq @user.trust_level 3))
        )
      }}
        <DButton
          class="btn-primary"
          style="margin-bottom: 1em;"
          @label="see_tl3_progress.modal_button_text"
          @action={{this.toggleModalState}}
          @icon={{this.siteSettings.modal_button_icon}}
        />
        {{#if this.modalShowing}}
          <DModal
            @title={{i18n
              (if
                (eq this.stats.time_period 1)
                "see_tl3_progress.modal_title.one"
                "see_tl3_progress.modal_title.other"
              )
              num_days=this.stats.time_period
            }}
            @closeModal={{this.toggleModalState}}
          >
            <Tl3ProgressModal
              @user={{@user}}
              @stats={{this.stats}}
              @is_locked={{this.lockedStatus.is_locked}}
              @locked_at_trust_level={{this.lockedStatus.locked_at_trust_level}}
            />
          </DModal>
        {{/if}}
      {{/if}}
    {{/if}}
  </template>
}
