import 'package:clbdoanhnhansg/models/order_model.dart';
import 'package:clbdoanhnhansg/providers/cart_provider.dart';
import 'package:clbdoanhnhansg/screens/tin_mua_hang/chi_tiet_don_hang.dart';
import 'package:clbdoanhnhansg/utils/router/router.name.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:clbdoanhnhansg/utils/Color/app_color.dart';

import '../../../widgets/horizontal_divider.dart';
import 'button_comfirm.dart';

class PurchaseOrderTab extends StatelessWidget {
  const PurchaseOrderTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF4F5F6),
      child: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          if (cartProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final orders = cartProvider.orderBuyList;

          if (orders.isEmpty) {
            return const Center(child: Text("Không có đơn hàng nào"));
          }

          // Group orders by month
          final Map<String, List<OrderModel>> ordersByMonth = {};

          for (var order in orders) {
            final monthKey = _getMonthKey(order.createdAt);

            if (!ordersByMonth.containsKey(monthKey)) {
              ordersByMonth[monthKey] = [];
            }
            ordersByMonth[monthKey]!.add(order);
          }

          return ListView.builder(
            itemCount: ordersByMonth.length,
            itemBuilder: (context, index) {
              final monthKey = ordersByMonth.keys.elementAt(index);
              final monthData = ordersByMonth[monthKey]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      monthKey,
                      style: GoogleFonts.roboto(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ...monthData.map((order) => _buildOrderCard(order, context)),
                ],
              );
            },
          );
        },
      ),
    );
  }

  String _getMonthKey(DateTime date) {
    final now = DateTime.now();

    // Nếu cùng tháng và năm với hiện tại thì là "Tháng này"
    if (date.year == now.year && date.month == now.month) {
      return 'Tháng này';
    }

    // Tất cả các tháng còn lại đều là "Tháng trước"
    return 'Tháng trước';
  }

  Widget _buildOrderCard(OrderModel order, BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildOrderItem(order, context),
          if (_shouldShowButtons(order)) _buildActionButtons(order),
        ],
      ),
    );
  }

  Widget _buildOrderItem(OrderModel order, BuildContext context) {
    // Get the first product image for display
    String imageUrl = '';
    if (order.products.isNotEmpty) {
      final albumUrl = order.products[0].product.album.isNotEmpty
          ? order.products[0].product.album[0]
          : '';
      // Check if the URL is a full URL or a local path
      if (albumUrl.startsWith('http')) {
        imageUrl = albumUrl;
      } else {
        // Use a placeholder if it's a local path that we can't load directly
        imageUrl = 'assets/images/placeholder.png';
      }
    }

    // Get product name for display
    String productName = order.products.isNotEmpty
        ? order.products[0].product.title
        : "Sản phẩm không xác định";

    // Calculate total product quantity
    int totalQuantity =
        order.products.fold(0, (sum, product) => sum + product.quantity);

    // Format price
    final priceFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    String formattedPrice = priceFormat.format(order.totalPay);

    // Determine order status
    String status = _getOrderStatusText(order.statusBuy);

    return GestureDetector(
      // onTap: () {
      //   ChiTietDonHang.show(context, order, status);
      // },
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Phần 1: Hình ảnh
                SizedBox(
                  width: 64,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: imageUrl.startsWith('http')
                        ? Image.network(
                            imageUrl,
                            width: 64,
                            height: 64,
                            fit: BoxFit.cover,
                            errorBuilder: (ctx, error, _) => Container(
                              width: 64,
                              height: 64,
                              color: Colors.grey[300],
                              child: const Icon(Icons.image_not_supported,
                                  color: Colors.grey),
                            ),
                          )
                        : Image.network(
                            UrlImage.errorImage,
                            width: 64,
                            height: 64,
                            fit: BoxFit.cover,
                          ),
                  ),
                ),

                // Phần 2: Tên sản phẩm
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        productName,
                        style: const TextStyle(fontSize: 16),
                        maxLines: 5,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Mã đơn: ${order.orderCode}",
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),

                // Phần 3: Trạng thái
                Expanded(
                  flex: 1,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: _buildStatusContainer(status),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Tổng số lượng sản phẩm',
                    style: TextStyle(color: Colors.grey[600])),
                Text('$totalQuantity'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Giá trị thanh toán',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  formattedPrice,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Container(
              margin: const EdgeInsets.only(top: 16),
              child: const HorizontalDivider(),
            )
          ],
        ),
      ),
    );
  }

  Container _buildStatusContainer(String status) {
    final statusColor = _getStatusColor(status);
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        status,
        style: TextStyle(color: statusColor, fontSize: 12),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'đang xử lý':
      case 'chờ xác nhận':
        return AppColor.warningYellow;
      case 'đã hủy':
        return AppColor.cancelRed;
      case 'thành công':
        return AppColor.successGreen;
      default:
        return Colors.grey; // Màu mặc định cho các status khác
    }
  }

  String _getOrderStatusText(int status) {
    switch (status) {
      case 0:
        return 'Chờ xác nhận';
      case 1:
        return 'Đang xử lý';
      case 2:
        return 'Thành công';
      case 3:
        return 'Đã hủy';
      default:
        return 'Không xác định';
    }
  }

  bool _shouldShowButtons(OrderModel order) {
    final status = _getOrderStatusText(order.statusBuy);
    return status == 'Chờ xác nhận' || status == 'Đang xử lý';
  }

  Widget _buildActionButtons(OrderModel order) {
    final status = _getOrderStatusText(order.statusBuy);

    if (status == 'Chờ xác nhận') {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF006AF5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0),
                child: const Text(
                  'Xác nhận mua hàng',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[200],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Hủy',
                  style: TextStyle(
                    color: Color(0xFF006AF5),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } else if (status == 'Đang xử lý') {
      return const Padding(
        padding: EdgeInsets.only(bottom: 16),
        child: ConfirmButton(),
      );
    }
    return const SizedBox.shrink();
  }
}

