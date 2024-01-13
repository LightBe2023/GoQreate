import 'package:flutter/material.dart';

class DynamicTextBoxList extends StatefulWidget {
  final Function(List<String?>) onValuesChanged;

  const DynamicTextBoxList({super.key, required this.onValuesChanged});

  @override
  State<DynamicTextBoxList> createState() => _DynamicTextBoxListState();
}

class _DynamicTextBoxListState extends State<DynamicTextBoxList> {
  List<Widget> textWidgets = [];
  List<String?> textBoxValues = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...textWidgets,
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
                      textBoxValues = [value];
                      widget.onValuesChanged(textBoxValues);
                      textBoxValues.add(value);
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
                      textWidgets.add(
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
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
                                        textBoxValues = [value];
                                        widget.onValuesChanged(textBoxValues);
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
                                  child: Icon(
                                    Icons.add,
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
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
      ],
    );
  }
}
