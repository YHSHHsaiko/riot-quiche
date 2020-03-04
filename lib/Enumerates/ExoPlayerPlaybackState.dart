enum ExoPlayerPlaybackState {
  	STATE_BUFFERING,
    STATE_ENDED,
    STATE_IDLE,
    STATE_PREPARING,
    STATE_READY,
    NONE
}

extension ExoPlayerPlaybackStateExtension on ExoPlayerPlaybackState {
  int get id {
    switch (this) {
      case ExoPlayerPlaybackState.STATE_BUFFERING: {
        return 3;
      }
      case ExoPlayerPlaybackState.STATE_ENDED: {
        return 5;
      }
      case ExoPlayerPlaybackState.STATE_IDLE: {
        return 1;
      }
      case ExoPlayerPlaybackState.STATE_PREPARING: {
        return 2;
      }
      case ExoPlayerPlaybackState.STATE_READY: {
        return 4;
      }
      default: {
        return -1;
      }
    }
  }

  static ExoPlayerPlaybackState of (int id) {
    for (ExoPlayerPlaybackState value in ExoPlayerPlaybackState.values) {
      if (value.id == id) {
        return value;
      }
    }

    return null;
  }
}