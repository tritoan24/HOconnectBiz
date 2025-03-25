import 'dart:convert';

import 'package:clbdoanhnhansg/providers/user_provider.dart';
import 'package:clbdoanhnhansg/widgets/input_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../models/business_model.dart';
import '../../../../../providers/business_provider.dart';
import '../../../../../widgets/input_text_number.dart';
import '../../../../../widgets/text_styles.dart';
import '../../shop/widget/checkbox.dart';
import '../../shop/widget/un_checkbox.dart';

class EditInformation extends StatefulWidget {
  const EditInformation({super.key});

  @override
  State<EditInformation> createState() => _EditInformationState();
}

class _EditInformationState extends State<EditInformation> {
  Map<String, String>? _formData;
  String? _phoneError; // Biến lưu lỗi của phoneNumber

  // Controllers để lấy dữ liệu từ InputText
  final _companyNameController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _descriptionController = TextEditingController();

  List<Map<String, String>> selectedBusinesses = [];

  String? _validatePhoneNumber(String? phoneNumber) {
    if (phoneNumber == null || phoneNumber.isEmpty) {
      return null; // Không validate nếu rỗng
    }

    // Biểu thức chính quy cho số điện thoại Việt Nam
    final phoneRegExp = RegExp(r'^(0[35789])[0-9]{8}$');
    if (!phoneRegExp.hasMatch(phoneNumber)) {
      return 'Số điện thoại không hợp lệ (VD: 0x12345678)';
    }
    return null; // Hợp lệ
  }

  void _removeBusiness(String id) {
    setState(() {
      selectedBusinesses.removeWhere((item) => item['id'] == id);
    });
  }

