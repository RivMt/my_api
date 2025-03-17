import 'package:flutter/material.dart';
import 'package:my_api/core/log.dart';
import 'package:my_api/core/widget/unknown_page.dart';

const String _tag = "Navigator";

class RoutePath {

  static final RoutePath home = RoutePath("");

  static final RoutePath login = RoutePath("login");

  static final RoutePath register = RoutePath("register");

  static final RoutePath unknown = RoutePath("404");

  RoutePath(String path, [this.uuid, this.queries, this.anchor]) {
    this.path = path.replaceAll("/", "");
  }

  RoutePath.parse(String? name) {
    final uri = Uri.parse(name ?? "");
    switch(uri.pathSegments.length) {
      case 0:
        path = "";
        break;
      case 1:
        path = uri.pathSegments[0];
        break;
      case 2:
        path = uri.pathSegments[0];
        uuid = uri.pathSegments[1];
        queries = uri.queryParameters;
        anchor = uri.fragment;
    }
  }

  late String path;

  late String? uuid;

  bool get isDetails => uuid != null;

  late Map<String, dynamic>? queries;

  late String? anchor;

  String get location {
    final StringBuffer buffer = StringBuffer();
    // Primary path
    buffer.write("/");
    buffer.write(path);
    // Secondary path
    if (uuid != null) {
      buffer.write("/");
      buffer.write(uuid);
    }
    // Query string
    if (queries != null) {
      buffer.write("?");
      buffer.write(List.generate(queries!.keys.length, (index) {
        final String key = queries!.keys.toList(growable: false)[index];
        return "$key=${queries![key]}";
      }).join("&"));
    }
    // Anchor
    if (anchor != null) {
      buffer.write("#$anchor");
    }
    return buffer.toString();
  }

  RoutePath details(String uuid) => RoutePath(path, uuid);

  RoutePath extend({
    int? pid,
    Map<String, dynamic>? queries,
    String? anchor,
  }) => RoutePath(path, uuid, queries, anchor);

  RoutePath previous() {
    // Anchor
    if (anchor != null) {
      return RoutePath(path, uuid, queries);
    }
    // Secondary Path
    if (uuid != null) {
      return RoutePath(path, null, queries);
    }
    // Home
    return RoutePath.home;
  }

  @override
  String toString() => location;

  @override
  bool operator ==(Object other) {
    if (other is RoutePath) {
      return location == other.location;
    }
    return super==(other);
  }

  @override
  int get hashCode => location.hashCode;
}

class RouteParser extends RouteInformationParser<RoutePath> {

  List<RoutePath> get d1 => [
    RoutePath.login,
    RoutePath.register,
  ];

  List<RoutePath> get d2 => [];

  @override
  Future<RoutePath> parseRouteInformation(RouteInformation routeInformation) async {
    final uri = Uri.parse(routeInformation.location ?? "");
    Log.v(_tag, "Parsing uri: ${routeInformation.location}");
    // Home
    if (uri.pathSegments.isEmpty) {
      return RoutePath.home;
    }
    // Depth 1
    if (uri.pathSegments.length == 1) {
      // TODO: Convert to binary search
      for(RoutePath route in d1) {
        if (uri.pathSegments[0] == route.path) {
          return route.extend(
            queries: uri.queryParameters,
            anchor: uri.fragment,
          );
        }
      }
    }
    // Depth 2
    if (uri.pathSegments.length == 2) {
      final int? pid = int.tryParse(uri.pathSegments[1]);
      if (pid != null) {
        for (RoutePath route in d2) {
          if (uri.pathSegments[0] == route.path) {
            return route.extend(
              pid: pid,
              queries: uri.queryParameters,
              anchor: uri.fragment,
            );
          }
        }
      }
    }
    // 404
    return RoutePath.unknown;
  }

  @override
  RouteInformation restoreRouteInformation(RoutePath configuration) {
    return RouteInformation(location: configuration.location);
  }
}

class CoreRouterDelegate extends RouterDelegate<RoutePath> with ChangeNotifier, PopNavigatorRouterDelegateMixin {

  CoreRouterDelegate() : navigatorKey = GlobalKey<NavigatorState>();

  @override
  final GlobalKey<NavigatorState> navigatorKey;

  @override
  RoutePath currentConfiguration = RoutePath.home;

  @override
  Widget build(BuildContext context) {
    final pages = this.pages;
    // Append unknown page if path is equal to RoutePath.unknown
    if (currentConfiguration.path == RoutePath.unknown.path) {
      pages.add(MaterialPage(
        key: ValueKey(RoutePath.unknown.location),
        child: const UnknownPage(),
      ));
    }
    return Navigator(
      key: navigatorKey,
      pages: pages,
      onPopPage: onPopPage,
    );
  }

  @override
  Future<void> setNewRoutePath(RoutePath configuration) async {
    currentConfiguration = configuration;
    Log.v(_tag, "Move to ${configuration.location}");
    notifyListeners();
    return;
  }

  @override
  Future<void> setInitialRoutePath(RoutePath configuration) async {
    currentConfiguration = configuration;
    Log.v(_tag, "Set initial route to: ${configuration.location}");
    return;
  }

  Widget get home => throw UnimplementedError("home widget does not defined");

  List<Page> get pages {
    final List<Page> pages = [
      MaterialPage(
        key: ValueKey(RoutePath.home.location),
        child: home,
      ),
    ];
    final finds = findPage();
    if (finds.isNotEmpty) {
      pages.addAll(finds);
    }
    return pages;
  }

  List<Page> findPage() {
    Log.v(_tag, "Find page about: ${currentConfiguration.location}");
    final List<Page> pages = [];
    return pages;
  }

  bool onPopPage(Route route, dynamic result) {
    if (!route.didPop(result)) {
      return false;
    }
    // If details page, make pid as null
    currentConfiguration = currentConfiguration.previous();
    notifyListeners();
    return true;
  }

}