import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'screens/home/widget/notification.dart';
import 'utils/router/router.dart';
import 'utils/router/router.name.dart';
import 'widgets/handling_permissions.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    // Use post-frame callback to ensure UI is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  Future<void> _initializeApp() async {
    setState(() => _isInitializing = true);

    // Request permissions first
    await PermissionService.requestPermissions(context);

    // Then check login status
    if (mounted) {
      await Provider.of<AuthProvider>(context, listen: false)
          .checkLoginStatus(context);
    }

    if (mounted) {
      setState(() => _isInitializing = false);
    }

    OneSignal.Notifications.addClickListener((event) {
      if (event.notification.jsonRepresentation().isNotEmpty) {
        final data = event.notification.additionalData;
        appRouter.go(AppRoutes.thongBao, extra: data);
      }
    });

    OneSignal.Notifications.addForegroundWillDisplayListener((event) {
      print(
          'NOTIFICATION WILL DISPLAY LISTENER CALLED WITH: ${event.notification.jsonRepresentation()}');

      /// Display Notification, preventDefault to not display
      event.preventDefault();

      /// Do async work

      /// notification.display() to display after preventing default
      event.notification.display();
    });

    OneSignal.InAppMessages.addClickListener((event) {
      print('In App Message Clicked: $event');
    });

    OneSignal.InAppMessages.addWillDisplayListener((event) {
      print("ON WILL DISPLAY IN APP MESSAGE ${event.message.messageId}");
    });

    OneSignal.InAppMessages.addDidDisplayListener((event) {
      print("ON DID DISPLAY IN APP MESSAGE ${event.message.messageId}");
    });

    OneSignal.InAppMessages.addWillDismissListener((event) {
      print("ON WILL DISMISS IN APP MESSAGE ${event.message.messageId}");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            appBarTheme: const AppBarTheme(
              elevation: 5,
              surfaceTintColor: Colors.transparent,
              shadowColor: Colors.white,
              backgroundColor: Colors.white,
            ),
          ),
          routerConfig: appRouter,
          title: 'GoRouter Flutter Example',
          builder: (context, child) {
            return Stack(
              children: [
                child!,
                if (_isInitializing)
                  Material(
                    color: Colors.black54,
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
        );
      },
    );
  }
}
