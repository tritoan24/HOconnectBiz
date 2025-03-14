import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/membership_model.dart';
import '../../../providers/membership_provider.dart';

class MemberLevelScreen extends StatefulWidget {
  const MemberLevelScreen({super.key});

  @override
  State<MemberLevelScreen> createState() => _MemberLevelScreenState();
}

class _MemberLevelScreenState extends State<MemberLevelScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  late Future<void> _loadDataFuture;
  @override
  void initState() {
    super.initState();
    _loadDataFuture = _fetchData();
  }

  Future<void> _fetchData() async {
    final provider = Provider.of<MemberShipProvider>(context, listen: false);
    await provider.getListMemberShip(context); // Chờ dữ liệu load xong
    if (provider.membership.isNotEmpty) {
      setState(() {
        _tabController =
            TabController(length: provider.membership.length, vsync: this);
      });
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _loadDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        return Consumer<MemberShipProvider>(
          builder: (context, provider, child) {
            if (provider.errorMessage != null) {
              return Center(child: Text(provider.errorMessage!));
            }

            final memberships = provider.membership;
            print("memberships: $memberships");

            if (memberships.isEmpty) {
              return const Center(child: Text("Không có dữ liệu thành viên"));
            }

            if (_tabController == null) {
              return const Center(child: CircularProgressIndicator());
            }

            return Column(
              children: [
                Container(
                  color: Colors.white,
                  height: 57,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(memberships.length, (index) {
                      return _buildTab(
                        text: 'Cấp ${memberships[index].level}',
                        index: index,
                      );
                    }),
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: List.generate(memberships.length, (index) {
                      return _buildLevelContent(
                        title:
                            'Quyền lợi cho hội viên cấp ${memberships[index].level}',
                        benefits: _parseBenefits(memberships[index].benefits),
                      );
                    }),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildTab({required String text, required int index}) {
    bool isSelected = _tabController?.index == index;

    return GestureDetector(
      onTap: () => _tabController?.animateTo(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              text,
              style: TextStyle(
                color:
                    isSelected == true ? const Color(0xFF006AF5) : Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (isSelected == true)
            Container(
              height: 2,
              width: 80,
              color: const Color(0xFF006AF5),
            ),
        ],
      ),
    );
  }

  Widget _buildLevelContent(
      {required String title, required List<String> benefits}) {
    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.black87,
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: benefits.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '• ',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF8F9499),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          benefits[index],
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF8F9499),
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  List<String> _parseBenefits(String? benefits) {
    if (benefits == null || benefits.isEmpty) {
      return ["Không có thông tin"];
    }
    return benefits
        .split(';'); // Giả sử dữ liệu API là chuỗi ngăn cách bởi dấu `;`
  }
}
