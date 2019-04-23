import 'dart:async';

import 'package:reddigram/api/api.dart';
import 'package:reddigram/models/models.dart';
import 'package:reddigram/store/store.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';

String _concatenateSubreddits(Iterable<String> subreddits) =>
    subreddits.join('+');

ThunkAction<ReddigramState> fetchFreshFeed([Completer completer]) {
  return (Store<ReddigramState> store) {
    store.dispatch(SetFeedFetching(true));

    apiRepository
        .subreddit(_concatenateSubreddits(store.state.subscriptions))
        .then(ListingPhotosMapper.map)
        .then((photos) => store.dispatch(SetFeed(photos)))
        .whenComplete(() {
      store.dispatch(SetFeedFetching(false));
      completer?.complete();
    });
  };
}

ThunkAction<ReddigramState> fetchMoreFeed() {
  return (Store<ReddigramState> store) {
    store.dispatch(SetFeedFetching(true));

    var after = '';
    if (store.state.feedState.photos.isNotEmpty) {
      after = store.state.feedState.photos.last.id;
    }

    apiRepository
        .subreddit(_concatenateSubreddits(store.state.subscriptions),
            after: after)
        .then(ListingPhotosMapper.map)
        .then((photos) => store.dispatch(AddMoreFeed(photos)))
        .whenComplete(() => store.dispatch(SetFeedFetching(false)));
  };
}

class SetFeedFetching {
  final bool fetching;

  SetFeedFetching(this.fetching);
}

class SetFeed {
  final List<Photo> photos;

  SetFeed(this.photos);
}

class AddMoreFeed {
  final List<Photo> photos;

  AddMoreFeed(this.photos);
}
