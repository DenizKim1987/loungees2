// 아이템 리포지토리 구현체
import '../../data/datasources/item_data_source.dart';
import '../../domain/entities/item.dart';
import '../../domain/repositories/item_repository.dart';

class ItemRepositoryImpl implements ItemRepository {
  final ItemDataSource _dataSource;

  ItemRepositoryImpl(this._dataSource);

  @override
  Future<void> createItem(Item item) async {
    await _dataSource.createItem(item);
  }

  @override
  Future<Item?> getItemById(String id) async {
    return await _dataSource.getItemById(id);
  }

  @override
  Future<void> updateItem(Item item) async {
    await _dataSource.updateItem(item);
  }

  @override
  Future<void> deleteItem(String id) async {
    await _dataSource.deleteItem(id);
  }

  @override
  Future<List<Item>> getAllItems() async {
    return await _dataSource.getAllItems();
  }

  @override
  Future<List<Item>> getItemsBySeller(String sellerId) async {
    return await _dataSource.getItemsBySeller(sellerId);
  }

  @override
  Future<bool> existsByProductNumber(String productNumber) async {
    return await _dataSource.existsByProductNumber(productNumber);
  }
}
