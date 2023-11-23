# Networking Plugin for Flutter

This plugin provides networking capabilities for your Flutter application. It includes functionality for making various types of HTTP requests and handling API responses. The module is organized into several files:

## Features:

1. **Flutter Network:**
   - Supports HTTP methods like `GET`, `POST`, `PUT`, `PATCH`, and `DELETE`.
   - Easily customizable with various options such as headers, timeouts, and more.

2. **Error Handling:**
   - `Failure` class representing different types of failure responses from the server.
   - Concrete classes like `BadRequest`, `Unauthorized`, etc., extend the `Failure` class.

3. **Caching:**
   - Integrated caching functionality using `dio_cache_interceptor`.
   - `CacheInterceptor` to add caching to your HTTP requests.
   - A caching directory can be added to `FlutterNetwork` for caching HTTP responses in initialize cache directory call back based on whether Hive is used in the project or not.
   - If Hive is used, no need to initialize, otherwise, initialize the cache directory.

4. **Token-based Authentication:**
   - Easy integration of authentication tokens with the `tokenCallBack` function.
   - The `FlutterNetwork` instance automatically handles the authentication token for protected API calls, eliminating the need to pass it multiple times during initialization.

5. **Dependency Management:**
   - Utilizes popular packages like `dio`, `dio_smart_retry`, `dio_cache_interceptor`, and `dio_cache_interceptor_hive_store`.

6. **Customizable:**
   - Can be easily customized to suit your application's specific requirements.

## `Dependencies:`
   - dio: 5.3.3
   - dio_smart_retry: 6.0.0
   - dio_cache_interceptor: 3.4.4
   - dio_cache_interceptor_hive_store: 3.2.1 
   - pretty_dio_logger: 1.3.1


## `network.dart`

This file serves as the entry point for the networking module and exports relevant components.

### Exported Components:

- `FlutterNetwork`: A class responsible for making HTTP requests. It supports different HTTP methods like `GET`, `POST`, `PUT`, `PATCH`, and `DELETE`.

- `Failure`: An abstract class representing different types of failure responses from the server. Various concrete classes like `BadRequest`, `Unauthorized`, etc., extend this class.

# `How to Use`

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

Feel free to customize the networking module to suit your application's requirements. Happy networking!