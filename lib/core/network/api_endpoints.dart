import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:clbdoanhnhansg/config/app_config.dart';

/// Tập hợp các endpoint API sử dụng trong ứng dụng
class ApiEndpoints {
  static final String baseUrl = AppConfig.apiBaseUrl;

  // Authentication endpoints
  static const String login = "login";
  static const String loginSocial = "login/social";
  static const String register = "register";
  static const String logout = "logout";
  static const String sendOtpEmail = "reset";
  static const String inputOtp = "verifyresetcode";
  static const String newPassForgot = "resetpassword";
  static const String changePassword = "changepassword";

  // Product endpoints
  static const String product = "product";
  static const String productPin = "product/pin";
  static const String productByUser = "product/getByUserId";
  static const String post = "post";
  static const String postById = "post/getById";
  static const String postByUser = "post/getByUserId";
  static const String likePost = "post/togglelike/";
  static const String commentPost = "post/comment";
  static const String postNew = "postNews";
  static const String banner = "banner";
  static const String business = "business";
  static const String businessType = "businessType";
  static const String user = "user";
  static const String getUserByID = "user/getById";
  static const String joinBusiness = "/bo";
  static const String approveBusiness = "/bo/accepted";
  static const String notification = "/notification";
  static const String chatList = "message/contacts";
  static const String chat = "/message";
  static const String chatConversation = "/message/conversation";
  static const String chatNow = "/message/contactnow";
  static const String rankRevenue = "/rank/revenue";
  static const String rankBusiness = "/rank/business";
  static const String boDataIn = "/bo/list";
  static const String bodeleteMember = "/bo/delete";
  static const String boDataOut = "/bo/listjoin";
  static const String boEnd = "/bo/close";
  static const String boLeave = "/bo";
  static const String boReview = "/bo/review";
  static const String boCriteria = "/bo/criteria";
  static const String membership = "/membership";
  static const String statistic = "/user/statistic";
  static const String orderSale = "/order/sell";
  static const String orderBuy = "/order/buy";
  static const String updateStatusCart = "/order";
  static const String oderDetail = "/order";
  static const String company = "/company";
}
