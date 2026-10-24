# frozen_string_literal: true

DiscourseSeeProgress::Engine.routes.draw do
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

Discourse::Application.routes.draw { mount ::DiscourseSeeProgress::Engine, at: "/" }
