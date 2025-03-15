import 'package:clbdoanhnhansg/providers/cart_provider.dart';
import 'package:clbdoanhnhansg/screens/cart/widget/purchase_order_tab.dart';
import 'package:clbdoanhnhansg/screens/cart/widget/sales_order_tab.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Thêm enum để quản lý các tab
enum CartTab { SaleOrder, PurchaseOrder }

class Cart extends StatefulWidget {
  final CartTab initialTab;

  const Cart({
    super.key,
    this.initialTab = CartTab.SaleOrder, // Mặc định là tab Đơn bán
  });

  @override
  State<Cart> createState() => _CardState();
}

class _CardState extends State<Cart> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  @override
  void initState() {
    // Khởi tạo TabController với tab ban đầu được chọn
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab.index,
    );
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.grey,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Container(
          height: 40,
          margin: EdgeInsets.only(right: 30),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(20),
          ),
          child: const TextField(
            decoration: InputDecoration(
              hintText: 'Tìm kiếm',
              hintStyle: TextStyle(color: Colors.grey),
              prefixIcon: Icon(
                Icons.search_outlined,
                color: Colors.grey,
              ),
              border: InputBorder.none,
              fillColor: Colors.grey,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            ),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.blue,
          tabs: const [
            Tab(text: 'Đơn bán'),
            Tab(text: 'Đơn mua'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          SalesOrderTab(),
          PurchaseOrderTab(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

