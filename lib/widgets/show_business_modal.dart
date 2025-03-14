import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/business_provider.dart';
import '../models/business_model.dart';

void showBusinessModal(
  BuildContext context, {
  required Function(List<Map<String, String>>) onBusinessSelected,
  List<Map<String, String>>?
      initialSelectedBusinesses, // Dữ liệu ban đầu đã chọn
}) {
  final businessProvider =
      Provider.of<BusinessProvider>(context, listen: false);
  List<BusinessModel> businessList = businessProvider.business;

  TextEditingController searchController = TextEditingController();
  List<BusinessModel> filteredData = List.from(businessList);

  // Chứa danh sách đã chọn (lưu cả ID và title)
  Set<Map<String, String>> selectedItems = initialSelectedBusinesses != null
      ? Set.from(initialSelectedBusinesses)
      : Set<Map<String, String>>();

  showModalBottomSheet(
    backgroundColor: Colors.white,
    context: context,
    isScrollControlled: true,
    isDismissible: false,
    enableDrag: false,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          // Hàm lọc danh sách ngành nghề theo từ khóa
          void _filterSearchResults(String query) {
            setState(() {
              filteredData = businessList
                  .where((item) =>
                      item.title.toLowerCase().contains(query.toLowerCase()))
                  .toList();
            });
          }

          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              height: MediaQuery.of(context).size.height * 0.7,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Thanh điều hướng với nút đóng
                  Row(
                    children: [
                      const Spacer(),
                      IconButton(
                        onPressed: () {
                          // Chuyển đổi Set thành List trước khi trả về
                          onBusinessSelected(selectedItems.toList());
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.close, size: 24),
                      ),
                    ],
                  ),

                  // Thanh tìm kiếm
                  TextField(
                    controller: searchController,
                    onChanged: _filterSearchResults,
                    decoration: InputDecoration(
                      prefixIcon:
                          const Icon(Icons.search, color: Color(0xff767A7F)),
                      hintText: "Tìm kiếm ngành nghề",
                      hintStyle: const TextStyle(color: Color(0xff767A7F)),
                      filled: true,
                      fillColor: const Color(0xffF4F5F6),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Danh sách ngành nghề
                  Expanded(
                    child: ListView.separated(
                      itemCount: filteredData.length,
                      separatorBuilder: (context, index) => const Divider(
                        color: Color(0xffD6E9FF),
                        thickness: 1,
                        height: 1,
                      ),
                      itemBuilder: (context, index) {
                        String itemId = filteredData[index].id;
                        String itemName = filteredData[index].title;
                        bool isSelected =
                            selectedItems.any((item) => item['id'] == itemId);

                        return ListTile(
                          title: Text(itemName,
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w400)),
                          trailing: GestureDetector(
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  selectedItems.removeWhere(
                                      (item) => item['id'] == itemId);
                                } else {
                                  selectedItems
                                      .add({'id': itemId, 'title': itemName});
                                }
                              });
                            },
                            child: isSelected ? const Check() : const UnCheck(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

// Widget Check (nếu cần)
class Check extends StatelessWidget {
  const Check({super.key});

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.check_circle, color: Colors.blue, size: 24);
  }
}

// Widget UnCheck (nếu cần)
class UnCheck extends StatelessWidget {
  const UnCheck({super.key});

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.circle_outlined, color: Colors.grey, size: 24);
  }
}
