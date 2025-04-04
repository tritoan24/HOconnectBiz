import 'package:clbdoanhnhansg/models/order_model.dart';
import 'package:clbdoanhnhansg/models/product_model.dart';
import 'package:clbdoanhnhansg/providers/user_provider.dart';
import 'package:clbdoanhnhansg/screens/tin_mua_hang/widgets/item_san_pham_mess.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/base/base_provider.dart';
import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../models/apiresponse.dart';
import '../repository/cart_repository.dart';
import '../screens/chat/deltails_sales_article.dart';
import '../utils/transitions/custom_page_transition.dart';
import '../widgets/loading_overlay.dart';
import 'auth_provider.dart';

class CartProvider extends BaseProvider {
  final CartRepository _repository = CartRepository();
  // Changed to make it accessible from outside
  final List<BuyProductModel> _cartItems = [];
  double totalPay = 0.0;
  double provisional = 0.0;
  int totalProduct = 0;
  double totalDiscount = 0;
  double totalPayAfterDiscount = 0.0;
  String receiverId = '';

  List<OrderModel> _searchResults = [];
  List<OrderModel> get searchResults => _searchResults;
  String _lastSearchKeyword = '';
  String get lastSearchKeyword => _lastSearchKeyword;

  List<OrderModel> _dataOderSale = [];
  List<OrderModel> get dataSale => _dataOderSale;

  List<OrderModel> _dataOderBuy = [];
  List<OrderModel> get dataBuy => _dataOderBuy;

  //loading
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<BuyProductModel> get cartItems => _cartItems;

  void clearCart() {
    _cartItems.clear();
    totalPay = 0.0;
    provisional = 0.0;
    totalProduct = 0;
    totalDiscount = 0.0;
    totalPayAfterDiscount = 0.0;
    receiverId = '';
    notifyListeners();
  }

  void addToCart(BuyProductModel product) {
    _cartItems.add(product);
    notifyListeners();
  }

  // Replace cart items with a new list
  void setCartItems(List<BuyProductModel> items) {
    _cartItems.clear();
    _cartItems.addAll(items);
    notifyListeners();
  }

  // ordersale
  List<OrderModel> _orderSaleList = [];
  bool _isLoadingOrderSale = false;
  String _errorMessageOrderSale = '';

  List<OrderModel> get orderSaleList => _orderSaleList;
  bool get isLoadingOrderSale => _isLoadingOrderSale;
  String get errorMessageOrderSale => _errorMessageOrderSale;

  // orderBuy
  List<OrderModel> _orderBuyList = [];
  bool _isLoadingOrderBuy = false;
  String _errorMessageOrderBuy = '';

  List<OrderModel> get orderBuyList => _orderBuyList;
  bool get isLoadingOrderBuy => _isLoadingOrderBuy;
  String get errorMessageOrderBuy => _errorMessageOrderBuy;

  Future<void> createBuild(
      BuildContext context, String userId, String name, String avatar) async {
    if (_cartItems.isEmpty) {
      setError("Giỏ hàng trống!");
      return;
    }

    // Debug: print the cart items before sending
    print("DEBUG - Cart items count: ${_cartItems.length}");
    for (var item in _cartItems) {
      print(
          "DEBUG - Item: productId=${item.id}, price=${item.price}, quantity=${item.quantity}, discount=${item.discount}");
    }

    LoadingOverlay.show(context);
    await executeApiCall(
      apiCall: () => _repository.placeOrder(
          _cartItems,
          userId,
          totalPay,
          provisional,
          totalProduct,
          totalDiscount,
          totalPayAfterDiscount,
          context),
      context: context,
      onSuccess: () async {
        _cartItems.clear();
        notifyListeners();
        String currentUserId;
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        currentUserId = (await authProvider.getuserID())!;
        Navigator.pushReplacement(
          context,
          CustomPageTransition(
            page: DeltailsSalesArticle(
              isCreate: true,
              currentUserId: currentUserId,
              idReceiver: receiverId,
              idMessage: receiverId,
              avatarImage: avatar,
              displayName: name,
            ),
            type: TransitionType.fade,
          ),
        );
      },
      successMessage: "Đặt hàng thành công!",
    );
    LoadingOverlay.hide();
  }

  // get list order sale
  Future<void> fetcOrderSale(BuildContext context) async {
    _isLoadingOrderSale = true;
    _errorMessageOrderSale = '';
    notifyListeners();

    try {
      final ApiResponse response = await _repository.getListOrderSale(context);

      if (response.isSuccess && response.data is List) {
        List<OrderModel> newList = (response.data as List)
            .map((json) => OrderModel.fromJson(json as Map<String, dynamic>))
            .toList();

        _orderSaleList = newList;
      } else {
        _errorMessageOrderSale = response.message ?? 'Không có dữ liệu';
        _orderSaleList.clear();
      }
    } catch (e) {
      _errorMessageOrderSale = "Lỗi khi tải dữ liệu: $e";
      _orderSaleList.clear();
    }

    _isLoadingOrderSale = false;
    notifyListeners();
  }

