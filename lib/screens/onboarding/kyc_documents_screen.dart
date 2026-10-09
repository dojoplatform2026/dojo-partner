
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../theme.dart';

class KycDocumentsScreen extends StatefulWidget {
  const KycDocumentsScreen({super.key});

  @override
  State<KycDocumentsScreen> createState() =>
      _KycDocumentsScreenState();
}

class _KycDocumentsScreenState
    extends State<KycDocumentsScreen> {
  final ImagePicker _picker = ImagePicker();

  final Map<String, File?> _documents = {
    'aadhaar_front': null,
    'aadhaar_back': null,
    'pan_card': null,
  };

  final Map<String, String> _labels = {
    'aadhaar_front': 'Aadhaar Card — Front',
    'aadhaar_back': 'Aadhaar Card — Back',
    'pan_card': 'PAN Card',
  };

  String? _activeKey;

  Future<void> _captureDocument(String key) async {
    if (_activeKey != null) return;

    setState(() => _activeKey = key);

    try {
      final image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1800,
      );

      if (!mounted) return;

      if (image != null) {
        setState(() {
          _documents[key] = File(image.path);
        });
      }
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Camera could not open. Please check permissions.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _activeKey = null);
      }
    }
  }

  Widget _documentCard(String key) {
    final file = _documents[key];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: file == null
              ? const Color(0xFFE7E7E7)
              : DojoPartnerTheme.primaryOrange,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                file == null
                    ? Icons.description_outlined
                    : Icons.check_circle_rounded,
                color: file == null
                    ? DojoPartnerTheme.textSecondary
                    : DojoPartnerTheme.primaryOrange,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _labels[key]!,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: DojoPartnerTheme.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (file != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                file,
                width: double.infinity,
                height: 155,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const SizedBox(
                  height: 100,
                  child: Center(
                    child: Icon(Icons.broken_image_outlined),
                  ),
                ),
              ),
            )
          else
            Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF5EC),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.add_a_photo_outlined,
                size: 34,
                color: DojoPartnerTheme.primaryOrange,
              ),
            ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: OutlinedButton.icon(
              onPressed: _activeKey != null
                  ? null
                  : () => _captureDocument(key),
              icon: Icon(
                file == null
                    ? Icons.camera_alt_outlined
                    : Icons.refresh_rounded,
              ),
              label: Text(
                _activeKey == key
                    ? 'Opening Camera...'
                    : file == null
                        ? 'Capture Document'
                        : 'Retake Photo',
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor:
                    DojoPartnerTheme.primaryOrange,
                side: const BorderSide(
                  color: DojoPartnerTheme.primaryOrange,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final completed =
        _documents.values.where((file) => file != null).length;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: const Text('KYC Documents'),
        centerTitle: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  const Text(
                    'Verify your documents',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w800,
                      color: DojoPartnerTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Capture clear, readable photos of your original documents.',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: DojoPartnerTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    '$completed of 3 documents captured',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _documentCard('aadhaar_front'),
                  const SizedBox(height: 14),
                  _documentCard('aadhaar_back'),
                  const SizedBox(height: 14),
                  _documentCard('pan_card'),
                  const SizedBox(height: 18),
                  const Text(
                    'Privacy: Only submit your own documents. '
                    'Keep document numbers readable and avoid glare.',
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.5,
                      color: DojoPartnerTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Color(0xFFE8E8E8)),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: completed == 3 && _activeKey == null
                      ? () {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Document upload and review flow '
                                'will be connected in the next step.',
                              ),
                            ),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        DojoPartnerTheme.primaryOrange,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        const Color(0xFFE5E5E5),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                  child: const Text(
                    'Continue to Review',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                    ),
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
