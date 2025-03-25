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

class EditProduct extends StatefulWidget {
  final ProductModel? product;
  const EditProduct({super.key, this.product});

  @override
  State<EditProduct> createState() => _editProductState();
}

class _editProductState extends State<EditProduct> {
  final _formKey = GlobalKey<FormBuilderState>();
  List<String> selectedImages = []; // Currently selected images
  List<String> deletedImages = []; // Images to be deleted
  List<String> originalImages = []; // Original images from product
  List<String> newImages = []; // New images added during edit

  final TextEditingController _controllerPrice = TextEditingController();
  final TextEditingController _controllerTenSanPham = TextEditingController();
  final TextEditingController _controllerChietKhau = TextEditingController();
  final TextEditingController _controllerMoTa = TextEditingController();
  final NumberFormat _formatter = NumberFormat('#,###', 'vi_VN');

  @override
  void initState() {
    super.initState();
    _controllerPrice.addListener(_formatMoney);

    // Nếu có sản phẩm được truyền vào, điền dữ liệu sẵn
    if (widget.product != null) {
      _controllerPrice.text = _formatter.format(widget.product!.price);
      _controllerTenSanPham.text = widget.product!.title.toString();
      _controllerChietKhau.text = widget.product!.discount.toString();
      _controllerMoTa.text = widget.product!.description.toString();

      setState(() {
        originalImages = List.from(widget.product!.album);
        selectedImages = List.from(widget.product!.album);
      });

      print('ảnh sản phẩm: ' + selectedImages.toString());
    }
  }

  // This method will be called when images are selected or removed
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

      // Update the main selected images list
      selectedImages = paths;
    });
  }

  // Add this method to your _editProductState class
  bool _validateForm() {
    // First use FormBuilder's built-in validation
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

  @override
  void dispose() {
    _controllerPrice.removeListener(_formatMoney);
    _controllerPrice.dispose();
    _controllerTenSanPham.dispose();
    _controllerChietKhau.dispose();
    _controllerMoTa.dispose();
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
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text("Sửa sản phẩm"),
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
                        color: Color(0xffB9BDC1),
                        width: 1.0,
                      ),
                    ),
                    hintStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0xffB9BDC1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Color(0xffB9BDC1),
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
                            color: Color(0xffB9BDC1),
                            width: 1.0,
                          ),
                        ),
                        hintStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Color(0xffB9BDC1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color(0xffB9BDC1),
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
                const SizedBox(height: 10),
                InputFileImages(
                  formKey: _formKey,
                  onImagesChanged: _onImagesSelected,
                  initialImages: selectedImages,
                ),
                const SizedBox(
                  height: 40,
                ),
                ButtonWidget(
                  label: widget.product != null ? "Cập nhật" : "Tạo sản phẩm",
                  onPressed: () async {
                    if (_validateForm()) {
                      if (_formKey.currentState?.saveAndValidate() ?? false) {
                        final formData = _formKey.currentState?.value;

                        // Dữ liệu gốc
                        final originalProduct = widget.product;

                        // Phân tích các ảnh được thêm mới và các ảnh bị xóa
                        List<String> newLocalImages = [];
                        List<String> retainedUrlImages = [];
                        List<String> deletedImages = [];

                        if (originalProduct != null) {
                          // Tìm ảnh mới (file local)
                          newLocalImages = selectedImages
                              .where((path) =>
                                  !path.startsWith('http') &&
                                  !originalProduct.album.contains(path))
                              .toList();

                          // Tìm các ảnh URL được giữ lại
                          retainedUrlImages = selectedImages
                              .where((path) => path.startsWith('http'))
                              .toList();

                          // Tìm các ảnh bị xóa (URL có trong originalProduct nhưng không còn trong selectedImages)
                          deletedImages = originalProduct.album
                              .where((path) =>
                                  path.startsWith('http') &&
                                  !selectedImages.contains(path))
                              .toList();
                        }

                        // Dữ liệu mới
                        final newProduct = ProductModel(
                          id: originalProduct?.id,
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

                        // Map lưu các trường bị thay đổi
                        Map<String, dynamic> updatedFields = {};

                        if (originalProduct == null) {
                          // Nếu là sản phẩm mới, gửi toàn bộ dữ liệu
                          await productProvider.createProduct(
                              context, newProduct,
                              files: selectedImages
                                  .map((path) => File(path))
                                  .toList());
                        } else {
                          // Nếu là cập nhật, chỉ gửi các trường bị thay đổi
                          if (newProduct.title != originalProduct.title) {
                            updatedFields['title'] = newProduct.title;
                          }
                          if (newProduct.price != originalProduct.price) {
                            updatedFields['price'] = newProduct.price;
                          }
                          if (newProduct.discount != originalProduct.discount) {
                            updatedFields['discount'] = newProduct.discount;
                          }
                          if (newProduct.description !=
                              originalProduct.description) {
                            updatedFields['description'] =
                                newProduct.description;
                          }

                          // Phần xử lý ảnh
                          if (newLocalImages.isNotEmpty ||
                              deletedImages.isNotEmpty) {
                            // Chỉ cập nhật album nếu có ảnh mới hoặc ảnh bị xóa
                            updatedFields['album'] = retainedUrlImages;
                          }

                          // Thêm danh sách ảnh cần xóa nếu có
                          if (deletedImages.isNotEmpty) {
                            updatedFields['delete'] = deletedImages;
                          }

                          // Nếu có bất kỳ thay đổi nào thì mới gửi yêu cầu cập nhật
                          if (updatedFields.isNotEmpty) {
                            // Tạo một ProductModel mới chỉ với các giá trị bị thay đổi
                            final updatedProduct = ProductModel(
                              id: originalProduct.id,
                              title: updatedFields.containsKey('title')
                                  ? updatedFields['title']
                                  : originalProduct.title,
                              price: updatedFields.containsKey('price')
                                  ? updatedFields['price']
                                  : originalProduct.price,
                              discount: updatedFields.containsKey('discount')
                                  ? updatedFields['discount']
                                  : originalProduct.discount,
                              description:
                                  updatedFields.containsKey('description')
                                      ? updatedFields['description']
                                      : originalProduct.description,
                              album: updatedFields.containsKey('album')
                                  ? updatedFields['album']
                                  : originalProduct.album,
                            );

                            // Chuẩn bị danh sách các file ảnh mới cần upload
                            List<File> newImageFiles = newLocalImages
                                .map((path) => File(path))
                                .toList();

                            await productProvider.editProduct(
                              context,
                              updatedProduct,
                              files: newImageFiles, // Chỉ upload file ảnh mới
                              deletedImages:
                                  deletedImages, // Danh sách ảnh cần xóa
                            );
                          }
                        }
                      }
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
