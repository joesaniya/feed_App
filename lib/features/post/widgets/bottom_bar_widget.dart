import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

@immutable
class BottomNavItem {
  final String svgAsset;

  
  final String label;

 
  final bool isAvatar;

  const BottomNavItem({
    required this.svgAsset,
    required this.label,
    this.isAvatar = false,
  });
}
class AppBottomNavBar extends StatelessWidget {
  final List<BottomNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final String? profileImageUrl;

  final double? iconSize;

  final Color? backgroundColor;
  final Color? activeColor;
  final Color? inactiveColor;

  const AppBottomNavBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.profileImageUrl,
    this.iconSize,           
    this.backgroundColor,
    this.activeColor,
    this.inactiveColor,
  })  : assert(items.length >= 2, 'Need at least 2 items'),
        assert(currentIndex >= 0 && currentIndex < items.length);

/*class AppBottomNavBar extends StatelessWidget {
  final List<BottomNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final String? profileImageUrl;

  final Color? backgroundColor;
  final Color? activeColor;
  final Color? inactiveColor;

  const AppBottomNavBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.profileImageUrl,
    this.backgroundColor,
    this.activeColor,
    this.inactiveColor,
  })  : assert(items.length >= 2, 'Need at least 2 items'),
        assert(currentIndex >= 0 && currentIndex < items.length);*/

  static const _defaultBg = Color(0xFFF3F6F8);
  static const _defaultActive = Color(0xFF5B5BF7);
  static const _defaultInactive = Color(0xFFB4BAC6);

  @override
  Widget build(BuildContext context) {
    final active = activeColor ?? _defaultActive;
    final inactive = inactiveColor ?? _defaultInactive;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor ?? _defaultBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 16,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {

            final slot = constraints.maxWidth / items.length;
final size = iconSize ?? (slot * 0.38).clamp(22.0, 32.0);

            return SizedBox(
              height: 72,
              child: Row(
                children: [
                  for (var i = 0; i < items.length; i++)
                    Expanded(
                      child: _NavButton(
                        key: ValueKey(items[i].svgAsset),
                        item: items[i],
                        selected: i == currentIndex,
                        iconSize: size,
                        activeColor: active,
                        inactiveColor: inactive,
                        profileImageUrl: profileImageUrl,
                        onTap: () => onTap(i),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final BottomNavItem item;
  final bool selected;
  final double iconSize;
  final Color activeColor;
  final Color inactiveColor;
  final String? profileImageUrl;
  final VoidCallback onTap;

  const _NavButton({
    super.key,
    required this.item,
    required this.selected,
    required this.iconSize,
    required this.activeColor,
    required this.inactiveColor,
    required this.onTap,
    this.profileImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? activeColor : inactiveColor;

    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      child: InkResponse(
        onTap: selected ? null : onTap,
        radius: 32,
        child: RepaintBoundary(
          child: Center(
            child: item.isAvatar
                ? _Avatar(
                    size: iconSize + 10,
                    url: profileImageUrl,
                    fallbackSvg: item.svgAsset,
                    ringColor: selected ? activeColor : inactiveColor,
                  )
                : SvgPicture.asset(
                    item.svgAsset,
                    width: iconSize,
                    height: iconSize,
                    colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                  ),
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final double size;
  final String? url;
  final String fallbackSvg;
  final Color ringColor;

  const _Avatar({
    required this.size,
    required this.fallbackSvg,
    required this.ringColor,
    this.url,
  });

  @override
  Widget build(BuildContext context) {
    final fallback = SvgPicture.asset(fallbackSvg, fit: BoxFit.cover);
    final hasUrl = url != null && url!.isNotEmpty;

    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: ringColor, width: 2),
      ),
      child: ClipOval(
        child: hasUrl
            ? Image.network(
                url!,
                fit: BoxFit.cover,
                cacheWidth: (size * 3).round(), 
                errorBuilder: (_, __, ___) => fallback,
              )
            : fallback,
      ),
    );
  }
}