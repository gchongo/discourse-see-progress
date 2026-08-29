# frozen_string_literal: true

module DiscourseSeeTl3Progress
  class Tl3ProgressController < ApplicationController
    requires_plugin PLUGIN_NAME
    requires_login

    def show
      user = User.find_by_username(params[:username])
      raise Discourse::NotFound unless user
      raise Discourse::InvalidAccess unless current_user == user || current_user.staff?

      render json: { stats_progress: progress_for(user) }
    end

    private

    def progress_for(user)
      if user.trust_level >= TrustLevel[2]
        ::DiscourseSeeTl3Progress::StatsProgress.new(user).stats
      else
        ::DiscourseSeeTl3Progress::BasicProgress.new(user).stats
      end
    end
  end
end
