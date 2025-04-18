// Model class for order data
import 'dart:ui';
import 'package:clbdoanhnhansg/models/order_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import '../../../utils/Color/app_color.dart';
import '../chi_tiet_don_hang.dart';

class OrderCardData {
  final String productImage;
  final String productName;
  final int quantity;
  final int additionalItems;
  final double totalAmount;
  final String status;

  OrderCardData({
    required this.productImage,
    required this.productName,
    required this.quantity,
    required this.additionalItems,
    required this.totalAmount,
    required this.status,
  });

  // Factory constructor to create OrderCardData from OrderModel
  factory OrderCardData.fromOrderModel(OrderModel orderModel) {
    // Get product image from the first product in the list
    String productImage = '';
    if (orderModel.products.isNotEmpty &&
        orderModel.products.first.product.album.isNotEmpty) {
      productImage = orderModel.products.first.product.album.first;
    }

    // Get product name from the first product
    String productName = orderModel.products.isNotEmpty
        ? orderModel.products.first.product.title
        : "Sản phẩm";

    // Calculate additional items (excluding the first one)
    int additionalItems = orderModel.products.length - 1;
    // Map status code to text
    String statusText;
    switch (orderModel.status) {
      case 0:
        statusText = "Chờ xác nhận";
        break;
      case 1:
        statusText = "Chờ vận chuyển";
        break;
      case 2:
        statusText = "Đang xử lý";
        break;
      case 3:
        statusText = "Thành công";
      case 4:
        statusText = "Đã hủy";
        break;
      default:
        statusText = "Không xác định";
    }

    // Kiểm tra xem người đang xem có phải là người tạo đơn hàng hay không
    OrderModel order = orderModel;
    String? currentUserId = '';

    // Kiểm tra nếu currentUserId trùng với người tạo đơn hàng
    bool isCreator = currentUserId != null && currentUserId == order.userCreate;
    return OrderCardData(
      productImage: productImage,
      productName: productName,
      quantity: orderModel.totalProduct,
      additionalItems: additionalItems > 0 ? additionalItems : 0,
      totalAmount: orderModel.totalPay.toDouble(),
      status: statusText,
    );
  }
}

class OrderCard extends StatelessWidget {
  final OrderCardData data;
  final OrderModel donHang;
  final String? currentUserId;

  const OrderCard({
    Key? key,
    required this.data,
    required this.donHang,
    this.currentUserId,
  }) : super(key: key);

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color textColor;

    switch (status) {
      case "Chờ xác nhận":
        backgroundColor = AppColor.warningYellowBg;
        textColor = AppColor.warningYellow;
        break;
      case "Chờ vận chuyển":
        backgroundColor = AppColor.warningYellowBg;
        textColor = AppColor.warningYellow;
        break;
      case "Đang xử lý":
        backgroundColor = AppColor.warningYellowBg;
        textColor = AppColor.warningYellow;
        break;
      case "Thành công":
        backgroundColor = AppColor.successGreenBg;
        textColor = AppColor.successGreen;
        break;
      case "Đã hủy":
        backgroundColor = AppColor.errorRedBg;
        textColor = AppColor.cancelRed;
        break;
      default:
        backgroundColor = const Color(0xFFFEF9E1);
        textColor = const Color(0xFFE8BA02);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 37),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(100),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: textColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Kiểm tra xem người đang xem có phải là người tạo đơn hàng hay không
    OrderModel order = donHang as OrderModel;
    // Kiểm tra nếu currentUserId trùng với người tạo đơn hàng
    bool isCreator = currentUserId != null && currentUserId == order.userCreate;
    print('trạng thái: ' + data.status);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0x000fffff),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFD6D9DC),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFFEBF4FF),
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                SvgPicture.asset(
                  "assets/icons/speaker.svg",
                  fit: BoxFit.cover,
                ),
                const SizedBox(width: 8),
                Text(
                  isCreator
                      ? 'Bạn đã tạo đơn hàng'
                      : 'Bạn vừa nhận được đơn hàng',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Product image section
                SizedBox(
                  width: 60,
                  height: 60,
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          data.productImage,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.error);
                          },
                        ),
                      ),
                      if (data.additionalItems > 0)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                '+${data.additionalItems}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // Product description
                Expanded(
                  flex: 3,
                  child: Text(
                    data.productName,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),

                const SizedBox(width: 12),

                // "View details" button
                _buildStatusChip(data.status),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Tổng số lượng sản phẩm'),
                    Text(
                      data.quantity.toString(),
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Giá trị thanh toán',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      NumberFormat.currency(
                              locale: 'vi_VN', symbol: '₫', decimalDigits: 0)
                          .format(data.totalAmount),
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            margin:
                const EdgeInsets.only(top: 5, left: 12, right: 12, bottom: 5),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Color(0xFFD6D9DC), width: 1),
              ),
            ),
            child: InkWell(
              onTap: () {
                ChiTietDonHang.show(context, order, data.status,
                    hideButtons: isCreator);
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(
                  left: 40,
                  right: 40,
                  top: 12,
                  bottom: 8,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: const Color(0xFFEBF4FF),
                ),
                child: const Text(
                  'Xem chi tiết',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.blueAccent,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
