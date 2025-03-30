import 'package:clbdoanhnhansg/providers/cart_provider.dart';
import 'package:clbdoanhnhansg/screens/cart/widget/purchase_order_tab.dart';
import 'package:clbdoanhnhansg/screens/cart/widget/sales_order_tab.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../utils/global_state.dart';
import '../../utils/router/router.name.dart';

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
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    // Khởi tạo TabController với tab ban đầu được chọn
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab.index,
    );
    super.initState();
    // Listen for tab changes to update search
    _tabController.addListener(_handleTabChange);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<CartProvider>(context, listen: false);
      provider.fetcOrderSale(context);
      provider.fetcOrderBuy(context);
    });
  }

  void _handleTabChange() {
    // If there's an active search, update it for the new tab
    if (_searchController.text.isNotEmpty) {
      _performSearch();
    }
  }

  void _performSearch() {
    final keyword = _searchController.text.trim();
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    // Determine the search type based on active tab
    String type = _tabController.index == 0 ? 'sell' : 'buy';

    if (keyword.isNotEmpty) {
      cartProvider.searchOrders(context, keyword, type);
    } else {
      cartProvider.clearSearchResults();
      // Reset to default lists
      if (_tabController.index == 0) {
        cartProvider.fetcOrderSale(context);
      } else {
        cartProvider.fetcOrderBuy(context);
      }
    }
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
          onPressed: () {
            // Check if we came from a notification
            if (GlobalAppState.launchedFromNotification) {
              // Navigate to home screen instead of just popping
              context.go(AppRoutes.trangChu.replaceFirst(':index', '0'));
              // Reset the flag
              GlobalAppState.launchedFromNotification = false;
            } else {
              // Normal back behavior
              Navigator.of(context).pop();
            }
          },
        ),
        title: Container(
          height: 40,
          margin: EdgeInsets.only(right: 30),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(20),
          ),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Tìm kiếm',
              hintStyle: const TextStyle(color: Colors.grey),
              prefixIcon: const Icon(
                Icons.search_outlined,
                color: Colors.grey,
              ),
              border: InputBorder.none,
              fillColor: Colors.grey,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon:
                          const Icon(Icons.clear, color: Colors.grey, size: 20),
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                        });
                        final cartProvider =
                            Provider.of<CartProvider>(context, listen: false);
                        cartProvider.clearSearchResults();
                        // Reset to default lists
                        if (_tabController.index == 0) {
                          cartProvider.fetcOrderSale(context);
                        } else {
                          cartProvider.fetcOrderBuy(context);
                        }
                      },
                    )
                  : null,
            ),
            onSubmitted: (value) {
              _performSearch();
            },
            onChanged: (value) {
              // If text becomes empty, fetch data
              if (value.isEmpty) {
                final cartProvider =
                    Provider.of<CartProvider>(context, listen: false);
                cartProvider.clearSearchResults();
                // Reset to default lists
                if (_tabController.index == 0) {
                  cartProvider.fetcOrderSale(context);
                } else {
                  cartProvider.fetcOrderBuy(context);
                }
              }
            },
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
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}
