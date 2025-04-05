import 'package:clbdoanhnhansg/models/is_join_model.dart';
import 'package:clbdoanhnhansg/providers/auth_provider.dart';
import 'package:clbdoanhnhansg/providers/business_op_provider.dart';
import 'package:clbdoanhnhansg/utils/icons/app_icons.dart';
import 'package:clbdoanhnhansg/utils/router/router.name.dart';
import 'package:clbdoanhnhansg/widgets/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../models/product_model.dart';
import '../../../../models/business_model.dart';
import '../../../../providers/post_provider.dart';
import '../../../../providers/product_provider.dart';
import '../../../../widgets/confirmdialog.dart';
import '../../../../widgets/showmenu.dart';
import '../../../business_opportunity_management/widget/waiting_list_approval.dart';
import '../../../details_image/details_image_screen.dart';
import '../../../home/widget/buy_product.dart';
import '../../../business_information/business_information.dart';
import '../../../comment/comments_screen.dart';
import 'package:clbdoanhnhansg/utils/Color/app_color.dart';
import 'package:clbdoanhnhansg/notifications/post_item_changed_notification.dart';
import 'package:clbdoanhnhansg/core/utils/date_time_utils.dart';

import '../../../manage/widget/post/edit_post.dart';

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
  final bool isF;
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
    this.isF = false,
    required this.idUser,
  }) : super(key: key);

  @override
  _PostItemState createState() => _PostItemState();
}

