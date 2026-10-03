import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:simple_app/core/config/app_colors.dart';

class HomeHeader extends StatelessWidget {
  final String userName;
  final VoidCallback? onSearchTap;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onChatTap;
  final VoidCallback? onPromptTap;
  final VoidCallback? onAskAiTap;
  final VoidCallback? onCreatePostTap;
  final VoidCallback? onLiveVideoTap;

  
  final ValueChanged<String>? onPromptChanged;


  final ValueChanged<String>? onPromptSubmitted;

  const HomeHeader({
    super.key,
    this.userName = '',
    this.onSearchTap,
    this.onNotificationTap,
    this.onChatTap,
    this.onPromptTap,
    this.onAskAiTap,
    this.onCreatePostTap,
    this.onLiveVideoTap,
    this.onPromptChanged,
    this.onPromptSubmitted,
  });

  static const _searchBarHeight = 52.0;
  static const _headerRowTop = 12.0;
  static const _headerRowHeight = 40.0;
  static const _gapRowToSearch = 14.0;
  static const _gapSearchToActions = 20.0;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    final searchTop =
        topInset + _headerRowTop + _headerRowHeight + _gapRowToSearch;
    final gradientHeight = searchTop + _searchBarHeight / 2;
    final hint = userName.isEmpty
        ? 'What would you like to do?'
        : 'What would you like to do $userName?';

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Column(
          children: [
            _GradientTop(
              height: gradientHeight,
              topInset: topInset,
              onSearchTap: onSearchTap,
              onNotificationTap: onNotificationTap,
              onChatTap: onChatTap,
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(
                16,
                _searchBarHeight / 2 + _gapSearchToActions,
                16,
                18,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(32),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      svgAsset: 'assets/create_post.svg',
                      label: 'Create a Post',
                      onTap: onCreatePostTap,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ActionButton(
                      svgAsset: 'assets/live_video.svg',
                      label: 'Live Video',
                      onTap: onLiveVideoTap,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Positioned(
          left: 16,
          right: 16,
          top: searchTop,
          child: _PromptBar(
            height: _searchBarHeight,
            hint: hint,
            onTap: onPromptTap,
            onAskAiTap: onAskAiTap,
            onChanged: onPromptChanged,
            onSubmitted: onPromptSubmitted,
          ),
        ),
      ],
    );
  }
}

class _GradientTop extends StatelessWidget {
  final double height;
  final double topInset;
  final VoidCallback? onSearchTap;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onChatTap;

  const _GradientTop({
    required this.height,
    required this.topInset,
    this.onSearchTap,
    this.onNotificationTap,
    this.onChatTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [HomeColors.gradientStart, HomeColors.gradientEnd],
        ),
      ),
      child: CustomPaint(
        painter: const _DiagonalShinePainter(),
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, topInset + 12, 16, 0),
          child: Align(
            alignment: Alignment.topCenter,
            child: Row(
              children: [
                SvgPicture.asset('assets/logo.svg', height: 30),
                const Spacer(),
                _CircleIconButton(
                  svgAsset: 'assets/search.svg',
                  label: 'Search',
                  onTap: onSearchTap,
                ),
                const SizedBox(width: 10),
                _CircleIconButton(
                  svgAsset: 'assets/notification.svg',
                  label: 'Notifications',
                  onTap: onNotificationTap,
                ),
                const SizedBox(width: 10),
                _CircleIconButton(
                  svgAsset: 'assets/chat.svg',
                  label: 'Chat',
                  onTap: onChatTap,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DiagonalShinePainter extends CustomPainter {
  const _DiagonalShinePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width * 0.22, 0)
      ..lineTo(size.width * 0.45, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = const Color(0x14FFFFFF));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CircleIconButton extends StatelessWidget {
  final String svgAsset;
  final String label;
  final VoidCallback? onTap;

  const _CircleIconButton({
    required this.svgAsset,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: HomeColors.circleButtonBg,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            width: 40,
            height: 40,
            child: Center(
              child: SvgPicture.asset(svgAsset, width: 20, height: 20),
            ),
          ),
        ),
      ),
    );
  }
}


class _PromptBar extends StatefulWidget {
  final double height;
  final String hint;
  final VoidCallback? onTap;
  final VoidCallback? onAskAiTap;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  const _PromptBar({
    required this.height,
    required this.hint,
    this.onTap,
    this.onAskAiTap,
    this.onChanged,
    this.onSubmitted,
  });

  @override
  State<_PromptBar> createState() => _PromptBarState();
}

class _PromptBarState extends State<_PromptBar> {
  final _controller = TextEditingController();
  final _focus = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(widget.height / 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x26000000),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _focus.requestFocus(),
            child: SvgPicture.asset(
              'assets/search_picimg.svg',
              width: 30,
              height: 30,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focus,
              onTap: widget.onTap,
              onChanged: widget.onChanged,
              onSubmitted: widget.onSubmitted,
              textInputAction: TextInputAction.search,
              maxLines: 1,
              cursorColor: HomeColors.primary,
              style: const TextStyle(
                fontSize: 13.5,
                color: HomeColors.actionLabel,
              ),
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                hintText: widget.hint,
                hintMaxLines: 1,
                hintStyle: const TextStyle(
                  fontSize: 13.5,
                  color: HomeColors.hint,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onAskAiTap,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Ariven AI',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: HomeColors.primary,
                  ),
                ),
                const SizedBox(width: 6),
                SvgPicture.asset(
                  'assets/arriven_ai.svg',
                  width: 22,
                  height: 22,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String svgAsset;
  final String label;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.svgAsset,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: HomeColors.actionButtonBg,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 48,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(svgAsset, width: 20, height: 20),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    color: HomeColors.actionLabel,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


/*import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:simple_app/core/config/app_colors.dart';

class HomeHeader extends StatelessWidget {
  final String userName;
  final VoidCallback? onSearchTap;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onChatTap;
  final VoidCallback? onPromptTap;
  final VoidCallback? onAskAiTap;
  final VoidCallback? onCreatePostTap;
  final VoidCallback? onLiveVideoTap;

  const HomeHeader({
    super.key,
    this.userName = '',
    this.onSearchTap,
    this.onNotificationTap,
    this.onChatTap,
    this.onPromptTap,
    this.onAskAiTap,
    this.onCreatePostTap,
    this.onLiveVideoTap,
  });

  static const _searchBarHeight = 52.0;
  static const _headerRowTop = 12.0;
  static const _headerRowHeight = 40.0;
  static const _gapRowToSearch = 14.0;
  static const _gapSearchToActions = 20.0;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    final searchTop =
        topInset + _headerRowTop + _headerRowHeight + _gapRowToSearch;
    final gradientHeight = searchTop + _searchBarHeight / 2;
    final hint = userName.isEmpty
        ? 'What would you like to do?'
        : 'What would you like to do $userName?';

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Column(
          children: [
            _GradientTop(
              height: gradientHeight,
              topInset: topInset,
              onSearchTap: onSearchTap,
              onNotificationTap: onNotificationTap,
              onChatTap: onChatTap,
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(
                16,
                _searchBarHeight / 2 + _gapSearchToActions,
                16,
                18,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(32),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      svgAsset: 'assets/create_post.svg',
                      label: 'Create a Post',
                      onTap: onCreatePostTap,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ActionButton(
                      svgAsset: 'assets/live_video.svg',
                      label: 'Live Video',
                      onTap: onLiveVideoTap,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Positioned(
          left: 16,
          right: 16,
          top: searchTop,
          child: _PromptBar(
            height: _searchBarHeight,
            hint: hint,
            onTap: onPromptTap,
            onAskAiTap: onAskAiTap,
          ),
        ),
      ],
    );
  }
}

class _GradientTop extends StatelessWidget {
  final double height;
  final double topInset;
  final VoidCallback? onSearchTap;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onChatTap;

  const _GradientTop({
    required this.height,
    required this.topInset,
    this.onSearchTap,
    this.onNotificationTap,
    this.onChatTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,

      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [HomeColors.gradientStart, HomeColors.gradientEnd],
        ),
      ),
      child: CustomPaint(
        painter: const _DiagonalShinePainter(),
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, topInset + 12, 16, 0),
          child: Align(
            alignment: Alignment.topCenter,
            child: Row(
              children: [
                SvgPicture.asset('assets/logo.svg', height: 30),
                const Spacer(),
                _CircleIconButton(
                  svgAsset: 'assets/search.svg',
                  label: 'Search',
                  onTap: onSearchTap,
                ),
                const SizedBox(width: 10),
                _CircleIconButton(
                  svgAsset: 'assets/notification.svg',
                  label: 'Notifications',
                  onTap: onNotificationTap,
                ),
                const SizedBox(width: 10),
                _CircleIconButton(
                  svgAsset: 'assets/chat.svg',
                  label: 'Chat',
                  onTap: onChatTap,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DiagonalShinePainter extends CustomPainter {
  const _DiagonalShinePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width * 0.22, 0)
      ..lineTo(size.width * 0.45, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = const Color(0x14FFFFFF));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CircleIconButton extends StatelessWidget {
  final String svgAsset;
  final String label;
  final VoidCallback? onTap;

  const _CircleIconButton({
    required this.svgAsset,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: HomeColors.circleButtonBg,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            width: 40,
            height: 40,
            child: Center(
              child: SvgPicture.asset(svgAsset, width: 20, height: 20),
            ),
          ),
        ),
      ),
    );
  }
}

class _PromptBar extends StatelessWidget {
  final double height;
  final String hint;
  final VoidCallback? onTap;
  final VoidCallback? onAskAiTap;

  const _PromptBar({
    required this.height,
    required this.hint,
    this.onTap,
    this.onAskAiTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(height / 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x26000000),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(height / 2),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                SvgPicture.asset(
                  'ssets/search_picimg.svg',
                  width: 30,
                  height: 30,
                ),

                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    hint,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13.5,
                      color: HomeColors.hint,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onAskAiTap,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Ariven AI',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: HomeColors.primary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      SvgPicture.asset(
                        'assets/arriven_ai.svg',
                        width: 22,
                        height: 22,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String svgAsset;
  final String label;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.svgAsset,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: HomeColors.actionButtonBg,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 48,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(svgAsset, width: 20, height: 20),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    color: HomeColors.actionLabel,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
*/