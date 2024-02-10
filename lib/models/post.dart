import 'package:http/http.dart' as http;
import 'dart:convert';

class Post {
  final int userId;
  final int id;
  final String title;
  final String body;
  List<Comment> comments;

  Post({
    required this.userId,
    required this.id,
    required this.title,
    required this.body,
    List<Comment>? comments,
  }) : comments = comments ?? [];

  int getWordCount() {
    return body.split(' ').length;
  }

  Future<void> fetchComments() async {
    final response = await http.get(
        Uri.parse('https://jsonplaceholder.typicode.com/posts/$id/comments'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      comments = data
          .map((json) => Comment(
                postId: json['postId'],
                id: json['id'],
                name: json['name'],
                email: json['email'],
                body: json['body'],
              ))
          .toList();
    } else {
      throw Exception('Failed to load comments');
    }
  }
}

class Comment {
  final int postId;
  final int id;
  final String name;
  final String email;
  final String body;

  Comment({
    required this.postId,
    required this.id,
    required this.name,
    required this.email,
    required this.body,
  });
}
