import 'package:flutter/material.dart';

class CustomBottomNavigationBar extends StatefulWidget {
  final Function(int) onIndexChanged; // Callback function

  const CustomBottomNavigationBar({super.key, required this.onIndexChanged});

  @override
  _CustomBottomNavigationBarState createState() =>
      _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          buildNavItem(
              _currentIndex == 0 ? 'assets/icons/home_white.png' : 'assets/icons/home_icon.png',
              0),
          buildNavItem(
              _currentIndex == 1 ? 'assets/icons/calendar_white.png' : 'assets/icons/calendar_icon.png',
              1),
          buildNavItem(
              _currentIndex == 2 ? 'assets/icons/notification_white.png' : 'assets/icons/notification_icon.png',
              2),
          buildNavItem(
              _currentIndex == 3 ? 'assets/icons/profile_white.png' : 'assets/icons/profile_icon.png',
              3),
        ],
      ),
    );
  }

  Widget buildNavItem(String assetPath, int index) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _currentIndex = index;
            // Call the callback function with the new index
            widget.onIndexChanged(_currentIndex);
          });
        },
        child: Stack(
          children: [
            SizedBox(
              height: 56.0,
              width: MediaQuery.of(context).size.width / 4,
            ),
            Positioned(
              top: 8.0,
              left: 0,
              right: 0,
              child: CircleAvatar(
                radius: 20.0,
                backgroundColor: _currentIndex == index
                    ? const Color(0xFF0AD3FF)
                    : Colors.white.withOpacity(0.5),
                child: Image.asset(
                  assetPath,
                  width: 20,
                  height: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
