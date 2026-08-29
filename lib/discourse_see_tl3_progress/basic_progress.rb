# frozen_string_literal: true

module DiscourseSeeTl3Progress
  # Progress towards the next trust level for TL0 and TL1 users.
  # The requirements mirror Promotion.tl1_met? and Promotion.tl2_met? in core.
  class BasicProgress
    def initialize(user)
      @user = user
      @stat = user.user_stat
    end

    def stats
      target = @user.trust_level == TrustLevel[0] ? TrustLevel[1] : TrustLevel[2]

      {
        target_trust_level: target,
        requirements: target == TrustLevel[1] ? tl1_requirements : tl2_requirements,
      }
    end

    private

    def tl1_requirements
      [
        requirement("topics_entered", @stat.topics_entered, :tl1_requires_topics_entered),
        requirement("posts_read", @stat.posts_read_count, :tl1_requires_read_posts),
        requirement("time_read", minutes_read, :tl1_requires_time_spent_mins),
        requirement("account_age", account_age_minutes, :tl1_requires_time_spent_mins),
      ]
    end

    def tl2_requirements
      [
        requirement("topics_entered", @stat.topics_entered, :tl2_requires_topics_entered),
        requirement("posts_read", @stat.posts_read_count, :tl2_requires_read_posts),
        requirement("time_read", minutes_read, :tl2_requires_time_spent_mins),
        requirement("account_age", account_age_minutes, :tl2_requires_time_spent_mins),
        requirement("days_visited", @stat.days_visited, :tl2_requires_days_visited),
        requirement("likes_received", @stat.likes_received, :tl2_requires_likes_received),
        requirement("likes_given", @stat.likes_given, :tl2_requires_likes_given),
        # Despite the bang, this method only runs a SELECT and does not write.
        requirement(
          "topics_replied_to",
          @stat.calc_topic_reply_count!,
          :tl2_requires_topic_reply_count,
        ),
      ]
    end

    def requirement(key, value, setting)
      { key: key, type: "min", value: value.to_i, total: SiteSetting.get(setting).to_i }
    end

    def minutes_read
      @stat.time_read.to_i / 60
    end

    def account_age_minutes
      (Time.now - @user.created_at) / 60
    end
  end
end
