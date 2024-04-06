import 'package:flutter/material.dart';
import 'package:go_qreate_teams/Common/colors.dart';

class SwipeToDelete extends StatefulWidget {
  final String milestone;
  final Function(String) onEdit;
  final Function(int) onApprove;
  final Function(int) onRevise;
  final Function(int) onDelete;
  final int index;
  final String isApprovedRevised;

  const SwipeToDelete({
    Key? key,
    required this.milestone,
    required this.onEdit,
    required this.onApprove,
    required this.onRevise,
    required this.onDelete,
    required this.index,
    required this.isApprovedRevised,
  }) : super(key: key);

  @override
  _SwipeToDeleteState createState() => _SwipeToDeleteState();
}

class _SwipeToDeleteState extends State<SwipeToDelete> {
  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) {}, // Consume the long-press event
      child: GestureDetector(
        onLongPress: () {
          // Show dialog for deleting milestone on long press
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Delete Milestone?'),
              content: Text('Do you want to delete this milestone?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    widget.onDelete(widget.index);
                  },
                  child: Text('Delete'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancel'),
                ),
              ],
            ),
          );
        },
        child: Dismissible(
          key: UniqueKey(),
          onDismissed: (direction) {
            if (direction == DismissDirection.startToEnd) {
              // Show dialog for approving milestone
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Approve Milestone?'),
                  content: Text('Do you want to approve this milestone?'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        widget.onApprove(widget.index);
                      },
                      child: Text('Approve'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                        });
                      },
                      child: Text('Cancel'),
                    ),
                  ],
                ),
              );
            } else if (direction == DismissDirection.endToStart) {
              // Show dialog for revising milestone
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Revise Milestone?'),
                  content: Text('Do you want to revise this milestone?'),
                  actions: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(right: 50),
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          widget.onDelete(widget.index);
                        },
                        child: const Text(
                            'Delete',
                            style: TextStyle(
                              color: Colors.red,
                            ),
                          ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        widget.onRevise(widget.index);
                      },
                      child: Text('Revise'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                        });
                      },
                      child: Text('Cancel'),
                    ),
                  ],
                ),
              );
            }
          },
          background: Container(
            color: ColorName.primaryColor,
            child: Icon(Icons.check, color: Colors.white),
            alignment: Alignment.centerRight,
            padding: EdgeInsets.only(right: 20.0),
          ),
          secondaryBackground: Container(
            color: Colors.red,
            child: Icon(Icons.delete, color: Colors.white),
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(left: 20.0),
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
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: Row(
                    children: [
                      Expanded( // Wrap the Row with Expanded
                        child: TextFormField(
                          initialValue: widget.milestone,
                          onChanged: widget.onEdit,
                          autofocus: false,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      if (widget.isApprovedRevised.contains('approved')) ...[
                        const Icon(
                          Icons.check_circle,
                          color: Colors.greenAccent,
                        )
                      ],

                      if (widget.isApprovedRevised.contains('revised')) ...[
                        const Icon(
                          Icons.close_rounded,
                          color: Colors.red,
                        )
                      ]
                    ],
                  ),
                ),
              ],
            ),

          ),
        ),
      ),
    );
  }
}
