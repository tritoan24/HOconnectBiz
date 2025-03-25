import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../../../providers/bo_provider.dart';
import 'item_post_business.dart';

class TabOutsideBusiness extends StatefulWidget {
  const TabOutsideBusiness({super.key});

  @override
  State<TabOutsideBusiness> createState() => _TabOutsideBusinessState();
}

class _TabOutsideBusinessState extends State<TabOutsideBusiness> {
  Future<void> _refreshData() async {
    await Provider.of<BoProvider>(context, listen: false)
        .fetchBoDataOut(context);
    return Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xffF4F5F6),
      child: Consumer<BoProvider>(
        builder: (context, boProvider, child) {
          final boListOut = boProvider.boListOut;

          if (boProvider.isLoadingBoOut) {
            return const Center(child: CircularProgressIndicator());
          }

          if (boProvider.errorMessageBoOut.isNotEmpty) {
            return RefreshIndicator(
              onRefresh: _refreshData,
              child: ListView(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 2,
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
              ),
            );
          }

          if (boListOut.isEmpty) {
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
              itemCount: boListOut.length,
              itemBuilder: (context, index) {
                return ItemPostBussiness(
                  bo: boListOut[index],
                  isInBusiness: false,
                );
              },
            ),
          );
        },
      ),
    );
  }
}
