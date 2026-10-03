
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:simple_app/core/config/app_colors.dart';

@immutable
class StoryItem {
  final String name;
  final String? imageUrl;
  final String? avatarUrl;

 final bool isAdd;

  const StoryItem({
    required this.name,
    this.imageUrl,
    this.avatarUrl,
    this.isAdd = false,
  });
}

class StoriesRow extends StatelessWidget {
  final List<StoryItem> stories;
  final ValueChanged<StoryItem>? onTap;

  const StoriesRow({super.key, required this.stories, this.onTap});

  static const _cardWidth = 92.0;
  static const _cardHeight = 130.0;

  @override
  Widget build(BuildContext context) {
    if (stories.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 184,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        itemCount: stories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) => _StoryCard(
          key: ValueKey('${stories[i].name}_$i'),
          item: stories[i],
          onTap: onTap == null ? null : () => onTap!(stories[i]),
        ),
      ),
    );
  }
}

class _StoryCard extends StatelessWidget {
  final StoryItem item;
  final VoidCallback? onTap;

  const _StoryCard({super.key, required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: StoriesRow._cardWidth,
          child: Column(
            children: [
              SizedBox(
                height: StoriesRow._cardHeight,
                width: StoriesRow._cardWidth,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: _NetImage(url: item.imageUrl, cacheWidth: 300),
                      ),
                    ),
                    Positioned(
                      bottom: -13,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: item.isAdd
                            ? const _AddBadge()
                            : _AvatarBadge(url: item.avatarUrl),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Text(
                item.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: HomeColors.storyLabel,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddBadge extends StatelessWidget {
  const _AddBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: const Color(0xFF3F5BFF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: const Icon(Icons.add, size: 16, color: Colors.white),
    );
  }
}

class _AvatarBadge extends StatelessWidget {
  final String? url;
  const _AvatarBadge({this.url});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      padding: const EdgeInsets.all(1.5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(color: HomeColors.primary, width: 2),
      ),
      child: ClipOval(child: _NetImage(url: url, cacheWidth: 90)),
    );
  }
}


class _NetImage extends StatelessWidget {
  final String? url;
  final int cacheWidth;
  const _NetImage({this.url, required this.cacheWidth});

  static const _placeholder = DecoratedBox(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFB9C3FF), Color(0xFF7C88E8)],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final path = url;
    if (path == null || path.isEmpty) return _placeholder;

    final isNetwork = path.startsWith('http');
    final isSvg = path.toLowerCase().split('?').first.endsWith('.svg');

    if (isSvg) {
      return isNetwork
          ? SvgPicture.network(
              path,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              placeholderBuilder: (_) => _placeholder,
            )
          : SvgPicture.asset(
              path,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              placeholderBuilder: (_) => _placeholder,
            );
    }

    if (isNetwork) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        cacheWidth: cacheWidth,
        loadingBuilder: (_, child, progress) =>
            progress == null ? child : _placeholder,
        errorBuilder: (_, __, ___) => _placeholder,
      );
    }

    return Image.asset(
      path,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      cacheWidth: cacheWidth,
      errorBuilder: (_, __, ___) => _placeholder,
    );
  }
}

