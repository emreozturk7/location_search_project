import 'package:flutter/material.dart';
import 'package:location_search_project/core/color_palette.dart';
import 'package:location_search_project/core/context_extensions.dart';
import 'package:location_search_project/view/search_view.dart';

class HomeView extends StatelessWidget {
  HomeView({Key? key}) : super(key: key);

  String explore = 'Explore';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: backgroundColor,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.only(
            topLeft: context.highRadius,
            topRight: context.highRadius,
          ),
        ),
        height: context.dynamicHeight(0.125),
        child: Container(
          padding: EdgeInsets.only(
            top: context.normalValue,
            right: context.lowValue,
            left: context.lowValue,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Text(
                    explore,
                    style: TextStyle(
                      color: themeColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: context.lowValue),
                  CircleAvatar(
                    radius: context.dynamicHeight(0.004),
                    backgroundColor: themeColor,
                  ),
                ],
              ),
              Column(children: [buildCircleAvatar(context, 'book_icon')]),
              Column(children: [buildCircleAvatar(context, 'plane_icon')]),
              Column(children: [buildCircleAvatar(context, 'bag_icon')]),
            ],
          ),
        ),
      ),
      body: const SearchView(),
    );
  }

  CircleAvatar buildCircleAvatar(BuildContext context, String iconName) {
    return CircleAvatar(
      radius: context.dynamicHeight(0.0175),
      backgroundColor: transparentColor,
      child: Image.asset('assets/images/$iconName.png'),
    );
  }
}