  void _openBusinessModal(BuildContext context) {
    _showCheckboxModal(context, (List<Map<String, String>> selectedItems) {
      setState(() {
        selectedBusinesses = selectedItems;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //
    // });

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.author;
    if (user != null) {
      _companyNameController.text =
          user.companyName?.isNotEmpty ?? false ? user.companyName! : "";
      _displayNameController.text =
          user.displayName?.isNotEmpty ?? false ? user.displayName! : "";
      _addressController.text =
          user.address?.isNotEmpty ?? false ? user.address! : "";
      _phoneController.text =
          user.phone?.isNotEmpty ?? false ? user.phone.toString() : "";
      _descriptionController.text = user.companyDescription?.isNotEmpty ?? false
          ? user.companyDescription!
          : "";
    }
    // Lắng nghe thay đổi của phoneController để validate realtime
    _phoneController.addListener(() {
      setState(() {
        _phoneError = _validatePhoneNumber(_phoneController.text);
      });
    });
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    _displayNameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Bỏ _handleFormDataChanged vì không cần thiết nữa với InputText hiện tại

  void _handleSubmit() async {
    List<String> businessIds =
        selectedBusinesses.map((business) => business['id']!).toList();

    // Validate phoneNumber trước khi gửi
    final phoneError = _validatePhoneNumber(_phoneController.text);
    if (phoneError != null) {
      setState(() {
        _phoneError = phoneError;
      });
      return; // Dừng xử lý nếu số điện thoại không hợp lệ
    }
    final formData = {
      'company_name': _companyNameController.text,
      'displayName': _displayNameController.text,
      'address': _addressController.text,
      'phoneNumber': _phoneController.text,
      'company_description': _descriptionController.text,
      'business': jsonEncode(businessIds),
    };

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final body = formData;

    try {
      await userProvider.updateUser(
        context,
        body: body,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi cập nhật thông tin: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<UserProvider, BusinessProvider>(
      builder: (context, userProvider, businessProvider, child) {
        if (userProvider.isLoading || businessProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          );
        }

        if (userProvider.author == null) {
          return const Center(
              child: Text('Không thể tải thông tin người dùng'));
        }

        final user = userProvider.author!;
        final companyName =
            user.companyName?.isNotEmpty ?? false ? user.companyName : "";
        final displayName =
            user.displayName?.isNotEmpty ?? false ? user.displayName : "";
        final address = user.address?.isNotEmpty ?? false ? user.address : "";
        final phoneNumber = user.phone?.isNotEmpty ?? false ? user.phone : "";
        final description = user.companyDescription?.isNotEmpty ?? false
            ? user.companyDescription
            : "";

        // Đồng bộ selectedBusinesses với user.business khi dữ liệu đã sẵn sàng
        if (selectedBusinesses.isEmpty &&
            businessProvider.business.isNotEmpty) {
          selectedBusinesses = businessProvider.business
              .where((business) => user.business.contains(business.id))
              .map((business) => {'id': business.id, 'title': business.title})
              .toList();
        }

        // Gán giá trị ban đầu cho các controller nếu chưa gán
        if (_companyNameController.text.isEmpty) {
          _companyNameController.text = companyName ?? "";
          _displayNameController.text = displayName ?? "";
          _addressController.text = address ?? "";
          _phoneController.text = phoneNumber ?? "";
          _descriptionController.text = description ?? "";
        }

        return Scaffold(
          backgroundColor: Colors.white,
          bottomNavigationBar: Material(
            elevation: 10,
            color: Colors.white,
            child: GestureDetector(
              onTap: _handleSubmit,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20),
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Color(0xff006AF5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Text(
                      'Lưu thông tin chỉnh sửa',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: () => Navigator.of(context).pop(),
            ),
            centerTitle: false,
            title: const Text(
              "Chỉnh sửa thông tin",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InputText(
                    controller: _companyNameController,
                    name: "name",
                    title: "Tên công ty",
                  ),
                  const SizedBox(height: 15),
                  InputText(
                    controller: _displayNameController,
                    name: "displayName",
                    title: "Chủ doanh nghiệp",
                  ),
                  const SizedBox(height: 15),
                  InputText(
                    controller: _addressController,
                    name: "address",
                    title: "Địa chỉ",
                  ),
                  const SizedBox(height: 15),
                  InputTextNumber(
                    controller: _phoneController,
                    name: "phoneNumber",
                    title: "Số điện thoại",
                    errorText: _phoneError,
                  ),
                  const SizedBox(height: 15),
                  Text(
                    "Ngành nghề kinh doanh",
                    style: TextStyles.textStyleNormal14W500,
                  ),
                  const SizedBox(height: 10),
                  Container(
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
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Flexible(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 4),
                                                child: Text(
                                                  business['title'] ?? '',
                                                  style: TextStyles
                                                      .textStyleNormal14W400,
                                                  overflow:
                                                      TextOverflow.visible,
                                                  softWrap: true,
                                                ),
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                _removeBusiness(
                                                    business['id']!);
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
                                ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: InkWell(
                            onTap: () => _openBusinessModal(context),
                            borderRadius: BorderRadius.circular(12),
                            // Bo góc cho hiệu ứng nhấn
                            splashColor: Colors.blue.withOpacity(0.3),
                            // Màu hiệu ứng khi nhấn
                            child: const SizedBox(
                              width: 40, // Tăng kích thước button
                              height: 40,
                              child: Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 30, // Tăng kích thước icon
                                color: Colors
                                    .black, // Màu icon (tùy chỉnh nếu muốn)
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  InputText(
                    controller: _descriptionController,
                    name: "description",
                    title: "Mô tả doanh nghiệp",
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showCheckboxModal(BuildContext context,
      Function(List<Map<String, String>>) onBusinessSelected) {
    final businessProvider =
        Provider.of<BusinessProvider>(context, listen: false);
    List<BusinessModel> businessList = businessProvider.business;

    TextEditingController searchController = TextEditingController();
    List<BusinessModel> filteredData = List.from(businessList);
    Set<Map<String, String>> selectedItems = Set.from(selectedBusinesses);

    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
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
                    Row(
                      children: [
                        const Spacer(),
                        IconButton(
                          onPressed: () {
                            onBusinessSelected(selectedItems.toList());
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.close, size: 24),
                        ),
                      ],
                    ),
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
                            title: Text(
                              itemName,
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w400),
                            ),
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
