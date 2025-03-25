import 'package:clbdoanhnhansg/providers/business_provider.dart';
import 'package:clbdoanhnhansg/widgets/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:provider/provider.dart';

import '../../../../models/business_model.dart';
import '../../../../widgets/input_file_images.dart';
import '../../../../widgets/input_text.dart';
import '../../../../widgets/input_text_area.dart';
import '../../../manage/widget/shop/widget/checkbox.dart';
import '../../../manage/widget/shop/widget/un_checkbox.dart';

class BusinessOpportunity extends StatefulWidget {
  final GlobalKey<FormBuilderState> formKey;
  final Function(List<String>) onImagesChanged;
  final Function(List<Map<String, String>>) onBusinessChanged;
  final List<String>? initialImages;
  final List<Map<String, String>>? initialBusinesses;

  const BusinessOpportunity({
    super.key,
    required this.formKey,
    required this.onImagesChanged,
    required this.onBusinessChanged,
    this.initialImages,
    this.initialBusinesses,
  });

  @override
  State<BusinessOpportunity> createState() => BusinessOpportunityState();
}

class BusinessOpportunityState extends State<BusinessOpportunity> {
  List<Map<String, String>> selectedBusinesses = [];

  List<String> selectedImages = []; // Currently selected images
  List<String> deletedImages = []; // Images to be deleted
  List<String> originalImages = []; // Original images from product
  List<String> newImages = []; // New images added during edit

  @override
  void initState() {
    super.initState();
    // Initialize business list
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BusinessProvider>(context, listen: false)
          .getListBusiness(context);
    });

    // Initialize images from passed data
    if (widget.initialImages != null && widget.initialImages!.isNotEmpty) {
      originalImages = List.from(widget.initialImages!);
      selectedImages = List.from(widget.initialImages!);
    }

    // Initialize selected businesses
    if (widget.initialBusinesses != null &&
        widget.initialBusinesses!.isNotEmpty) {
      selectedBusinesses = List.from(widget.initialBusinesses!);
    }
  }

  Map<String, dynamic> getImageData() {
    return {
      'newImages': newImages,
      'deletedImages': deletedImages,
      'selectedImages': selectedImages,
    };
  }

  void _onImagesSelected(List<String> paths) {
    setState(() {
      selectedImages = paths;
      widget.onImagesChanged(paths);
    });
  }

  void _removeBusiness(String id) {
    setState(() {
      selectedBusinesses.removeWhere((item) => item['id'] == id);
      widget.onBusinessChanged(selectedBusinesses);
    });
  }

  void _openBusinessModal(BuildContext context) {
    _showCheckboxModal(context, (List<Map<String, String>> selectedItems) {
      setState(() {
        selectedBusinesses = selectedItems;
        widget.onBusinessChanged(selectedItems);
      });
    });

    void _onImagesSelected(List<String> paths) {
      setState(() {
        // Determine which images are new (not in originalImages)
        newImages = paths
            .where((path) =>
                !path.startsWith('http') && !originalImages.contains(path))
            .toList();

        // Determine which original images were deleted
        deletedImages =
            originalImages.where((path) => !paths.contains(path)).toList();

        // Update main selected images list
        selectedImages = paths;
        widget.onImagesChanged(paths);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 20,
        ),
        const InputText(
          name: 'tieuDe',
          title: "Tiêu đề",
          hintText: "Nhập tên sản phẩm",
        ),
        const SizedBox(
          height: 20,
        ),
        const InputTextArea(
          title: "Nội dung bài đăng",
          name: 'noiDungBaiDang',
          hintText: "Nhập mô tả chi tiết sản phẩm",
        ),
        const SizedBox(
          height: 20,
        ),
        const Text(
          "Ngành nghề",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () {
            if (selectedBusinesses.isEmpty) _openBusinessModal(context);
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                    child: selectedBusinesses.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              "Chọn ngành nghề...",
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        : Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: selectedBusinesses.map((business) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xffD6E9FF),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: IntrinsicWidth(
                                  // Giúp ô không bị giãn full width
                                  child: Row(
                                    mainAxisSize: MainAxisSize
                                        .min, // Tự co lại theo nội dung
                                    children: [
                                      Flexible(
                                        // Cho phép chữ tự động xuống dòng
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 4),
                                          child: Text(
                                            business['title'] ?? '',
                                            style: TextStyles
                                                .textStyleNormal14W400,
                                            overflow: TextOverflow
                                                .visible, // Không bị cắt chữ
                                            softWrap:
                                                true, // Cho phép xuống dòng
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          _removeBusiness(business['id']!);
                                        },
                                        child: const Icon(
                                          Icons.close,
                                          size: 22,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          )),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      _openBusinessModal(context);
                    },
                    child: Icon(Icons.keyboard_arrow_down_rounded, size: 24),
                  ),
                )
              ],
            ),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        const Text("Ảnh bài đăng",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            )),
        const SizedBox(
          height: 10,
        ),
        InputFileImages(
          formKey: widget.formKey,
          onImagesChanged: _onImagesSelected,
          initialImages: selectedImages,
        )
      ],
    );
  }

  void _showCheckboxModal(BuildContext context,
      Function(List<Map<String, String>>) onBusinessSelected) {
    final businessProvider =
        Provider.of<BusinessProvider>(context, listen: false);
    List<BusinessModel> businessList = businessProvider.business;

    TextEditingController searchController = TextEditingController();
    List<BusinessModel> filteredData = List.from(businessList);

    // Chứa danh sách đã chọn (lưu cả ID và title)
    Set<Map<String, String>> selectedItems = Set.from(selectedBusinesses);

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
                              child:
                                  isSelected ? const Check() : const UnCheck(),
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
}
