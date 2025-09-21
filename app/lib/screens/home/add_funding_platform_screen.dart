import 'package:flutter/material.dart';
import '../../models/funding_platform_model.dart';
import '../../services/funding_service.dart';

class AddFundingPlatformScreen extends StatefulWidget {
  static const String routeName = '/add-funding-platform';
  
  const AddFundingPlatformScreen({super.key});

  @override
  State<AddFundingPlatformScreen> createState() =>
      _AddFundingPlatformScreenState();
}

class _AddFundingPlatformScreenState extends State<AddFundingPlatformScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _websiteUrlController = TextEditingController();
  final _logoUrlController = TextEditingController();
  bool _isLoading = false;
  final FundingService _fundingService = FundingService();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _websiteUrlController.dispose();
    _logoUrlController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Create and save the new platform
      await _fundingService.createPlatform(
        FundingPlatform(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: _nameController.text,
          description: _descriptionController.text,
          websiteUrl: _websiteUrlController.text,
          logoUrl: _logoUrlController.text.isNotEmpty
              ? _logoUrlController.text
              : 'https://via.placeholder.com/150',
          type: PlatformType.other,
          status: PlatformStatus.active,
          isFeatured: false,
          isRecommended: false,
          createdAt: DateTime.now(),
        ),
      );
      
      if (mounted) {
        Navigator.pop(context, true); // Return success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create platform: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Funding Platform'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Platform Logo Preview
                    if (_logoUrlController.text.isNotEmpty) ...[
                      Center(
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: NetworkImage(_logoUrlController.text),
                          onBackgroundImageError: (_, __) =>
                              const Icon(Icons.business, size: 50),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    // Platform Name
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Platform Name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.business),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a platform name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Description
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                        prefixIcon: Icon(Icons.description),
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Website URL
                    TextFormField(
                      controller: _websiteUrlController,
                      decoration: const InputDecoration(
                        labelText: 'Website URL',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.link),
                        hintText: 'https://example.com',
                      ),
                      keyboardType: TextInputType.url,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a website URL';
                        }
                        if (!value.startsWith('http')) {
                          return 'Please enter a valid URL (start with http:// or https://)';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Logo URL
                    TextFormField(
                      controller: _logoUrlController,
                      decoration: const InputDecoration(
                        labelText: 'Logo URL (optional)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.image),
                        hintText: 'https://example.com/logo.png',
                      ),
                      keyboardType: TextInputType.url,
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          setState(() {}); // Trigger rebuild to update preview
                        }
                      },
                    ),
                    const SizedBox(height: 24),
                    // Submit Button
                    ElevatedButton(
                      onPressed: _isLoading ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Add Platform',
                              style: TextStyle(fontSize: 16),
                            ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
