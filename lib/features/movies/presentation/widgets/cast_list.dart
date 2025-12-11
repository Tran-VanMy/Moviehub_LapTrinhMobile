// Path: lib/features/movies/presentation/widgets/cast_list.dart
import 'package:flutter/material.dart';
import '../../../../core/constants.dart';
import '../../data/models/cast.dart';

class CastList extends StatelessWidget {
  const CastList({super.key, required this.cast});
  final List<Cast> cast;

  @override
  Widget build(BuildContext context) {
    if (cast.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Cast", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
        const SizedBox(height: 8),
        SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemBuilder: (_, i) {
              final c = cast[i];
              final avatar = c.profilePath.isEmpty ? null : "${AppConstants.imageBaseUrl}${c.profilePath}";
              return SizedBox(
                width: 90,
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundImage: avatar == null ? null : NetworkImage(avatar),
                      backgroundColor: Colors.black12,
                    ),
                    const SizedBox(height: 6),
                    Text(c.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text(c.character, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11)),
                  ],
                ),
              );
            },
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemCount: cast.length,
          ),
        )
      ],
    );
  }
}
