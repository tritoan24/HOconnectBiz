import 'package:clbdoanhnhansg/models/product_model.dart';
import 'package:clbdoanhnhansg/models/order_model.dart';
import 'package:clbdoanhnhansg/providers/cart_provider.dart';
import 'package:clbdoanhnhansg/screens/tin_mua_hang/chi_tiet_don_hang.dart';
import 'package:clbdoanhnhansg/utils/router/router.name.dart';
import 'package:clbdoanhnhansg/widgets/horizontal_divider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:clbdoanhnhansg/utils/Color/app_color.dart';

class SalesOrderTab extends StatefulWidget {
  const SalesOrderTab({super.key});

  @override
  State<SalesOrderTab> createState() => _SalesOrderTabState();
}

class _SalesOrderTabState extends State<SalesOrderTab> {
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
    await provider.fetcOrderSale(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F5F6),
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          if (cartProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // if (cartProvider.errorMessage!.isNotEmpty) {
          //   return Center(child: Text("lỗi"));
          // }

          final orders = cartProvider.orderSaleList;

          if (orders.isEmpty) {
            return RefreshIndicator(
              key: _refreshIndicatorKey,
              onRefresh: _loadData,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 200),
                  Center(child: Text("Không có đơn hàng nào"))
                ],
              ),
            );
          }

          // Group orders by month
          final Map<String, List<OrderModel>> ordersByMonth = {};

          for (var order in orders) {
            final monthYear = DateFormat('MM-yyyy').format(order.createdAt);
            final monthName = _getMonthName(monthYear);

            if (!ordersByMonth.containsKey(monthName)) {
              ordersByMonth[monthName] = [];
            }
            ordersByMonth[monthName]!.add(order);
          }

          // Tạo danh sách các mục để hiển thị
          final List<Widget> monthSections = [];
          ordersByMonth.forEach((month, orderList) {
            monthSections.add(
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  month,
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );

            for (var order in orderList) {
              monthSections.add(_buildOrderCard(context, order));
            }
          });

          return RefreshIndicator(
            key: _refreshIndicatorKey,
            onRefresh: _loadData,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: monthSections,
            ),
          );
        },
      ),
    );
  }

  String _getMonthName(String monthYear) {
    final parts = monthYear.split('-');
    final month = int.parse(parts[0]);
    final year = parts[1];

    if (DateFormat('MM-yyyy').format(DateTime.now()) == monthYear) {
      return 'Tháng này';
    } else if (DateFormat('MM-yyyy')
            .format(DateTime.now().subtract(const Duration(days: 30))) ==
        monthYear) {
      return 'Tháng trước';
    } else {
      return 'Tháng $month, $year';
    }
  }

  Widget _buildOrderCard(BuildContext context, OrderModel order) {
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
        // Assuming ChiTietDonHang expects an OrderModel, we pass the order object
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
                      _buildStatusChip(status),
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

  // Kiểm tra trạng thái của đơn hàng để quyết định có hiển thị các nút hành động không
  bool _shouldShowButtons(OrderModel order) {
    final status = _getOrderStatusText(order.status);
    return status == 'Đang xử lý';
  }

  // Hiển thị các nút hành động dựa trên trạng thái của đơn hàng
  Widget _buildActionButtons(OrderModel order) {
    final status = _getOrderStatusText(order.status);

    // Đơn hàng đang xử lý (status = 0) - hiển thị nút hoàn tất màu xám không có hành động
    if (status == 'Đang xử lý') {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: const HorizontalDivider(),
            ),
            ElevatedButton(
              onPressed: null, // Không có hành động khi nhấn nút
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE9EBED),
                minimumSize: const Size(double.infinity, 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Hoàn tất đơn hàng',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Đơn hàng sẽ được hoàn tất khi khách hàng xác nhận đã nhận được hàng',
              style: GoogleFonts.roboto(
                fontSize: 12,
                color: const Color(0XFFF1645F),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  String _getOrderStatusText(int status) {
    switch (status) {
      case 0:
        return 'Đang xử lý';
      case 1:
        return 'Thành công';
      case 2:
        return 'Đã hủy';
      default:
        return 'Không xác định';
    }
  }

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color textColor;

    switch (status.toLowerCase()) {
      case 'đang xử lý':
        backgroundColor = AppColor.warningYellowBg;
        textColor = AppColor.warningYellow;
        break;
      case 'thành công':
        backgroundColor = AppColor.successGreenBg;
        textColor = AppColor.successGreen;
        break;
      case 'đã hủy':
        backgroundColor = AppColor.errorRedBg;
        textColor = AppColor.cancelRed;
        break;
      default:
        backgroundColor = Colors.grey[100]!;
        textColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
        ),
      ),
    );
  }

  void _showConfirmDialog(BuildContext context, String title, String message,
      VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm();
              },
              child: const Text('Đồng ý',
                  style: TextStyle(color: Color(0xFF006AF5))),
            ),
          ],
        );
      },
    );
  }
}
