/// A sort order.
///
/// `true` is ascending, `false` is descending.
enum SortOrder {
  asc(true),
  desc(false);

  /// Whether the order is ascending.
  final bool order;

  /// Creates a sort order from its ascending flag.
  const SortOrder(this.order);

  @override
  String toString() => order ? "asc" : "desc";
}
