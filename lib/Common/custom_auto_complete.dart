import 'package:flutter/material.dart';

class CustomAutocomplete extends StatefulWidget {
  @override
  _CustomAutocompleteState createState() => _CustomAutocompleteState();
}

class _CustomAutocompleteState extends State<CustomAutocomplete> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Autocomplete<String>(
          optionsBuilder: (TextEditingValue textEditingValue) async {
            // Your data fetching logic here
            List<String> suggestions = ['Option 1', 'Option 2', 'Option 3'];

            return suggestions
                .where((option) =>
                option.toLowerCase().contains(textEditingValue.text.toLowerCase()))
                .toList();
          },
          onSelected: (String value) {
            // Handle the selected value
            _searchController.text = value;
          },
        ),
        SizedBox(height: 10),
        ElevatedButton(
          onPressed: () {
            _showCustomAutocompleteDialog(context);
          },
          child: Text('Show Custom Autocomplete'),
        ),
      ],
    );
  }

  void _showCustomAutocompleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Custom Autocomplete'),
          content: Container(
            height: 200, // Adjust the height as needed
            width: 300, // Adjust the width as needed
            child: Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) async {
                // Your data fetching logic here
                List<String> suggestions = ['Option 1', 'Option 2', 'Option 3'];

                return suggestions
                    .where((option) =>
                    option.toLowerCase().contains(textEditingValue.text.toLowerCase()))
                    .toList();
              },
              onSelected: (String value) {
                // Handle the selected value
                _searchController.text = value;
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ),
        );
      },
    );
  }
}