import 'package:clbdoanhnhansg/models/order_model.dart';
import 'package:clbdoanhnhansg/screens/tin_mua_hang/widgets/button.dart';
import 'package:clbdoanhnhansg/screens/tin_mua_hang/widgets/status_cho_xac_nhan_don_mua.dart';
import 'package:clbdoanhnhansg/screens/tin_mua_hang/widgets/status_done.dart';
import 'package:clbdoanhnhansg/utils/router/router.name.dart';
import 'package:clbdoanhnhansg/widgets/horizontal_divider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

double _calculatePriceAfterDiscount(double tamTinh, double chietKhau) {
  double total = tamTinh - chietKhau;
  return total;
}

class ChiTietDonHang extends StatelessWidget {
  final OrderModel donHang;
  final String status;

  const ChiTietDonHang({
    super.key,
    required this.donHang,
    required this.status,
  });

  static void show(BuildContext context, OrderModel donHang, String status) {
    print('Status: $status');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.9,
        child: ChiTietDonHang(donHang: donHang, status: status),
      ),
    );
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
              _buildOrderDetailRow('Đơn hàng -', donHang.id),
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
                itemCount: donHang.products.length,
                itemBuilder: (context, index) {
                  final sp = donHang.products[index];
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
                _buildTotalRow('Tạm tính',
                    formatCurrency.format(donHang.provisional.toDouble())),
                _buildTotalRow('Tổng số lượng sản phẩm',
                    ((donHang.totalProduct).toString())),
                _buildTotalRow('Chiết khấu',
                    formatCurrency.format(-donHang.totalDiscount.toDouble()),
                    isDiscount: true),
                _buildTotalRow('Giá sau chiết khấu',
                    formatCurrency.format(donHang.totalPayAfterDiscount)),
                const HorizontalDivider(),
                _buildTotalRow('Giá trị thanh toán',
                    formatCurrency.format(donHang.totalPay),
                    isTotal: true),
              ]),
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: const HorizontalDivider(),
            )
          ],
        ),
        // kiểm tra các trạng thái và dựa vào đó để hiển thị ra giao diện
        _buildStatusWidget(status, donHang.id)
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
      color: const Color(0xFFD6E9FF),
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
                  '${formatCurrency.format(price)}',
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    color: const Color(0xFFDC1F18),
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

Widget _buildStatusWidget(String status, String id) {
  String statusLowerCase = status.toLowerCase();

  if (statusLowerCase == 'thành công') {
    return const StatusDone();
  } else if (statusLowerCase == 'chờ xác nhận') {
    return Button(
      id: id,
    );
  } else if (statusLowerCase == 'Chờ xác nhận tin mua') {
    return const StatusProcessing();
  } else {
    return const SizedBox();
  }
}