  // get list order buy
  Future<void> fetcOrderBuy(BuildContext context) async {
    // _isLoadingOrderBuy = true;
    _errorMessageOrderBuy = '';
    notifyListeners();

    try {
      final ApiResponse response = await _repository.getListOrderBuy(context);

      if (response.isSuccess && response.data is List) {
        List<OrderModel> newList = (response.data as List)
            .map((json) => OrderModel.fromJson(json as Map<String, dynamic>))
            .toList();

        _orderBuyList = newList;
      } else {
        _errorMessageOrderBuy = response.message ?? 'Không có dữ liệu';
        _orderBuyList.clear();
      }
    } catch (e) {
      _errorMessageOrderBuy = "Lỗi khi tải dữ liệu: $e";
      _orderBuyList.clear();
    }

    // _isLoadingOrderBuy = false;
    notifyListeners();
  }

  //update status order mua
  Future<void> updateStatusOrderBuy(
      String orderId, int status, BuildContext context) async {
    LoadingOverlay.show(context);
    await executeApiCall(
      apiCall: () => _repository.updateStatusOrderBuy(orderId, status, context),
      context: context,
      onSuccess: () async {
        await fetcOrderBuy(context);
        notifyListeners();
      },
      successMessage: "Cập nhật trạng thái đơn hàng thành công!",
    );
    LoadingOverlay.hide();
  }

  //update status order bán
  Future<void> updateStatusOrderSale(
      String orderId, int status, BuildContext context) async {
    LoadingOverlay.show(context);
    await executeApiCall(
      apiCall: () => _repository.updateStatusOrderBuy(orderId, status, context),
      context: context,
      onSuccess: () async {
        await fetcOrderSale(context);
        await Provider.of<UserProvider>(context, listen: false)
            .fetchUser(context, showLoading: false);
        notifyListeners();
      },
      successMessage: "Cập nhật trạng thái đơn hàng thành công!",
    );
    LoadingOverlay.hide();
  }

  OrderModel? orderModel;

  // get list order sale
  Future<void> fetcOrderDetail(BuildContext context, String orderId) async {
    // _isLoadingOrderSale = true;
    // _errorMessageOrderSale = '';
    notifyListeners();

    try {
      final ApiResponse response =
          await _repository.getOrderDetail(context, orderId);

      if (response.isSuccess && response.data is Map<String, dynamic>) {
        Map<String, dynamic> data = response.data as Map<String, dynamic>;

        orderModel = OrderModel.fromJson(data);
      } else {
        // _errorMessageOrderSale = response.message ?? 'Không có dữ liệu';
        // _orderSaleList.clear();
      }
    } catch (e) {
      // _errorMessageOrderSale = "Lỗi khi tải dữ liệu: $e";
      // _orderSaleList.clear();
    }

    // _isLoadingOrderSale = false;
    notifyListeners();
  }

  // Phương thức tìm kiếm đơn hàng
  Future<void> searchOrders(
      BuildContext context, String keyword, String type) async {
    // When keyword is empty, clear search results and fetch original data
    if (keyword.trim().isEmpty) {
      _searchResults = [];
      _lastSearchKeyword = '';

      // Fetch appropriate data based on type
      if (type == 'sell') {
        await fetcOrderSale(context);
      } else if (type == 'buy') {
        await fetcOrderBuy(context);
      }

      notifyListeners();
      return;
    }

    _isLoading = true;
    _lastSearchKeyword = keyword;
    notifyListeners();

    try {
      // Create request body with type parameter
      Map<String, dynamic> body = {'keyword': keyword, 'type': type};

      // Send POST request to API
      final response = await ApiClient().postRequest(
        ApiEndpoints.oderDetail,
        body,
        context,
      );

      if (response != null && response.containsKey('data')) {
        List ordersData = response['data'] ?? [];

        // Convert JSON data to OrderModel objects
        _searchResults =
            ordersData.map((order) => OrderModel.fromJson(order)).toList();
        debugPrint('Found ${_searchResults.length} orders matching "$keyword"');
      } else {
        _searchResults = [];
        debugPrint('No orders found matching "$keyword"');
      }
    } catch (e) {
      debugPrint('Error searching orders: $e');
      _searchResults = [];
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã xảy ra lỗi khi tìm kiếm: $e')),
      );
    }

    _isLoading = false;
    notifyListeners();
  }

  // Clear search results
  void clearSearchResults() {
    _searchResults = [];
    _lastSearchKeyword = '';
    notifyListeners();
  }
}
