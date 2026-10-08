import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../theme.dart';

class WorkZoneScreen extends StatefulWidget {
  const WorkZoneScreen({super.key});

  @override
  State<WorkZoneScreen> createState() => _WorkZoneScreenState();
}

class _WorkZoneScreenState extends State<WorkZoneScreen> {
  String? _selectedZoneId;
  String? _selectedZoneName;

  bool _isSaving = false;

  Future<void> _saveZone() async {
    if (_selectedZoneId == null || _selectedZoneName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your primary work zone.'),
        ),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login session expired. Please login again.'),
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('walkers')
          .doc(user.uid)
          .set(
        {
          'zoneId': _selectedZoneId,
          'zoneName': _selectedZoneName,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Work zone saved successfully.'),
        ),
      );

      // Next onboarding step will be added here.
    } on FirebaseException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.message ?? 'Unable to save your work zone.',
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Something went wrong. Please try again.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Work Zone'),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 24, 24, 8),
              child: Text(
                'Choose your work zone',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: DojoPartnerTheme.textPrimary,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Text(
                'Select the primary area where you want to provide DOJO services.',
                style: TextStyle(
                  fontSize: 15,
                  color: DojoPartnerTheme.textSecondary,
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('service_zones')
                    .where('isActive', isEqualTo: true)
                    .orderBy('name')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'Unable to load work zones. Please try again later.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: DojoPartnerTheme.textSecondary,
                          ),
                        ),
                      ),
                    );
                  }

                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: DojoPartnerTheme.primaryOrange,
                      ),
                    );
                  }

                  final zones = snapshot.data?.docs ?? [];

                  if (zones.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'No work zones are currently available.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: DojoPartnerTheme.textSecondary,
                          ),
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                      24,
                      0,
                      24,
                      24,
                    ),
                    itemCount: zones.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final doc = zones[index];
                      final data = doc.data();

                      final name =
                          data['name']?.toString() ?? 'Unnamed Zone';

                      final city =
                          data['city']?.toString() ?? '';

                      final isSelected =
                          _selectedZoneId == doc.id;

                      return InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: _isSaving
                            ? null
                            : () {
                                setState(() {
                                  _selectedZoneId = doc.id;
                                  _selectedZoneName = name;
                                });
                              },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected
                                  ? DojoPartnerTheme.primaryOrange
                                  : const Color(0xFFE5E5E5),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? DojoPartnerTheme.primaryOrange
                                          .withValues(alpha: 0.10)
                                      : const Color(0xFFF3F3F3),
                                  borderRadius:
                                      BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.location_on_outlined,
                                  color: isSelected
                                      ? DojoPartnerTheme.primaryOrange
                                      : DojoPartnerTheme.textSecondary,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w700,
                                        color:
                                            DojoPartnerTheme.textPrimary,
                                      ),
                                    ),
                                    if (city.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        city,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: DojoPartnerTheme
                                              .textSecondary,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              Radio<String>(
                                value: doc.id,
                                groupValue: _selectedZoneId,
                                activeColor:
                                    DojoPartnerTheme.primaryOrange,
                                onChanged: _isSaving
                                    ? null
                                    : (value) {
                                        if (value == null) return;

                                        setState(() {
                                          _selectedZoneId = value;
                                          _selectedZoneName = name;
                                        });
                                      },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                24,
                8,
                24,
                24,
              ),
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveZone,
                child: _isSaving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
