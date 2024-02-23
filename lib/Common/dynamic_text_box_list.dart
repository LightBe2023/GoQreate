import 'package:flutter/material.dart';

class DynamicTextBoxList extends StatefulWidget {
  final Function(List<String?>) onValuesChanged;

  const DynamicTextBoxList({super.key, required this.onValuesChanged});

  @override
  State<DynamicTextBoxList> createState() => _DynamicTextBoxListState();
}

class _DynamicTextBoxListState extends State<DynamicTextBoxList> {
  List<Widget> textWidgets = [];
  List<List<String?>> textBoxValuesList = [[]]; // Initialize with an empty list

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 0.1,
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: TextFormField(
                    maxLines: null,
                    onChanged: (value) {
                      setState(() {
                        // Update the value of the first text field
                        textBoxValuesList[0] = [value];
                        // Notify the parent widget about the updated values
                        widget.onValuesChanged(mergeValues());
                      });
                    },
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.all(5),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 5),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      // Add a new text field widget
                      textWidgets.add(
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10, right: 25),
                          child: SizedBox(
                            width: double.infinity,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(6),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.5),
                                          spreadRadius: 0.1,
                                          blurRadius: 3,
                                          offset: const Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                    child: TextFormField(
                                      maxLines: null,
                                      onChanged: (value) {
                                        setState(() {
                                          // Update the value of this text field
                                          textBoxValuesList[textWidgets.length] = [value];
                                          // Notify the parent widget about the updated values
                                          widget.onValuesChanged(mergeValues());
                                        });
                                      },
                                      decoration: const InputDecoration(
                                        contentPadding: EdgeInsets.all(5),
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                ),
                                // const Padding(
                                //   padding: EdgeInsets.only(left: 5),
                                //   child: Icon(
                                //     Icons.add,
                                //     size: 20,
                                //   ),
                                // ),
                              ],
                            ),
                          ),
                        ),
                      );
                      // Add an empty list for the new text field
                      textBoxValuesList.add([]);
                    });
                  },
                  child: const Icon(
                    Icons.add,
                    size: 20,
                  ),
                ),
              )
            ],
          ),
        ),
        const SizedBox(height: 10,),
        ...textWidgets,
      ],
    );
  }

  // Merge values from all text fields into a single list
  List<String?> mergeValues() {
    return textBoxValuesList.expand((values) => values).toList();
  }
}




