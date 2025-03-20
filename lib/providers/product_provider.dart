import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../core/base/base_provider.dart';
import '../repository/product_repository.dart';
import '../models/product_model.dart';
import '../widgets/loading_overlay.dart';

class ProductProvider extends BaseProvider {
  List<ProductModel> _products = [];
  List<ProductModel> get products => _products;

  List<ProductModel> _productsByUser = [];
  List<ProductModel> get productsByUser => _productsByUser;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  final ProductRepository _productRepository = ProductRepository();

  // Phương thức hiển thị thông báo ghim thành công
  void showSuccessMessage(String message, {BuildContext? context}) {
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(bottom: 10, left: 10, right: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  Future<void> createProduct(BuildContext context, ProductModel product,
      {List<File>? files}) async {
    LoadingOverlay.show(context);
    await executeApiCall(
      apiCall: () =>
          _productRepository.createProduct(product, context, files: files),
      context: context,
      onSuccess: () async {
        await getListProduct(context);
        Navigator.of(context).pop();
      },
      successMessage: 'Tạo sản phẩm thành công!',
    );
    LoadingOverlay.hide();
  }

  Future<void> getListProduct(BuildContext context) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      final response = await _productRepository.getListProduct(context);

      if (response.isSuccess && response.data is List) {
        _products = (response.data as List)
            .map((item) => ProductModel.fromJson(item))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      // Handle error appropriately
      print('Error fetching products: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  //edit product
  Future<void> editProduct(
    BuildContext context,
    ProductModel product, {
    List<File>? files,
    List<String>? deletedImages,
  }) async {
    LoadingOverlay.show(context);
    await executeApiCall(
      apiCall: () => _productRepository.editProduct(
        product,
        context,
        files: files,
        deletedImages: deletedImages,
      ),
      context: context,
      onSuccess: () async {
        await getListProduct(context);
        Navigator.of(context).pop();
      },
      successMessage: 'Cập nhật sản phẩm thành công!',
    );
    LoadingOverlay.hide();
  }

  //chỉnh sủa pin
  Future<void> editPinProduct(
    List<Map<String, dynamic>> pinData,
    BuildContext context,
  ) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      LoadingOverlay.show(context);

      final response =
          await _productRepository.editProductPin(pinData, context);

      if (response.isSuccess) {
        // Cập nhật state nếu cần
        //load lại danh sách sản phẩm
        await getListProduct(context);
        showSuccessMessage('Cập nhật ghim sản phẩm thành công', context: context);
        Navigator.of(context).pop();
      } else {
        print('Lỗi: ${response.message}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: ${response.message}')),
        );
      }
    } catch (e) {
      print('Lỗi khi cập nhật ghim sản phẩm: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi cập nhật ghim sản phẩm: $e')),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
      LoadingOverlay.hide();
    }
  }

  Future<void> deleteProduct(BuildContext context, String productId) async {
    LoadingOverlay.show(context);
    await executeApiCall(
      apiCall: () => _productRepository.deleteProduct(productId, context),
      context: context,
      onSuccess: () => getListProduct(context),
      successMessage: 'Xóa sản phẩm thành công!',
    );
    LoadingOverlay.hide();
  }

  //get list product by User ID
  Future<void> fetchListProductByUser(BuildContext context, String id) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      final response =
          await _productRepository.fetchListProductByUser(context, id);
      if (response.isSuccess) {
        if (response.isSuccess && response.data is List) {
          _productsByUser = (response.data as List)
              .map((item) => ProductModel.fromJson(item))
              .toList();
          notifyListeners();
        }
      } else {
        print('Error fetching products by user: ${response.message}');
      }
    } catch (e) {
      print('Error fetching products by user: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
