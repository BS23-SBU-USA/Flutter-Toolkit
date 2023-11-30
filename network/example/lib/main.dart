import 'package:flutter/material.dart';
import 'package:flutter_network/flutter_network.dart';
import 'package:network_example/post_model.dart';

const String baseUrl = 'https://jsonplaceholder.typicode.com';
const String posts = '/posts';

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  /// Creates an instance of [FlutterNetwork] for making HTTP requests.
  ///
  /// Parameters:
  /// - [baseUrl]: Specifies the base URL for API requests.
  /// - [tokenCallBack]: A callback function that provides the authentication
  ///   token required for API requests. It returns a [Future<String?>].
  /// - [onUnAuthorizedError]: An optional callback function that handles
  ///   unauthorized errors. For example, it can be used to facilitate immediate
  ///   logout in scenarios where a user is logged in across multiple devices.
  /// - [initializeCacheDirectory]: An optional callback function that allows
  ///   custom initialization of the cache directory used for caching network
  ///   responses. If not provided, the default cache directory will be used. If
  ///   Hive is used, no need to initialize, otherwise, initialize the cache
  ///   directory.
  final FlutterNetwork flutterNetwork = FlutterNetwork(
    baseUrl: baseUrl,
    tokenCallBack: () {
      return Future.value();
    },
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Network Package Example',
      home: NetworkExample(flutterNetwork: flutterNetwork),
    );
  }
}

class NetworkExample extends StatelessWidget {
  const NetworkExample({
    Key? key,
    required this.flutterNetwork,
  }) : super(key: key);

  final FlutterNetwork flutterNetwork;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Network Package'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<PostModel>>(
        future: fetchPosts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No data available'),
            );
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    child: ListTile(
                      title: Text(
                        snapshot.data![index].title,
                      ),
                      subtitle: Text(
                        snapshot.data![index].body,
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  /// Fetches a list of posts from the specified API endpoint.
  ///
  /// Parameters:
  /// - [flutterNetwork]: The instance of [FlutterNetwork] used to make the
  ///   HTTP GET request.
  /// - [endpoint]: Specifies the specific API endpoint.
  /// - [apiType]: The [APIType] enum defines the type of API (public or
  ///   protected) to be accessed.
  /// - [query]: Optional parameter for passing query parameters.
  ///
  /// Returns a response containing the data from the API, or throws an
  /// exception if the request fails.
  Future<List<PostModel>> fetchPosts() async {
    try {
      final response = await flutterNetwork.get(
        posts,
        apiType: APIType.public,
        query: {
          '_page': 1,
          '_limit': 10,
        },
      );
      List<dynamic> body = response.data;
      return body.map((dynamic item) => PostModel.fromJson(item)).toList();
    } catch (e, stackTrace) {
      print(e.toString());
      print(stackTrace.toString());
      throw Exception('Failed to load posts');
    }
  }
}
