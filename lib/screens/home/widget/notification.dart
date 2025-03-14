import 'package:clbdoanhnhansg/providers/notification_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'conten_thong_bao.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationState();
}

class _NotificationState extends State<NotificationScreen> {
  //bắt đầu vào màn hình lấy danh sahcs

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notiProvider =
          Provider.of<NotificationProvider>(context, listen: false);
      notiProvider.fetchNotifications(context);
    });
  }

  // Helper method to check if two dates are on the same day
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F5F6),
      appBar: AppBar(
        centerTitle: false,
        title: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(Icons.arrow_back_ios),
            ),
            const SizedBox(width: 8),
            const Text(
              "Thông báo",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        elevation: 5,
        automaticallyImplyLeading: false,
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.notifications.isEmpty) {
            return const Center(child: Text('Không có thông báo nào'));
          }

          // Group notifications by date
          final now = DateTime.now();
          final todayNotifications = provider.notifications
              .where((n) => _isSameDay(n.timestamp, now))
              .toList();
          final yesterdayNotifications = provider.notifications
              .where((n) => _isSameDay(
                  n.timestamp, now.subtract(const Duration(days: 1))))
              .toList();
          final earlierNotifications = provider.notifications
              .where((n) =>
                  n.timestamp.isBefore(now.subtract(const Duration(days: 1))))
              .toList();

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Today Section
                if (todayNotifications.isNotEmpty)
                  Container(
                    decoration: const BoxDecoration(color: Colors.white),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Text(
                            "Hôm nay",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        ...todayNotifications.map(
                          (notification) => Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child:
                                    ContenThongBao(notification: notification),
                              ),
                              const Divider(indent: 20, endIndent: 20),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 10),
                // Yesterday and Earlier Section
                Container(
                  decoration: const BoxDecoration(color: Colors.white),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (yesterdayNotifications.isNotEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Text(
                            "Hôm qua",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        ...yesterdayNotifications.map(
                          (notification) => Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child:
                                    ContenThongBao(notification: notification),
                              ),
                              const Divider(indent: 20, endIndent: 20),
                            ],
                          ),
                        ),
                      ],
                      if (earlierNotifications.isNotEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Text(
                            "Trước đó",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        ...earlierNotifications.map(
                          (notification) => Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child:
                                    ContenThongBao(notification: notification),
                              ),
                              const Divider(indent: 20, endIndent: 20),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }
}

