// 아이템 프로바이더 - 파이어베이스 연동
import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

class ItemProvider with ChangeNotifier {
  final ItemRepository _itemRepository;
  final CreateItemUseCase _createItemUseCase;
  final UpdateItemUseCase _updateItemUseCase;
  final DeleteItemUseCase _deleteItemUseCase;
  final GetAllItemsUseCase _getAllItemsUseCase;
  final CheckProductNumberExistsUseCase _checkProductNumberExistsUseCase;

  ItemProvider({
    required ItemRepository itemRepository,
    required CreateItemUseCase createItemUseCase,
    required UpdateItemUseCase updateItemUseCase,
    required DeleteItemUseCase deleteItemUseCase,
    required GetAllItemsUseCase getAllItemsUseCase,
    required CheckProductNumberExistsUseCase checkProductNumberExistsUseCase,
  }) : _itemRepository = itemRepository,
       _createItemUseCase = createItemUseCase,
       _updateItemUseCase = updateItemUseCase,
       _deleteItemUseCase = deleteItemUseCase,
       _getAllItemsUseCase = getAllItemsUseCase,
       _checkProductNumberExistsUseCase = checkProductNumberExistsUseCase;

  final List<Item> _items = [];
  bool _isLoading = false;
  String? _error;

  List<Item> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;
  String? get error => _error;

  // 아이템 추가 (파이어베이스 연동)
  Future<void> addItem(Item item) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _createItemUseCase(item);
      await loadItems(); // 전체 아이템 다시 로드
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 아이템 수정 (파이어베이스 연동)
  Future<void> updateItem(String id, Item updatedItem) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _updateItemUseCase(updatedItem);
      await loadItems(); // 전체 아이템 다시 로드
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 아이템 삭제 (파이어베이스 연동)
  Future<void> deleteItem(String id) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _deleteItemUseCase(id);
      await loadItems(); // 전체 아이템 다시 로드
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 아이템 목록 로드
  Future<void> loadItems() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _items.clear();
      _items.addAll(await _getAllItemsUseCase());
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 상품번호 중복 확인
  Future<bool> checkProductNumberExists(String productNumber) async {
    try {
      return await _checkProductNumberExistsUseCase(productNumber);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ID로 아이템 찾기
  Item? getItemById(String id) {
    try {
      return _items.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }

  // 셀러별 아이템 조회
  List<Item> getItemsBySeller(String sellerId) {
    return _items.where((item) => item.sellerCompany == sellerId).toList();
  }

  // 필터별 아이템 조회
  List<Item> getItemsByFilter(String filter) {
    return _items.where((item) => item.filters.contains(filter)).toList();
  }

  // 아이템 개수
  int get itemCount => _items.length;
}
