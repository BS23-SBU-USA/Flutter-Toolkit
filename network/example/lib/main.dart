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
        /// Here, in a Flutter Network we are passing a base URL, a callback
        /// function named tokenCallBack that is responsible for providing
        /// the authentication token required for the API requests which
        /// returns a Future<String?> that is used for the authorization
        /// process and an optional parameter named onUnAuthorizedError that
        /// represents a callback function to handle unauthorized errors. For
        /// example, onUnAuthorizedError function can be used to facilitate
        /// immediate logout in scenarios where a user is logged in across
        /// multiple devices.
        flutterNetwork: FlutterNetwork(
          baseUrl: baseUrl,
          tokenCallBack: () => Future.value(null),
          // onUnAuthorizedError:
          //     () {},
        ),
      ),
    );
  }
}

// class NetworkExample extends StatefulWidget {
//   const NetworkExample({
//     super.key,
//     required this.flutterNetwork,
//   });
//
//   final FlutterNetwork flutterNetwork;
//
//   @override
//   State<NetworkExample> createState() => _NetworkExampleState();
// }
//
// class _NetworkExampleState extends State<NetworkExample> {
//   late List<PostModel> posts = [];
//
//   @override
//   void initState() {
//     super.initState();
//     fetchPosts();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Network Package'),
//         centerTitle: true,
//       ),
//       body: posts.isEmpty
//           ? const Center(
//               child: CircularProgressIndicator(),
//             )
//           : ListView.builder(
//               itemCount: posts.length,
//               itemBuilder: (BuildContext context, int index) {
//                 return Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Card(
//                     child: ListTile(
//                       title: Text(
//                         posts[index].title,
//                       ),
//                       subtitle: Text(
//                         posts[index].body,
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//     );
//   }
//
//   Future<void> fetchPosts() async {
//     /// Here, we are passing the API type (public/ protected) and end point URL
//     /// with required query parameters
//     final response = await widget.flutterNetwork.get(
//       APIType.public,
//       baseUrl,
//       query: {
//         '_page': 1,
//         '_limit': 10,
//       },
//     );
//     if (response.statusCode == 200) {
//       List<dynamic> body = response.data;
//
//       setState(() {
//         posts = body.map((dynamic item) => PostModel.fromJson(item)).toList();
//       });
//     } else {
//       throw Exception('Failed to load posts');
//     }
//   }
// }

// Implementation with FutureBuilder

class NetworkExample extends StatefulWidget {
  const NetworkExample({
    Key? key,
    required this.flutterNetwork,
  }) : super(key: key);

  final FlutterNetwork flutterNetwork;

  @override
  State<NetworkExample> createState() => _NetworkExampleState();
}

class _NetworkExampleState extends State<NetworkExample> {
  late Future<List<PostModel>> futurePosts;

  @override
  void initState() {
    super.initState();
    futurePosts = fetchPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Network Package'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<PostModel>>(
        future: futurePosts,
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

  Future<List<PostModel>> fetchPosts() async {
    /// Here, we are passing the API type (public/ protected) and end point URL
    /// with required query parameters
    final response = await widget.flutterNetwork.get(
      APIType.public,
      baseUrl,
      query: {
        '_page': 1,
        '_limit': 10,
      },
    );
    if (response.statusCode == 200) {
      List<dynamic> body = response.data;
      return body.map((dynamic item) => PostModel.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load posts');
    }
  }
}
