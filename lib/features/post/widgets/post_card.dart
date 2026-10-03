import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:simple_app/core/config/app_colors.dart';
import '../models/post_model.dart';

const _font = 'Roboto';

class PostCard extends StatelessWidget {
  final PostModel post;
  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final text = post.plainContent;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: HomeColors.card,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 12,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (post.repostedBy != null) _repostBanner(),
          _header(),
          if (post.postType?.slug == 'conscious-act') _consciousActChips(),
          if (text.isNotEmpty) ...[
            const SizedBox(height: 10),
            _LinkifiedText(text),
          ],
          if (post.location != null) _locationRow(),
          if (post.files.isNotEmpty) ...[
            const SizedBox(height: 10),
            _PostMedia(files: post.files),
          ],
          const SizedBox(height: 10),
          _statsLine(),
          const SizedBox(height: 10),
          _actions(),
        ],
      ),
    );
  }

  Widget _repostBanner() {
    final r = post.repostedBy!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          const Icon(Icons.repeat_rounded, size: 16, color: HomeColors.muted),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              '${r.fullName.isNotEmpty ? r.fullName : r.username} reposted',
              style: const TextStyle(
                fontFamily: _font,
                fontSize: 12,
                color: HomeColors.muted,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header() {
    final name = post.profile.fullName.isNotEmpty
        ? post.profile.fullName
        : post.user.username;

    return Row(
      children: [
        _Avatar(url: post.profile.profilePicture, name: name),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: name,
                      style: const TextStyle(
                        fontFamily: _font,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: HomeColors.name,
                      ),
                    ),
                    if (post.feeling != null)
                      TextSpan(
                        text: '  feeling ${post.feeling}',
                        style: const TextStyle(
                          fontFamily: _font,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: HomeColors.muted,
                        ),
                      ),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  const Icon(Icons.public, size: 11, color: HomeColors.muted),
                  const SizedBox(width: 4),
                  Text(
                    post.createdAt != null ? _timeAgo(post.createdAt!) : '',
                    style: const TextStyle(
                      fontFamily: _font,
                      fontSize: 11,
                      color: HomeColors.muted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const _CircleButton(
          svgAsset: 'assets/more_menu.svg',
          fallback: Icons.more_horiz,
          size: 34,
          iconSize: 5,
          // iconSize: 16,
        ),
      ],
    );
  }

  Widget _consciousActChips() {
    final labels = <String>[
      post.postType!.name,
      if (post.categoryName != null) post.categoryName!,
      if (post.subCategoryName != null) post.subCategoryName!,
    ];
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: [
          for (final l in labels)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: HomeColors.circleBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                l,
                style: const TextStyle(
                  fontFamily: _font,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: HomeColors.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _locationRow() => Padding(
    padding: const EdgeInsets.only(top: 8),
    child: Row(
      children: [
        const Icon(Icons.place_outlined, size: 14, color: HomeColors.primary),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            post.location!.name,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: _font,
              fontSize: 12,
              color: HomeColors.muted,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _statsLine() => Text(
    '${_compact(post.likesCount)} Likes . '
    '${_compact(post.totalCommentCount)} Comments . '
    '${_compact(post.shareCount)} Shares',
    style: const TextStyle(
      fontFamily: _font,
      fontSize: 10,
      color: HomeColors.muted,
    ),
  );

  Widget _actions() => Row(
    children: [
      const _CircleButton(
        svgAsset: 'assets/like.svg',
        fallback: Icons.thumb_up_alt_rounded,
      ),
      const SizedBox(width: 10),
      const _CircleButton(
        svgAsset: 'assets/comment.svg',
        fallback: Icons.chat_bubble_rounded,
      ),
      const SizedBox(width: 10),
      const _CircleButton(
        svgAsset: 'assets/share.svg',
        fallback: Icons.share_rounded,
      ),
      const Spacer(),
      if (post.isLiked) ...[
        const Text(
          'You Reacted',
          style: TextStyle(
            fontFamily: _font,
            fontSize: 10,
            color: HomeColors.muted,
          ),
        ),
        const SizedBox(width: 6),
        const Icon(Icons.favorite, size: 20, color: HomeColors.heart),
      ],
    ],
  );

  static String _compact(int n) {
    if (n >= 1000000) return '${_trim(n / 1000000)}M';
    if (n >= 1000) return '${_trim(n / 1000)}k';
    return '$n';
  }

  static String _trim(double v) {
    final s = v.toStringAsFixed(1);
    return s.endsWith('.0') ? s.substring(0, s.length - 2) : s;
  }

  static String _timeAgo(DateTime d) {
    final diff = DateTime.now().difference(d);
    String unit(int n, String s) => '$n $s${n == 1 ? '' : 's'} ago';
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return unit(diff.inMinutes, 'Min');
    if (diff.inHours < 24) return unit(diff.inHours, 'Hour');
    if (diff.inDays < 30) return unit(diff.inDays, 'Day');
    if (diff.inDays < 365) return unit(diff.inDays ~/ 30, 'Month');
    return unit(diff.inDays ~/ 365, 'Year');
  }
}

class _Avatar extends StatelessWidget {
  final String? url;
  final String name;
  const _Avatar({this.url, required this.name});

  @override
  Widget build(BuildContext context) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final fallback = Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: HomeColors.circleBg,
      ),
      child: Text(
        initial,
        style: const TextStyle(
          fontFamily: _font,
          fontWeight: FontWeight.w700,
          color: HomeColors.primary,
        ),
      ),
    );
    if (url == null || url!.isEmpty) return fallback;

    return ClipOval(
      child: Image.network(
        url!,
        width: 44,
        height: 44,
        fit: BoxFit.cover,
        cacheWidth: 132,
        errorBuilder: (_, __, ___) => fallback,
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final String svgAsset;
  final IconData fallback;
  final double size;
  final double iconSize;
  const _CircleButton({
    required this.svgAsset,
    required this.fallback,
    this.size = 40,
    this.iconSize = 16,
    // this.size = 40,
    // this.iconSize = 18,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: HomeColors.circleBg,
      ),
      child: SvgPicture.asset(
        svgAsset,
        width: iconSize,
        height: iconSize,
        colorFilter: const ColorFilter.mode(
          HomeColors.primary,
          BlendMode.srcIn,
        ),
        placeholderBuilder: (_) =>
            Icon(fallback, size: iconSize, color: HomeColors.primary),
      ),
    );
  }
}

class _LinkifiedText extends StatelessWidget {
  final String text;
  const _LinkifiedText(this.text);

  static final _url = RegExp(r'https?://[^\s]+');

  @override
  Widget build(BuildContext context) {
    const base = TextStyle(
      fontFamily: _font,
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 20 / 16,
      letterSpacing: 0,
      color: HomeColors.body,
    );

    final spans = <InlineSpan>[];
    var last = 0;
    for (final m in _url.allMatches(text)) {
      if (m.start > last) {
        spans.add(TextSpan(text: text.substring(last, m.start)));
      }
      spans.add(
        TextSpan(
          text: m.group(0),
          style: const TextStyle(
            color: HomeColors.link,
            decoration: TextDecoration.underline,
            decorationColor: HomeColors.link,
          ),
        ),
      );
      last = m.end;
    }
    if (last < text.length) spans.add(TextSpan(text: text.substring(last)));

    return Text.rich(TextSpan(style: base, children: spans));
  }
}

class _PostMedia extends StatelessWidget {
  final List<PostFile> files;
  const _PostMedia({required this.files});

  static const _gap = 6.0;
  static const _radius = 14.0;

  @override
  Widget build(BuildContext context) {
    final single = files.length == 1;
    final shown = files.take(3).toList();
    final extra = files.length - shown.length;

    return SizedBox(
      height: single ? 260.0 : 200.0,
      child: Row(
        children: [
          for (var i = 0; i < shown.length; i++) ...[
            if (i > 0) const SizedBox(width: _gap),
            Expanded(
              child: _MediaTile(
                file: shown[i],
                overlayCount: (i == shown.length - 1 && extra > 0) ? extra : 0,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/*
class _PostMedia extends StatelessWidget {
  final List<PostFile> files;
  const _PostMedia({required this.files});

  static const _gap = 6.0;
  static const _radius = 14.0;

  @override
  Widget build(BuildContext context) {
    final single = files.length == 1;
    final shown = files.take(3).toList();
    final extra = files.length - shown.length;
    final height = single ? 260.0 : 200.0;

    return SizedBox(
      height: height,
      child: Stack(
        children: [
          Row(
            children: [
              for (var i = 0; i < shown.length; i++) ...[
                if (i > 0) const SizedBox(width: _gap),
                Expanded(
                  child: _MediaTile(
                    file: shown[i],
                    overlayCount: (i == shown.length - 1 && extra > 0)
                        ? extra
                        : 0,
                  ),
                ),
              ],
            ],
          ),
          if (!single)
            Positioned(
              right: 8,
              bottom: 8,
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: HomeColors.primary,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x40000000),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.collections_rounded,
                  size: 18,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
*/
class _MediaTile extends StatelessWidget {
  final PostFile file;
  final int overlayCount;
  const _MediaTile({required this.file, this.overlayCount = 0});

  @override
  Widget build(BuildContext context) {
    const placeholder = ColoredBox(
      color: HomeColors.mediaBg,
      child: Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          color: HomeColors.muted,
        ),
      ),
    );
    const loadingPlaceholder = ColoredBox(
      color: HomeColors.mediaBg,
      child: Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final cacheWidth =
            (constraints.maxWidth * MediaQuery.devicePixelRatioOf(context))
                .ceil()
                .clamp(1, 1600)
                .toInt();

        return ClipRRect(
          borderRadius: BorderRadius.circular(_PostMedia._radius),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (file.previewUrl.isEmpty)
                placeholder
              else
                Image.network(
                  file.previewUrl,
                  fit: BoxFit.cover,
                  cacheWidth: cacheWidth,
                  frameBuilder: (_, child, frame, loadedSynchronously) =>
                      loadedSynchronously || frame != null
                      ? child
                      : loadingPlaceholder,
                  errorBuilder: (_, __, ___) => placeholder,
                ),
              if (file.isVideo)
                const Center(
                  child: CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.black54,
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
              if (overlayCount > 0)
                Container(
                  color: Colors.black45,
                  alignment: Alignment.center,
                  child: Text(
                    '+$overlayCount',
                    style: const TextStyle(
                      fontFamily: _font,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/*import 'package:flutter/material.dart';
import '../models/post_model.dart';

class PostCard extends StatelessWidget {
  final PostModel post;
  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = post.plainContent;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (post.repostedBy != null) _repostBanner(theme),
          _header(theme),
          if (post.postType?.slug == 'conscious-act') _consciousActChip(theme),
          if (text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
              child: Text(text, style: theme.textTheme.bodyMedium),
            ),
          if (post.location != null) _locationRow(theme),
          if (post.files.isNotEmpty) _media(),
          _footer(theme),
        ],
      ),
    );
  }

  Widget _repostBanner(ThemeData theme) => Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
        child: Row(
          children: [
            Icon(Icons.repeat, size: 16, color: theme.colorScheme.outline),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                '${post.repostedBy!.fullName.isNotEmpty ? post.repostedBy!.fullName : post.repostedBy!.username} reposted',
                style: theme.textTheme.labelMedium
                    ?.copyWith(color: theme.colorScheme.outline),
              ),
            ),
          ],
        ),
      );

  Widget _header(ThemeData theme) => ListTile(
        leading: _Avatar(url: post.profile.profilePicture, name: post.profile.fullName),
        title: Text(
          post.profile.fullName.isNotEmpty ? post.profile.fullName : post.user.username,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          [
            '@${post.user.username}',
            if (post.createdAt != null) _timeAgo(post.createdAt!),
            if (post.feeling != null) 'feeling ${post.feeling}',
          ].join(' · '),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: post.ifFollowing
            ? Icon(Icons.check_circle, size: 18, color: theme.colorScheme.primary)
            : null,
      );

  Widget _consciousActChip(ThemeData theme) => Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
        child: Wrap(
          spacing: 6,
          children: [
            Chip(
              avatar: const Icon(Icons.spa, size: 16),
              label: Text(post.postType!.name),
              visualDensity: VisualDensity.compact,
            ),
            if (post.categoryName != null)
              Chip(
                label: Text(post.categoryName!),
                visualDensity: VisualDensity.compact,
              ),
            if (post.subCategoryName != null)
              Chip(
                label: Text(post.subCategoryName!),
                visualDensity: VisualDensity.compact,
              ),
          ],
        ),
      );

  Widget _locationRow(ThemeData theme) => Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
        child: Row(
          children: [
            Icon(Icons.place, size: 16, color: theme.colorScheme.primary),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                post.location!.name,
                style: theme.textTheme.labelMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );

  Widget _media() {
    if (post.files.length == 1) {
      return _MediaTile(file: post.files.first, height: 260);
    }
    return SizedBox(
      height: 260,
      child: PageView.builder(
        itemCount: post.files.length,
        itemBuilder: (_, i) => Padding(
          padding: const EdgeInsets.only(right: 2),
          child: _MediaTile(file: post.files[i], height: 260),
        ),
      ),
    );
  }

  Widget _footer(ThemeData theme) => Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: Row(
          children: [
            _stat(post.isLiked ? Icons.favorite : Icons.favorite_border,
                post.likesCount, post.isLiked ? Colors.red : null),
            const SizedBox(width: 20),
            _stat(Icons.mode_comment_outlined, post.totalCommentCount, null),
            const SizedBox(width: 20),
            _stat(Icons.repeat, post.repostCount, null),
            const SizedBox(width: 20),
            _stat(Icons.share_outlined, post.shareCount, null),
            const Spacer(),
            Icon(post.isSaved ? Icons.bookmark : Icons.bookmark_border, size: 20),
          ],
        ),
      );

  Widget _stat(IconData icon, int count, Color? color) => Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 4),
          Text('$count'),
        ],
      );

  static String _timeAgo(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${d.day}/${d.month}/${d.year}';
  }
}

class _Avatar extends StatelessWidget {
  final String? url;
  final String name;
  const _Avatar({this.url, required this.name});

  @override
  Widget build(BuildContext context) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final fallback = CircleAvatar(child: Text(initial));
    if (url == null || url!.isEmpty) return fallback;

    return ClipOval(
      child: Image.network(
        url!,
        width: 40,
        height: 40,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => fallback,
      ),
    );
  }
}

class _MediaTile extends StatelessWidget {
  final PostFile file;
  final double height;
  const _MediaTile({required this.file, required this.height});

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      height: height,
      width: double.infinity,
      color: Colors.black12,
      child: const Icon(Icons.image_not_supported_outlined),
    );

    return Stack(
      alignment: Alignment.center,
      children: [
        if (file.previewUrl.isEmpty)
          placeholder
        else
          Image.network(
            file.previewUrl,
            height: height,
            width: double.infinity,
            fit: BoxFit.cover,
            loadingBuilder: (_, child, progress) => progress == null
                ? child
                : Container(
                    height: height,
                    color: Colors.black12,
                    alignment: Alignment.center,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  ),
            errorBuilder: (_, __, ___) => placeholder,
          ),
        if (file.isVideo)
          const CircleAvatar(
            radius: 28,
            backgroundColor: Colors.black54,
            child: Icon(Icons.play_arrow, color: Colors.white, size: 36),
          ),
      ],
    );
  }
}*/
