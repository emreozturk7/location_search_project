import 'package:flutter/material.dart';
import 'package:location_search_project/core/constants.dart';
import 'package:location_search_project/view/search_view.dart';

class HomeView extends StatelessWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(42),
            topRight: Radius.circular(42),
          ),
        ),
        height: 100,
        child: Container(
          padding: const EdgeInsets.only(top: 12.0, right: 6.0, left: 6.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Text(
                    'Explore',
                    style: TextStyle(
                      color: themeColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  CircleAvatar(
                    radius: 2.5,
                    backgroundColor: themeColor,
                  ),
                ],
              ),
              Column(
                children: [
                  CircleAvatar(
                    radius: 15,
                    backgroundColor: transparentColor,
                    child: Image.asset('assets/images/img_2.png'),
                  ),
                ],
              ),
              Column(
                children: [
                  CircleAvatar(
                    radius: 15,
                    backgroundColor: transparentColor,
                    child: Image.asset('assets/images/img_5.png'),
                  ),
                ],
              ),
              Column(
                children: [
                  CircleAvatar(
                    radius: 15,
                    backgroundColor: transparentColor,
                    child: Image.asset('assets/images/img_1.png'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: const SearchView(),
    );
  }
}
