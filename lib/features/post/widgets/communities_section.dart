import 'package:flutter/material.dart';
import 'package:simple_app/core/config/app_colors.dart';

const _font = 'Roboto';

@immutable
class CommunityItem {
  final String name;
  final String members;
  final String postsPerDay;
  final String? imageUrl;

  const CommunityItem({
    required this.name,
    required this.members,
    required this.postsPerDay,
    this.imageUrl,
  });
}


class CommunitiesSection extends StatefulWidget {
  final List<CommunityItem> items;
  final VoidCallback? onSeeAll;
  final ValueChanged<CommunityItem>? onJoin;

  const CommunitiesSection({
    super.key,
    this.items = defaultCommunities,
    this.onSeeAll,
    this.onJoin,
  });

  static const defaultCommunities = <CommunityItem>[
    CommunityItem(
      name: 'InnerPeace',
      members: '274k members',
      postsPerDay: '10 posts a day',
      imageUrl:
          'https://liforme.com/cdn/shop/articles/0004_Tree_Pose_-_Vrksasana_08_India_Mindful_Garden_3598a015-0c39-4cbc-9edb-3189788507e8.jpg?v=1778794268',
    ),
    CommunityItem(
      name: 'Sacred Space',
      members: '62k members',
      postsPerDay: '6 posts a day',
      imageUrl:
          'https://img.magnific.com/free-vector/gold-mandala-ornament-design-with-circle-middle-isolated-dark-background_8130-2566.jpg?semt=ais_hybrid&w=740&q=80',
    ),
    CommunityItem(
      name: 'Yoga Flow',
      members: '120k members',
      postsPerDay: '14 posts a day',
      imageUrl:
          'https://img.magnific.com/premium-photo/trishul-lord-shiva-maha-shivratri_723055-6008.jpg?semt=ais_hybrid&w=740&q=80',
    ),
  ];

  @override
  State<CommunitiesSection> createState() => _CommunitiesSectionState();
}

class _CommunitiesSectionState extends State<CommunitiesSection> {
  late final List<CommunityItem> _items = [...widget.items];
  final Set<String> _joined = {};

  static const _cardWidth = 300.0;

  @override
  Widget build(BuildContext context) {
    if (_items.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Expanded(
                  child: Text(
                    'Communities you might like',
                    style: TextStyle(
                      fontFamily: _font,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: HomeColors.name,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: widget.onSeeAll,
                  behavior: HitTestBehavior.opaque,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 6),
                    child: Text(
                      'See all',
                      style: TextStyle(
                        fontFamily: _font,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: HomeColors.link,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 226,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _items.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, i) {
                final item = _items[i];
                return _CommunityCard(
                  key: ValueKey(item.name),
                  width: _cardWidth,
                  item: item,
                  joined: _joined.contains(item.name),
                  onDismiss: () => setState(() => _items.removeAt(i)),
                  onJoin: () {
                    setState(() {
                      if (!_joined.add(item.name)) _joined.remove(item.name);
                    });
                    widget.onJoin?.call(item);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CommunityCard extends StatelessWidget {
  final double width;
  final CommunityItem item;
  final bool joined;
  final VoidCallback onDismiss;
  final VoidCallback onJoin;

  const _CommunityCard({
    super.key,
    required this.width,
    required this.item,
    required this.joined,
    required this.onDismiss,
    required this.onJoin,
  });

  static const _joinBlue = Color(0xFF4A5BF5);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
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
          
          SizedBox(
            height: 142,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: _cover(),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: onDismiss,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0x80FFFFFF),
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        size: 13,
                        color: Color(0xFF5A6482),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                const Icon(
                  Icons.groups_2_rounded,
                  size: 22,
                  color: HomeColors.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: _font,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: HomeColors.name,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        '${item.members}  .  ${item.postsPerDay}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: _font,
                          fontSize: 9,
                          color: HomeColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Material(
                  color: joined ? HomeColors.circleBg : _joinBlue,
                  borderRadius: BorderRadius.circular(20),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: onJoin,
                    child: Container(
                      height: 30,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      alignment: Alignment.center,
                      child: Text(
                        joined ? 'Joined' : 'Join group',
                        style: TextStyle(
                          fontFamily: _font,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: joined ? HomeColors.primary : Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _cover() {
    const fallback = DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF7FD6C8), Color(0xFF2F8F9D)],
        ),
      ),
    );
    final url = item.imageUrl;
    if (url == null || url.isEmpty) return fallback;
    return Image.network(
      url,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      cacheWidth: 700,
      loadingBuilder: (_, child, p) => p == null ? child : fallback,
      errorBuilder: (_, __, ___) => fallback,
    );
  }
}