import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'next_page.dart';

class InspectionFormPage extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _InspectionFormPageState createState() => _InspectionFormPageState();
}

class _InspectionFormPageState extends State<InspectionFormPage> {
  final _formKey = GlobalKey<FormBuilderState>();
  final Map<String, String> remarks = {};
  int currentPage = 0;

  final List<Map<String, dynamic>> inspectionPages = [
    {
      'title': 'Building Inspection',
      'items': [
        {
          'title': 'Proper connectivity between bare copper cable & earth rod at the inspection pit.',
          'fieldName': 'Earth_rod_connectivity',
          'options': ['Ok', 'Not Ok'],
        },
        {
          'title': 'Proper connectivity between main ground bar & the wire.',
          'fieldName': 'Main_ground_bar_wire',
          'options': ['Ok', 'Not Ok'],
        },
        {
          'title': 'Copper cable connections at the main ground bars.',
          'fieldName': 'Main_ground_bar_cable',
          'options': ['Ok', 'Not Ok'],
        },
        {
          'title': 'Earth resistance from different parts of the earthing system to confirm the continuity.',
          'fieldName': 'Earth_resistance_continuity',
          'options': ['Ok', 'Not Ok'],
        },
      ],
    },
    {
      'title': 'Additional Checks',
      'items': [
        {
          'title': 'Proper connection between lightning arrestor and the down conductor at the rooftop.',
          'fieldName': 'Lightning_arrestor_connection',
          'options': ['Ok', 'Not Ok'],
        },
            {
          'title': 'Proper connection between down conductor/roof grid conductor and buried earthing system.',
          'fieldName': 'Roof_earthing_connection',
          'options': ['Ok', 'Not Ok'],
        },
      ],
    },
  ];

  void _showRemarksDialog(String field) async {
    TextEditingController remarksController = TextEditingController();

    String? remark = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Remark'),
        content: TextField(
          controller: remarksController,
          decoration: const InputDecoration(hintText: 'Enter your remark here'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, remarksController.text), child: const Text('OK')),
        ],
      ),
    );

    if (remark != null && remark.isNotEmpty) {
      setState(() {
        remarks[field] = remark;
      });
    }
  }

  bool _validateCurrentPage() {
    bool isValid = true;
    for (var item in inspectionPages[currentPage]['items']) {
      String fieldName = item['fieldName'];
      if (_formKey.currentState?.fields[fieldName]?.value == null && remarks[fieldName] == null) {
        isValid = false;
        break;
      }
    }
    return isValid;
  }

  void _nextPage() {
    if (_validateCurrentPage()) {
      if (currentPage < inspectionPages.length - 1) {
        setState(() {
          currentPage++;
        });
      } else {
        _submitForm();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill out all fields and remarks where necessary.')),
      );
    }
  }

  void _previousPage() {
    if (currentPage > 0) {
      setState(() {
        currentPage--;
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.saveAndValidate()) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NextPage(formData: _formKey.currentState!.value, remarks: remarks),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            inspectionPages[currentPage]['title'],
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 16.0),
              FormBuilder(
                key: _formKey,
                child: Column(
                  children: [
                    ...inspectionPages[currentPage]['items'].map<Widget>((item) {
                      return _buildInspectionItem(
                        title: item['title'],
                        fieldName: item['fieldName'],
                        options: item['options'],
                      );
                    }).toList(),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (currentPage > 0)
                          ElevatedButton(
                            onPressed: _previousPage,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(255, 1, 75, 136),
                              foregroundColor: Colors.white,
                            ),
                            child: const Text("Previous"),
                          ),
                        ElevatedButton(
                          onPressed: _nextPage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 1, 75, 136),
                            foregroundColor: Colors.white,
                          ),
                          child: Text(currentPage < inspectionPages.length - 1 ? "Next" : "Submit"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInspectionItem({required String title, required String fieldName, required List<String> options}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blueAccent),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              ElevatedButton(
                onPressed: () => _showRemarksDialog(fieldName),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(33, 150, 243, 1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                child: const Text("+ Remarks"),
              ),
            ],
          ),
          FormBuilderRadioGroup(
            name: fieldName,
            options: options.map((option) => FormBuilderFieldOption(value: option)).toList(),
            decoration: const InputDecoration(border: InputBorder.none),
            validator: (value) {
              if (value == null && remarks[fieldName] == null) {
                return 'Please select an option or enter a remark.';
              }
              return null;
            },
          ),
          if (remarks[fieldName] != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text("Remark: ${remarks[fieldName]!}"),
            ),
        ],
      ),
    );
  }
}
