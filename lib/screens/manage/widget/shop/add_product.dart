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

  void _onImagesSelected(List<String> paths) {
    setState(() {
      selectedImages = paths;
    });
  }

  final TextEditingController _controllerPrice = TextEditingController();
  final NumberFormat _formatter = NumberFormat('#,###', 'vi_VN');

  @override
  void initState() {
    super.initState();
    _controllerPrice.addListener(_formatMoney); // Correct function name
  }

  @override
  void dispose() {
    _controllerPrice.removeListener(_formatMoney);
    _controllerPrice.dispose();
    super.dispose();
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
      // Add Scaffold
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
            // Add FormBuilder here
            key: _formKey, // Use the formKey
            child: Column(
              mainAxisSize: MainAxisSize
                  .min, // Đảm bảo Column không chiếm toàn bộ chiều cao
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const InputText(
                  name: 'tenSanPham',
                  title: "Tên sản phẩm",
                  hintText: "Nhập tên sản phẩm",
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
                      maxLines: null, // Cho phép xuống dòng tự do
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
                            BoxConstraints(minWidth: 20, minHeight: 20),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                const InputTextArea(
                  title: "Mô tả sản phẩm",
                  name: 'moTaSanPham',
                  hintText: "Nhập mô tả chi tiết sản phẩm",
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
                    if (_formKey.currentState?.saveAndValidate() ?? false) {
                      final formData = _formKey.currentState?.value;
                      final product = ProductModel(
                        title: formData?['tenSanPham'],
                        price: int.parse(_controllerPrice.text
                                .replaceAll(RegExp(r'[^0-9]'), '')) ??
                            0,
                        discount:
                            int.parse(formData?['chietKhauHoiVien'] ?? '0'),
                        description: formData?['moTaSanPham'],
                        album: selectedImages ?? [],
                      );

                      // Chuyển tất cả các ảnh trong selectedImages thành tệp
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

