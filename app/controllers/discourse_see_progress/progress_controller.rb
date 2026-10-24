# frozen_string_literal: true

module DiscourseSeeProgress
  class ProgressController < ApplicationController
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
        ::DiscourseSeeProgress::StatsProgress.new(user).stats
      else
        ::DiscourseSeeProgress::BasicProgress.new(user).stats
      end
    end
  end
end
