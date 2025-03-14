import 'auth_model.dart';
import 'order_model.dart';

class Message {
  final String? id;
  final Author? sender;
  final Author? receiver;
  final String content;
  final List<String> album;
  final bool read;
  final OrderModel? data;
  final DateTime timestamp;

  Message({
    this.id,
    this.sender,
    this.receiver,
    required this.content,
    this.album = const [],
    this.read = false,
    this.data,
    DateTime? timestamp,
  }) : this.timestamp = timestamp ?? DateTime.now();

  // Trong Message.fromJson
  factory Message.fromJson(Map<String, dynamic> json) {
    // Cải thiện cách xử lý dữ liệu
    List<String> albumList = [];
    if (json['album'] != null) {
      try {
        if (json['album'] is List) {
          albumList = List<String>.from(json['album']);
        } else if (json['album'] is String) {
          albumList = [json['album']];
        }
      } catch (e) {
        print("Lỗi xử lý album: $e");
      }
    }

    return Message(
      id: json['_id']?.toString(),
      sender: json['sender'] != null ? Author.fromJson(json['sender']) : null,
      receiver:
          json['receiver'] != null ? Author.fromJson(json['receiver']) : null,
      content: json['content']?.toString() ?? '',
      album: albumList,
      read: json['read'] == true,
      data: json['data'] != null ? OrderModel.fromJson(json['data']) : null,
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'album': album,
    };
  }

  String getFormattedTime() {
    return "${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}";
  }
}
//
// class MessageOrderData {
//   final String orderCode;
//   final List<String>? album;
//   final String? title;
//   final List<ProductModel>? product;
//   final String userCreate;
//   final String userReceive;
//   final int totalPay;
//   final int provisional;
//   final int totalProduct;
//   final int totalDiscount;
//   final int totalPayAfterDiscount;
//   final String paymentMethod;
//
//   MessageOrderData({
//     required this.orderCode,
//     this.album,
//     this.title,
//     this.product,
//     required this.userCreate,
//     required this.userReceive,
//     required this.totalPay,
//     required this.provisional,
//     required this.totalProduct,
//     required this.totalDiscount,
//     required this.totalPayAfterDiscount,
//     required this.paymentMethod,
//   });
//
//   factory MessageOrderData.fromJson(Map<String, dynamic> json) {
//     List<String>? albumList;
//     if (json['album'] != null) {
//       albumList = List<String>.from(json['album']);
//     }
//
//     List<ProductModel>? productList;
//     if (json['product'] != null) {
//       productList = (json['product'] as List)
//           .map((e) => ProductModel.fromJson(e))
//           .toList();
//     }
//
//     return MessageOrderData(
//       orderCode: json['orderCode'] ?? '',
//       album: albumList,
//       title: json['title'],
//       product: productList,
//       userCreate: json['user_create'] ?? '',
//       userReceive: json['user_receive'] ?? '',
//       totalPay: json['total_pay'] ?? 0,
//       provisional: json['provisional'] ?? 0,
//       totalProduct: json['total_product'] ?? 0,
//       totalDiscount: json['total_discount'] ?? 0,
//       totalPayAfterDiscount: json['total_pay_after_discount'] ?? 0,
//       paymentMethod: json['paymentMethod'] ?? 'cash',
//     );
//   }
//   OrderCardData toOrderCardData() {
//     // Get the first product image if available
//     String productImage = '';
//     if (album != null && album!.isNotEmpty) {
//       productImage = album!.first;
//     } else if (product != null &&
//         product!.isNotEmpty &&
//         product!.first.album != null &&
//         product!.first.album!.isNotEmpty) {
//       productImage = product!.first.album!.first;
//     }
//
//     // Get product name
//     String productName = title ??
//         (product != null && product!.isNotEmpty
//             ? product!.first.title ?? "Sản phẩm"
//             : "Sản phẩm");
//
//     // Calculate additional items
//     int additionalItems = (product?.length ?? 1) - 1;
//
//     return OrderCardData(
//       title: "BẠN VỪA NHẬN ĐƯỢC ĐƠN HÀNG",
//       productImage: productImage,
//       productName: productName,
//       quantity: totalProduct,
//       additionalItems: additionalItems > 0 ? additionalItems : 0,
//       totalAmount: totalPayAfterDiscount.toDouble(),
//       status: "Chờ xác nhận",
//     );
//   }
// }
