import 'package:clbdoanhnhansg/widgets/text_styles.dart';
import 'package:flutter/material.dart';

class CarInforCompany extends StatefulWidget {
  const CarInforCompany(
      {super.key,
      required this.ulrIcon,
      required this.label,
      required this.value,
      this.isNganhNghe = false,
      this.nganhNghe});
  final String ulrIcon;
  final String label;
  final String value;
  final bool isNganhNghe;
  final List<String>? nganhNghe;

  @override
  State<CarInforCompany> createState() => _CarInforCompanyState();
}

class _CarInforCompanyState extends State<CarInforCompany> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.45,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                "${widget.ulrIcon}",
                width: 24,
                height: 24,
              ),
              const SizedBox(
                width: 4,
              ),
              Text("${widget.label}", style: TextStyles.textStyleNormal14W500),
            ],
          ),
        ),
        Expanded(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.55,
            child: widget.isNganhNghe == false
                ? Align(
                    alignment: Alignment
                        .centerLeft, // Căn giữa theo chiều dọc, căn trái theo chiều ngang
                    child: Text(
                      "${widget.value}",
                      softWrap: true,
                      overflow: TextOverflow.visible,
                      textAlign:
                          TextAlign.left, // Căn trái nội dung text bên trong
                      style: TextStyles.textStyleNormal14W400,
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var nganh in widget.nganhNghe!) ...{
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.lightBlueAccent,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(nganh,
                                style: TextStyles.textStyleNormal14W400),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                      }
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}

