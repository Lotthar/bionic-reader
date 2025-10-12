import 'package:flutter/material.dart';

class BionicReaderHomeScreen extends StatefulWidget {

  final String title;

  const BionicReaderHomeScreen({super.key, required this.title});

  @override
  State<BionicReaderHomeScreen> createState() => _BionicReaderScreenState();
}

class _BionicReaderScreenState extends State<BionicReaderHomeScreen> {
  // Placeholder for the converted Bionic Text
  String? _bionicText;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(_bionicText ?? 'Tap to select a document'),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickAndConvertFile,
        tooltip: 'Select Document',
        child: const Icon(Icons.upload_file),
      ),
    );
  }

  void _pickAndConvertFile() async {
    // File picking and conversion logic from Phase 1 & 2 will go here
    // For now, it's just a placeholder:
    setState(() {
      _isLoading = true;
      _bionicText = null;
    });

    // Simulate work
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
      _bionicText = "The document was successfully loaded and is ready for conversion.";
    });
  }
}