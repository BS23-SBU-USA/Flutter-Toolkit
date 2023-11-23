import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_hive_store/dio_cache_interceptor_hive_store.dart';

class DioCacheService {
  static CacheOptions getCacheOptions({String? path}) {
    return CacheOptions(
      store: HiveCacheStore(path),
      policy: CachePolicy.forceCache,
      maxStale: const Duration(days: 10),
      priority: CachePriority.high,
    );
  }
}
