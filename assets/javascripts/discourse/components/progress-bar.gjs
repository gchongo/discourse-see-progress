import Component from "@glimmer/component";
import { service } from "@ember/service";
import { trustHTML } from "@ember/template";
// import { modifier } from "ember-modifier";
// import loadScript from "discourse/lib/load-script";
import icon from "discourse/ui-kit/helpers/d-icon";
import { i18n } from "discourse-i18n";

export default class ProgressBar extends Component {
  @service session;
  @service siteSettings;

  get iconType() {
    // eslint-disable-next-line curly
    if (this.args.value === 0 && this.args.total === 0) return "check";
    if (this.args.type === "min") {
      if (this.args.value >= this.args.total) {
        return "check";
      } else {
        return "xmark";
      }
    } else {
      // Handle max, for flags
      if (this.args.value <= this.args.total) {
        return "check";
      } else {
        return "xmark";
      }
    }
  }

  get iconColor() {
    return (
      "color: " +
      (this.iconType === "xmark" ? "var(--danger)" : "var(--success)") +
      ";"
    );
  }

  get meterStyle() {
    const value = this.args.value || 0;
    const total = this.args.total || 0;
    // eslint-disable-next-line no-useless-assignment
    let percent = 0;

    if (this.args.type === "max") {
      if (total === 0) {
        percent = value === 0 ? 100 : 0;
      } else {
        percent = Math.max(0, ((total - value) / total) * 100);
      }
    } else {
      if (total === 0) {
        percent = 100;
      } else {
        percent = Math.min(100, (value / total) * 100);
      }
    }

    const width = percent <= 5 && percent > 0 ? 5 : percent;
    const isDark =
      this.session.defaultColorSchemeIsDark || this.session.darkModeAvailable;
    const color = isDark
      ? this.siteSettings.progress_bar_color_dark
      : this.siteSettings.progress_bar_color_light;

    return `width: ${width}%; background-color: ${color};`;
  }

  get meterBgStyle() {
    return `background-color: ${this.session.defaultColorSchemeIsDark || this.session.darkModeAvailable ? this.siteSettings.progress_bar_background_color_dark : this.siteSettings.progress_bar_background_color_light};`;
  }

  <template>
    <p class="inline-bar-wrapper">
      <div style={{trustHTML this.iconColor}}>{{icon this.iconType}}</div>
      {{i18n @title}}
      <div class="tl3-progress-bar" style={{trustHTML this.meterBgStyle}}>
        <div
          class="tl3-progress-bar-meter"
          style={{trustHTML this.meterStyle}}
        ></div>
      </div>
      <div class="tl3-progress-text">
        {{@value}}/{{@total}}
      </div>
    </p>
  </template>
}
