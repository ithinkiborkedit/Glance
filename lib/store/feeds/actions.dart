import 'dart:async';

import 'package:reddigram/api/api.dart';
import 'package:reddigram/store/photos/actions.dart';
import 'package:reddigram/store/store.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';

const BEST_SUBSCRIBED = 'BEST_SUBSCRIBED';

String _getProperFeedName(Store<ReddigramState> store, String feed) {
  switch (feed) {
    case BEST_SUBSCRIBED:
      return store.state.authState.authenticated
          ? 'r/' + store.state.subscriptions.join('+')
          : '';
    default:
      return feed;
  }
}

ThunkAction<ReddigramState> fetchFreshFeed(String feedName,
    {int limit, Completer completer}) {
  return (Store<ReddigramState> store) {
    redditRepository
        .feed(_getProperFeedName(store, feedName), limit: limit)
        .then(ListingPhotosMapper.map)
        .then((photos) {
      store.dispatch(FetchedPhotos(photos));
      store.dispatch(FetchedFreshFeed(feedName, photosIds(photos)));
    }).whenComplete(() => completer?.complete());
  };
}

ThunkAction<ReddigramState> fetchMoreFeed(String feedName,
    {int limit, Completer completer}) {
  return (Store<ReddigramState> store) {
    final feed = store.state.feeds[feedName];
    final after = feed.isEmpty ? '' : feed.last;

    redditRepository
        .feed(_getProperFeedName(store, feedName), after: after, limit: limit)
        .then(ListingPhotosMapper.map)
        .then((photos) {
      store.dispatch(FetchedPhotos(photos));
      store.dispatch(FetchedMoreFeed(feedName, photosIds(photos)));
    }).whenComplete(() => completer?.complete());
  };
}

class FetchedFreshFeed {
  final String name;
  final List<String> photosIds;

  FetchedFreshFeed(this.name, this.photosIds);
}

class FetchedMoreFeed {
  final String name;
  final List<String> photosIds;

  FetchedMoreFeed(this.name, this.photosIds);
}