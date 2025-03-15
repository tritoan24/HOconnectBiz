import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/StatisticalProvider.dart';
import '../../widgets/text_styles.dart';
import '../../utils/Color/app_color.dart';

class MemberStatistics extends StatefulWidget {
  const MemberStatistics({Key? key}) : super(key: key);

  @override
  State<MemberStatistics> createState() => _MemberStatisticsState();
}

class _MemberStatisticsState extends State<MemberStatistics> {
  final ScrollController _scrollController = ScrollController();
  final ScrollController _headerScrollController = ScrollController();

  // Border style được định nghĩa một lần để tái sử dụng
  final BoxDecoration cellDecoration = BoxDecoration(
    color: Colors.white,
    border: Border.all(
      color: AppColor.borderGrey,
      width: 0.5,
    ),
  );
  final BoxDecoration cellDecoration2 = BoxDecoration(
    color: const Color(0xfffafafa),
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
    // Sync both scroll controllers
    _scrollController.addListener(() {
      _headerScrollController.jumpTo(_scrollController.offset);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thống kê thành viên CLB'),
        leading: const BackButton(),
      ),
      body: Consumer<StatisticalProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // if (provider.isLoad) {
          //   return Center(child: Text("có lỗi xảy ra"));
          // }

          final data = provider.statistics;
          final currentPage = provider.currentPage;
          final totalMembers = provider.totalMembers;
          final totalPages = (totalMembers / provider.limit).ceil();

          return Column(
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
                                    padding: EdgeInsets.only(left: 8),
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
                                physics: const NeverScrollableScrollPhysics(),
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
                                          child: Text('Số cơ hội kinh doanh',
                                              style: TextStyles
                                                  .titleStyleColumnW600),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Container(
                                            width: 100,
                                            height: 50,
                                            decoration: headerCellDecoration,
                                            child: Center(
                                                child: Text('Đã tạo ra',
                                                    style: TextStyles
                                                        .titleStyleColumnW600)),
                                          ),
                                          Container(
                                            width: 100,
                                            height: 50,
                                            decoration: headerCellDecoration,
                                            child: Center(
                                                child: Text('Tham gia',
                                                    style: TextStyles
                                                        .titleStyleColumnW600)),
                                          ),
                                          Container(
                                            width: 100,
                                            height: 50,
                                            decoration: headerCellDecoration,
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
                                      .map((item) => Container(
                                            child: Row(
                                              children: [
                                                Container(
                                                  width: 50,
                                                  height: 70,
                                                  decoration: BoxDecoration(
                                                    color:
                                                        const Color(0xffEBF4FF),
                                                    border: Border.all(
                                                      color:
                                                          AppColor.borderGrey,
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
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 8),
                                                  decoration: cellDecoration,
                                                  child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Container(
                                                        width: 24,
                                                        height: 24,
                                                        margin: const EdgeInsets
                                                            .only(right: 8),
                                                        child: item.avatarImage
                                                                .isNotEmpty
                                                            ? Image.network(
                                                                item.avatarImage,
                                                                fit: BoxFit
                                                                    .contain,
                                                                errorBuilder:
                                                                    (context,
                                                                        error,
                                                                        stackTrace) {
                                                                  return Icon(
                                                                      Icons
                                                                          .business,
                                                                      size: 24,
                                                                      color: Colors
                                                                          .grey);
                                                                },
                                                              )
                                                            : Icon(
                                                                Icons.business,
                                                                size: 24,
                                                                color: Colors
                                                                    .grey),
                                                      ),
                                                      Expanded(
                                                        child: Text(
                                                          (item.companyName !=
                                                                  null)
                                                              ? item.companyName
                                                                      .isNotEmpty
                                                                  ? item
                                                                      .companyName
                                                                  : "Chưa cập nhật"
                                                              : "Chưa cập nhật",
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: GoogleFonts
                                                              .roboto(
                                                            fontSize: 14,
                                                            height: 1.2,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
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
                                                      CrossAxisAlignment.center,
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
                                                              TextAlign.center,
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
                                                          item.join.toString(),
                                                          textAlign:
                                                              TextAlign.center,
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
                                                          item.total.toString(),
                                                          textAlign:
                                                              TextAlign.center,
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
                        IconButton(
                          icon: const Icon(Icons.chevron_left),
                          onPressed: currentPage > 1
                              ? () => provider.fetchStatistics(context,
                                  page: currentPage - 1)
                              : null,
                        ),
                        for (int i = 1; i <= totalPages; i++)
                          if (i == 1 ||
                              i == totalPages ||
                              (i >= currentPage - 1 && i <= currentPage + 1))
                            PaginationNumber(
                              number: i,
                              isSelected: i == currentPage,
                              onTap: () =>
                                  provider.fetchStatistics(context, page: i),
                            )
                          else if (i == currentPage - 2 || i == currentPage + 2)
                            const Text('...', style: TextStyle(fontSize: 16)),
                        IconButton(
                          icon: const Icon(Icons.chevron_right),
                          onPressed: currentPage < totalPages
                              ? () => provider.fetchStatistics(context,
                                  page: currentPage + 1)
                              : null,
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
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const TextSpan(text: ' thành viên CLB'),
                        ],
                      ),
                    )
                  ],
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
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
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
