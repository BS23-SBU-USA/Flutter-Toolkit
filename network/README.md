# Networking Plugin for Flutter

This plugin provides networking capabilities for your Flutter application. It includes functionality for making various types of HTTP requests and handling API responses. The module is organized into several files:

## `How to Use`

1. Import the networking module in your Dart files:
   ```dart
   import 'package:network/flutter_network.dart';
   ```

2. Create an instance of `FlutterNetwork` to make HTTP requests:
   ```dart
   FlutterNetwork flutterNetwork = FlutterNetwork(
     baseUrl: 'https://api.example.com',
     tokenCallBack: () {
      return Future.value();
    },
   );
   ```

3. Use the `flutterNetwork` instance to make HTTP requests:
   ```dart
   Response<dynamic> response = await flutterNetwork.get(
     '/endpoint',
     apiType: APIType.protected,
     data: {'requestBody': requestBody}  
     query: {'param': 'value'},
   );
   ```

## Features:

1. **Flutter Network:**
   - Supports HTTP methods like `GET`, `POST`, `PUT`, `PATCH`, and `DELETE`.
   - Easily customizable with various options such as headers, timeouts, and more.

2. **Error Handling:**
   - `Failure` class representing different types of failure responses from the server.
   - Concrete classes like `BadRequest`, `Unauthorized`, etc., extend the `Failure` class.

3. **Caching:**
   - Integrated caching functionality using `dio_cache_interceptor`.
   - CacheOptions: To enable caching for your HTTP requests, make sure to include the `CacheOptions` when initializing `FlutterNetwork`. Example:
      ```dart
      final FlutterNetwork flutterNetwork = FlutterNetwork(
        baseUrl: "https://api.example.com",
        cacheOptions: CacheOptions(
          store: MemCacheStore(maxSize: 10485760, maxEntrySize: 1048576),
          policy: CachePolicy.forceCache,
          maxStale: const Duration(days: 10),
          priority: CachePriority.high,
        ),
      );
      ```
     Customize the `CacheOptions` to tailor caching behavior according to your specific requirements.
   - Easily add the retry feature to your HTTP requests by including the `RetryInterceptor` when initializing `FlutterNetwork`. Example:
     ```dart
     final FlutterNetwork flutterNetwork = FlutterNetwork(
      baseUrl: "https://api.example.com",
      retryInterceptor: RetryInterceptor(
        dio: dio, // specify your Dio instance
        logPrint: print, // specify log function (optional)
        retries: 3, // retry count (optional)
        retryDelays: const [
          Duration(seconds: 1), // wait 1 sec before the first retry
          Duration(seconds: 2), // wait 2 sec before the second retry
          Duration(seconds: 3), // wait 3 sec before the third retry
        ],
      ),
     );
     ```
     Customize the `RetryInterceptor` parameters to define your preferred retry strategy, including the number of retries and delays between retries.

4. **Token-based Authentication:**
   - Easy integration of authentication tokens with the `tokenCallBack` function.
   - The `FlutterNetwork` instance automatically handles the authentication token for protected API calls, eliminating the need to pass it multiple times during initialization.

5. **Dependency Management:**
   - Utilizes popular packages like `dio`, `dio_smart_retry`, `dio_cache_interceptor`, and `pretty_dio_logger`.

6. **Customizable:**
   - Can be easily customized to suit your application's specific requirements.

## `Dependencies:`
   - dio: 5.3.4
   - dio_smart_retry: 6.0.0
   - dio_cache_interceptor: 3.5.0
   - pretty_dio_logger: 1.3.1

Feel free to customize the networking module to suit your application's requirements. Happy networking!