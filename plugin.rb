# frozen_string_literal: true

# name: discourse-see-progress
# about: See your own progress to each Trust Level.
# meta_topic_id: TODO
# version: 0.1.0
# authors: Nate Dhaliwal, gchongo
# url: https://github.com/gchongo/discourse-see-progress
# required_version: 2.7.0

enabled_site_setting :see_progress_enabled

module ::DiscourseSeeProgress
  PLUGIN_NAME = "discourse-see-progress"
end

require_relative "lib/discourse_see_progress/engine"
require_relative "lib/discourse_see_progress/stats_progress"
require_relative "lib/discourse_see_progress/basic_progress"
register_svg_icon "triangle-exclamation"
register_asset "stylesheets/common/progress-bar.scss"

after_initialize do
  Discourse::Application.routes.append do
    get "/u/:username/progress.json" => "progress#show",
        :constraints => {
          username: RouteFormat.username,
        }
  end

  DiscourseSeeProgress::Engine.routes.draw do
    get "/u/:username/is-locked.json" => "is_locked#show",
        :constraints => {
          username: RouteFormat.username,
        }
  end
end
