enum PlaybackState {
  	STATE_BUFFERING,
    STATE_PLAYING,
    STATE_PAUSED,
    STATE_STOPPED,
    NONE
}

extension PlaybackStateExt on PlaybackState {
  int get id {
    switch (this) {
      case PlaybackState.STATE_BUFFERING: {
        return 6;
      }
      case PlaybackState.STATE_PLAYING: {
        return 3;
      }
      case PlaybackState.STATE_PAUSED: {
        return 2;
      }
      case PlaybackState.STATE_STOPPED: {
        return 1;
      }
      case PlaybackState.NONE: {
        return 0;
      }
      default: {
        return -1;
      }
    }
  }

  static PlaybackState of (int id) {
    for (PlaybackState value in PlaybackState.values) {
      if (value.id == id) {
        return value;
      }
    }

    return null;
  }
}