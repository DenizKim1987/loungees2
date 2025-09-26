// 아이템 리포지토리 인터페이스
import '../entities/item.dart';

abstract class ItemRepository {
  // 아이템 생성
  Future<void> createItem(Item item);

  // 아이템 조회
  Future<Item?> getItemById(String id);

  // 아이템 수정
  Future<void> updateItem(Item item);

  // 아이템 삭제
  Future<void> deleteItem(String id);

  // 모든 아이템 조회
  Future<List<Item>> getAllItems();

  // 셀러별 아이템 조회
  Future<List<Item>> getItemsBySeller(String sellerId);

  // 상품번호로 아이템 존재 여부 확인
  Future<bool> existsByProductNumber(String productNumber);
}
