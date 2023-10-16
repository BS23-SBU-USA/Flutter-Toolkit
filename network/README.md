# Flutter Networking Module

This module provides networking capabilities for your Flutter application. It includes functionality for making various types of HTTP requests and handling API responses. The module is organized into several files:

## `Dependencies:`
   - dio: 5.1.1
   - http_parser: 4.0.2
   - pretty_dio_logger: 1.3.1
   - logger: 1.1.0
   - internet_connection_checker: 1.0.0+1
   - equatable: 2.0.5

## `network.dart`

This file serves as the entry point for the networking module and exports relevant components.

### Exported Components:

- `RestClient`: A class responsible for making HTTP requests. It supports different HTTP methods like `GET`, `POST`, `PUT`, `PATCH`, and `DELETE`.

- `Failure`: An abstract class representing different types of failure responses from the server. Various concrete classes like `BadRequest`, `Unauthorized`, etc., extend this class.

- `PrettyDioLogger`: A custom Dio interceptor that logs network requests and responses in a readable and organized format. It helps with debugging and understanding API interactions.

## `pretty_dio_logger.dart`

This file contains the implementation of the `PrettyDioLogger` class, which is a custom Dio interceptor for logging network requests and responses.

## `failures.dart`

This file defines different types of failure classes representing various HTTP error responses. Each class corresponds to a specific HTTP status code and includes information about the error, such as the error message and status code.

## `exception_message.dart`

This file contains a class `ExceptionMessage` with pre-defined error messages. It provides a central place for maintaining error messages that can be used throughout the networking module.

## `rest_client.dart`

This file contains the implementation of the `RestClient` class, which is responsible for making HTTP requests. It supports different HTTP methods, handles response parsing, and manages headers.

# `How to Use`

1. Import the networking module in your Dart files:
   ```dart
   import 'package:network/network.dart';
   ```

2. Create an instance of `RestClient` to make HTTP requests:
   ```dart
   RestClient restClient = RestClient(
     baseUrl: 'https://api.example.com',
     token: 'your_access_token',
   );
   ```

3. Use the `restClient` instance to make HTTP requests:
   ```dart
   Response<dynamic> response = await restClient.get(
     APIType.public,
     '/endpoint',
     query: {'param': 'value'},
   );
   ```

4. Handle responses and errors using the relevant classes:
   ### Example Snippet (Clean Architecture):
   *P.S - Feel free to use any architecture of your liking*
   
   ### Data Source
   ```dart
   /// Interface Class
   abstract class ProductDataSource {
      Future<Response> fetchProductList();

      Future<Response> fetchProduct(int id);
   }

   /// Implementation Class
   class ProductDataSourceImpl implements ProductDataSource {
      ProductDataSourceImpl({
         required this.client,
      });

      final RestClient client;

      @override
      Future<Response> fetchProductList() async {
         return await client.get(
            APIType.public,
            'products',
         );
      }

      @override
      Future<Response> fetchProduct(int id) async {
         return await client.get(
            APIType.public,
            'products/$id',
         );
      }
   }
   ```
   ### Repository
   ```dart
   /// Interface Class
   /// P.S. you can use Either from dartz library or you can use Records feature
   abstract class ProductRepository {
      Future<Either<ErrorModel, List<ProductModel>>> productList();

      Future<Either<ErrorModel, ProductModel>> product(int id);
   }
   
   /// Implementation Class
   class ProductRepositoryImpl implements ProductRepository {
      ProductRepositoryImpl({required this.dataSource});

      final ProductDataSource dataSource;

      @override
      Future<Either<ErrorModel, List<ProductModel>>> productList() async {
         return await dataSource.fetchProductList().guard(
               (data) => (data as List).map((e) {
                  return ProductModel.fromJson(e);
               }).toList(),
            );
      }

      @override
      Future<Either<ErrorModel, ProductModel>> product(int id) async {
         return await dataSource
            .fetchProduct(id)
            .guard((data) => ProductModel.fromJson(data));
      }
   }

   ```
   ### Helper Extension to handle response and Error
   ```dart
   extension FutureResponseExtension on Future<Response> {
      /// Use Either from dartz library or you can use Records feature
      /// ErrorModel can be any model of your choice
      Future<Either<ErrorModel, T>> guard<T>(Function(dynamic) parse) async {
         try {
            final response = await this;

            return Right(parse(response.data));
         } on Failure catch (e, stacktrace) {
            /// Feel free to change the log with any logger library of your choice
            log(
               runtimeType.toString(),
               error: {},
               stackTrace: stacktrace,
            );
            ErrorModel errorModel = ErrorModel.fromJson(e.error);

            return Left(errorModel);
         }
      }
   }
   ```

Feel free to customize the networking module to suit your application's requirements. Happy networking!