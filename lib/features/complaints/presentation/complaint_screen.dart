import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

enum Urgency { Low, Medium, High }

class ComplaintPage extends StatefulWidget {
  const ComplaintPage({super.key});

  @override
  State<ComplaintPage> createState() => _ComplaintPageState();
}

class _ComplaintPageState extends State<ComplaintPage> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _landmarkController = TextEditingController();

  // State variables
  String? _selectedCategory;
  Urgency? _selectedUrgency;
  List<XFile> _pickedImages = [];
  Position? _currentPosition;
  bool _isFetchingLocation = false;

  final List<String> _categories = [
    'Pipe Leakage', 'Water Contamination', 'Illegal Boring/Well',
    'Water Wastage', 'No Water Supply', 'Other'
  ];

  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();
    setState(() {
      _pickedImages.addAll(images);
    });
  }

  Future<void> _getGpsLocation() async {
    setState(() => _isFetchingLocation = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Location permissions are denied')));
          setState(() => _isFetchingLocation = false);
          return;
        }
      }
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _currentPosition = position;
        _isFetchingLocation = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Failed to get location')));
      setState(() => _isFetchingLocation = false);
    }
  }

  void _submitComplaint() {
    if (_formKey.currentState!.validate()) {
      // Logic to process and submit the data would go here.
      // For now, we just show a confirmation dialog.
      _showConfirmationDialog();
    }
  }

  void _showConfirmationDialog() {
    // Generate a unique complaint ID
    final timestamp = DateFormat('yyMMdd-HHmmss').format(DateTime.now());
    final complaintId = 'JAL-PUNE-$timestamp';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Complaint Submitted'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Your complaint has been successfully registered.'),
              const SizedBox(height: 16),
              Text('Tracking ID:', style: TextStyle(color: Colors.grey[600])),
              Text(complaintId, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              const Text('Please save this ID for future reference.'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                Navigator.of(context).pop(); // Go back from the complaint page
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('File a Complaint'),
        backgroundColor: const Color(0xFF0D47A1),
      ),
      // backgroundColor: const Color(0xFFF4F6F8),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader("Issue Details"),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        hint: const Text('Select Complaint Category'),
                        items: _categories.map((String category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (newValue) => setState(() => _selectedCategory = newValue),
                        validator: (value) => value == null ? 'Please select a category' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Describe the issue',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 4,
                        validator: (value) => value == null || value.isEmpty ? 'Please enter a description' : null,
                      ),
                      const SizedBox(height: 16),
                       Align(
                        alignment: Alignment.centerLeft,
                        child: Text("Urgency Level", style: TextStyle(color: Colors.grey[700]))
                       ),
                       const SizedBox(height: 8),
                       ToggleButtons(
                        isSelected: [
                          _selectedUrgency == Urgency.Low,
                          _selectedUrgency == Urgency.Medium,
                          _selectedUrgency == Urgency.High
                        ],
                        onPressed: (index) {
                          setState(() {
                             _selectedUrgency = Urgency.values[index];
                          });
                        },
                        borderRadius: BorderRadius.circular(8),
                        children: const [
                          Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text("Low")),
                          Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text("Medium")),
                          Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text("High")),
                        ],
                       ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
              _buildSectionHeader("Location"),
               Card(
                 child: Padding(
                   padding: const EdgeInsets.all(16.0),
                   child: Column(
                    children: [
                       SizedBox(
                        width: double.infinity,
                         child: ElevatedButton.icon(
                          icon: _isFetchingLocation
                               ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                               : const Icon(Icons.my_location),
                          label: const Text('Use My Current Location'),
                          onPressed: _getGpsLocation,
                         ),
                       ),
                        if (_currentPosition != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              'Lat: ${_currentPosition!.latitude.toStringAsFixed(4)}, Lon: ${_currentPosition!.longitude.toStringAsFixed(4)}',
                              style: TextStyle(color: Colors.green[700]),
                            ),
                          ),
                       const SizedBox(height: 16),
                       TextFormField(
                        controller: _landmarkController,
                        decoration: const InputDecoration(
                          labelText: 'Address / Landmark (Optional)',
                          border: OutlineInputBorder(),
                        ),
                       ),
                    ],
                   ),
                 ),
               ),
              
              const SizedBox(height: 24),
              _buildSectionHeader("Attachments"),
               Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                       OutlinedButton.icon(
                        icon: const Icon(Icons.attach_file),
                        label: const Text('Add Photos'),
                        onPressed: _pickImages,
                       ),
                       const SizedBox(height: 8),
                       if (_pickedImages.isNotEmpty)
                          Wrap(
                            spacing: 8.0,
                            runSpacing: 8.0,
                            children: _pickedImages.map((image) {
                              return Stack(
                                children: [
                                   Image.file(
                                    File(image.path),
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                   ),
                                   Positioned(
                                    right: 0,
                                    top: 0,
                                     child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _pickedImages.remove(image);
                                        });
                                      },
                                       child: const CircleAvatar(
                                        radius: 12,
                                        backgroundColor: Colors.black54,
                                        child: Icon(Icons.close, color: Colors.white, size: 14)),
                                     ),
                                   )
                                ],
                              );
                            }).toList(),
                          )
                    ],
                  ),
                ),
               ),

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: const Color(0xFF0D47A1),
                  ),
                  onPressed: _submitComplaint,
                  child: const Text('SUBMIT COMPLAINT', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Colors.grey[600],
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _landmarkController.dispose();
    super.dispose();
  }
}