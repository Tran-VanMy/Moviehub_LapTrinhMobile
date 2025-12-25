// Path: lib/features/movies/presentation/widgets/cast_list.dart
import 'package:flutter/material.dart';
import '../../../../core/constants.dart';
import '../../../../core/router.dart';
import '../../data/models/cast.dart';

class CastList extends StatefulWidget {
  const CastList({super.key, required this.cast});
  final List<Cast> cast;

  @override
  State<CastList> createState() => _CastListState();
}

class _CastListState extends State<CastList> {
  final ScrollController _scrollController = ScrollController();

  void _scrollBy(double offset) {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final target = (_scrollController.offset + offset).clamp(
      0.0,
      maxScroll.toDouble(),
    );
    _scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.cast.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Cast",
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 130,
          child: Stack(
            alignment: Alignment.center,
            children: [
              ListView.separated(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                itemBuilder: (_, i) {
                  final c = widget.cast[i];
                  final avatar = c.profilePath.isEmpty
                      ? null
                      : "${AppConstants.imageBaseUrl}${c.profilePath}";
                  return SizedBox(
                    width: 90,
                    child: InkWell(
                      onTap: () {
                        // Mở trang chi tiết người nổi tiếng
                        Navigator.pushNamed(
                          context,
                          AppRouter.personDetail,
                          arguments: c.id,
                        );
                      },
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 32,
                            backgroundImage:
                                avatar == null ? null : NetworkImage(avatar),
                            backgroundColor: Colors.black12,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            c.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            c.character,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemCount: widget.cast.length,
              ),

              // Nút mũi tên trái
              Positioned(
                left: 0,
                child: _CastArrowButton(
                  icon: Icons.chevron_left_rounded,
                  onTap: () => _scrollBy(-180),
                ),
              ),

              // Nút mũi tên phải
              Positioned(
                right: 0,
                child: _CastArrowButton(
                  icon: Icons.chevron_right_rounded,
                  onTap: () => _scrollBy(180),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CastArrowButton extends StatelessWidget {
  const _CastArrowButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.35),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(
            icon, // dùng icon truyền vào -> trái / phải hiển thị đúng chiều
            size: 22,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
