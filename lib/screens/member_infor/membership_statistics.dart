import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import '../../providers/StatisticalProvider.dart';
import '../../widgets/text_styles.dart';
import '../../utils/Color/app_color.dart';
import '../business_information/business_information.dart';

class MemberStatistics extends StatefulWidget {
  const MemberStatistics({super.key});

  @override
  State<MemberStatistics> createState() => _MemberStatisticsState();
}

class _MemberStatisticsState extends State<MemberStatistics> {
  final ScrollController _scrollController = ScrollController();
  final ScrollController _headerScrollController = ScrollController();

  final BoxDecoration cellDecoration2 = BoxDecoration(
    color: const Color(0x00e9ebed),
    border: Border.all(
      color: AppColor.borderGrey,
      width: 0.5,
    ),
  );

  final BoxDecoration headerCellDecoration = BoxDecoration(
    color: AppColor.secondaryBlue,
    border: Border.all(
      color: AppColor.borderGrey,
      width: 0.5,
    ),
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Fetch data when the widget is built
      Provider.of<StatisticalProvider>(context, listen: false)
          .fetchStatistics(context);
    });

    // Sync both scroll controllers
    _scrollController.addListener(() {
      _headerScrollController.jumpTo(_scrollController.offset);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundColorApp,
      appBar: AppBar(
        title: const Text('Thống kê thành viên CLB'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Consumer<StatisticalProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return Center(
              child: Lottie.asset(
                'assets/lottie/loading.json',
                width: 70,
                height: 70,
                fit: BoxFit.contain,
              ),
            );
          }

          final data = provider.statistics;
          final currentPage = provider.currentPage;
          final totalMembers = provider.totalMembers;
          final totalPages = (totalMembers / provider.limit).ceil();

          return Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Container(
                            height: 100,
                            color: Colors.blue[50],
                            child: Row(
                              children: [
                                // Left fixed section (Rank and Company)
                                SizedBox(
                                  width: 230,
                                  height: 100,
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 50,
                                        height: 100,
                                        padding: const EdgeInsets.only(left: 8),
                                        decoration: headerCellDecoration,
                                        child: Center(
                                            child: Text('Thứ hạng',
                                                style: TextStyles
                                                    .titleStyleColumnW600)),
                                      ),
                                      Container(
                                        width: 180,
                                        height: 100,
                                        decoration: headerCellDecoration,
                                        child: Center(
                                            child: Text('Doanh nghiệp',
                                                style: TextStyles
                                                    .titleStyleColumnW600)),
                                      ),
                                    ],
                                  ),
                                ),
                                // Right scrollable header
                                Expanded(
                                  child: SingleChildScrollView(
                                    controller: _headerScrollController,
                                    scrollDirection: Axis.horizontal,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    child: Container(
                                      width: 300,
                                      height: 100,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            height: 50,
                                            decoration: headerCellDecoration,
                                            child: Center(
                                              child: Text(
                                                  'Số cơ hội kinh doanh',
                                                  style: TextStyles
                                                      .titleStyleColumnW600),
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              Container(
                                                width: 100,
                                                height: 50,
                                                decoration:
                                                    headerCellDecoration,
                                                child: Center(
                                                    child: Text('Đã tạo ra',
                                                        style: TextStyles
                                                            .titleStyleColumnW600)),
                                              ),
                                              Container(
                                                width: 100,
                                                height: 50,
                                                decoration:
                                                    headerCellDecoration,
                                                child: Center(
                                                    child: Text('Tham gia',
                                                        style: TextStyles
                                                            .titleStyleColumnW600)),
                                              ),
                                              Container(
                                                width: 100,
                                                height: 50,
                                                decoration:
                                                    headerCellDecoration,
                                                child: Center(
                                                    child: Text('Đã đóng góp',
                                                        style: TextStyles
                                                            .titleStyleColumnW600)),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Data rows

                          Expanded(
                            child: SingleChildScrollView(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Left fixed section
                                  SizedBox(
                                    width: 230,
                                    child: Column(
                                      children: data
                                          .map((item) => GestureDetector(
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          BusinessInformation(
                                                        idUser: item.id,
                                                        isMe: false,
                                                      ),
                                                    ),
                                                  );
                                                },
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      width: 50,
                                                      height: 70,
                                                      decoration: BoxDecoration(
                                                        color: const Color(
                                                            0xffEBF4FF),
                                                        border: Border.all(
                                                          color: AppColor
                                                              .borderGrey,
                                                          width: 0.5,
                                                        ),
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                          item.rank.toString(),
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      width: 180,
                                                      height: 70,
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 8),
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        border: Border.all(
                                                          color: AppColor
                                                              .borderGrey,
                                                          width: 0.5,
                                                        ),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Color(
                                                                    0xffE9EBED)
                                                                .withOpacity(
                                                                    0.5),
                                                            offset: const Offset(
                                                                15,
                                                                2), // Rất nhỏ, chỉ đủ để tạo hiệu ứng ở bên phải
                                                            blurRadius:
                                                                15, // Không làm mờ để tạo đường viền sắc nét
                                                            spreadRadius: 0,
                                                          ),
                                                        ],
                                                      ),
                                                      child: Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          Container(
                                                            width: 24,
                                                            height: 24,
                                                            margin:
                                                                const EdgeInsets
                                                                    .only(
                                                                    right: 8),
                                                            decoration:
                                                                BoxDecoration(
                                                              shape: BoxShape
                                                                  .circle,
                                                              color: Colors.grey
                                                                  .withOpacity(
                                                                      0.2),
                                                            ),
                                                            clipBehavior:
                                                                Clip.antiAlias,
                                                            child: item
                                                                    .avatarImage
                                                                    .isNotEmpty
                                                                ? Image.network(
                                                                    item.avatarImage,
                                                                    fit: BoxFit
                                                                        .cover,
                                                                    errorBuilder:
                                                                        (context,
                                                                            error,
                                                                            stackTrace) {
                                                                      return const Icon(
                                                                        Icons
                                                                            .business,
                                                                        size:
                                                                            20,
                                                                        color: Colors
                                                                            .grey,
                                                                      );
                                                                    },
                                                                  )
                                                                : const Icon(
                                                                    Icons
                                                                        .business,
                                                                    size: 20,
                                                                    color: Colors
                                                                        .grey,
                                                                  ),
                                                          ),
                                                          Expanded(
                                                            child: Text(
                                                              (item.displayName !=
                                                                      null)
                                                                  ? item.displayName
                                                                          .isNotEmpty
                                                                      ? item
                                                                          .displayName
                                                                      : "Chưa cập nhật"
                                                                  : "Chưa cập nhật",
                                                              maxLines: 2,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: GoogleFonts
                                                                  .roboto(
                                                                fontSize: 14,
                                                                height: 1.2,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ))
                                          .toList(),
                                    ),
                                  ),
                                  // Right scrollable section
                                  Expanded(
                                    child: SingleChildScrollView(
                                      controller: _scrollController,
                                      scrollDirection: Axis.horizontal,
                                      child: SizedBox(
                                        width: 300,
                                        child: Column(
                                          children: data
                                              .map((item) => Container(
                                                    child: Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        Container(
                                                          width: 100,
                                                          height: 70,
                                                          decoration:
                                                              cellDecoration2,
                                                          child: Center(
                                                            child: Text(
                                                              item.create
                                                                  .toString(),
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                            ),
                                                          ),
                                                        ),
                                                        Container(
                                                          width: 100,
                                                          height: 70,
                                                          decoration:
                                                              cellDecoration2,
                                                          child: Center(
                                                            child: Text(
                                                              item.join
                                                                  .toString(),
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                            ),
                                                          ),
                                                        ),
                                                        Container(
                                                          width: 100,
                                                          height: 70,
                                                          decoration:
                                                              cellDecoration2,
                                                          child: Center(
                                                            child: Text(
                                                              NumberFormat
                                                                  .currency(
                                                                locale: 'vi_VN',
                                                                symbol: '₫',
                                                                decimalDigits:
                                                                    0,
                                                              ).format(
                                                                  item.total),
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: GoogleFonts
                                                                  .roboto(
                                                                fontSize: 14,
                                                                height: 1.2,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ))
                                              .toList(),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Pagination
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 3,
                          offset: const Offset(0, -1),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 29, // Fixed width
                              height: 32, // Fixed height
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: const Color(0xffD6D6D6)),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: IconButton(
                                padding: EdgeInsets.zero, // Remove padding
                                constraints:
                                    const BoxConstraints(), // Remove constraints
                                icon: const Icon(Icons.chevron_left),
                                onPressed: currentPage > 1
                                    ? () => provider.fetchStatistics(context,
                                        page: currentPage - 1)
                                    : null,
                              ),
                            ),
                            for (int i = 1; i <= totalPages; i++)
                              if (i == 1 ||
                                  i == totalPages ||
                                  (i >= currentPage - 1 &&
                                      i <= currentPage + 1))
                                PaginationNumber(
                                  number: i,
                                  isSelected: i == currentPage,
                                  onTap: () => provider.fetchStatistics(context,
                                      page: i),
                                )
                              else if (i == currentPage - 2 ||
                                  i == currentPage + 2)
                                Center(
                                  child: Container(
                                      alignment: Alignment.center,
                                      height: 32, // Match button height
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 4),
                                      child: const Image(
                                          width: 17,
                                          image: AssetImage(
                                              'assets/icons/more.png'))),
                                ),
                            Container(
                              width: 29, // Fixed width
                              height: 32, // Fixed height
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: const Color(0xffD6D6D6)),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: IconButton(
                                padding: EdgeInsets.zero, // Remove padding
                                constraints:
                                    const BoxConstraints(), // Remove constraints
                                icon: const Icon(Icons.chevron_right),
                                onPressed: currentPage < totalPages
                                    ? () => provider.fetchStatistics(context,
                                        page: currentPage + 1)
                                    : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                            children: [
                              const TextSpan(text: 'Tổng số '),
                              TextSpan(
                                text: '$totalMembers',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              const TextSpan(text: ' thành viên CLB'),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
              if (provider.isPageLoading)
                Container(
                  color: Colors.black.withOpacity(0.1),
                  child: Center(
                    child: Lottie.asset(
                      'assets/lottie/loading.json',
                      width: 70,
                      height: 70,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _headerScrollController.dispose();
    super.dispose();
  }
}

class PaginationNumber extends StatelessWidget {
  final int number;
  final bool isSelected;
  final VoidCallback onTap;

  const PaginationNumber({
    super.key,
    required this.number,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isSelected ? Colors.blue : const Color(0xffD6D6D6),
            width: 1,
          ),
        ),
        child: Text(
          number.toString(),
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
