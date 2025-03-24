import 'package:clbdoanhnhansg/models/order_model.dart';
import 'package:clbdoanhnhansg/providers/cart_provider.dart';
import 'package:clbdoanhnhansg/screens/cart/cart_tab.dart';
import 'package:clbdoanhnhansg/screens/tin_mua_hang/widgets/button.dart';
import 'package:clbdoanhnhansg/screens/tin_mua_hang/widgets/status_cho_xac_nhan_don_mua.dart';
import 'package:clbdoanhnhansg/screens/tin_mua_hang/widgets/status_done.dart';
import 'package:clbdoanhnhansg/utils/router/router.name.dart';
import 'package:clbdoanhnhansg/widgets/horizontal_divider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:clbdoanhnhansg/utils/Color/app_color.dart';
import 'package:provider/provider.dart';

final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

// double _calculatePriceAfterDiscount(double tamTinh, double chietKhau) {
//   double total = tamTinh - chietKhau;
//   return total;
// }

class ChiTietDonHang extends StatefulWidget {
  final OrderModel donHang;
  final String status;
  final bool hideButtons;

  const ChiTietDonHang({
    super.key,
    required this.donHang,
    required this.status,
    this.hideButtons = false,
  });

  static void show(BuildContext context, OrderModel donHang, String status,
      {bool hideButtons = false}) {
    print('Status: $status');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.9,
        child: ChiTietDonHang(
          donHang: donHang,
          status: status,
          hideButtons: hideButtons,
        ),
      ),
    );
  }

  @override
  State<ChiTietDonHang> createState() => _ChiTietDonHangState();
}

class _ChiTietDonHangState extends State<ChiTietDonHang> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);

      cartProvider.fetcOrderDetail(context, widget.donHang.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        // Drag Handle
        Container(
          width: 36,
          height: 4,
          margin: const EdgeInsets.only(bottom: 30, top: 20),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(10),
          ),
        ),

        // Thông tin đơn hàng
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            children: [
              _buildOrderDetailRow('Đơn hàng -', widget.donHang.orderCode),
            ],
          ),
        ),

        // Danh sách sản phẩm
        Flexible(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            child: Scrollbar(
              thumbVisibility: true,
              interactive: true,
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.all(16),
                itemCount: widget.donHang.products.length,
                itemBuilder: (context, index) {
                  final sp = widget.donHang.products[index];
                  return _buildProductDetailCard(
                      image: sp.product.album[0],
                      productName: sp.product.title,
                      quantity: sp.quantity,
                      price: sp.product.price.toDouble(),
                      phanTramChieuKhau: sp.product.discount);
                },
              ),
            ),
          ),
        ),

        // Tổng tiền
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  top: 16, bottom: 0, right: 16, left: 16),
              child: Column(children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Thanh toán',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
                _buildTotalRow(
                    'Tạm tính',
                    formatCurrency
                        .format(widget.donHang.provisional.toDouble())),
                _buildTotalRow('Tổng số lượng sản phẩm',
                    ((widget.donHang.totalProduct).toString())),
                _buildTotalRow(
                    'Chiết khấu',
                    formatCurrency
                        .format(-widget.donHang.totalDiscount.toDouble()),
                    isDiscount: true),
                _buildTotalRow(
                    'Giá sau chiết khấu',
                    formatCurrency
                        .format(widget.donHang.totalPayAfterDiscount)),
                const HorizontalDivider(),
                _buildTotalRow('Giá trị thanh toán',
                    formatCurrency.format(widget.donHang.totalPay),
                    isTotal: true),
              ]),
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: const HorizontalDivider(),
            )
          ],
        ),

        // Add this Consumer at the very bottom, before the closing Column child
        Consumer<CartProvider>(
          builder: (context, cartProvider, ___) {
            String statusText;
            switch (cartProvider.orderModel?.status) {
              case 0:
                statusText = "Chờ xác nhận";
                break;
              case 1:
                statusText = "Đang xử lý";
                break;
              case 2:
                statusText = "Thành công";
                break;
              case 3:
                statusText = "Đã hủy";
                break;
              default:
                statusText = "Không xác định";
            }
            return _buildStatusWidget(
                statusText, widget.donHang.id, widget.hideButtons, context);
          },
        ),
      ]),
    );
  }
}

