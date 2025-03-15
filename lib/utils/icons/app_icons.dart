import 'package:flutter/material.dart';

/// Lớp quản lý tất cả các icon trong ứng dụng
/// Sử dụng lớp này để dễ dàng thay đổi icon khi cần thiết
class AppIcons {
  // Icon khi ảnh bị lỗi hoặc không có ảnh
  static const Icon brokenImage = Icon(
    Icons.image_not_supported,
  );
  
  // Lấy icon broken image với kích thước tùy chỉnh
  static Icon getBrokenImage({double? size, Color? color}) {
    return Icon(
      Icons.image_not_supported,
      size: size,
      color: color,
    );
  }
  
  // Icon navigation
  static const Icon arrowBackIos = Icon(Icons.arrow_back_ios);
  static const Icon arrowForwardIos = Icon(Icons.arrow_forward_ios_rounded);
  static const Icon close = Icon(Icons.close);
  static const Icon add = Icon(Icons.add);
  static const Icon remove = Icon(Icons.remove);
  
  // Icon bottom navigation
  static const Icon home = Icon(Icons.home);
  static const Icon search = Icon(Icons.search);
  static const Icon person = Icon(Icons.person);
  static const Icon settings = Icon(Icons.settings);
  static const Icon chat = Icon(Icons.chat);

  // Icon cho form và input
  static const Icon error = Icon(Icons.error);
  static const Icon clear = Icon(Icons.clear);
  static const Icon searchRounded = Icon(Icons.search_rounded);
  static const Icon keyboardArrowDown = Icon(Icons.keyboard_arrow_down_rounded);
  static const Icon check = Icon(Icons.check);
  static const Icon checkCircle = Icon(Icons.check_circle);
  static const Icon circleOutlined = Icon(Icons.circle_outlined);
  static const Icon star = Icon(Icons.star);
  
  // Phương thức để lấy icon với kích thước và màu tùy chỉnh
  static Icon getIcon(IconData iconData, {double? size, Color? color}) {
    return Icon(
      iconData,
      size: size,
      color: color,
    );
  }
  
  // Phương thức lấy icon với kích thước và màu tùy chỉnh cho các icon navigation
  static Icon getArrowBackIos({double? size, Color? color}) {
    return Icon(
      Icons.arrow_back_ios,
      size: size,
      color: color,
    );
  }
  
  static Icon getClose({double? size, Color? color}) {
    return Icon(
      Icons.close,
      size: size,
      color: color,
    );
  }
  
  static Icon getSearch({double? size, Color? color}) {
    return Icon(
      Icons.search,
      size: size,
      color: color,
    );
  }
  
  static Icon getAdd({double? size, Color? color}) {
    return Icon(
      Icons.add,
      size: size,
      color: color,
    );
  }
  
  static Icon getClear({double? size, Color? color}) {
    return Icon(
      Icons.clear,
      size: size,
      color: color,
    );
  }
  
  static Icon getCheck({double? size, Color? color}) {
    return Icon(
      Icons.check,
      size: size,
      color: color,
    );
  }
  
  static Icon getCheckCircle({double? size, Color? color}) {
    return Icon(
      Icons.check_circle,
      size: size,
      color: color,
    );
  }
  
  static Icon getCircleOutlined({double? size, Color? color}) {
    return Icon(
      Icons.circle_outlined,
      size: size,
      color: color,
    );
  }
  
  static Icon getPerson({double? size, Color? color}) {
    return Icon(
      Icons.person,
      size: size,
      color: color,
    );
  }
  
  static Icon getError({double? size, Color? color}) {
    return Icon(
      Icons.error,
      size: size,
      color: color,
    );
  }
  
  static Icon getStar({double? size, Color? color}) {
    return Icon(
      Icons.star,
      size: size,
      color: color,
    );
  }
} 