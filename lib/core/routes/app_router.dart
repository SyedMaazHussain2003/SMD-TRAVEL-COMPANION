import 'package:go_router/go_router.dart';
import '../../domain/entities/place.dart';
import '../../data/models/place_model.dart';
import '../../presentation/pages/home_page.dart';
import '../../presentation/pages/detail_page.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/detail',
        name: 'detail',
        builder: (context, state) {
          final extra = state.extra;
          if (extra is Place) {
            return DetailPage(place: extra);
          } else if (extra is Map<String, dynamic>) {
            return DetailPage(place: PlaceModel.fromJson(extra));
          }
          // If something goes wrong, redirect home instead of crashing
          return const HomePage();
        },
      ),
    ],
  );
}
