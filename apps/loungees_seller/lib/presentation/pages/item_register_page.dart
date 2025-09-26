// 아이템 등록/수정 페이지
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/item_provider.dart';

class ItemRegisterPage extends StatefulWidget {
  final String sellerId;
  final Item? itemToEdit; // 수정할 아이템 (null이면 새로 등록)

  const ItemRegisterPage({super.key, required this.sellerId, this.itemToEdit});

  @override
  State<ItemRegisterPage> createState() => _ItemRegisterPageState();
}

class _ItemRegisterPageState extends State<ItemRegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _itemNameController = TextEditingController();
  final _priceController = TextEditingController();
  final _productNumberPrefixController = TextEditingController(); // 상품번호 앞자리
  final _productNumberSuffixController = TextEditingController(); // 상품번호 뒷자리
  final _sellerController = TextEditingController();
  final _imageUrlController = TextEditingController(); // 이미지 URL 컨트롤러 추가
  final List<TextEditingController> _filterControllers = [];

  @override
  void initState() {
    super.initState();

    // 수정 모드일 때 기존 데이터로 폼 채우기
    if (widget.itemToEdit != null) {
      final item = widget.itemToEdit!;
      _itemNameController.text = item.name;
      _priceController.text = item.price.toString();

      // 상품번호를 앞뒤로 분리
      final productNumberParts = item.productNumber.split('-');
      if (productNumberParts.length >= 2) {
        _productNumberPrefixController.text = productNumberParts[0];
        _productNumberSuffixController.text = productNumberParts
            .sublist(1)
            .join('-');
      } else {
        // 하이픈이 없는 경우 전체를 앞자리로 설정
        _productNumberPrefixController.text = item.productNumber;
        _productNumberSuffixController.text = '';
      }

      _sellerController.text = item.sellerCompany;
      _imageUrlController.text = item.imageUrl ?? '';

      // 필터들 추가
      for (final filter in item.filters) {
        final controller = TextEditingController(text: filter);
        _filterControllers.add(controller);
      }
    }
  }

  @override
  void dispose() {
    _itemNameController.dispose();
    _priceController.dispose();
    _productNumberPrefixController.dispose();
    _productNumberSuffixController.dispose();
    _sellerController.dispose();
    _imageUrlController.dispose(); // 이미지 URL 컨트롤러 dispose
    for (var controller in _filterControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addFilterField() {
    setState(() {
      _filterControllers.add(TextEditingController());
    });
  }

  void _removeFilterField(int index) {
    setState(() {
      _filterControllers[index].dispose();
      _filterControllers.removeAt(index);
    });
  }

  List<String> _getFilters() {
    return _filterControllers
        .map((controller) => controller.text.trim())
        .where((text) => text.isNotEmpty)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.itemToEdit != null ? '아이템 수정' : '아이템 등록'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 아이템 이름
                TextFormField(
                  controller: _itemNameController,
                  decoration: const InputDecoration(
                    labelText: '아이템 이름',
                    hintText: '아이템 이름을 입력하세요',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '아이템 이름을 입력해주세요';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // 금액
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(
                    labelText: '금액',
                    hintText: '가격을 입력하세요',
                    border: OutlineInputBorder(),
                    prefixText: '₩ ',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '금액을 입력해주세요';
                    }
                    if (int.tryParse(value) == null) {
                      return '올바른 숫자를 입력해주세요';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // 상품번호 (앞뒤로 분리)
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _productNumberPrefixController,
                        decoration: const InputDecoration(
                          labelText: '상품번호 (앞자리)',
                          hintText: '예: ABC123',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '상품번호 앞자리를 입력해주세요';
                          }
                          return null;
                        },
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        '-',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: TextFormField(
                        controller: _productNumberSuffixController,
                        decoration: const InputDecoration(
                          labelText: '상품번호 (뒷자리)',
                          hintText: '예: 456',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '상품번호 뒷자리를 입력해주세요';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 판매업체
                TextFormField(
                  controller: _sellerController,
                  decoration: const InputDecoration(
                    labelText: '판매업체',
                    hintText: '판매업체명을 입력하세요',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '판매업체명을 입력해주세요';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // 이미지 URL
                TextFormField(
                  controller: _imageUrlController,
                  decoration: const InputDecoration(
                    labelText: '이미지 URL',
                    hintText: '상품 이미지 URL을 입력하세요 (선택사항)',
                    border: OutlineInputBorder(),
                    helperText: 'CORS 문제로 일부 외부 이미지가 표시되지 않을 수 있습니다.',
                  ),
                  keyboardType: TextInputType.url,
                ),
                const SizedBox(height: 16),

                // 필터 정보 (동적 추가/삭제)
                Row(
                  children: [
                    const Text(
                      '필터 정보',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: _addFilterField,
                      icon: const Icon(Icons.add),
                      tooltip: '필터 추가',
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // 필터 입력 필드들
                ...List.generate(_filterControllers.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _filterControllers[index],
                            decoration: InputDecoration(
                              hintText: '필터 ${index + 1}',
                              border: const OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () => _removeFilterField(index),
                          icon: const Icon(
                            Icons.remove_circle,
                            color: Colors.red,
                          ),
                          tooltip: '필터 삭제',
                        ),
                      ],
                    ),
                  );
                }),

                // 필터가 없을 때 안내 메시지
                if (_filterControllers.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Text(
                      '필터를 추가하려면 + 버튼을 눌러주세요',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                const SizedBox(height: 32),

                // 저장 버튼
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final itemProvider = Provider.of<ItemProvider>(
                        context,
                        listen: false,
                      );

                      final isEditMode = widget.itemToEdit != null;
                      final productNumber =
                          '${_productNumberPrefixController.text.trim()}-${_productNumberSuffixController.text.trim()}';

                      // 새 등록 모드일 때만 상품번호 중복 확인
                      if (!isEditMode) {
                        try {
                          final exists = await itemProvider
                              .checkProductNumberExists(productNumber);
                          if (exists) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('이미 등록된 상품번호입니다: $productNumber'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('상품번호 확인 중 오류가 발생했습니다: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
                      }

                      final item = Item(
                        id: productNumber, // 상품번호를 ID로 사용
                        name: _itemNameController.text.trim(),
                        price: int.parse(_priceController.text.trim()),
                        productNumber: productNumber, // 상품번호
                        sellerCompany: _sellerController.text.trim(),
                        filters: _getFilters(),
                        imageUrl:
                            _imageUrlController.text.trim().isNotEmpty
                                ? _imageUrlController.text.trim()
                                : null,
                        createdAt:
                            isEditMode
                                ? widget.itemToEdit!.createdAt
                                : DateTime.now(),
                        updatedAt: DateTime.now(),
                      );

                      try {
                        if (isEditMode) {
                          await itemProvider.updateItem(
                            productNumber,
                            item,
                          ); // 상품번호를 ID로 사용
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('아이템이 성공적으로 수정되었습니다!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } else {
                          await itemProvider.addItem(item);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('아이템이 성공적으로 등록되었습니다!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }

                        Navigator.pop(context);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('오류가 발생했습니다: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    widget.itemToEdit != null ? '수정 완료' : '등록 완료',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
