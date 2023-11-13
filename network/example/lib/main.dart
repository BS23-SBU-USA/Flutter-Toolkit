import 'package:flutter/material.dart';
import 'package:flutter_network/flutter_network.dart';
import 'package:network_example/post_model.dart';

const String baseUrl = 'https://jsonplaceholder.typicode.com/posts';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Network Package Example',
      home: NetworkExample(
        // Passing a rest client for handling network requests
        restClient: FlutterNetwork(
          // baseUrl represents the base URL for the API requests
          baseUrl: baseUrl,

          /* tokenCallBack a callback function that is responsible for providing
          the authentication token required for the API requests. It returns
          a Future<String?> which is used for the authorization process.*/
          tokenCallBack: () => Future.value(null),

          /* This is an optional parameter that represents a callback function
         to handle unauthorized errors. For example, this function can be used
         to facilitate immediate logout in scenarios where a user is logged in
         across multiple devices. */

          // onUnAuthorizedError:
          //     () {},
        ),
      ),
    );
  }
}

class NetworkExample extends StatefulWidget {
  const NetworkExample({
    super.key,
    required this.restClient,
  });

  final FlutterNetwork restClient;

  @override
  State<NetworkExample> createState() => _NetworkExampleState();
}

class _NetworkExampleState extends State<NetworkExample> {
  late List<PostModel> posts = [];

  @override
  void initState() {
    super.initState();
    fetchPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Network Package'),
        centerTitle: true,
      ),
      body: posts.isEmpty
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: posts.length,
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    child: ListTile(
                      title: Text(
                        posts[index].title,
                      ),
                      subtitle: Text(
                        posts[index].body,
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Future<void> fetchPosts() async {
    final response = await widget.restClient.get(
      APIType
          .public, // Passing the API type, protected can be used for private API
      baseUrl, // Passing the endpoint url
      query: {
        '_page': 1,
        '_limit': 10,
      }, // Takes the query parameters required for the API calling
    );
    if (response.statusCode == 200) {
      List<dynamic> body = response.data;

      setState(() {
        posts = body.map((dynamic item) => PostModel.fromJson(item)).toList();
      });
    } else {
      throw Exception('Failed to load posts');
    }
  }
}
