import 'package:clbdoanhnhansg/models/order_model.dart';
import 'package:clbdoanhnhansg/providers/cart_provider.dart';
import 'package:clbdoanhnhansg/utils/Color/app_color.dart';
import 'package:clbdoanhnhansg/utils/router/router.name.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../widgets/horizontal_divider.dart';
import '../../tin_mua_hang/chi_tiet_don_hang.dart';
import 'button_comfirm.dart';

class PurchaseOrderTab extends StatefulWidget {
  const PurchaseOrderTab({super.key});

  @override
  State<PurchaseOrderTab> createState() => _PurchaseOrderTabState();
}

class _PurchaseOrderTabState extends State<PurchaseOrderTab> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final provider = Provider.of<CartProvider>(context, listen: false);
    await provider.fetcOrderBuy(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF4F5F6),
      child: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          // Check if search is active
          final bool isSearching = cartProvider.lastSearchKeyword.isNotEmpty;
          final orders = isSearching
              ? cartProvider.searchResults
              : cartProvider.orderBuyList;

          if (cartProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (orders.isEmpty) {
            return RefreshIndicator(
              key: _refreshIndicatorKey,
              onRefresh: _loadData,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const SizedBox(height: 200),
                  Center(
                      child: Text(isSearching
                          ? "Không tìm thấy đơn hàng nào phù hợp"
                          : "Không có đơn hàng nào"))
                ],
              ),
            );
          }

          // For search results, show a simple list without month grouping
          if (isSearching) {
            return ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                return _buildOrderCard(orders[index], context);
              },
            );
          }

          // For regular view, group orders by month
          final Map<String, List<OrderModel>> ordersByMonth = {};

          for (var order in orders) {
            final monthKey = _getMonthKey(order.createdAt);

            if (!ordersByMonth.containsKey(monthKey)) {
              ordersByMonth[monthKey] = [];
            }
            ordersByMonth[monthKey]!.add(order);
          }

          return RefreshIndicator(
            key: _refreshIndicatorKey,
            onRefresh: _loadData,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
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
                    ...monthData
                        .map((order) => _buildOrderCard(order, context)),
                  ],
                );
              },
            ),
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
    // Get the first product image for display
    String imageUrl = '';
    if (order.products.isNotEmpty) {
      final albumUrl = order.products[0].product.album.isNotEmpty
          ? order.products[0].product.album[0]
          : '';
      if (albumUrl.startsWith('http')) {
        imageUrl = albumUrl;
      } else {
        imageUrl = 'assets/images/placeholder.png';
      }
    }

    // Calculate total product quantity
    int totalQuantity =
        order.products.fold(0, (sum, product) => sum + product.quantity);

    // Format price
    final priceFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    String formattedPrice = priceFormat.format(order.totalPay);

    // Get product name for display
    String productName = order.products.isNotEmpty
        ? order.products[0].product.title
        : "Sản phẩm không xác định";

    // Determine order status
    String status = _getOrderStatusText(order.status);

    return GestureDetector(
      onTap: () {
        ChiTietDonHang.show(context, order, status);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
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
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              productName,
                              style: const TextStyle(fontSize: 14),
                              maxLines: 5,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Mã đơn: ${order.orderCode}",
                              style: TextStyle(
                                  color: Colors.grey[600], fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: _buildStatusContainer(status),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tổng số lượng sản phẩm',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
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
                ],
              ),
            ),
            if (_shouldShowButtons(order)) _buildActionButtons(order),
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
      case 'chờ vận chuyển':
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
        return 'Chờ vận chuyển';
      case 2:
        return 'Đang xử lý';
      case 3:
        return 'Thành công';
      case 4:
        return 'Đã hủy';
      default:
        return 'Không xác định';
    }
  }

  bool _shouldShowButtons(OrderModel order) {
    final status = _getOrderStatusText(order.status);
    return status == 'Chờ xác nhận' ||
        status == 'Đang xử lý' ||
        status == 'Chờ vận chuyển' ||
        status == 'Đã hủy' ||
        status == 'Thành công';
  }

  Widget _buildActionButtons(OrderModel order) {
    final status = _getOrderStatusText(order.status);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    if (status == 'Chờ xác nhận') {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  // Cập nhật trạng thái sang "Đang xử lý" (status = 1)
                  _showConfirmDialog(
                    context: context,
                    title: 'Xác nhận mua hàng',
                    content: 'Bạn có chắc chắn muốn xác nhận mua đơn hàng này?',
                    onConfirm: () {
                      final cartProvider =
                          Provider.of<CartProvider>(context, listen: false);
                      cartProvider.updateStatusOrderBuy(order.id, 1, context);
                    },
                  );
                },
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
                onPressed: () {
                  // Cập nhật trạng thái sang "Đã hủy" (status = 3)
                  _showConfirmDialog(
                    context: context,
                    title: 'Hủy đơn hàng',
                    content: 'Bạn có chắc chắn muốn hủy đơn hàng này?',
                    onConfirm: () {
                      final cartProvider =
                          Provider.of<CartProvider>(context, listen: false);
                      cartProvider.updateStatusOrderBuy(order.id, 4, context);
                    },
                  );
                },
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
    } else if (status == 'Chờ vận chuyển') {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: ConfirmButtonWithAction(
          onConfirm: () {
            _showConfirmDialog(
              context: context,
              title: 'Xác nhận hoàn thành',
              content: 'Bạn xác nhận đã nhận được đơn hàng này?',
              onConfirm: () async {
                final cartProvider =
                    Provider.of<CartProvider>(context, listen: false);
                await cartProvider.updateStatusOrderBuy(order.id, 2, context);
              },
            );
          },
        ),
      );
    } else if (status == 'Đang xử lý') {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check,
              color: AppColor.primaryBlue,
            ),
            SizedBox(width: 8),
            Text(
              'Đã nhận hàng',
              style: TextStyle(
                  color: AppColor.primaryBlue, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    } else {
      return const SizedBox();
    }
  }

  void _showConfirmDialog({
    required BuildContext context,
    required String title,
    required String content,
    required Function onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Xác nhận',
                  style: TextStyle(color: Color(0xFF006AF5))),
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm();
              },
            ),
          ],
        );
      },
    );
  }
}
