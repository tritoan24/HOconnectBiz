import 'package:clbdoanhnhansg/widgets/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class GalleryPhotoViewWrapper extends StatefulWidget {
  final List<String> galleryItems;
  final int initialIndex;
  final Axis scrollDirection;

  const GalleryPhotoViewWrapper({
    Key? key,
    required this.galleryItems,
    this.initialIndex = 0,
    this.scrollDirection = Axis.horizontal,
  }) : super(key: key);

  @override
  _GalleryPhotoViewWrapperState createState() =>
      _GalleryPhotoViewWrapperState();
}

class _GalleryPhotoViewWrapperState extends State<GalleryPhotoViewWrapper> {
  late int currentIndex;
  late PageController pageController;

  @override
  void initState() {
    currentIndex = widget.initialIndex;
    pageController = PageController(initialPage: widget.initialIndex);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: Text(
          "Ảnh ${currentIndex + 1}/${widget.galleryItems.length}",
          style: TextStyles.textStyleNormal14W500White,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: PhotoViewGallery.builder(
        itemCount: widget.galleryItems.length,
        pageController: pageController,
        scrollDirection: widget.scrollDirection,
        builder: (context, index) {
          final imageUrl = widget.galleryItems[index];
          return PhotoViewGalleryPageOptions(
            imageProvider: NetworkImage(imageUrl),
            initialScale: PhotoViewComputedScale.contained,
            minScale: PhotoViewComputedScale.contained * 0.8,
            maxScale: PhotoViewComputedScale.covered * 2,
            heroAttributes: PhotoViewHeroAttributes(tag: imageUrl),
          );
        },
        onPageChanged: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        loadingBuilder: (context, event) => Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}

