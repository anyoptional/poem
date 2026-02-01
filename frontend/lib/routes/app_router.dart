import 'package:go_router/go_router.dart';
import 'package:poem/models/poem.dart';
import 'package:poem/screens/add_poem_screen.dart';
import 'package:poem/screens/edit_poem_screen.dart';
import 'package:poem/screens/list_poem_screen.dart';
import 'package:poem/screens/view_poem_screen.dart';

class AppRoutes {
  static const String listPoem = 'listPoem';
  static const String viewPoem = 'viewPoem';
  static const String addPoem = 'addPoem';
  static const String editPoem = 'editPoem';

  static const String _listPoemPath = '/';
  static const String _viewPoemPath = '/poem/:id';
  static const String _addPoemPath = '/add';
  static const String _editPoemPath = '/edit';
}

final goRouter = GoRouter(
  initialLocation: AppRoutes._listPoemPath,
  routes: [
    GoRoute(
      name: AppRoutes.listPoem,
      path: AppRoutes._listPoemPath,
      builder: (context, state) => const ListPoemScreen(),
    ),
    GoRoute(
      name: AppRoutes.viewPoem,
      path: AppRoutes._viewPoemPath,
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        final poem = state.extra as Poem?;
        return ViewPoemScreen(poemId: int.parse(id), poem: poem);
      },
    ),
    GoRoute(
      name: AppRoutes.editPoem,
      path: AppRoutes._editPoemPath,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return EditPoemScreen(poem: extra['poem'], part: extra['part']);
      },
    ),
    GoRoute(
      name: AppRoutes.addPoem,
      path: AppRoutes._addPoemPath,
      builder: (context, state) => const AddPoemScreen(),
    ),
  ],
);
