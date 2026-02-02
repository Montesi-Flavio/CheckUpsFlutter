abstract class TableData {
  int id;
  String tableName;
  String primaryKey;

  TableData(this.id, this.tableName, this.primaryKey);

  void selfRemoveFromList();
}
