import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../models/product_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/button_widget.dart';
import '../../widgets/horizontal_divider.dart';
import '../../widgets/input_text.dart';
import '../post/widget/advertising_article/attached_product.dart';
import 'deltails_sales_article.dart';
import 'package:provider/provider.dart';
import 'package:clbdoanhnhansg/providers/product_provider.dart';
import '../../utils/router/router.name.dart';

class CreateOrder extends StatefulWidget {
  final String idRecive;
  final String? name;
  final String? avatar;
  const CreateOrder(
      {super.key, required this.idRecive, this.name, this.avatar});

  @override
  State<CreateOrder> createState() => _CreateOrderState();
}

class _CreateOrderState extends State<CreateOrder> {
  Map<ProductModel, bool> selectedProducts = {};
  List<ProductModel> selectedProductsList = [];
  List<ProductModel> poductsList = [];
  Map<ProductModel, int> productQuantities = {};
  double totalAmount = 0;
  int totalQuantity = 0;
  double totalDiscount = 0;
  String idRecive = '';
  TextEditingController totalAmountController = TextEditingController();

  //giá sau khi chiết khấu
  double totalAmountDiscount = 0;

  void updateSelectedProducts() {
    setState(() {
      selectedProductsList = poductsList
          .where((product) => selectedProducts[product] == true)
          .toList();
    });

    // Debug để kiểm tra
    print('Các sản phẩm đã chọn:');
    for (var product in selectedProductsList) {
      print('Title: ${product.title}');
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false)
          .getListProduct(context);
      final products =
          Provider.of<ProductProvider>(context, listen: false).products;
      for (var product in products) {
        selectedProducts[product] = false;
        productQuantities[product] = 1;
      }
    });
    // Add listener for currency formatting
    totalAmountController.addListener(_formatMoney);
  }

  final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
  // Hàm tính tổng tiền
  void calculateTotal() {
    double total = 0;
    int quantity = 0;
    double discountTotal = 0;

    for (var product in selectedProductsList) {
      int productQuantity = productQuantities[product] ?? 1;
      double discountAmount =
          (product.price * product.discount / 100) * productQuantity;
      total += product.price * productQuantity;
      quantity += productQuantity;
      discountTotal += discountAmount;
    }

    setState(() {
      totalAmount = total;
      totalQuantity = quantity;
      totalDiscount = discountTotal;
      totalAmountDiscount = total - discountTotal;
      totalAmountController.text =
          currencyFormatter.format(totalAmountDiscount);
    });
  }

  // Hàm cập nhật số lượng
  void updateQuantity(ProductModel product, int newQuantity) {
    setState(() {
      productQuantities[product] = newQuantity;
      calculateTotal();
    });
  }

  @override
  void dispose() {
    // Remove listener before disposing
    totalAmountController.removeListener(_formatMoney);
    totalAmountController.dispose();
    super.dispose();
  }

  void _formatMoney() {
    // Only format when the field is not focused
    if (!FocusScope.of(context).hasFocus) {
      String text =
          totalAmountController.text.replaceAll(RegExp(r'[^0-9]'), '');
      if (text.isNotEmpty) {
        String formatted = currencyFormatter.format(int.parse(text));
        if (formatted != totalAmountController.text) {
          totalAmountController.value = TextEditingValue(
            text: formatted,
            selection: TextSelection.collapsed(offset: formatted.length),
          );
        }
      }
    }
  }

  // Hàm để thêm sản phẩm đã chọn vào giỏ hàng
  void addToCart() {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    // Create a new list for cart items
    List<BuyProductModel> newCartItems = [];

    // Add selected products to the new list
    for (var product in selectedProductsList) {
      int quantity = productQuantities[product] ?? 1;

      // Make sure the ID format matches what the API expects (without 'product-' prefix if any)
      String productId = product.id ?? '';
      if (productId.startsWith('product-')) {
        productId =
            productId.substring(8); // Remove 'product-' prefix if it exists
      }

      // Create product model with correct format
      BuyProductModel productWithQuantity = BuyProductModel(
        id: productId,
        price: product.price,
        quantity: quantity,
        discount: product.discount,
      );

      newCartItems.add(productWithQuantity);
    }

    // Update the cart items at once
    cartProvider.setCartItems(newCartItems);

    // Update total pay
    // Xử lý giá trị từ input nếu người dùng đã thay đổi
    String rawInput = totalAmountController.text
        .replaceAll('₫', '')
        .replaceAll('.', '')
        .trim();
    double totalPayInput = double.tryParse(rawInput) ?? totalAmountDiscount;
    cartProvider.totalPay = totalPayInput;

    cartProvider.totalPay = totalPayInput;
    cartProvider.provisional = totalAmount;
    cartProvider.totalProduct = totalQuantity;
    cartProvider.totalDiscount = totalDiscount;
    cartProvider.totalPayAfterDiscount = totalAmountDiscount;
    cartProvider.receiverId = widget.idRecive;

    // Print debug info
    print("DEBUG - Added ${newCartItems.length} items to cart");
    print("DEBUG - Total pay: ${cartProvider.totalPay}");
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    poductsList = productProvider.products;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.5,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
        ),
        title: const Text('Tạo đơn bán'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    child: Text(
                      'Chọn sản phẩm đính kèm',
                      style: GoogleFonts.roboto(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        isDismissible: false,
                        context: context,
                        enableDrag: false,
                        builder: (BuildContext context) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0),
                                child: Column(
                                  children: <Widget>[
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text("Danh sách sản phẩm"),
                                        IconButton(
                                          onPressed: () {
                                            updateSelectedProducts();
                                            calculateTotal();
                                            Navigator.pop(context);
                                          },
                                          icon: const Icon(
                                            Icons.close,
                                            size: 24,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Divider(
                                      color: Colors.grey,
                                      thickness: 1,
                                      height: 1,
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Expanded(
                                      child: poductsList.isEmpty
                                          ? const Center(
                                              child:
                                                  Text('Không có sản phẩm nào'),
                                            )
                                          : ListView.builder(
                                              itemCount: poductsList.length,
                                              itemBuilder: (context, index) {
                                                final product =
                                                    poductsList[index];
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          bottom: 8.0),
                                                  child: SanPhamDinhKem(
                                                    sanPham: product,
                                                    choice: (value) {
                                                      setState(() {
                                                        selectedProducts[
                                                                product] =
                                                            value ?? false;
                                                      });
                                                    },
                                                    initialValue:
                                                        selectedProducts[
                                                                product] ??
                                                            false,
                                                  ),
                                                );
                                              },
                                            ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: const Color(0xFFEBF4FF),
                      ),
                      child: Text(
                        'Thêm sản phẩm',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.roboto(
                          color: Colors.blueAccent,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  // Hiển thị danh sách sản phẩm đã chọn
                  if (selectedProductsList.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      height: 230,
                      child: Scrollbar(
                        thickness: 6,
                        radius: Radius.circular(10),
                        child: ListView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          itemCount: selectedProductsList.length,
                          itemBuilder: (context, index) {
                            final product = selectedProductsList[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: ItemProductCreate(
                                sanPham: product,
                                quantity: productQuantities[product] ?? 1,
                                onQuantityChanged: (newQuantity) {
                                  updateQuantity(product, newQuantity);
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Column(
                      children: [
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          child: Text(
                            'Thanh toán:',
                            style: GoogleFonts.roboto(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Tạm tính:',
                              style: GoogleFonts.roboto(
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xff676767),
                              ),
                            ),
                            Text(
                              currencyFormatter.format(totalAmount),
                              style: GoogleFonts.roboto(
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xff141415),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Tổng số lượng sản phẩm:',
                              style: GoogleFonts.roboto(
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xff676767),
                              ),
                            ),
                            Text(
                              totalQuantity.toString(),
                              style: GoogleFonts.roboto(
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xff141415),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Chiết khấu:',
                              style: GoogleFonts.roboto(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: Colors.red,
                              ),
                            ),
                            Text(
                              currencyFormatter.format(totalDiscount),
                              style: GoogleFonts.roboto(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Giá sau khi chiết khấu:',
                              style: GoogleFonts.roboto(
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xff141415),
                              ),
                            ),
                            Text(
                              currencyFormatter
                                  .format(totalAmount - totalDiscount),
                              style: GoogleFonts.roboto(
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xff141415),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const HorizontalDivider(),
                        const SizedBox(height: 12),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Cài đặt giá trị đơn hàng",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            FocusScope(
                              child: Focus(
                                onFocusChange: (hasFocus) {
                                  if (hasFocus) {
                                    // When focused, display only raw numbers without any formatting
                                    String text = totalAmountController.text
                                        .replaceAll(RegExp(r'[^0-9]'), '');
                                    if (text.isNotEmpty) {
                                      totalAmountController.value =
                                          TextEditingValue(
                                        text: text,
                                        selection: TextSelection.collapsed(
                                            offset: text.length),
                                      );
                                    }
                                  } else {
                                    // When losing focus, apply full formatting including currency symbol
                                    String text = totalAmountController.text
                                        .replaceAll(RegExp(r'[^0-9]'), '');
                                    if (text.isNotEmpty) {
                                      String formatted = currencyFormatter
                                          .format(int.parse(text));
                                      totalAmountController.value =
                                          TextEditingValue(
                                        text: formatted,
                                        selection: TextSelection.collapsed(
                                            offset: formatted.length),
                                      );
                                    }
                                  }
                                },
                                child: FormBuilderTextField(
                                  controller: totalAmountController,
                                  name: 'orderValue',
                                  maxLines: null,
                                  keyboardType: TextInputType.number,
                                  textInputAction: TextInputAction.done,
                                  autovalidateMode: AutovalidateMode.always,
                                  // Remove any automatic formatting in the onChanged
                                  onChanged: (value) {
                                    // Prevent any automatic formatting during typing
                                  },
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    hintText: 'Nhập giá trị đơn hàng',
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: Color(0xFFE0E0E0),
                                        width: 1.0,
                                      ),
                                    ),
                                    hintStyle: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xFFE0E0E0),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                        color: Color(0xFFE0E0E0),
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    // suffixText: hasFocus ? null : 'đ',
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: selectedProductsList.isNotEmpty
          ? Container(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                height: 50,
                child: ButtonWidget(
                  label: "Tạo đơn",
                  onPressed: () async {
                    addToCart();
                    final cartProvider =
                        Provider.of<CartProvider>(context, listen: false);
                    await cartProvider.createBuild(context, widget.idRecive,
                        widget.name.toString(), widget.avatar.toString());
                  },
                ),
              ),
            )
          : null,
    );
  }
}

class ItemProductCreate extends StatelessWidget {
  final ProductModel sanPham;
  final int quantity;
  final Function(int) onQuantityChanged;

  const ItemProductCreate({
    Key? key,
    required this.sanPham,
    required this.quantity,
    required this.onQuantityChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currencyFormatter =
        NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFEBF4FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              sanPham.album.isNotEmpty
                  ? sanPham.album.first
                  : UrlImage.defaultProductImage,
              height: 88,
              width: 88,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Image.asset(
                  'assets/images/image_error.jpg',
                  height: 88,
                  width: 88,
                  fit: BoxFit.cover,
                );
              },
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sanPham.title,
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Chiết khấu ${sanPham.discount}% cho hội viên CLB',
                  style: GoogleFonts.roboto(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Colors.red,
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      currencyFormatter.format(sanPham.price),
                      style: GoogleFonts.roboto(
                        fontSize: 16,
                        color: Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: SvgPicture.asset(
                            "assets/icons/icongiam.svg",
                            fit: BoxFit.cover,
                          ),
                          onPressed: () {
                            if (quantity > 1) {
                              onQuantityChanged(quantity - 1);
                            }
                          },
                        ),
                        Text(
                          quantity.toString(),
                          style: GoogleFonts.roboto(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        IconButton(
                          icon: SvgPicture.asset(
                            "assets/icons/icontang.svg",
                            fit: BoxFit.cover,
                          ),
                          onPressed: () {
                            onQuantityChanged(quantity + 1);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
