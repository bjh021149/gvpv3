import 'package:emby_client/core/models/base_item_dto.dart';
import 'package:emby_client/services/cache/emby_cache.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider that watches the [_core] box for a specific item.
///
/// Emits a lightweight [BaseItemDto] without heavy fields.
/// Suitable for components that only need core metadata
/// (title, year, rating, overview, image tags, etc.).
final itemCoreProvider = StreamProvider.family<BaseItemDto?, String>(
  (ref, id) => ref.watch(embyCacheProvider).watchItemCore(id),
);

/// Provider that watches ALL boxes related to an item.
///
/// Emits a fully assembled [BaseItemDto] whenever any box changes.
/// Use this when you need the complete item with heavy fields.
final itemFullProvider = StreamProvider.family<BaseItemDto?, String>(
  (ref, id) => ref.watch(embyCacheProvider).watchItemFull(id),
);

/// Provider that watches the [_people] box for a specific item.
///
/// Emits the cast/crew list. Only rebuilds when people data changes.
final peopleProvider = StreamProvider.family<List<PersonDto>?, String>(
  (ref, id) => ref.watch(embyCacheProvider).watchPeople(id),
);

/// Provider that watches the [_studios] box for a specific item.
///
/// Emits the studio list. Only rebuilds when studios data changes.
final studiosProvider = StreamProvider.family<List<StudioDto>?, String>(
  (ref, id) => ref.watch(embyCacheProvider).watchStudios(id),
);

/// Provider that watches the [_genres] box for a specific item.
///
/// Emits the genre tag list. Only rebuilds when genres data changes.
final genresProvider = StreamProvider.family<List<String>?, String>(
  (ref, id) => ref.watch(embyCacheProvider).watchGenres(id),
);
