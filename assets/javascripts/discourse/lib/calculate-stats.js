export function stepsDone(stats) {
  let steps = 0;
  const allReqs = [
    !(stats["penalty_counts"]["silenced"] > 0 || stats["silenced"]),
    !(stats["penalty_counts"]["suspended"] > 0 || stats["suspended"]),
    stats.days_visited >= stats.min_days_visited,
    stats.num_topics_replied_to >= stats.min_topics_replied_to,
    stats.topics_viewed >= stats.min_topics_viewed,
    stats.posts_read >= stats.min_posts_read,
    stats.num_flagged_posts <= stats.max_flagged_posts,
    stats.num_flagged_by_users <= stats.max_flagged_by_users,
    stats.topics_viewed_all_time >= stats.min_topics_viewed_all_time,
    stats.posts_read_all_time >= stats.min_posts_read_all_time,
    stats.num_likes_given >= stats.min_likes_given,
    stats.num_likes_received >= stats.min_likes_received,
    stats.num_likes_received_days >= stats.min_likes_received_days,
    stats.num_likes_received_users >= stats.min_likes_received_users,
  ];

  for (const req of allReqs) {
    if (req) {
      steps++;
    }
  }
  return steps;
}

export function percentageDone(stats) {
  let total = 0;
  const allReqs = [
    stats["penalty_counts"]["silenced"] > 0 || stats["silenced"] ? 0 : 1,
    stats["penalty_counts"]["suspended"] > 0 || stats["suspended"] ? 0 : 1,
    stats.days_visited >= stats.min_days_visited
      ? 1
      : stats.days_visited / stats.min_days_visited,
    stats.num_topics_replied_to >= stats.min_topics_replied_to
      ? 1
      : stats.num_topics_replied_to / stats.min_topics_replied_to,
    stats.topics_viewed >= stats.min_topics_viewed
      ? 1
      : stats.topics_viewed / stats.min_topics_viewed,
    stats.posts_read >= stats.min_posts_read
      ? 1
      : stats.posts_read / stats.min_posts_read,
    stats.max_flagged_posts === 0
      ? 1
      : stats.num_flagged_posts <= stats.max_flagged_posts
        ? (stats.max_flagged_posts - stats.num_flagged_posts) /
          stats.max_flagged_posts
        : 0,
    stats.max_flagged_by_users === 0
      ? 1
      : stats.num_flagged_by_users <= stats.max_flagged_by_users
        ? (stats.max_flagged_by_users - stats.num_flagged_by_users) /
          stats.max_flagged_by_users
        : 0,
    stats.topics_viewed_all_time >= stats.min_topics_viewed_all_time
      ? 1
      : stats.topics_viewed_all_time / stats.min_topics_viewed_all_time,
    stats.posts_read_all_time >= stats.min_posts_read_all_time
      ? 1
      : stats.posts_read_all_time / stats.min_posts_read_all_time,
    stats.num_likes_given >= stats.min_likes_given
      ? 1
      : stats.num_likes_given / stats.min_likes_given,
    stats.num_likes_received >= stats.min_likes_received
      ? 1
      : stats.num_likes_received / stats.min_likes_received,
    stats.num_likes_received_days >= stats.min_likes_received_days
      ? 1
      : stats.num_likes_received_days / stats.min_likes_received_days,
    stats.num_likes_received_users >= stats.min_likes_received_users
      ? 1
      : stats.num_likes_received_users / stats.min_likes_received_users,
  ];

  for (const req of allReqs) {
    total += req;
  }

  return Math.round((total / 14) * 100);
}

export function doesQualify(stats) {
  return (
    !(stats["penalty_counts"]["silenced"] > 0 || stats["silenced"]) &&
    !(stats["penalty_counts"]["suspended"] > 0 || stats["suspended"]) &&
    stats.days_visited >= stats.min_days_visited &&
    stats.num_topics_replied_to >= stats.min_topics_replied_to &&
    stats.topics_viewed >= stats.min_topics_viewed &&
    stats.posts_read >= stats.min_posts_read &&
    stats.num_flagged_posts <= stats.max_flagged_posts &&
    stats.num_flagged_by_users <= stats.max_flagged_by_users &&
    stats.topics_viewed_all_time >= stats.min_topics_viewed_all_time &&
    stats.posts_read_all_time >= stats.min_posts_read_all_time &&
    stats.num_likes_given >= stats.min_likes_given &&
    stats.num_likes_received >= stats.min_likes_received &&
    stats.num_likes_received_days >= stats.min_likes_received_days &&
    stats.num_likes_received_users >= stats.min_likes_received_users
  );
}

export function diffLess(stats) {
  const diffs = {
    days_visited: stats.min_days_visited - stats.days_visited,
    topics_replied_to:
      stats.min_topics_replied_to - stats.num_topics_replied_to,
    topics_viewed: stats.min_topics_viewed - stats.topics_viewed,
    posts_read: stats.min_posts_read - stats.posts_read,
    topics_viewed_all_time:
      stats.min_topics_viewed_all_time - stats.topics_viewed_all_time,
    posts_read_all_time:
      stats.min_posts_read_all_time - stats.posts_read_all_time,
    likes_given: stats.min_likes_given - stats.num_likes_given,
    likes_received: stats.min_likes_received - stats.num_likes_received,
    likes_received_days:
      stats.min_likes_received_days - stats.num_likes_received_days,
    likes_received_users:
      stats.min_likes_received_users - stats.num_likes_received_users,
  };

  for (const [key, value] of Object.entries(diffs)) {
    if (value <= 0) {
      delete diffs[key];
    }
  }

  const min_val = Math.min(...Object.values(diffs));
  const stat_name = Object.keys(diffs).find((key) => diffs[key] === min_val);

  return {
    key: stat_name,
    left: diffs[stat_name],
  };
}

export function diffMore(stats, site_settings) {
  const diffs = {
    days_visited: stats.days_visited - stats.min_days_visited,
    topics_replied_to:
      stats.num_topics_replied_to - stats.min_topics_replied_to,
    topics_viewed: stats.topics_viewed - stats.min_topics_viewed,
    posts_read: stats.posts_read - stats.min_posts_read,
    topics_viewed_all_time:
      stats.topics_viewed_all_time - stats.min_topics_viewed_all_time,
    posts_read_all_time:
      stats.posts_read_all_time - stats.min_posts_read_all_time,
    likes_given: stats.num_likes_given - stats.min_likes_given,
    likes_received: stats.num_likes_received - stats.min_likes_received,
    likes_received_days:
      stats.num_likes_received_days - stats.min_likes_received_days,
    likes_received_users:
      stats.num_likes_received_users - stats.min_likes_received_users,
    flagged_posts: stats.max_flagged_posts - stats.num_flagged_posts,
    flagged_by_users: stats.max_flagged_by_users - stats.num_flagged_by_users,
  };

  for (const [key, value] of Object.entries(diffs)) {
    if (value >= site_settings.low_tl3_stats_minimum || value < 0) {
      delete diffs[key];
    }
  }
  const all_keys = Object.keys(diffs);
  if (all_keys.length === 0) {
    return null;
  }
  const min_val = Math.min(...Object.values(diffs));
  const stat_name = all_keys.find((key) => diffs[key] === min_val);

  return {
    key: stat_name,
    left: diffs[stat_name],
  };
}
