import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

abstract class AppRoutingBase {
  GoRouter getRoutes({List<NavigatorObserver>? observers});
}
