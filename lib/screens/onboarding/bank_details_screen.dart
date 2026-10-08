import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../theme.dart';

class BankDetailsScreen extends StatefulWidget {
  const BankDetailsScreen({super.key});

  @override
  State<BankDetailsScreen> createState() => _BankDetailsScreenState();
}

class _BankDetailsScreenState extends State<BankDetailsScreen> {
  final _formKey = GlobalKey<FormState>();

  final _holderNameController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _confirmAccountController = TextEditingController();
  final _ifscController = TextEditingController();

  bool _isSaving = false;
  bool _obscureAccount = true;
  bool _obscureConfirmAccount = true;

  @override
  void dispose() {
    _holderNameController.dispose();
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _confirmAccountController.dispose();
    _ifscController.dispose();
    super.dispose();
  }

  String _cleanAccountNumber(String value) {
    return value.replaceAll(RegExp(r'\D'), '');
  }

  String _cleanIfsc(String value) {
    return value.trim().toUpperCase().replaceAll(' ', '');
  }

  Future<void> _continue() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Login session expired. Please login again.',
          ),
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final accountNumber =
          _cleanAccountNumber(_accountNumberController.text);

      final maskedAccount =
          'XXXXXX${accountNumber.substring(accountNumber.length - 4)}';

      final ifsc = _cleanIfsc(_ifscController.text);

      await FirebaseFirestore.instance
          .collection('walkers')
          .doc(user.uid)
          .set(
        {
          'bank': {
            'accountHolderName':
                _holderNameController.text.trim(),
            'bankName':
                _bankNameController.text.trim(),
            'maskedAccountNumber': maskedAccount,
            'ifsc': ifsc,
            'status': 'pending',
          },
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Bank details saved successfully.',
          ),
        ),
      );

      // Next step: Working Schedule.
    } on FirebaseException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.message ?? 'Unable to save bank details.',
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
        title: const Text('Bank Details'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              24,
              24,
              24,
              32,
            ),
            children: [
              const Text(
                'Add your bank details',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: DojoPartnerTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Your bank account will be used for Partner payouts.',
                style: TextStyle(
                  fontSize: 15,
                  color: DojoPartnerTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 32),

              TextFormField(
                controller: _holderNameController,
                textCapitalization: TextCapitalization.words,
                enabled: !_isSaving,
                decoration: const InputDecoration(
                  labelText: 'Account Holder Name',
                  hintText: 'Enter name as per bank account',
                ),
                validator: (value) {
                  final name = value?.trim() ?? '';

                  if (name.isEmpty) {
                    return 'Enter account holder name';
                  }

                  if (name.length < 3) {
                    return 'Enter a valid name';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _bankNameController,
                textCapitalization: TextCapitalization.words,
                enabled: !_isSaving,
                decoration: const InputDecoration(
                  labelText: 'Bank Name',
                  hintText: 'Enter your bank name',
                ),
                validator: (value) {
                  final bank = value?.trim() ?? '';

                  if (bank.isEmpty) {
                    return 'Enter bank name';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _accountNumberController,
                keyboardType: TextInputType.number,
                maxLength: 18,
                obscureText: _obscureAccount,
                enabled: !_isSaving,
                decoration: InputDecoration(
                  labelText: 'Account Number',
                  hintText: 'Enter account number',
                  counterText: '',
                  suffixIcon: IconButton(
                    tooltip: _obscureAccount
                        ? 'Show account number'
                        : 'Hide account number',
                    onPressed: _isSaving
                        ? null
                        : () {
                            setState(() {
                              _obscureAccount =
                                  !_obscureAccount;
                            });
                          },
                    icon: Icon(
                      _obscureAccount
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                ),
                validator: (value) {
                  final account =
                      _cleanAccountNumber(value ?? '');

                  if (account.isEmpty) {
                    return 'Enter account number';
                  }

                  if (account.length < 9 ||
                      account.length > 18) {
                    return 'Enter a valid account number';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _confirmAccountController,
                keyboardType: TextInputType.number,
                maxLength: 18,
                obscureText: _obscureConfirmAccount,
                enabled: !_isSaving,
                decoration: InputDecoration(
                  labelText: 'Confirm Account Number',
                  hintText: 'Re-enter account number',
                  counterText: '',
                  suffixIcon: IconButton(
                    tooltip: _obscureConfirmAccount
                        ? 'Show account number'
                        : 'Hide account number',
                    onPressed: _isSaving
                        ? null
                        : () {
                            setState(() {
                              _obscureConfirmAccount =
                                  !_obscureConfirmAccount;
                            });
                          },
                    icon: Icon(
                      _obscureConfirmAccount
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                ),
                validator: (value) {
                  final account =
                      _cleanAccountNumber(value ?? '');

                  final original = _cleanAccountNumber(
                    _accountNumberController.text,
                  );

                  if (account.isEmpty) {
                    return 'Confirm your account number';
                  }

                  if (account != original) {
                    return 'Account numbers do not match';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _ifscController,
                keyboardType: TextInputType.text,
                textCapitalization:
                    TextCapitalization.characters,
                maxLength: 11,
                enabled: !_isSaving,
                decoration: const InputDecoration(
                  labelText: 'IFSC Code',
                  hintText: 'Example: SBIN0001234',
                  counterText: '',
                ),
                validator: (value) {
                  final ifsc = _cleanIfsc(value ?? '');

                  if (ifsc.isEmpty) {
                    return 'Enter IFSC code';
                  }

                  if (!RegExp(
                    r'^[A-Z]{4}0[A-Z0-9]{6}$',
                  ).hasMatch(ifsc)) {
                    return 'Enter a valid IFSC code';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7F0),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFFFE0C2),
                  ),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.lock_outline,
                      color: DojoPartnerTheme.primaryOrange,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'For security, DOJO does not store your complete bank account number in the app database. Only a masked reference is saved.',
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          color: DojoPartnerTheme.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 36),

              ElevatedButton(
                onPressed: _isSaving ? null : _continue,
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
            ],
          ),
        ),
      ),
    );
  }
}
