import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/bo_provider.dart';
import 'item_post_business.dart';

class TabOutsideBusiness extends StatefulWidget {
  const TabOutsideBusiness({super.key});

  @override
  State<TabOutsideBusiness> createState() => _TabOutsideBusinessState();
}

class _TabOutsideBusinessState extends State<TabOutsideBusiness> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xffF4F5F6),
      child: Consumer<BoProvider>(
        builder: (context, boProvider, child) {
          // Lấy dữ liệu từ BoProvider
          final boListOut = boProvider.boListOut;

          // Nếu đang tải dữ liệu, hiển thị loading
          if (boProvider.isLoadingBoOut) {
            return const Center(child: CircularProgressIndicator());
          }

          // Nếu có lỗi khi tải dữ liệu, hiển thị thông báo lỗi
          if (boProvider.errorMessageBoOut.isNotEmpty) {
            return Center(child: Text(boProvider.errorMessageBoOut));
          }

          // Nếu không có dữ liệu, hiển thị thông báo không có bài viết
          if (boListOut.isEmpty) {
            return const Center(child: Text("Không có bài viết nào"));
          }

          // Sử dụng ListView.builder để hiển thị danh sách các bài viết
          return ListView.builder(
            itemCount: boListOut.length,
            itemBuilder: (context, index) {
              // Truyền từng đối tượng Bo vào ItemBaiVietDoanhNghiep
              return ItemPostBussiness(
                bo: boListOut[index],
                isInBusiness: false,
              );
            },
          );
        },
      ),
    );
  }
}
