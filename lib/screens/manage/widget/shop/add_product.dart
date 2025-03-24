import 'package:clbdoanhnhansg/widgets/button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart';
import '../../../../models/product_model.dart';
import '../../../../widgets/input_file_images.dart';
import '../../../../widgets/input_text.dart';
import '../../../../widgets/input_text_area.dart';
import 'package:provider/provider.dart';
import 'package:clbdoanhnhansg/providers/product_provider.dart';
import 'dart:io';
import 'package:clbdoanhnhansg/utils/Color/app_color.dart';

class AddProduct extends StatefulWidget {
  const AddProduct({super.key});
  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  final _formKey = GlobalKey<FormBuilderState>();
  List<String> selectedImages = [];

  // Add controllers for all fields
  final TextEditingController _controllerPrice = TextEditingController();
  final TextEditingController _controllerTenSanPham = TextEditingController();
  final TextEditingController _controllerChietKhau = TextEditingController();
  final TextEditingController _controllerMoTa = TextEditingController();
  final NumberFormat _formatter = NumberFormat('#,###', 'vi_VN');

  void _onImagesSelected(List<String> paths) {
    setState(() {
      selectedImages = paths;
    });
  }

  @override
  void initState() {
    super.initState();
    _controllerPrice.addListener(_formatMoney);
  }

  @override
  void dispose() {
    _controllerPrice.removeListener(_formatMoney);
    _controllerPrice.dispose();
    _controllerTenSanPham.dispose();
    _controllerChietKhau.dispose();
    _controllerMoTa.dispose();
    super.dispose();
  }

  // Add form validation method
  bool _validateForm() {
    // Use FormBuilder's built-in validation
    if (!(_formKey.currentState?.saveAndValidate() ?? false)) {
      return false;
    }

    // Additional custom validations
    bool isValid = true;
    String errorMessage = '';

    // Validate product name
    if (_controllerTenSanPham.text.trim().isEmpty) {
      errorMessage = 'Vui lòng nhập tên sản phẩm';
      isValid = false;
    }

    // Validate price
    if (_controllerPrice.text.trim().isEmpty) {
      errorMessage = 'Vui lòng nhập giá sản phẩm';
      isValid = false;
    } else {
      String priceText =
          _controllerPrice.text.replaceAll(RegExp(r'[^0-9]'), '');
      if (int.tryParse(priceText) == null || int.parse(priceText) <= 0) {
        errorMessage = 'Giá sản phẩm phải lớn hơn 0';
        isValid = false;
      }
    }

    // Validate discount (if provided)
    if (_controllerChietKhau.text.isNotEmpty) {
      int? discount = int.tryParse(_controllerChietKhau.text);
      if (discount == null || discount < 0 || discount > 100) {
        errorMessage = 'Chiết khấu phải từ 0-100%';
        isValid = false;
      }
    }

    // Validate images
    if (selectedImages.isEmpty) {
      errorMessage = 'Vui lòng chọn ít nhất 1 ảnh sản phẩm';
      isValid = false;
    }

    // Show error message if validation fails
    if (!isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
      );
    }

    return isValid;
  }

  void _formatMoney() {
    String text = _controllerPrice.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (text.isNotEmpty) {
      String formatted = _formatter.format(int.parse(text));
      if (formatted != _controllerPrice.text) {
        _controllerPrice.value = TextEditingValue(
          text: formatted,
          selection: TextSelection.collapsed(offset: formatted.length),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text("Tạo sản phẩm"),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FormBuilder(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InputText(
                  name: 'tenSanPham',
                  title: "Tên sản phẩm",
                  hintText: "Nhập tên sản phẩm",
                  controller: _controllerTenSanPham,
                ),
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  "Nhập giá tiền",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                FormBuilderTextField(
                  controller: _controllerPrice,
                  name: 'money',
                  maxLines: null,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  autovalidateMode: AutovalidateMode.always,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                    hintText: 'Nhập số tiền',
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColor.borderColor,
                        width: 1.0,
                      ),
                    ),
                    hintStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColor.borderColor,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: AppColor.borderColor,
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    suffixText: 'VNĐ',
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Chiết Khấu Hội Viên",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    FormBuilderTextField(
                      controller: _controllerChietKhau,
                      maxLines: null,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      autovalidateMode: AutovalidateMode.always,
                      name: 'chietKhauHoiVien',
                      decoration: InputDecoration(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 10),
                        hintText: 'Nhập chiết khấu cho hội viên',
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColor.borderColor,
                            width: 1.0,
                          ),
                        ),
                        hintStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColor.borderColor,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: AppColor.borderColor,
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        suffixIcon: const Padding(
                          padding: EdgeInsets.only(right: 10),
                          child: Text(
                            '%',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        suffixIconConstraints:
                            const BoxConstraints(minWidth: 20, minHeight: 20),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                InputTextArea(
                  title: "Mô tả sản phẩm",
                  name: 'moTaSanPham',
                  hintText: "Nhập mô tả chi tiết sản phẩm",
                  controller: _controllerMoTa,
                ),
                const SizedBox(
                  height: 20,
                ),
                const Text("Ảnh sản phẩm",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    )),
                const SizedBox(
                  height: 10,
                ),
                InputFileImages(
                  formKey: _formKey,
                  onImagesChanged: _onImagesSelected,
                ),
                const SizedBox(
                  height: 40,
                ),
                ButtonWidget(
                  label: "Thêm sản phẩm",
                  onPressed: () async {
                    if (_validateForm()) {
                      final product = ProductModel(
                        title: _controllerTenSanPham.text,
                        price: int.parse(_controllerPrice.text
                                .replaceAll(RegExp(r'[^0-9]'), '')) ??
                            0,
                        discount: int.parse(_controllerChietKhau.text.isEmpty
                            ? '0'
                            : _controllerChietKhau.text),
                        description: _controllerMoTa.text,
                        album: selectedImages,
                      );

                      // Convert all images to File objects
                      List<File> files =
                          selectedImages.map((path) => File(path)).toList();

                      await productProvider.createProduct(context, product,
                          files: files);
                    }
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
