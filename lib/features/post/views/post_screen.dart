import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:simple_app/core/config/app_colors.dart';
import 'package:simple_app/features/post/widgets/communities_section.dart';
import 'package:simple_app/features/post/widgets/home_header.dart';
import 'package:simple_app/features/post/widgets/post_card.dart';
import 'package:simple_app/features/post/widgets/quick_links_row.dart';
import 'package:simple_app/features/post/widgets/story_item.dart';
import '../models/post_model.dart';
import '../provider/post_provider.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({super.key});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  final _scrollController = ScrollController();

  static const _communitiesAt = 2;

  static const _stories = <StoryItem>[
    StoryItem(
      name: 'Add Thoughts',
      isAdd: true,
      imageUrl:
          'https://img.magnific.com/premium-photo/trishul-lord-shiva-maha-shivratri_723055-6008.jpg?semt=ais_hybrid&w=740&q=80',
    ),
    StoryItem(
      name: 'Erica Sinclair',
      imageUrl:
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRPO1CC_s7ZVQXFEPfaB3t48kYY5zLVwkTd0fSWuqQOOkfmshrsN5ty26k&s=10',
      avatarUrl:
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSlHwKHE0tG733iYLisLzchbCNVZ5uYIdNS9MhjAuVSY9zgl0MfS2dpwSs&s=10',
    ),
    StoryItem(
      name: 'Nandhiji',
      imageUrl:
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT2Zt1nZoA8vuNzz2W6fgxU2sgNJuxPW1DMb27IUhtVV-R1blXQOD5JUxk&s=10',
      avatarUrl: 'https://nandhiji.com/wp-content/uploads/2025/12/Gal-1.jpg',
    ),
    StoryItem(
      name: 'Will Byers',
      imageUrl:
          'https://liforme.com/cdn/shop/articles/0004_Tree_Pose_-_Vrksasana_08_India_Mindful_Garden_3598a015-0c39-4cbc-9edb-3189788507e8.jpg?v=1778794268',
      avatarUrl:
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR_bbJbgkF9zgLF7gs5c1SsmRlw5u1JvQvUCdk0sNr-Sw&s',
    ),
    StoryItem(
      name: 'Maya',
      imageUrl:
          'https://img.magnific.com/free-vector/gold-mandala-ornament-design-with-circle-middle-isolated-dark-background_8130-2566.jpg?semt=ais_hybrid&w=740&q=80',
      avatarUrl:
          'https://i.pinimg.com/736x/85/64/4f/85644fc8246e922f3c3ccddefec10f0d.jpg',
    ),
  ];

  static const _quickLinks = <QuickLinkItem>[
    QuickLinkItem(svgAsset: 'assets/marketplace.svg', label: 'Marketplace'),
    QuickLinkItem(svgAsset: 'assets/directory.svg', label: 'Directory'),
    QuickLinkItem(svgAsset: 'assets/Mask group.svg', label: 'Best Practises'),
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<PostProvider>().fetchPosts();
    });
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      context.read<PostProvider>().loadMore();
    }
  }

  void _openCreatePost() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Create post')));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: HomeColors.pageBg,
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: _CreatePostFab(onTap: _openCreatePost),
        body: RefreshIndicator(
          onRefresh: () => context.read<PostProvider>().fetchPosts(),
          edgeOffset: MediaQuery.paddingOf(context).top,
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: HomeHeader(
                  userName: 'Sri',
                  onCreatePostTap: _openCreatePost,
                ),
              ),
              const SliverToBoxAdapter(child: StoriesRow(stories: _stories)),
              const SliverToBoxAdapter(
                child: QuickLinksRow(items: _quickLinks),
              ),
              Consumer<PostProvider>(
                builder: (_, provider, _) =>
                    SliverMainAxisGroup(slivers: _bodySlivers(provider)),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _bodySlivers(PostProvider provider) {
    final posts = provider.posts;

    return switch (provider.state) {
      ViewState.initial || ViewState.loading when posts.isEmpty => const [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ),
          ),
        ),
      ],
      ViewState.error when posts.isEmpty => [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    provider.errorMessage ?? 'Error',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: provider.fetchPosts,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
      ViewState.empty => const [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text('No posts yet. Pull to refresh.'),
            ),
          ),
        ),
      ],
      _ => [
        if (provider.errorMessage != null)
          SliverToBoxAdapter(
            child: _InlineError(
              message: provider.errorMessage!,
              onRetry: provider.fetchPosts,
            ),
          ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          sliver: SliverList.builder(
            itemCount:
                posts.length +
                (posts.length >= _communitiesAt ? 1 : 0) +
                (provider.hasMore &&
                        (provider.isLoadingMore ||
                            provider.paginationErrorMessage != null)
                    ? 1
                    : 0),
            itemBuilder: (_, i) {
              final hasSection = posts.length >= _communitiesAt;

              if (hasSection && i == _communitiesAt) {
                return CommunitiesSection(onSeeAll: () {});
              }

              final postIndex = (hasSection && i > _communitiesAt) ? i - 1 : i;
              if (postIndex >= posts.length) {
                if (provider.isLoadingMore) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                return _InlineError(
                  message: provider.paginationErrorMessage!,
                  onRetry: provider.loadMore,
                );
              }
              final post = posts[postIndex];
              return Selector<PostProvider, PostModel?>(
                key: ValueKey(post.uniqueKey),
                selector: (_, provider) => postIndex < provider.posts.length
                    ? provider.posts[postIndex]
                    : null,
                builder: (_, selectedPost, _) => selectedPost == null
                    ? const SizedBox.shrink()
                    : PostCard(post: selectedPost),
              );
            },
          ),
        ),
      ],
    };
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(16),
    child: Row(
      children: [
        Expanded(child: Text(message)),
        TextButton(onPressed: onRetry, child: const Text('Retry')),
      ],
    ),
  );
}

class _CreatePostFab extends StatelessWidget {
  final VoidCallback onTap;
  const _CreatePostFab({required this.onTap});

  static const _size = 52.0;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Create post',
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x665B5BF7),
              blurRadius: 16,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: HomeColors.primary,
          borderRadius: BorderRadius.circular(16),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: SizedBox(
              width: _size,
              height: _size,
              child: Center(
                child: SvgPicture.asset(
                  'assets/new_post.svg',
                  width: 24,
                  height: 24,
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                  placeholderBuilder: (_) => const Icon(
                    Icons.add_box_outlined,
                    size: 24,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
