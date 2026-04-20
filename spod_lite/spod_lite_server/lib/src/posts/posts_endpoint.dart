import 'package:serverpod/serverpod.dart';
import '../admin/admin_authentication_handler.dart';
import '../generated/protocol.dart';

class PostsEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  @override
  Set<Scope> get requiredScopes => {adminScope};

  Future<List<Post>> listPosts(Session session) async {
    return Post.db.find(
      session,
      orderBy: (p) => p.createdAt,
      orderDescending: true,
    );
  }

  Future<Post> createPost(Session session, String title, String body) async {
    final post = Post(title: title, body: body);
    return Post.db.insertRow(session, post);
  }

  Future<void> deletePost(Session session, int id) async {
    await Post.db.deleteWhere(session, where: (p) => p.id.equals(id));
  }
}
