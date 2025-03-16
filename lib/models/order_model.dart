import 'package:clbdoanhnhansg/models/product_model.dart';

import '../screens/tin_mua_hang/widgets/item_san_pham_mess.dart';

class OrderModel {
  final String id;
  final String orderCode;
  final List<OrderProduct> products;
  final String userCreate;
  final String userReceive;
  final int status;
  final int totalPay;
  final String paymentMethod;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int provisional;
  final int totalProduct;
  final double totalDiscount; // Chuyển sang double
  final double totalPayAfterDiscount; // Chuyển sang double

  OrderModel({
    required this.id,
    required this.orderCode,
    required this.products,
    required this.userCreate,
    required this.userReceive,
    required this.status,
    required this.totalPay,
    required this.paymentMethod,
    required this.createdAt,
    required this.updatedAt,
    this.provisional = 0,
    this.totalProduct = 0,
    this.totalDiscount = 0.0,
    this.totalPayAfterDiscount = 0.0,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['_id'] ?? '', // Tránh lỗi khi JSON không có _id
      orderCode: json['orderCode'] ?? '',
      products: (json['product'] as List? ?? [])
          .map((item) => OrderProduct.fromJson(item))
          .toList(),
      userCreate: json['user_create'] ?? '',
      userReceive: json['user_receive'] ?? '',
      status: json['status'] ?? 0, // Giá trị mặc định nếu thiếu
      totalPay: json['total_pay'] ?? 0,
      paymentMethod: json['paymentMethod'] ?? 'cash',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(), // Giá trị mặc định nếu thiếu
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(), // Giá trị mặc định nếu thiếu
      provisional: json['provisional'] ?? 0,
      totalProduct: json['total_product'] ?? 0,
      totalDiscount: (json['total_discount'] as num?)?.toDouble() ??
          0.0, // Ép kiểu tránh lỗi
      totalPayAfterDiscount:
          (json['total_pay_after_discount'] as num?)?.toDouble() ??
              0.0, // Ép kiểu tránh lỗi
    );
  }
}

class OrderProduct {
  final ProductModel product;
  final int quantity;

  OrderProduct({
    required this.product,
    required this.quantity,
  });

  factory OrderProduct.fromJson(Map<String, dynamic> json) {
    return OrderProduct(
      product: ProductModel.fromJson(json['product']),
      quantity: json['quantity'] ?? 1, // Mặc định 1 nếu thiếu
    );
  }
}
