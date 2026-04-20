import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';

const _postsChannel = 'posts:feed';

/// Legacy demo endpoint kept around for the demo app. Gated via
/// `requireLogin` so any authenticated caller (admin or end-user) can use
/// it. New work should prefer the generic collections/records API which
/// supports per-op rules.
class PostsEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  Future<List<Post>> listPosts(Session session) async {
    return Post.db.find(
      session,
      orderBy: (p) => p.createdAt,
      orderDescending: true,
    );
  }

  Future<Post> createPost(Session session, String title, String body) async {
    final post = Post(title: title, body: body);
    final saved = await Post.db.insertRow(session, post);
    await session.messages.postMessage(_postsChannel, saved);
    return saved;
  }

  Future<void> deletePost(Session session, int id) async {
    await Post.db.deleteWhere(session, where: (p) => p.id.equals(id));
  }

  /// Live feed — every new post from [createPost] is pushed to subscribers
  /// over a WebSocket. Useful primarily for the demo app.
  Stream<Post> watchPosts(Session session) async* {
    yield* session.messages.createStream<Post>(_postsChannel);
  }
}
