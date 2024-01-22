import 'package:flutter/material.dart';
import 'package:go_qreate_teams/Common/colors.dart';

class SwipeToDelete extends StatefulWidget {
  final List milestones;
  final Function(bool) onDelete;

  const SwipeToDelete({
    super.key,
    required this.milestones,
    required this.onDelete,
  });

  @override
  _SwipeToDeleteState createState() => _SwipeToDeleteState();
}

class _SwipeToDeleteState extends State<SwipeToDelete> {
  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: UniqueKey(),
      onDismissed: (direction) {
        // Handle the item deletion here
        setState(() {
          // Remove the first milestone from the list
          // widget.milestones.removeAt(0);
          widget.onDelete(true);
        });
      },
      background: Container(
        color: ColorName.primaryColor, // Background color when swiping
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Image.asset(
              'assets/icons/delete_icon.png',
              fit: BoxFit.contain,
              height: 18,
              color: Colors.white, // Icon color
            ),
          ),
        ),
      ),
      child: Container(
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 0.1,
              blurRadius: 3,
              offset: const Offset(0, -1),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: TextFormField(
                maxLines: null,
                initialValue: widget.milestones.first,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(15),
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    color: Colors.grey.withOpacity(0.8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
