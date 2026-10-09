import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../theme.dart';
import 'personal_details_screen.dart';

class WorkZoneScreen extends StatefulWidget {
  const WorkZoneScreen({super.key});

  @override
  State<WorkZoneScreen> createState() => _WorkZoneScreenState();
}

class _WorkZoneScreenState extends State<WorkZoneScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _selectedState;
  String? _selectedCity;
  String? _selectedArea;

  final Set<String> _selectedZoneIds = {};

  bool _isSaving = false;

  CollectionReference<Map<String, dynamic>> get _zones =>
      _firestore.collection('service_zones');

  Stream<QuerySnapshot<Map<String, dynamic>>> _locationsStream() {
    return _zones
        .where('isActive', isEqualTo: true)
        .snapshots();
  }

  List<String> _uniqueValues(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
    String field,
    Map<String, dynamic> Function(
      QueryDocumentSnapshot<Map<String, dynamic>>,
    ) filter,
  ) {
    final values = <String>{};

    for (final doc in docs) {
      final data = doc.data();

      if (filter(doc).isEmpty) continue;

      final value = data[field]?.toString().trim() ?? '';

      if (value.isNotEmpty) {
        values.add(value);
      }
    }

    final result = values.toList()..sort();
    return result;
  }

  List<String> _states(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    return _uniqueValues(
      docs,
      'state',
      (_) => {'valid': true},
    );
  }

  List<String> _cities(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    return _uniqueValues(
      docs,
      'city',
      (doc) => {
        'valid': doc.data()['state']?.toString() == _selectedState,
      },
    );
  }

  List<String> _areas(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    return _uniqueValues(
      docs,
      'area',
      (doc) => {
        'valid':
            doc.data()['state']?.toString() == _selectedState &&
            doc.data()['city']?.toString() == _selectedCity,
      },
    );
  }

  bool _matchesCurrentArea(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();

    return data['state']?.toString() == _selectedState &&
        data['city']?.toString() == _selectedCity &&
        data['area']?.toString() == _selectedArea;
  }

  Future<void> _continue(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> allZones,
  ) async {
    if (_selectedState == null ||
        _selectedCity == null ||
        _selectedArea == null) {
      _showMessage('Please select your state, city and area.');
      return;
    }

    if (_selectedZoneIds.isEmpty) {
      _showMessage('Please select at least one work zone.');
      return;
    }

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _showMessage('Login session expired. Please log in again.');
      return;
    }

    final selectedDocs = allZones
        .where((doc) =>
            _selectedZoneIds.contains(doc.id) &&
            _matchesCurrentArea(doc))
        .toList();

    if (selectedDocs.length != _selectedZoneIds.length) {
      _showMessage(
        'Some selected zones are no longer available. Please select again.',
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final zoneIds = selectedDocs.map((doc) => doc.id).toList();

      final zoneNames = selectedDocs.map((doc) {
        return doc.data()['name']?.toString() ?? '';
      }).toList();

      await _firestore.collection('walkers').doc(user.uid).set(
        {
          'userId': user.uid,
          'walkerId': user.uid,
          'state': _selectedState,
          'city': _selectedCity,
          'area': _selectedArea,
          'zoneIds': zoneIds,
          'zoneNames': zoneNames,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const PersonalDetailsScreen(),
        ),
      );
    } on FirebaseException catch (e) {
      if (!mounted) return;

      _showMessage(
        e.code == 'permission-denied'
            ? 'Firebase access denied. Please check your Firestore rules.'
            : e.message ?? 'Unable to save your location.',
      );
    } catch (_) {
      if (!mounted) return;
      _showMessage('Something went wrong. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget _sectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w800,
            color: DojoPartnerTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 14,
            height: 1.5,
            color: DojoPartnerTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _dropdown({
    required String label,
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: DojoPartnerTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          isExpanded: true,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: const Color(0xFFFAFAFA),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: const BorderSide(
                color: DojoPartnerTheme.primaryOrange,
                width: 1.5,
              ),
            ),
          ),
          items: items
              .map(
                (item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
          onChanged: _isSaving ? null : onChanged,
        ),
      ],
    );
  }

  Widget _zoneTile(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    final name = data['name']?.toString() ?? 'Unnamed Zone';
    final selected = _selectedZoneIds.contains(doc.id);

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: _isSaving
          ? null
          : () {
              setState(() {
                if (selected) {
                  _selectedZoneIds.remove(doc.id);
                } else {
                  _selectedZoneIds.add(doc.id);
                }
              });
            },
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFFFF5EC)
              : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? DojoPartnerTheme.primaryOrange
                : const Color(0xFFE5E5E5),
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: selected
                    ? DojoPartnerTheme.primaryOrange.withValues(alpha: 0.12)
                    : const Color(0xFFF4F4F4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.location_on_outlined,
                color: selected
                    ? DojoPartnerTheme.primaryOrange
                    : DojoPartnerTheme.textSecondary,
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Text(
                name,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: DojoPartnerTheme.textPrimary,
                ),
              ),
            ),
            Icon(
              selected
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: selected
                  ? DojoPartnerTheme.primaryOrange
                  : const Color(0xFFBDBDBD),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Work Location'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _locationsStream(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Unable to load locations. Check your connection and Firestore rules.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: DojoPartnerTheme.textSecondary,
                    ),
                  ),
                ),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: DojoPartnerTheme.primaryOrange,
                ),
              );
            }

            final docs = snapshot.data?.docs ?? [];

            if (docs.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'No active work locations are available yet. Please contact DOJO support.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: DojoPartnerTheme.textSecondary,
                    ),
                  ),
                ),
              );
            }

            final states = _states(docs);
            final cities = _cities(docs);
            final areas = _areas(docs);

            final availableZones = docs
                .where(_matchesCurrentArea)
                .toList()
              ..sort((a, b) {
                final aName = a.data()['name']?.toString() ?? '';
                final bName = b.data()['name']?.toString() ?? '';
                return aName.compareTo(bName);
              });

            return Column(
              children: [
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 480),
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                        children: [
                          Center(
                            child: Container(
                              width: 58,
                              height: 58,
                              decoration: BoxDecoration(
                                color: DojoPartnerTheme.primaryOrange,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: const Icon(
                                Icons.pets_rounded,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          const Text(
                            'DOJO PARTNER',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 3,
                              color: DojoPartnerTheme.primaryOrange,
                            ),
                          ),
                          const SizedBox(height: 22),
                          _sectionTitle(
                            'Where would you like to work?',
                            'Choose your preferred location and select all zones you can comfortably serve.',
                          ),
                          const SizedBox(height: 26),
                          _dropdown(
                            label: 'State',
                            hint: 'Select state',
                            value: _selectedState,
                            items: states,
                            onChanged: (value) {
                              setState(() {
                                _selectedState = value;
                                _selectedCity = null;
                                _selectedArea = null;
                                _selectedZoneIds.clear();
                              });
                            },
                          ),
                          const SizedBox(height: 18),
                          _dropdown(
                            label: 'City',
                            hint: 'Select city',
                            value: _selectedCity,
                            items: cities,
                            onChanged: _selectedState == null
                                ? (_) {}
                                : (value) {
                                    setState(() {
                                      _selectedCity = value;
                                      _selectedArea = null;
                                      _selectedZoneIds.clear();
                                    });
                                  },
                          ),
                          const SizedBox(height: 18),
                          _dropdown(
                            label: 'Area / Locality',
                            hint: 'Select area',
                            value: _selectedArea,
                            items: areas,
                            onChanged: _selectedCity == null
                                ? (_) {}
                                : (value) {
                                    setState(() {
                                      _selectedArea = value;
                                      _selectedZoneIds.clear();
                                    });
                                  },
                          ),
                          const SizedBox(height: 28),
                          _sectionTitle(
                            'Select work zones',
                            'Select one or more zones within your chosen area.',
                          ),
                          const SizedBox(height: 14),
                          if (_selectedArea == null)
                            Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFAFAFA),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: const Color(0xFFEEEEEE),
                                ),
                              ),
                              child: const Text(
                                'Choose your state, city and area first to see available zones.',
                                style: TextStyle(
                                  fontSize: 14,
                                  height: 1.5,
                                  color: DojoPartnerTheme.textSecondary,
                                ),
                              ),
                            )
                          else if (availableZones.isEmpty)
                            Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFAFAFA),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Text(
                                'No active zones are available in this area.',
                                style: TextStyle(
                                  color: DojoPartnerTheme.textSecondary,
                                ),
                              ),
                            )
                          else ...[
                            Text(
                              '${_selectedZoneIds.length} zone(s) selected',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: DojoPartnerTheme.primaryOrange,
                              ),
                            ),
                            const SizedBox(height: 10),
                            ...availableZones.map(_zoneTile),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(24, 14, 24, 20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(color: Color(0xFFEEEEEE)),
                    ),
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 480),
                      child: SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: _isSaving
                              ? null
                              : () => _continue(docs),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: DojoPartnerTheme.primaryOrange,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: _isSaving
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Save Location & Continue',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
