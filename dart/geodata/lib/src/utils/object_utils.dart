import 'package:meta/meta.dart';

/// Tests equality of two iterables (NOT a deep equality implementation).
@internal
bool testIterableEquality<E>(Iterable<E>? list1, Iterable<E>? list2) {
  if (list1 == null && list2 == null) return true;
  if (list1 == null || list2 == null) return false;
  if (identical(list1, list2)) return true;

  final iter1 = list1.iterator;
  final iter2 = list2.iterator;
  if (iter1.moveNext()) {
    do {
      if (iter2.moveNext()) {
        if (iter1.current != iter2.current) return false;
      } else {
        return false;
      }
    } while (iter1.moveNext());
    if (iter2.moveNext()) return false;
  } else {
    return !iter2.moveNext();
  }
  return true;
}

/// Tests equality of two lists (NOT a deep equality implementation).
@internal
bool testListEquality<E>(List<E>? list1, List<E>? list2) {
  if (list1 == null && list2 == null) return true;
  if (list1 == null || list2 == null) return false;
  if (identical(list1, list2)) return true;
  if (list1.length != list2.length) return false;

  for (var i = 0, len = list1.length; i < len; i++) {
    if (list1[i] != list2[i]) return false;
  }
  return true;
}

/// Tests equality of two maps (NOT a deep equality implementation).
@internal
bool testMapEquality<K, E>(Map<K, E>? map1, Map<K, E>? map2) {
  if (map1 == null && map2 == null) return true;
  if (map1 == null || map2 == null) return false;
  if (identical(map1, map2)) return true;
  if (map1.length != map2.length) return false;

  for (final key1 in map1.keys) {
    if (!map2.containsKey(key1)) return false;
    if (map1[key1] != map2[key1]) return false;
  }
  return true;
}

/// Return a string with list items separated by `,`. If the list is empty or
/// null then returns an empty string.
@internal
String listToString<E>(Iterable<E>? list) =>
    list != null ? (StringBuffer()..writeAll(list, ',')).toString() : '';

/// Return a string with map entries (represented like `key:value`) separated
/// by `,`. If the map is empty or null then returns an empty string.
@internal
String mapToString<K, V>(Map<K, V>? map) {
  if (map == null) return '';
  final buf = StringBuffer();
  var isFirst = true;
  final iter = map.values.iterator;
  for (final key in map.keys) {
    iter.moveNext();
    final value = iter.current;
    if (isFirst) {
      isFirst = false;
    } else {
      buf.write(',');
    }
    buf
      ..write(key)
      ..write(':')
      ..write(value);
  }
  return buf.toString();
}

const int _mask = 0x7fffffff;

/// Return a hash code for a map (NOT a deep hash implementation).
int mapHashCode<K, V>(Map<K, V>? map) {
  if (map == null) return null.hashCode;
  var hash = 0;
  final iter = map.values.iterator;
  for (final key in map.keys) {
    iter.moveNext();
    final value = iter.current;
    hash = (hash + 3 * key.hashCode + 7 * value.hashCode) & _mask;
  }
  hash = (hash + (hash << 3)) & _mask;
  hash ^= hash >> 11;
  hash = (hash + (hash << 15)) & _mask;
  return hash;
}
