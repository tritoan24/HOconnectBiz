import 'package:clbdoanhnhansg/screens/business_opportunity_management/widget/tab_in_business.dart';
import 'package:clbdoanhnhansg/screens/business_opportunity_management/widget/tab_outside_business.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/bo_provider.dart';
import '../../utils/Color/app_color.dart';

class ManageBO extends StatefulWidget {
  const ManageBO({super.key});

  @override
  State<ManageBO> createState() => _ManageBOState();
}

class _ManageBOState extends State<ManageBO>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Quản lý cơ hội kinh doanh",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Tab Bar
          TabBar(
            controller: _tabController,
            isScrollable: false,
            unselectedLabelColor: AppColor.borderColor,
            labelColor: AppColor.primaryBlue,
            indicatorColor: AppColor.primaryBlue,
            labelStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            tabs: const [
              Tab(text: "Thuộc doanh nghiệp"),
              Tab(text: "Ngoài doanh nghiệp"),
            ],
          ),

          // Tab Bar View
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                TabInBusiness(),
                TabOutsideBusiness(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Tab Indicator if needed
class CustomTabIndicator extends Decoration {
  final TabController controller;

  const CustomTabIndicator({required this.controller});

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _CustomTabIndicatorPainter(controller, onChanged);
  }
}

class _CustomTabIndicatorPainter extends BoxPainter {
  final TabController controller;

  _CustomTabIndicatorPainter(this.controller, VoidCallback? onChanged)
      : super(onChanged);

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final Paint paint = Paint()
      ..color = AppColor.primaryBlue
      ..style = PaintingStyle.fill;

    final double width = configuration.size?.width ?? 0;
    final double height = 2.0;
    final double xPos = offset.dx;
    final double yPos = offset.dy + (configuration.size?.height ?? 0) - height;

    canvas.drawRect(
      Rect.fromLTWH(xPos, yPos, width, height),
      paint,
    );
  }
}
