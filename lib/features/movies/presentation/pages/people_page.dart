// Path: lib/features/movies/presentation/pages/people_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants.dart';
import '../../../../core/router.dart';
import '../providers/movie_providers.dart';
import '../../data/models/person.dart';

/// Màn hình hiển thị danh sách người nổi tiếng (Popular People)
class PeoplePage extends ConsumerWidget {
  const PeoplePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final peopleAsync = ref.watch(popularPeopleProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Popular People"),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.people_alt_rounded),
          ),
        ],
      ),
      body: peopleAsync.when(
        data: (people) => GridView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: people.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisExtent: 260,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemBuilder: (_, i) => _PersonCard(person: people[i]),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Error: $e")),
      ),
    );
  }
}

class _PersonCard extends StatelessWidget {
  const _PersonCard({required this.person});

  final Person person;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final avatar = person.profilePath.isEmpty
        ? null
        : "${AppConstants.imageBaseUrl}${person.profilePath}";

    return InkWell(
      onTap: () => Navigator.pushNamed(
        context,
        AppRouter.personDetail,
        arguments: person.id,
      ),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        elevation: 1.2,
        child: Column(
          children: [
            const SizedBox(height: 10),
            CircleAvatar(
              radius: 46,
              backgroundColor: Colors.black12,
              backgroundImage: avatar == null ? null : NetworkImage(avatar),
              child:
                  avatar == null ? const Icon(Icons.person_rounded, size: 38) : null,
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                person.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              person.knownForDepartment,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.local_fire_department_rounded,
                      color: Colors.orange, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    person.popularity.toStringAsFixed(1),
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