Widget _buildOrderDetailRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      children: [
        Text(
          label,
          style: GoogleFonts.roboto(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.roboto(
            fontSize: 14,
          ),
        ),
      ],
    ),
  );
}

Widget _buildProductDetailCard({
  required String image,
  required String productName,
  required int quantity,
  required double price,
  required int phanTramChieuKhau,
}) {
  phanTramChieuKhau = phanTramChieuKhau ?? 0;
  return Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: AppColor.secondaryBlue,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        Image.network(
          image,
          width: 60,
          height: 60,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Image.network(
              UrlImage.errorImage,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            );
          },
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                productName,
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                'Số lượng: $quantity',
                style: GoogleFonts.roboto(
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                  color: Colors.black,
                ),
              ),
              Text(
                'Chiết khấu $phanTramChieuKhau% cho thành viên CLB',
                style: GoogleFonts.roboto(
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                    color: const Color(0xFFF1645F)),
              ),
              //giá tiền
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  formatCurrency.format(price),
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    color: AppColor.errorRed,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildTotalRow(String label, String value,
    {bool isDiscount = false, bool isTotal = false}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.roboto(
            fontSize: 15,
            color: isDiscount
                ? Colors.red
                : (isTotal ? Colors.black : Colors.grey[700]),
            fontWeight: isDiscount
                ? FontWeight.normal
                : (isTotal ? FontWeight.bold : FontWeight.normal),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.roboto(
            fontSize: 14,
            color: isDiscount
                ? Colors.red
                : (isTotal ? Colors.black : Colors.grey[800]),
            fontWeight: isDiscount
                ? FontWeight.normal
                : (isTotal ? FontWeight.bold : FontWeight.normal),
          ),
        ),
      ],
    ),
  );
}

Widget _buildStatusWidget(
    String status, String id, bool hideButtons, BuildContext context) {
  // Nếu hideButtons là true, không hiển thị các nút
  if (hideButtons) {
    if (status == "Đang xử lý") {
      return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const Cart(initialTab: CartTab.SaleOrder),
              ),
            );
          },
          child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.check,
                        color: AppColor.primaryBlue,
                      ),
                      Text(
                        'Đã được nhận mua hàng',
                        style: TextStyle(
                          color: AppColor.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                  Icon(Icons.arrow_forward_ios_rounded),
                ],
              )));
    } else if (status == "Đã hủy") {
      return ListTile(
        title: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Text(
            'Đã hủy',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Colors.red,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: Colors.grey,
          size: 34,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const Cart(initialTab: CartTab.SaleOrder),
              ));
        },
      );
    } else {
      return ListTile(
        title: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Text(
            'Đang chờ khách hàng xác nhận',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: Colors.grey,
          size: 34,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const Cart(initialTab: CartTab.SaleOrder),
              ));
        },
      );
    }
  }

  // Kiểm tra nếu status là "1"

  String statusLowerCase = status.toLowerCase();

  if (statusLowerCase == 'thành công') {
    return const StatusDone();
  } else if (statusLowerCase == 'chờ xác nhận') {
    return Button(
      id: id,
    );
  } else if (statusLowerCase == 'Chờ xác nhận tin mua') {
    return const StatusProcessing();
  } else if (statusLowerCase == 'đang xử lý') {
    return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  const Cart(initialTab: CartTab.PurchaseOrder),
            ),
          );
        },
        child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.check,
                      color: AppColor.primaryBlue,
                    ),
                    Text(
                      'Đã Xác nhận mua hàng',
                      style: TextStyle(
                        color: AppColor.primaryBlue,
                      ),
                    ),
                  ],
                ),
                Icon(Icons.arrow_forward_ios_rounded),
              ],
            )));
  } else if (statusLowerCase == "đã hủy") {
    return ListTile(
      title: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Text(
          'Đã hủy',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Colors.red,
          ),
          textAlign: TextAlign.center,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: Colors.grey,
        size: 34,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const Cart(initialTab: CartTab.SaleOrder),
            ));
      },
    );
  } else {
    return const SizedBox();
  }
}
