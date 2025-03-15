// post_detail_screen.dart
import 'package:clbdoanhnhansg/widgets/horizontal_divider.dart';
import 'package:flutter/material.dart';
import 'package:clbdoanhnhansg/utils/icons/app_icons.dart';

class ChiTietBaiDang extends StatefulWidget {
  final List<String> imageList;
  final int initialIndex;
  final String companyName;
  final int like;
  final int comment;
  final String dateTime;
  final String description;

  const ChiTietBaiDang({
    super.key,
    required this.imageList,
    required this.initialIndex,
    required this.companyName,
    required this.like,
    required this.comment,
    required this.dateTime,
    required this.description,
  });

  @override
  State<ChiTietBaiDang> createState() => _ChiTietBaiDanglScreenState();
}

class _ChiTietBaiDanglScreenState extends State<ChiTietBaiDang> {
  late PageController _pageController;
  late int _currentPage;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: AppIcons.getArrowBackIos(
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
        title: Column(
          children: [
            Text(
              widget.dateTime,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                "${_currentPage + 1}/${widget.imageList.length}",
                style: const TextStyle(
                  color: Colors.blue,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: widget.imageList.length,
              itemBuilder: (context, index) {
                return InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Image.network(
                    widget.imageList[index],
                    fit: BoxFit.contain,
                  ),
                );
              },
            ),
          ),
          Container(
            color: Colors.black.withOpacity(0.7),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.description
                      .split('\n')
                      .join('\n • '), // Thêm dấu "." trước mỗi dòng mới
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                  maxLines: 10,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                const HorizontalDivider(),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const ImageIcon(
                      AssetImage('assets/icons/heart.png'),
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.like.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const ImageIcon(
                      AssetImage('assets/icons/comment.png'),
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.comment.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

