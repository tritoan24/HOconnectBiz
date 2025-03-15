import 'package:clbdoanhnhansg/models/is_join_model.dart';
import 'package:clbdoanhnhansg/providers/auth_provider.dart';
import 'package:clbdoanhnhansg/providers/business_op_provider.dart';
import 'package:clbdoanhnhansg/utils/icons/app_icons.dart';
import 'package:clbdoanhnhansg/utils/router/router.name.dart';
import 'package:clbdoanhnhansg/widgets/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../models/product_model.dart';
import '../../../../models/business_model.dart';
import '../../../../providers/post_provider.dart';
import '../../../business_opportunity_management/widget/waiting_list_approval.dart';
import '../../../details_image/details_image_screen.dart';
import '../../../home/widget/buy_product.dart';
import '../../../business_information/business_information.dart';
import '../../../comment/comments_screen.dart';
import 'package:clbdoanhnhansg/utils/Color/app_color.dart';

// Constants
const double _kPadding = 12.0;
const double _kBorderRadius = 16.0;
const double _kImageSize = 40.0;
const double _kProductImageSize = 88.0;
const double _kModalHeight = 0.7;

// Styles
const kContentTextStyle = TextStyle(fontSize: 14);
const kDisplayNameStyle = TextStyle(
    fontSize: 16, fontWeight: FontWeight.w700, overflow: TextOverflow.ellipsis);
const kDateTimeStyle = TextStyle(fontSize: 12, fontWeight: FontWeight.w400);
const kPriceStyle =
    TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.red);
const kDiscountStyle = TextStyle(
    fontSize: 12, fontWeight: FontWeight.w400, color: AppColor.textGrey);
const kProductTitleStyle = TextStyle(
    fontSize: 14, fontWeight: FontWeight.w400, color: AppColor.textDark);

class PostItem extends StatefulWidget {
  static final formatCurrency =
      NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

  final String postId;
  final int postType;
  final String displayName;
  final String avatar_image;
  final String dateTime;
  final String title;
  final String content;
  final List<String> images;
  final List<BusinessModel> business;
  final List<ProductModel> product;
  final List<String> likes;
  final int comments;
  final List<IsJoin>? isJoin;
  final bool isComment;
  final bool isMe;
  final String idUser;

  const PostItem({
    Key? key,
    required this.postId,
    required this.postType,
    required this.displayName,
    required this.avatar_image,
    required this.dateTime,
    required this.title,
    required this.content,
    required this.images,
    required this.business,
    required this.product,
    required this.likes,
    required this.comments,
    this.isJoin,
    this.isComment = false,
    this.isMe = false,
    required this.idUser,
  }) : super(key: key);

  @override
  _PostItemState createState() => _PostItemState();
}

