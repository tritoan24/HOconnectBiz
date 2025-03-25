import 'package:clbdoanhnhansg/providers/bo_provider.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'item_post_business.dart';
import 'package:lottie/lottie.dart';

class TabInBusiness extends StatefulWidget {
  const TabInBusiness({super.key});

  @override
  State<TabInBusiness> createState() => _TabInBusinessState();
}

class _TabInBusinessState extends State<TabInBusiness> {
  Future<void> _refreshData() async {
    await Provider.of<BoProvider>(context, listen: false).fetchBoData(context);
    return Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xffF4F5F6),
      child: Consumer<BoProvider>(
        builder: (context, boProvider, child) {
          final boList = boProvider.boList;

          if (boProvider.isLoadingBo) {
            return Center(
              child: Lottie.asset(
                'assets/lottie/loading.json',
                width: 70,
                height: 70,
                fit: BoxFit.contain,
              ),
            );
          }

          if (boProvider.errorMessageBo.isNotEmpty) {
            return RefreshIndicator(
              onRefresh: _refreshData,
              child: ListView(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 2,
                    child: Center(child: Text(boProvider.errorMessageBo)),
                  ),
                ],
              ),
            );
          }

          if (boList.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refreshData,
              child: ListView(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 2,
                    child: const Center(child: Text("Không có bài viết nào")),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refreshData,
            child: ListView.builder(
              itemCount: boList.length,
              itemBuilder: (context, index) {
                return ItemPostBussiness(
                  bo: boList[index],
                );
              },
            ),
          );
        },
      ),
    );
  }
}
