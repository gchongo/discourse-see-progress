# frozen_string_literal: true

module DiscourseSeeTl3Progress
  class StatsProgress
    def initialize(user)
      @user = user
      @reqs = TrustLevel3Requirements.new(user)
    end

    def stats
      # TODO: Set user_id to @user.id
      # notification_level = 0 : muted
      num_posts_in_muted_categories = DB.query_single(<<~SQL, @user.id).first || 0
          SELECT COUNT(p.id)
          FROM posts p
          JOIN topics t ON t.id = p.topic_id
          JOIN category_users cu ON cu.category_id = t.category_id
          WHERE cu.notification_level = 0
            AND cu.user_id = ?
            AND p.deleted_at IS NULL
        SQL

      num_topics_in_muted_categories = (DB.query(<<~SQL, @user.id)).count()
          SELECT id
            FROM topics
            WHERE category_id IN (
              SELECT category_id
              FROM category_users
              WHERE notification_level = 0
                AND user_id = ?
            );
        SQL

      {
        time_period: SiteSetting.tl3_time_period,
        on_grace_period: @reqs.on_grace_period,
        num_posts_in_muted_categories: num_posts_in_muted_categories,
        num_topics_in_muted_categories: num_topics_in_muted_categories,
        silenced: @user.silenced?,
        suspended: @user.suspended?,
        penalty_counts: @reqs.penalty_counts,
        days_visited: @reqs.days_visited, # >= min_days_visited
        num_topics_replied_to: @reqs.num_topics_replied_to, # >= min_topics_replied_to
        topics_viewed: @reqs.topics_viewed, # >= min_topics_viewed
        posts_read: @reqs.posts_read, # >= min_posts_read
        num_flagged_posts: @reqs.num_flagged_posts, # <= max_flagged_posts
        num_flagged_by_users: @reqs.num_flagged_by_users, # <= max_flagged_by_users
        topics_viewed_all_time: @reqs.topics_viewed_all_time, # >= min_topics_viewed_all_time
        posts_read_all_time: @reqs.posts_read_all_time, # >= min_posts_read_all_time
        num_likes_given: @reqs.num_likes_given, # >= min_likes_given
        num_likes_received: @reqs.num_likes_received, # >= min_likes_received
        num_likes_received_users: @reqs.num_likes_received_users, # >= min_likes_received_users
        num_likes_received_days: @reqs.num_likes_received_days, # >= min_likes_received_days
        min_days_visited: @reqs.min_days_visited,
        min_topics_replied_to: @reqs.min_topics_replied_to,
        min_topics_viewed: @reqs.min_topics_viewed,
        min_posts_read: @reqs.min_posts_read,
        max_flagged_posts: @reqs.max_flagged_posts,
        max_flagged_by_users: @reqs.max_flagged_by_users,
        min_topics_viewed_all_time: @reqs.min_topics_viewed_all_time,
        min_posts_read_all_time: @reqs.min_posts_read_all_time,
        min_likes_given: @reqs.min_likes_given,
        min_likes_received: @reqs.min_likes_received,
        min_likes_received_users: @reqs.min_likes_received_users,
        min_likes_received_days: @reqs.min_likes_received_days,
      }
    end
  end
end
