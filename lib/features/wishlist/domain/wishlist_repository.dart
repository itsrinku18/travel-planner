abstract interface class WishlistRepository {
  Future<Set<String>> load();
  Future<void> add(String destinationId);
  Future<void> remove(String destinationId);
  Future<void> toggle(String destinationId);
}
