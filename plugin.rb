# frozen_string_literal: true

# name: discourse-see-tl3-progress
# about: See your own progress to TL3.
# meta_topic_id: TODO
# version: 0.0.1
# authors: Nate Dhaliwal
# url: TODO
# required_version: 2.7.0

enabled_site_setting :see_tl3_progress_enabled

module ::DiscourseSeeTl3Progress
  PLUGIN_NAME = "discourse-see-tl3-progress"
end

require_relative "lib/discourse_see_tl3_progress/engine"
require_relative "lib/discourse_see_tl3_progress/stats_progress"
register_svg_icon "triangle-exclamation"
register_asset "stylesheets/common/progress-bar.scss"

after_initialize do
  Discourse::Application.routes.append do
    get "/u/:username/tl3-progress.json" => "tl3_progress#show",
        :constraints => {
          username: RouteFormat.username,
        }
  end

  DiscourseSeeTl3Progress::Engine.routes.draw do
    get "/u/:username/is-locked.json" => "is_locked#show",
        :constraints => {
          username: RouteFormat.username,
        }
  end
end