class _PostItemState extends State<PostItem> {
  final storage = const FlutterSecureStorage();
  late int likeCount;
  late int commentCount;
  bool isLiked = false;
  bool isJoind = false;
  String? idUserID;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    likeCount = widget.likes.length;
    commentCount = widget.comments;
    _loadUserIdandStatusLikePost(authProvider);
    _loadUserStatusJoinBusiness(authProvider);
  }

  @override
  void didUpdateWidget(PostItem oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Nếu danh sách likes hoặc comments thay đổi, cập nhật lại trạng thái
    if (oldWidget.likes.length != widget.likes.length ||
        oldWidget.comments != widget.comments) {
      setState(() {
        likeCount = widget.likes.length;
        commentCount = widget.comments;

        // Chỉ cập nhật isLiked nếu đã có idUserID
        if (idUserID != null && idUserID!.isNotEmpty) {
          isLiked = widget.likes.contains(idUserID);
        }
      });

      if (oldWidget.comments != widget.comments) {
        debugPrint(
            "🔍 DEBUG PostItem: Cập nhật từ didUpdateWidget - commentCount từ ${oldWidget.comments} thành ${widget.comments}");
      }

      if (oldWidget.likes.length != widget.likes.length) {
        debugPrint(
            "🔍 DEBUG PostItem: Cập nhật từ didUpdateWidget - likeCount=$likeCount, isLiked=$isLiked");
      }
    }
  }

  Future<void> _loadUserIdandStatusLikePost(AuthProvider authProvider) async {
    final userId = await authProvider.getuserID();
    final oldIsLiked = isLiked;
    final oldLikeCount = likeCount;

    setState(() {
      idUserID = userId ?? "";
      // Nếu idUserID có tồn tại trong mảng likes thì isLiked = true
      isLiked = widget.likes.contains(idUserID);
      likeCount = widget.likes.length;
    });
  }

  Future<void> _loadUserStatusJoinBusiness(AuthProvider authProvider) async {
    final userId = await authProvider.getuserID();
    setState(() {
      idUserID = userId ?? "";
      debugPrint("🔑 id user: $idUserID");
      debugPrint("🔑 list user Join: ${widget.isJoin}");
      if (widget.isJoin != null) {
        isJoind = widget.isJoin!.any((join) => join.user?.id == idUserID);
      }
    });
  }

  // Hàm xử lý like/bỏ like
  void _likePost(BuildContext context) {
    debugPrint(
        "🔍 DEBUG PostItem: _likePost bắt đầu cho postId: ${widget.postId}");

    final postProvider = Provider.of<PostProvider>(context, listen: false);
    final oldIsLiked = isLiked;
    final oldLikeCount = likeCount;

    // Cập nhật UI ngay lập tức để phản hồi nhanh với người dùng
    setState(() {
      isLiked = !isLiked;
      likeCount += isLiked ? 1 : -1;
    });

    debugPrint(
        "🔍 DEBUG PostItem: Trạng thái like thay đổi từ $oldIsLiked thành $isLiked");
    debugPrint(
        "🔍 DEBUG PostItem: Số lượng like thay đổi từ $oldLikeCount thành $likeCount");

    // Phát ra thông báo để cập nhật các màn hình khác
    PostItemChangedNotification(widget.postId, isLiked, isJoined: isJoind)
        .dispatch(context);

    // Gọi API để cập nhật trạng thái like trên server nhưng đánh dấu là không cập nhật UI
    postProvider.toggleLikeWithoutNotify(widget.postId, context).then((_) {
      debugPrint(
          "🔍 DEBUG PostItem: Đã gọi postProvider.toggleLikeWithoutNotify");
    }).catchError((error) {
      // Nếu có lỗi, khôi phục lại trạng thái gốc
      debugPrint("🔍 DEBUG PostItem: Lỗi khi gọi toggleLike: $error");
      // setState(() {
      //   isLiked = oldIsLiked;
      //   likeCount = oldLikeCount;
      // });
    });
  }

  bool get isBusiness => widget.postType == 1;

  DateTime _parseCustomDateTime(String dateTime) {
    try {
      final parsedDate = DateFormat("dd/MM/yyyy HH:mm").parse(dateTime);
      return DateTimeUtils.toLocalTime(parsedDate);
    } catch (e) {
      debugPrint("Error parsing date: $e");
      return DateTimeUtils.getCurrentTime();
    }
  }

  Widget _buildDateTime() {
    final dateTime = _parseCustomDateTime(widget.dateTime);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: _kPadding, vertical: 8),
      child: Text(
        DateTimeUtils.formatDateTime(dateTime, format: 'HH:mm, dd/MM/yyyy'),
        style: kDateTimeStyle,
      ),
    );
  }

  // Hàm chuyển sang màn chi tiết bài đăng
  void _navigateToDetailScreen(int index) {
    debugPrint(
        "🔍 DEBUG PostItem: _navigateToDetailScreen bắt đầu với index=$index");
    debugPrint("🔍 DEBUG PostItem: Truyền isLiked=$isLiked sang màn chi tiết");

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChiTietBaiDang(
          imageList: widget.images,
          postType: widget.postType,
          initialIndex: index,
          companyName: widget.displayName,
          like: widget.likes.length,
          comment: widget.comments,
          dateTime: widget.dateTime,
          description: widget.content,
          postId: widget.postId,
          title: widget.title,
          isLiked: isLiked,
          isMe: widget.isMe,
          isBusiness: isBusiness,
          likes: widget.likes,
          isJoin: widget.isJoin,
        ),
      ),
    ).then((result) {
      debugPrint(
          "🔍 DEBUG PostItem: Quay lại từ màn chi tiết với result=$result");

      // Nếu có sự thay đổi từ màn hình chi tiết (like, comment)
      if (result == true) {
        debugPrint(
            "🔍 DEBUG PostItem: Cập nhật UI sau khi quay lại từ màn chi tiết");

        // Lấy dữ liệu mới nhất từ provider mà không tải lại toàn bộ danh sách
        final postProvider = Provider.of<PostProvider>(context, listen: false);
        final updatedPost = postProvider.getPostById(widget.postId);

        if (updatedPost != null) {
          debugPrint("🔍 DEBUG PostItem: Đã lấy được dữ liệu mới từ provider");
          debugPrint(
              "🔍 DEBUG PostItem: Số lượng like mới: ${updatedPost.like?.length}");
          debugPrint(
              "🔍 DEBUG PostItem: Số lượng comment mới: ${updatedPost.totalComment}");

          // Cập nhật UI với dữ liệu mới
          setState(() {
            // Cập nhật số lượng comment và trạng thái like từ dữ liệu mới
            likeCount = updatedPost.like?.length ?? 0;
            // Cập nhật trạng thái isLiked nếu có idUserID
            if (idUserID != null && idUserID!.isNotEmpty) {
              isLiked = updatedPost.like?.contains(idUserID) ?? false;
            }
            debugPrint(
                "🔍 DEBUG PostItem: UI đã cập nhật với likeCount=$likeCount, isLiked=$isLiked");
          });
        } else {
          debugPrint(
              "⚠️ WARNING PostItem: Không lấy được dữ liệu mới từ provider");
          // Nếu không lấy được dữ liệu mới, vẫn cập nhật qua AuthProvider
          final authProvider =
              Provider.of<AuthProvider>(context, listen: false);
          _loadUserIdandStatusLikePost(authProvider);
        }
      }
    });

    debugPrint("🔍 DEBUG PostItem: _navigateToDetailScreen hoàn tất");
  }

  @override
  Widget build(BuildContext context) {
    // Sử dụng giá trị isLiked và likeCount từ state đã được khởi tạo
    debugPrint(
        "🔍 DEBUG PostItem build: postId=${widget.postId}, isLiked=$isLiked, likeCount=$likeCount");

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
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!widget.isComment) ...[
              _buildHeader(context),
              _buildDateTime(),
            ],
            _buildTitleAndContent(),
            if (widget.business.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                child: _buildBusiness(context),
              ),
            ],
            if (widget.images.isNotEmpty) ...[
              const SizedBox(height: 5),
              _buildImages(),
            ],
            if (!isBusiness) ...[
              const SizedBox(height: 8),
              _buildProductSection(context),
            ],
            _buildActions(context, isLiked),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleAndContent() {
    return GestureDetector(
      onTap: () => _navigateToComments(context, widget.isMe),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: _kPadding, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.title,
              style: TextStyles.textStyleNormal14W700,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              widget.content,
              style: kContentTextStyle,
              maxLines: widget.isF ? 1 : 100,
              overflow:
                  widget.isF ? TextOverflow.ellipsis : TextOverflow.visible,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return GestureDetector(
      onTap: () => widget.isMe ? null : _navigateToBusinessInfo(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: _kPadding, vertical: 8),
        child: Row(
          children: [
            _buildAvatar(),
            const SizedBox(width: 10),
            Text(widget.displayName, style: kDisplayNameStyle),
            const Spacer(),
            //dấu ...
            widget.isMe
                ? // Inside your PostItem widget
                MoreButton(
                    postId: widget.postId,
                    onEdit: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditPost(
                            imageList: widget.images,
                            postType: widget.postType,
                            description: widget.content,
                            postId: widget.postId,
                            title: widget.title,
                            isBusiness: isBusiness,
                            business: widget.business,
                            product: widget.product,
                          ),
                        ),
                      );
                    },
                    onDelete: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return CustomConfirmDialog(
                            content:
                                'Bạn có chắc chắn muốn xóa bài viết không?',
                            titleButtonLeft: 'Quay lại',
                            titleButtonRight: 'Xóa',
                            onConfirm: () {
                              final postProvider = Provider.of<PostProvider>(
                                  context,
                                  listen: false);
                              postProvider.deletePost(context, widget.postId);
                            },
                          );
                        },
                      );
                    },
                  )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(_kImageSize),
      child: CachedNetworkImage(
        imageUrl: widget.avatar_image.isNotEmpty
            ? widget.avatar_image
            : UrlImage.errorImage,
        width: _kImageSize,
        height: _kImageSize,
        fit: BoxFit.cover,
        errorWidget: (context, url, error) =>
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

  Widget _buildFourOrMoreImages() {
    var imagesToShow = widget.images.take(4).toList();
    int remainingCount = widget.images.length - 4;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: SizedBox(
        height: 262, // Fixed height
        child: Column(
          children: [
            // Top image (approximately 2/3 of height)
            Expanded(
              flex: 2,
              child: GestureDetector(
                onTap: () => _navigateToDetailScreen(0),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: imagesToShow[0],
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorWidget: (context, url, error) =>
                          AppIcons.getBrokenImage(size: _kProductImageSize),
                    ),
                  ),
                ),
              ),
            ),

            // Bottom row with 3 images (approximately 1/3 of height)
            Expanded(
              flex: 1,
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
                                child: CachedNetworkImage(
                                  imageUrl: imagesToShow[i],
                                  fit: BoxFit.cover,
                                  errorWidget: (context, url, error) =>
                                      AppIcons.getBrokenImage(
                                          size: _kProductImageSize),
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
      ),
    );
  }

  Widget _buildThreeImages() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: SizedBox(
        height: 262, // Fixed height
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
      child: SizedBox(
        height: 262, // Fixed height
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
      child: Container(
        height: 262, // Fixed height
        padding: const EdgeInsets.all(10),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: CachedNetworkImage(
            imageUrl: widget.images[0],
            width: double.infinity,
            fit: BoxFit.cover,
            errorWidget: (context, url, error) =>
                AppIcons.getBrokenImage(size: _kProductImageSize),
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
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorWidget: (context, url, error) =>
              AppIcons.getBrokenImage(size: _kProductImageSize),
        ),
      ),
    );
  }

  Widget _buildBusiness(BuildContext context) {
    if (!isBusiness || widget.business.isEmpty) return const SizedBox();

    return Wrap(
      spacing: 10,
      runSpacing: 10.0,
      children: widget.business.map((b) => _buildBusinessTag(b)).toList(),
    );
  }

  Widget _buildBusinessTag(BusinessModel business) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      // margin: const EdgeInsets.symmetric(horizontal: 10),
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
        ? CachedNetworkImage(
            imageUrl: sanPham.album.first,
            width: _kProductImageSize,
            height: _kProductImageSize,
            fit: BoxFit.cover,
            errorWidget: (context, url, error) =>
                AppIcons.getBrokenImage(size: _kProductImageSize),
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
        Expanded(
          // Để tự động xuống dòng nếu nội dung quá dài
          child: Text(
            PostItem.formatCurrency.format(sanPham.price),
            style: kPriceStyle,
            softWrap: true, // Cho phép xuống dòng
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (!isBusiness && !widget.isMe && widget.idUser != idUserID)
          _buildPurchaseButton(context, sanPham),
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
                commentCount,
                onTap: widget.isComment
                    ? null
                    : () => _navigateToComments(context, widget.isMe),
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
                CompanyBottomSheet.show(
                  context,
                  isJoin: widget.isJoin ?? [],
                  postId: widget.postId,
                  isPostItem: true,
                );
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
              : (widget.idUser == idUserID)
                  ? GestureDetector(
                      onTap: () {
                        CompanyBottomSheet.show(
                          context,
                          isJoin: widget.isJoin ?? [],
                          postId: widget.postId,
                          isPostItem: true,
                        );
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
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15.0),
                                child: Text("Chờ phê duyệt",
                                    style: TextStyles.textStyleNormal12W500),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : GestureDetector(
                      onTap: () {
                        setState(() {
                          isJoind = true;
                        });

                        // Gọi API để đăng ký tham gia
                        businessProvider.joinBusiness(widget.postId, context);

                        // Phát ra thông báo để cập nhật các màn hình khác
                        PostItemChangedNotification(widget.postId, isLiked,
                                isJoined: true)
                            .dispatch(context);

                        // Cập nhật trạng thái isJoin trong post provider
                        Provider.of<PostProvider>(context, listen: false)
                            .updatePostJoinStatus(widget.postId, context);
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

  Future<void> _navigateToComments(BuildContext context, bool isMe) async {
    debugPrint(
        "🔍 DEBUG PostItem: _navigateToComments bắt đầu cho postId: ${widget.postId}");

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
          commentCount: commentCount,
          isComment: true,
          isMe: isMe,
          idUser: widget.idUser,
          isJoin: widget.isJoin,
        ),
      ),
    );

    debugPrint(
        "🔍 DEBUG PostItem: Quay lại từ màn comments với result=$result");

    // Kiểm tra xem context có còn mounted không và Provider có sẵn không
    if (!context.mounted) {
      debugPrint("⚠️ WARNING PostItem: Context không còn mounted");
      return;
    }

    try {
      // Luôn cập nhật UI khi quay về từ màn hình comments để đảm bảo đồng bộ
      final postProvider = Provider.of<PostProvider>(context, listen: false);
      final updatedPost = postProvider.getPostById(widget.postId);

      if (updatedPost != null) {
        debugPrint("🔍 DEBUG PostItem: Đã lấy được dữ liệu mới từ provider");
        debugPrint(
            "🔍 DEBUG PostItem: Số lượng like mới: ${updatedPost.like?.length}");
        debugPrint(
            "🔍 DEBUG PostItem: Số lượng comment mới: ${updatedPost.totalComment}");
        debugPrint(
            "🔍 DEBUG PostItem: Số lượng isJoin mới: ${updatedPost.isJoin?.length}");

        // Cập nhật UI với dữ liệu mới
        setState(() {
          // Cập nhật số lượng comment và trạng thái like từ dữ liệu mới
          likeCount = updatedPost.like?.length ?? 0;
          commentCount = updatedPost.totalComment ?? 0;

          // Cập nhật trạng thái isLiked nếu có idUserID
          if (idUserID != null && idUserID!.isNotEmpty) {
            isLiked = updatedPost.like?.contains(idUserID) ?? false;
          }

          // Cập nhật trạng thái isJoind
          if (updatedPost.isJoin != null) {
            isJoind =
                updatedPost.isJoin!.any((join) => join.user?.id == idUserID);
            debugPrint(
                "🔍 DEBUG PostItem: Cập nhật trạng thái isJoind = $isJoind");
          }

          debugPrint(
              "🔍 DEBUG PostItem: UI đã cập nhật với likeCount=$likeCount, commentCount=$commentCount, isLiked=$isLiked");
        });
      } else {
        debugPrint(
            "⚠️ WARNING PostItem: Không lấy được dữ liệu mới từ provider");
        // Nếu không lấy được dữ liệu mới, vẫn cập nhật qua AuthProvider
        if (context.mounted) {
          final authProvider =
              Provider.of<AuthProvider>(context, listen: false);
          _loadUserIdandStatusLikePost(authProvider);
          _loadUserStatusJoinBusiness(authProvider);
        }
      }
    } catch (e) {
      debugPrint("⚠️ ERROR PostItem: Lỗi khi truy cập Provider: $e");
      // Xử lý trường hợp Provider không tồn tại hoặc lỗi khác
      if (context.mounted) {
        try {
          final authProvider =
              Provider.of<AuthProvider>(context, listen: false);
          _loadUserIdandStatusLikePost(authProvider);
          _loadUserStatusJoinBusiness(authProvider);
        } catch (authError) {
          debugPrint(
              "⚠️ ERROR PostItem: Lỗi khi truy cập AuthProvider: $authError");
        }
      }
    }

    debugPrint("🔍 DEBUG PostItem: _navigateToComments hoàn tất");
  }

  void _navigateToPurchase(BuildContext context, ProductModel selectedProduct) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BuyProduct(
          product: selectedProduct,
          idUser: widget.idUser,
          avatar_image: widget.avatar_image,
          displayName: widget.displayName,
        ),
      ),
    );
  }
}
