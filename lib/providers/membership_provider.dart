import 'package:clbdoanhnhansg/models/membership_model.dart';
import 'package:flutter/cupertino.dart';
import '../core/base/base_provider.dart';
import '../repository/membershop_repository.dart';

class MemberShipProvider extends BaseProvider {
  final MemberShipRepository _membershipRepository = MemberShipRepository();
  late List<MemberShipModel> _membership = [];
  List<MemberShipModel> get membership => _membership;

  //get list membership
  Future<void> getListMemberShip(BuildContext context) async {
    try {
      final response = await _membershipRepository.getListMemberShip(context);

      if (response.isSuccess) {
        _membership = (response.data as List)
            .map((item) => MemberShipModel.fromJson(item))
            .toList();

        print("đã call dữ liệu thành công");

        notifyListeners();
      }
    } catch (e) {
      // Handle error appropriately
      print('Error fetching: $e');
    }
  }
}

