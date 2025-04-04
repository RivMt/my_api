import 'package:flutter/material.dart';
import 'package:my_api/core/log.dart';
import 'package:my_api/core/widget/unknown_page.dart';

const String _tag = "Navigator";

class RoutePath {

  static final RoutePath home = RoutePath("");

  static final RoutePath unknown = RoutePath("404");

  RoutePath(this.path, {
    this.uuid,
    this.queries,
    this.anchor,
    this.index = 0,
  });

  final String path;

  final String? uuid;

  final Map<String, dynamic>? queries;

  final String? anchor;

  final int index;

  /// Value of this route path is about details or not
  bool get isDetails => uuid != null;

  /// List of path segments
  List<String> get pathSegments {
    final segments = <String>[];
    segments.add("/$path");
    if (uuid != null) segments.add(uuid!);
    return segments;
  }

  /// Depth of path
  int get depth => pathSegments.length;

  /// Current uri
  Uri get uri {
    return Uri(
      pathSegments: pathSegments,
      queryParameters: queries,
      fragment: anchor,
    );
  }

  /// Generate details uri from current
  RoutePath details(String uuid) => RoutePath(path, uuid: uuid);

  /// Generate complex uri from current
  RoutePath extend({
    String? uuid,
    Map<String, dynamic>? queries,
    String? anchor,
  }) => RoutePath(path,
    uuid: uuid,
    queries: queries,
    anchor: anchor,
  );

  /// Generate previous uri from current
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

class RouteParser extends RouteInformationParser<RoutePath> {

  /// List of path segments does not have detail uri
  List<RoutePath> get pathStandalone => [];

  /// List of path segments which have detail uri
  List<RoutePath> get pathDetails => [];

  /// List of tab page by home index
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

abstract class CoreRouterDelegate extends RouterDelegate<RoutePath> with ChangeNotifier, PopNavigatorRouterDelegateMixin {

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
    return;
  }

  /// Widget of home page
  Widget get home;

  /// Stack of pages to current uri
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

  /// Move to previous page
  void onDidRemovePage(Page page) {
    currentConfiguration = currentConfiguration.previous();
    notifyListeners();
  }

}