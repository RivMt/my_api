import 'package:flutter/material.dart';
import 'package:my_api/src/core/log.dart';
import 'package:my_api/src/core/widget/unknown_page.dart';

const String _tag = "Navigator";

/// Describes an application route and its optional detail state.
class RoutePath {

  /// Root application route.
  static final RoutePath home = RoutePath("");

  /// Fallback route for unknown locations.
  static final RoutePath unknown = RoutePath("404");

  /// Creates a route path.
  RoutePath(this.path, {
    this.uuid,
    this.queries,
    this.anchor,
    this.index = 0,
  });

  /// Base path segment.
  final String path;

  /// Optional identifier for a detail route.
  final String? uuid;

  /// Optional query parameters.
  final Map<String, dynamic>? queries;

  /// Optional URI fragment.
  final String? anchor;

  /// Tab index associated with the route.
  final int index;

  /// Whether this route targets a detail item.
  bool get isDetails => uuid != null;

  /// Route path segments.
  List<String> get pathSegments {
    final segments = <String>[];
    segments.add("/$path");
    if (uuid != null) segments.add(uuid!);
    return segments;
  }

  /// Number of path segments.
  int get depth => pathSegments.length;

  /// URI represented by this route.
  Uri get uri {
    return Uri(
      pathSegments: pathSegments,
      queryParameters: queries,
      fragment: anchor,
    );
  }

  /// Returns a detail route for [uuid].
  RoutePath details(String uuid) => RoutePath(path, uuid: uuid);

  /// Returns this route with the supplied optional components.
  RoutePath extend({
    String? uuid,
    Map<String, dynamic>? queries,
    String? anchor,
  }) => RoutePath(path,
    uuid: uuid,
    queries: queries,
    anchor: anchor,
  );

  /// Returns the previous route state.
  RoutePath previous() {
    // Anchor
    if (anchor != null) {
      return RoutePath(path,
        uuid: uuid,
        queries: queries,
      );
    }
    // Secondary Path
    if (uuid != null) {
      return RoutePath(path,
        uuid: null,
        queries: queries,
      );
    }
    // Home
    return RoutePath.home;
  }

  @override
  String toString() => uri.toString();

  @override
  bool operator ==(Object other) {
    if (other is RoutePath) {
      return uri == other.uri;
    }
    return super==(other);
  }

  @override
  int get hashCode => uri.hashCode;
}

/// Converts platform route information to and from [RoutePath].
class RouteParser extends RouteInformationParser<RoutePath> {

  /// Routes that do not accept a detail identifier.
  List<RoutePath> get pathStandalone => [];

  /// Routes that accept a detail identifier.
  List<RoutePath> get pathDetails => [];

  /// Home-tab routes ordered by index.
  List<RoutePath> get pathIndex => [];

  @override
  Future<RoutePath> parseRouteInformation(RouteInformation routeInformation) async {
    final uri = routeInformation.uri;
    Log.v(_tag, "Parsing uri: $uri");
    // Home
    if (uri.pathSegments.isEmpty) {
      return RoutePath.home;
    }
    // Depth 1
    else if (uri.pathSegments.length == 1) {
      // Single page
      int index = pathStandalone.indexWhere((route) => route.path == uri.pathSegments[0]);
      if (index >= 0) {
        final route = pathStandalone[index];
        return route.extend(
          queries: uri.queryParameters,
          anchor: uri.fragment,
        );
      }
      // Tab page
      index = pathIndex.indexWhere((route) => route.path == uri.pathSegments[0]);
      if (index >= 0) {
        return pathIndex[index];
      }
    }
    // Depth 2
    else if (uri.pathSegments.length == 2) {
      final String uuid = uri.pathSegments[1];
      final index = pathDetails.indexWhere((route) => route.path == uri.pathSegments[0]);
      if (index >= 0) {
        return pathDetails[index].extend(
          uuid: uuid,
          queries: uri.queryParameters,
          anchor: uri.fragment,
        );
      }
    }
    // 404
    return RoutePath.unknown;
  }

  @override
  RouteInformation restoreRouteInformation(RoutePath configuration) {
    return RouteInformation(uri: configuration.uri);
  }
}

/// Base router delegate that builds a page stack from [RoutePath].
abstract class CoreRouterDelegate extends RouterDelegate<RoutePath> with ChangeNotifier, PopNavigatorRouterDelegateMixin {

  /// Creates a router delegate with a navigator key.
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
        key: ValueKey(RoutePath.unknown.uri),
        child: const UnknownPage(),
      ));
    }
    return Navigator(
      key: navigatorKey,
      pages: pages,
      onDidRemovePage: onDidRemovePage,
    );
  }

  @override
  Future<void> setNewRoutePath(RoutePath configuration) async {
    currentConfiguration = configuration;
    Log.v(_tag, "Move to $configuration");
    notifyListeners();
    return;
  }

  @override
  Future<void> setInitialRoutePath(RoutePath configuration) async {
    currentConfiguration = configuration;
    Log.v(_tag, "Set initial route to: $configuration");
    setNewRoutePath(configuration);
    return;
  }

  /// Root page widget.
  Widget get home;

  /// Page stack from [home] to the current route.
  ///
  /// This variable should returns pages from [home] to current.
  ///
  /// If current uri is `example.com/abc/def`, the stack should be like this:
  /// ```dart
  /// [
  ///   "example.com/abc",
  ///   "example.com/abc/def"
  /// ];
  /// ```
  List<Page> get pages;

  /// Updates the route after [page] is removed.
  void onDidRemovePage(Page page) {
    currentConfiguration = currentConfiguration.previous();
    notifyListeners();
  }

}
