import 'package:clbdoanhnhansg/providers/bo_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'item_post_business.dart';

class TabInBusiness extends StatefulWidget {
  const TabInBusiness({super.key});

  @override
  State<TabInBusiness> createState() => _TabInBusinessState();
}

class _TabInBusinessState extends State<TabInBusiness> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xffF4F5F6),
      child: Consumer<BoProvider>(
        builder: (context, boProvider, child) {
          final boList = boProvider.boList;

          if (boProvider.isLoadingBo) {
            return const Center(child: CircularProgressIndicator());
          }

          if (boProvider.errorMessageBo.isNotEmpty) {
            return Center(child: Text(boProvider.errorMessageBo));
          }

          if (boList.isEmpty) {
            return const Center(child: Text("Không có bài viết nào"));
          }

          return ListView.builder(
            itemCount: boList.length,
            itemBuilder: (context, index) {
              return ItemPostBussiness(
                bo: boList[index],
              );
            },
          );
        },
      ),
    );
  }
}

