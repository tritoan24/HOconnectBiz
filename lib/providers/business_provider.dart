import 'package:clbdoanhnhansg/repository/business_repository.dart';
import 'package:flutter/cupertino.dart';
import '../core/base/base_provider.dart';
import '../models/business_model.dart';

class BusinessProvider extends BaseProvider {
  final BusinessRepository _businessRepository = BusinessRepository();
  List<BusinessModel> _business = [];
  List<BusinessModel> get business => _business;

  //get list post
  Future<void> getListBusiness(BuildContext context) async {
    try {
      final response = await _businessRepository.getBusiness(context);

      if (response.isSuccess && response.data is List) {
        _business = (response.data as List)
            .map((item) => BusinessModel.fromJson(item))
            .toList();

        notifyListeners();
      }
    } catch (e) {
      // Handle error appropriately
      print('Error fetching: $e');
    }
  }
}

