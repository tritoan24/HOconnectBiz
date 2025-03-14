import 'package:clbdoanhnhansg/screens/profile/widget/member_profile.dart';
import 'package:clbdoanhnhansg/screens/profile/widget_member_level/member_level_screen.dart';
import 'package:flutter/material.dart';

class MemberLever extends StatefulWidget {
  const MemberLever({super.key});

  @override
  State<StatefulWidget> createState() => _MemberLeverState();
}

class _MemberLeverState extends State<MemberLever> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hạng hội viên'),
      ),
      body: const Center(
          child: Column(
        children: [
          Member(isProfile: false),
          Expanded(
            child: MemberLevelScreen(),
          ),
        ],
      )),
    );
  }
}

