import 'package:amplify_test/amplifyconfiguration.dart';
import 'package:amplify_test/models/Blog.dart';
import 'package:amplify_test/models/Comment.dart';
import 'package:amplify_test/models/ModelProvider.dart';
import 'package:amplify_test/models/Post.dart';
import 'package:flutter/material.dart';
import 'package:amplify_authenticator/amplify_authenticator.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_datastore/amplify_datastore.dart';

Future<void> configureAmplify() async {
  try {
    if (!Amplify.isConfigured) {
      await Amplify.addPlugins([
        AmplifyAuthCognito(),
        AmplifyAPI(),
        AmplifyDataStore(modelProvider: ModelProvider.instance),
      ]);
      await Amplify.configure(amplifyconfig);
      debugPrint('Amplify successfully configured.');
    }
  } catch (e) {
    debugPrint('Error configuring Amplify: $e');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await configureAmplify();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Authenticator(
      child: MaterialApp(
        builder: Authenticator.builder(),
        debugShowCheckedModeBanner: false,
        title: 'Amplify DataStore',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const BlogListScreen(),
      ),
    );
  }
}

class BlogListScreen extends StatefulWidget {
  const BlogListScreen({Key? key}) : super(key: key);

  @override
  State<BlogListScreen> createState() => _BlogListScreenState();
}

class _BlogListScreenState extends State<BlogListScreen> {
  List<Blog> blogs = [];

  @override
  void initState() {
    super.initState();
    _fetchBlogs();
  }

  Future<void> _fetchBlogs() async {
    try {
      final blogList = await Amplify.DataStore.query(Blog.classType);
      setState(() {
        blogs = blogList;
      });
    } catch (e) {
      print('Error fetching blogs: $e');
    }
  }

  Future<void> _addBlog(String name) async {
    try {
      final newBlog = Blog(name: name);
      await Amplify.DataStore.save(newBlog);
      _fetchBlogs();
    } catch (e) {
      print('Error adding blog: $e');
    }
  }

  void _showAddBlogDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Blog'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Blog Name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _addBlog(controller.text);
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _navigateToPosts(Blog blog) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PostListScreen(blog: blog)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Blogs')),
      body: ListView.builder(
        itemCount: blogs.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(blogs[index].name),
            onTap: () => _navigateToPosts(blogs[index]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddBlogDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class PostListScreen extends StatefulWidget {
  final Blog blog;
  const PostListScreen({Key? key, required this.blog}) : super(key: key);

  @override
  State<PostListScreen> createState() => _PostListScreenState();
}

class _PostListScreenState extends State<PostListScreen> {
  List<Post> posts = [];

  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  Future<void> _fetchPosts() async {
    try {
      final postList = await Amplify.DataStore.query(
        Post.classType,
        where: Post.BLOG.eq(widget.blog),
      );
      setState(() {
        posts = postList;
      });
    } catch (e) {
      print('Error fetching posts: $e');
    }
  }

  Future<void> _addPost(String title) async {
    try {
      final newPost = Post(title: title, blog: widget.blog);
      await Amplify.DataStore.save(newPost);
      _fetchPosts();
    } catch (e) {
      print('Error adding post: $e');
    }
  }

  void _showAddPostDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Post'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Post Title'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _addPost(controller.text);
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _navigateToComments(Post post) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CommentListScreen(post: post)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Posts')),
      body: ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(posts[index].title),
            onTap: () => _navigateToComments(posts[index]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddPostDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class CommentListScreen extends StatefulWidget {
  final Post post;
  const CommentListScreen({Key? key, required this.post}) : super(key: key);

  @override
  State<CommentListScreen> createState() => _CommentListScreenState();
}

class _CommentListScreenState extends State<CommentListScreen> {
  List<Comment> comments = [];

  @override
  void initState() {
    super.initState();
    _fetchComments();
  }

  Future<void> _fetchComments() async {
    try {
      final commentList = await Amplify.DataStore.query(
        Comment.classType,
        where: Comment.POST.eq(widget.post),
      );
      setState(() {
        comments = commentList;
      });
    } catch (e) {
      print('Error fetching comments: $e');
    }
  }

  Future<void> _addComment(String content) async {
    try {
      final newComment = Comment(content: content, post: widget.post);
      await Amplify.DataStore.save(newComment);
      _fetchComments();
    } catch (e) {
      print('Error adding comment: $e');
    }
  }

  void _showAddCommentDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Comment'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Comment Content'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _addComment(controller.text);
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Comments')),
      body: ListView.builder(
        itemCount: comments.length,
        itemBuilder: (context, index) {
          return ListTile(title: Text(comments[index].content));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCommentDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
