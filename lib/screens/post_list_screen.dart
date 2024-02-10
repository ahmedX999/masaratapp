import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/post.dart';
import 'post_detail_screen.dart';

class PostListScreen extends StatefulWidget {
  @override
  _PostListScreenState createState() => _PostListScreenState();
}

class _PostListScreenState extends State<PostListScreen> {
  late Future<List<Post>> _postsFuture;
  TextEditingController _searchController = TextEditingController();
  String _searchText = '';
  int _currentPage = 1;
  int _itemsPerPage = 10;

  @override
  void initState() {
    super.initState();
    _postsFuture = fetchPosts();
  }

  Future<List<Post>> fetchPosts() async {
    final response = await http.get(Uri.parse(
        'https://jsonplaceholder.typicode.com/posts?_page=$_currentPage&_limit=$_itemsPerPage'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data
          .map((json) => Post(
                userId: json['userId'],
                id: json['id'],
                title: json['title'],
                body: json['body'],
              ))
          .toList();
    } else {
      throw Exception('Failed to load posts');
    }
  }

  List<Post> _filterPosts(List<Post> posts) {
    if (_searchText.isEmpty) {
      return posts;
    } else {
      return posts
          .where((post) =>
              post.title.toLowerCase().contains(_searchText.toLowerCase()))
          .toList();
    }
  }

  void _loadNextPage() {
    setState(() {
      _currentPage++;
      _postsFuture = fetchPosts();
    });
  }

  void _loadPreviousPage() {
    if (_currentPage > 1) {
      setState(() {
        _currentPage--;
        _postsFuture = fetchPosts();
      });
    }
  }

  void _confirmDelete(Post post) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to delete this post?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                _deletePost(post);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _deletePost(Post post) {
    setState(() {
      _postsFuture = _postsFuture.then((posts) {
        return posts.where((p) => p.id != post.id).toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Posts'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              setState(() {
                _searchText = _searchController.text;
              });
            },
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search...',
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  setState(() {
                    _searchText = value;
                  });
                },
              ),
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<Post>>(
        future: _postsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final filteredPosts = _filterPosts(snapshot.data!);
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredPosts.length,
                    itemBuilder: (context, index) {
                      final post = filteredPosts[index];
                      return ListTile(
                        title: Text(post.title),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(post.body),
                            Text('Word Count: ${post.getWordCount()}'),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    PostDetailScreen(post: post)),
                          );
                        },
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            _confirmDelete(post);
                          },
                        ),
                      );
                    },
                  ),
                ),
                ButtonBar(
                  alignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: _loadPreviousPage,
                      child: Text('Previous Page'),
                    ),
                    ElevatedButton(
                      onPressed: _loadNextPage,
                      child: Text('Next Page'),
                    ),
                  ],
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