class _PostItemState extends State<PostItem> {
  final storage = const FlutterSecureStorage();
  late int likeCount;
  bool isLiked = false;
  bool isJoind = false;
  String? idUserID;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    likeCount = widget.likes.length;
    _loadUserIdandStatusLikePost(authProvider);
    _loadUserStatusJoinBusiness(authProvider);
  }

  Future<void> _loadUserIdandStatusLikePost(AuthProvider authProvider) async {
    final userId = await authProvider.getuserID();
    setState(() {
      idUserID = userId ?? "";
      print("🔑 id user: $idUserID");
      print("🔑 like: ${widget.likes}");
      // Nếu idUserID có tồn tại trong mảng likes thì isLiked = true
      isLiked = widget.likes.contains(idUserID);
    });
  }

  Future<void> _loadUserStatusJoinBusiness(AuthProvider authProvider) async {
    final userId = await authProvider.getuserID();
    setState(() {
      idUserID = userId ?? "";
      print("🔑 id user: $idUserID");
      print("🔑 list user Join: ${widget.isJoin}");
      // Nếu idUserID có tồn tại trong mảng likes thì isLiked = true
      isJoind = widget.isJoin!.any((join) => join.user?.id == idUserID);
    });
  }

  // Hàm xử lý like/bỏ like
  void _likePost(BuildContext context) {
    final postProvider = Provider.of<PostProvider>(context, listen: false);

    setState(() {
      isLiked = !isLiked;
      likeCount += isLiked ? 1 : -1;
    });

    postProvider.toggleLike(widget.postId, context);
  }

  bool get isBusiness => widget.postType == 1;

  DateTime _parseCustomDateTime(String dateTime) {
    try {
      return DateFormat("dd/MM/yyyy HH:mm").parse(dateTime);
    } catch (e) {
      print("Error parsing date: $e");
      return DateTime.now();
    }
  }

  // Hàm chuyển sang màn chi tiết bài đăng
  void _navigateToDetailScreen(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChiTietBaiDang(
          imageList: widget.images,
          initialIndex: index,
          companyName: widget.displayName,
          like: widget.likes.length,
          comment: widget.comments,
          dateTime: widget.dateTime,
          description: widget.content,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Sử dụng giá trị isLiked và likeCount từ state đã được khởi tạo
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: _buildPostCard(context, isLiked),
    );
  }

  Widget _buildPostCard(BuildContext context, bool isLiked) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_kBorderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!widget.isComment) ...[
            _buildHeader(context),
            _buildDateTime(),
          ],
          _buildTitleAndContent(),
          _buildBusiness(context),
          _buildImages(),
          if (!isBusiness) _buildProductSection(context),
          _buildActions(context, isLiked),
        ],
      ),
    );
  }

  Widget _buildDateTime() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: _kPadding, vertical: 8),
      child: Text(
        DateFormat("HH:mm dd/MM/yyyy")
            .format(_parseCustomDateTime(widget.dateTime)),
        style: kDateTimeStyle,
      ),
    );
  }

  Widget _buildTitleAndContent() {
    return GestureDetector(
      onTap: () => _navigateToDetailScreen(0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: _kPadding, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.title, style: TextStyles.textStyleNormal14W700),
            const SizedBox(height: 8),
            Text(widget.content, style: kContentTextStyle),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToBusinessInfo(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: _kPadding, vertical: 8),
        child: Row(
          children: [
            _buildAvatar(),
            const SizedBox(width: 10),
            Text(widget.displayName, style: kDisplayNameStyle)
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(_kImageSize),
      child: Image.network(
        widget.avatar_image.isNotEmpty
            ? widget.avatar_image
            : UrlImage.errorImage,
        width: _kImageSize,
        height: _kImageSize,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            AppIcons.getBrokenImage(size: _kImageSize),
      ),
    );
  }

  Widget _buildImages() {
    if (widget.images.isEmpty) return const SizedBox();

    if (widget.images.length == 1) {
      return _buildSingleImage();
    } else if (widget.images.length == 2) {
      return _buildTwoImages();
    } else if (widget.images.length == 3) {
      return _buildThreeImages();
    } else {
      // For 4 or more images
      return _buildFourOrMoreImages();
    }
  }
// Cập nhật tất cả các hàm để hiển thị ảnh placeholder khi chờ tải

  Widget _buildFourOrMoreImages() {
    var imagesToShow = widget.images.take(4).toList();
    int remainingCount = widget.images.length - 4;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          // Top image
          AspectRatio(
            aspectRatio: 16 / 9,
            child: GestureDetector(
              onTap: () => _navigateToDetailScreen(0),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    imagesToShow[0],
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) {
                        return child;
                      }
                      return Image.asset(
                        'assets/icons/image_waiting.png',
                        fit: BoxFit.cover,
                        width: 30,
                        height: 30,
                      );
                    },
                    errorBuilder: (context, error, stackTrace) =>
                        AppIcons.getBrokenImage(size: _kProductImageSize),
                  ),
                ),
              ),
            ),
          ),

          // Bottom row with 3 images
          AspectRatio(
            aspectRatio: 16 / 5,
            child: Row(
              children: [
                for (int i = 1; i < 4; i++)
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _navigateToDetailScreen(i),
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                imagesToShow[i],
                                fit: BoxFit.cover,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) {
                                    return child;
                                  }
                                  return Image.asset(
                                    'assets/icons/image_waiting.png',
                                    width: 20,
                                    height: 20,
                                    // fit: BoxFit.cover,
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) =>
                                    AppIcons.getBrokenImage(size: _kProductImageSize),
                              ),
                            ),

                            // Overlay for the last image if there are more images
                            if (i == 3 && remainingCount > 0)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  color: Colors.black.withOpacity(0.5),
                                  child: Center(
                                    child: Text(
                                      '+$remainingCount',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
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

  Widget _buildThreeImages() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: AspectRatio(
        aspectRatio: 4 / 3,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 2,
              child: GestureDetector(
                onTap: () => _navigateToDetailScreen(0),
                child: _buildImageContainer(widget.images[0]),
              ),
            ),
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _navigateToDetailScreen(1),
                      child: _buildImageContainer(widget.images[1]),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _navigateToDetailScreen(2),
                      child: _buildImageContainer(widget.images[2]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTwoImages() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Row(
          children: widget.images.asMap().entries.map((entry) {
            int idx = entry.key;
            String image = entry.value;
            return Expanded(
              child: GestureDetector(
                onTap: () => _navigateToDetailScreen(idx),
                child: _buildImageContainer(image),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSingleImage() {
    return GestureDetector(
      onTap: () => _navigateToDetailScreen(0),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              widget.images[0],
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) {
                  return child;
                }
                return Image.asset(
                  'assets/icons/image_waiting.png',
                  // fit: BoxFit.cover,
                  width: 30,
                  height: 30,
                );
              },
              errorBuilder: (context, error, stackTrace) =>
                  AppIcons.getBrokenImage(size: _kProductImageSize),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageContainer(String imageUrl) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) {
              return child;
            }
            return Image.asset(
              'assets/icons/image_waiting.png',
              // fit: BoxFit.cover,
              width: 30,
              height: 30,
            );
          },
          errorBuilder: (context, error, stackTrace) =>
              AppIcons.getBrokenImage(size: _kProductImageSize),
        ),
      ),
    );
  }

  Widget _buildBusiness(BuildContext context) {
    if (!isBusiness || widget.business.isEmpty) return const SizedBox();

    return Wrap(
      spacing: 10.0,
      runSpacing: 10.0,
      children: widget.business.map((b) => _buildBusinessTag(b)).toList(),
    );
  }

  Widget _buildBusinessTag(BusinessModel business) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      margin: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppColor.secondaryBlue,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        business.title,
        style: TextStyles.textStyleNormal14W400,
      ),
    );
  }

  Widget _buildProductSection(BuildContext context) {
    if (widget.product.isEmpty) return const SizedBox();

    final ProductModel sanPham = widget.product.first;
    return Container(
      decoration: const BoxDecoration(color: AppColor.lightBlue),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: _buildProductContent(context, sanPham),
      ),
    );
  }

  Widget _buildProductContent(BuildContext context, ProductModel sanPham) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildProductImage(sanPham),
        const SizedBox(width: 10),
        Expanded(
          child: _buildProductDetails(context, sanPham),
        ),
      ],
    );
  }

  Widget _buildProductImage(ProductModel sanPham) {
    return sanPham.album.isNotEmpty
        ? Image.network(
            sanPham.album.first,
            width: _kProductImageSize,
            height: _kProductImageSize,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return AppIcons.getBrokenImage(size: _kProductImageSize);
            },
          )
        : AppIcons.getBrokenImage(size: _kProductImageSize);
  }

  Widget _buildProductDetails(BuildContext context, ProductModel sanPham) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Text(sanPham.title, style: kProductTitleStyle),
        if (sanPham.discount > 0) _buildDiscountInfo(sanPham),
        const SizedBox(height: 10),
        _buildPriceAndButton(context, sanPham),
      ],
    );
  }

  Widget _buildDiscountInfo(ProductModel sanPham) {
    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Text(
        "Chiết khấu ${sanPham.discount}% hội viên CLB",
        style: kDiscountStyle,
      ),
    );
  }

  Widget _buildPriceAndButton(BuildContext context, ProductModel sanPham) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          PostItem.formatCurrency.format(sanPham.price),
          style: kPriceStyle,
        ),
        if (!isBusiness & !widget.isMe) _buildPurchaseButton(context, sanPham),
      ],
    );
  }

  Widget _buildPurchaseButton(BuildContext context, ProductModel sanPham) {
    return GestureDetector(
      onTap: () => _navigateToPurchase(context, sanPham),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xff006AF5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          "Mua ngay",
          style: TextStyles.textStyleNormal14W500White,
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context, bool isLiked) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              _buildIconTextButton(
                isLiked
                    ? "assets/icons/heart_on.png"
                    : "assets/icons/icon_hear.png",
                likeCount,
                onTap: () => _likePost(context),
              ),
              _buildIconTextButton(
                "assets/icons/ichat.png",
                widget.comments,
                onTap: widget.isComment
                    ? null
                    : () => _navigateToComments(context),
              )
            ],
          ),
          isBusiness ? _buildButtonJoin() : _buildCart(context),
        ],
      ),
    );
  }

  Widget _buildIconTextButton(
    String icon,
    int count, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Image.asset(icon, width: 24, height: 24),
            const SizedBox(width: 10),
            Text("$count"),
          ],
        ),
      ),
    );
  }

  Widget _buildButtonJoin() {
    final businessProvider =
        Provider.of<BusinessOpProvider>(context, listen: false);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 20),
      child: widget.isMe
          ? GestureDetector(
              onTap: () {
                CompanyBottomSheet.show(context, isJoin: widget.isJoin ?? []);
              },
              child: SizedBox(
                height: 36,
                child: Row(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        SvgPicture.asset(
                          "assets/icons/icon_list.svg",
                          fit: BoxFit.cover,
                        ),
                        Positioned(
                          right: -8,
                          top: -8,
                          child: Container(
                            padding: const EdgeInsets.all(7),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              "${widget.isJoin?.where((join) => join.isAccept == false).length}",
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0),
                        child: Text("Chờ phê duyệt",
                            style: TextStyles.textStyleNormal12W500),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : isJoind
              ? Container(
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.blue[100], // Màu nhạt hơn
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AppIcons.getCheck(color: Colors.blue, size: 18),
                          const SizedBox(width: 5),
                          const Text(
                            "Đã đăng ký",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : GestureDetector(
                  onTap: () => {
                    businessProvider.joinBusiness(widget.postId, context),
                    setState(() {
                      isJoind = !isJoind;
                    })
                  },
                  child: Container(
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.blue, // Màu xanh đậm
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15.0),
                        child: Text(
                          "Đăng ký tham gia",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
    );
  }

  Widget _buildCart(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 20),
      child: GestureDetector(
        onTap: () => _showProductListModal(context),
        child: Container(
          height: 36,
          child: Row(
            children: [
              _buildCartIcon(),
              const Text(
                "Cửa hàng",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCartIcon() {
    return SizedBox(
      width: 45,
      height: 50,
      child: Stack(
        children: [
          SvgPicture.asset(
            "assets/icons/card.svg",
            fit: BoxFit.cover,
          ),
          Positioned(
            right: 5,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: Text(
                  "${widget.product.length}",
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  void _showProductListModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return _buildModalContent(context);
      },
    );
  }

  Widget _buildModalContent(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      height: MediaQuery.of(context).size.height * _kModalHeight,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildModalHeader(context),
          const Divider(),
          _buildProductsList(),
        ],
      ),
    );
  }

  Widget _buildModalHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "${widget.displayName} >",
          style: kDisplayNameStyle,
        ),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: AppIcons.getClose(size: 24),
        ),
      ],
    );
  }

  Widget _buildProductsList() {
    return Expanded(
      child: widget.product.isEmpty
          ? const Center(child: Text("Không có sản phẩm nào"))
          : ListView.builder(
              itemCount: widget.product.length,
              itemBuilder: (context, index) => _buildProductListItem(
                context,
                widget.product[index],
              ),
            ),
    );
  }

  Widget _buildProductListItem(BuildContext context, ProductModel sanPham) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: const Color(0xffEBF4FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: _buildProductContent(context, sanPham),
    );
  }

  // Navigation methods
  void _navigateToBusinessInfo(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BusinessInformation(
          idUser: widget.idUser,
        ),
      ),
    );
  }

  Future<void> _navigateToComments(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CommentsScreen(
          postId: widget.postId,
          postType: widget.postType,
          displayName: widget.displayName,
          avatar_image: widget.avatar_image,
          dateTime: widget.dateTime,
          title: widget.title,
          content: widget.content,
          images: widget.images,
          business: widget.business,
          product: widget.product,
          likes: widget.likes,
          commentCount: widget.comments,
          isComment: true,
          idUser: widget.idUser,
        ),
      ),
    );
    if (result == true) {
      Provider.of<PostProvider>(context, listen: false).fetchPosts(context);
    }
    // Trong _navigateToComments
    print("Navigating to comments for postId: ${widget.postId}");
  }

  void _navigateToPurchase(BuildContext context, ProductModel selectedProduct) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BuyProduct(
          product: selectedProduct,
          avatar_image: widget.avatar_image,
          displayName: widget.displayName,
        ),
      ),
    );
  }
}
