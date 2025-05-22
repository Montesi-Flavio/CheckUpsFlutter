abstract class BaseRepository<T> {
  Future<T?> getById(int id);
  Future<List<T>> getAll();
  Future<int> insert(T entity);
  Future<bool> update(T entity);
  Future<bool> delete(int id);
}
