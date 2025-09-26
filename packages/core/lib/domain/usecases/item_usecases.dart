// 아이템 유즈케이스들
import '../entities/item.dart';
import '../repositories/item_repository.dart';

// 아이템 생성 유즈케이스
class CreateItemUseCase {
  final ItemRepository _repository;

  CreateItemUseCase(this._repository);

  Future<void> call(Item item) async {
    // 상품번호 중복 확인
    final exists = await _repository.existsByProductNumber(item.productNumber);
    if (exists) {
      throw Exception('이미 등록된 상품번호입니다: ${item.productNumber}');
    }

    await _repository.createItem(item);
  }
}

// 아이템 조회 유즈케이스
class GetItemByIdUseCase {
  final ItemRepository _repository;

  GetItemByIdUseCase(this._repository);

  Future<Item?> call(String id) async {
    return await _repository.getItemById(id);
  }
}

// 아이템 수정 유즈케이스
class UpdateItemUseCase {
  final ItemRepository _repository;

  UpdateItemUseCase(this._repository);

  Future<void> call(Item item) async {
    await _repository.updateItem(item);
  }
}

// 아이템 삭제 유즈케이스
class DeleteItemUseCase {
  final ItemRepository _repository;

  DeleteItemUseCase(this._repository);

  Future<void> call(String id) async {
    await _repository.deleteItem(id);
  }
}

// 모든 아이템 조회 유즈케이스
class GetAllItemsUseCase {
  final ItemRepository _repository;

  GetAllItemsUseCase(this._repository);

  Future<List<Item>> call() async {
    return await _repository.getAllItems();
  }
}

// 셀러별 아이템 조회 유즈케이스
class GetItemsBySellerUseCase {
  final ItemRepository _repository;

  GetItemsBySellerUseCase(this._repository);

  Future<List<Item>> call(String sellerId) async {
    return await _repository.getItemsBySeller(sellerId);
  }
}

// 상품번호 중복 확인 유즈케이스
class CheckProductNumberExistsUseCase {
  final ItemRepository _repository;

  CheckProductNumberExistsUseCase(this._repository);

  Future<bool> call(String productNumber) async {
    return await _repository.existsByProductNumber(productNumber);
  }
}
