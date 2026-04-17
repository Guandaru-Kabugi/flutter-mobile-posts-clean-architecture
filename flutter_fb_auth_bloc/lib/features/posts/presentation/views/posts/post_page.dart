import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fb_auth_bloc/features/posts/presentation/blocs/posts_bloc/posts_bloc.dart';
import 'package:flutter_fb_auth_bloc/features/posts/presentation/listeners/posts_listeners/post_listeners.dart';
import 'package:flutter_fb_auth_bloc/features/posts/presentation/widgets/posts/post_widget.dart';
import 'package:flutter_fb_auth_bloc/features/posts/presentation/widgets/posts/showmodalfunctionsheet.dart';

class PostPage extends StatefulWidget {
  const PostPage({super.key});

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  @override
  void initState() {
    context.read<PostsBloc>().add(FetchPostsEvent());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Posts Page'),
        actions: [
          IconButton(
            onPressed: () => showAddPostModal(context),
            icon: Icon(Icons.add),
          ),
        ],
      ),
      body: BlocConsumer<PostsBloc, PostsState>(
        listener: postListeners,
        builder: (context, state) {
          return BlocBuilder<PostsBloc, PostsState>(
            builder: (context, state) {
              if (state is PostLoadingState) {
                return Center(child: CircularProgressIndicator());
              } else if (state is PostSuccessState) {
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: state.posts.length,
                  itemBuilder: (context, index) {
                    final post = state.posts[index];

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: Card(
                        elevation: 2,
                        shadowColor: const Color.fromARGB(31, 176, 8, 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: PostWidget(post: post),
                        ),
                      ),
                    );
                  },
                );
              } else if (state is PostCreatedSuccessState) {
                return Card(child: PostWidget(post: state.post));
              } else if (state is PostErrorState) {
                return Center(child: Text(state.message));
              } else {
                return Center(child: Text(''));
              }
            },
          );
        },
      ),
    );
  }
}
