import 'package:flutter/material.dart';

import '../../theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            // Profile header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: const Color(0xFFEAEAEA),
                ),
              ),
              child: const Column(
                children: [
                  CircleAvatar(
                    radius: 42,
                    child: Icon(
                      Icons.person,
                      size: 42,
                    ),
                  ),
                  SizedBox(height: 14),
                  Text(
                    'Rahul',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '+91 XXXXX XXXXX',
                    style: TextStyle(
                      fontSize: 13,
                      color: DojoPartnerTheme.textSecondary,
                    ),
                  ),
                  SizedBox(height: 10),
                  _VerifiedBadge(),
                ],
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'WORK INFORMATION',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
                color: DojoPartnerTheme.textSecondary,
              ),
            ),

            const SizedBox(height: 12),

            _ProfileItem(
              icon: Icons.badge_outlined,
              title: 'Partner ID',
              value: 'DOJO-W-00124',
            ),

            _ProfileItem(
              icon: Icons.location_on_outlined,
              title: 'Primary Zone',
              value: 'Civil Lines',
            ),

            _ProfileItem(
              icon: Icons.pets_outlined,
              title: 'Service',
              value: 'Dog Walking',
            ),

            _ProfileItem(
              icon: Icons.star_outline,
              title: 'Rating',
              value: '4.9 / 5.0',
            ),

            const SizedBox(height: 24),

            const Text(
              'ACCOUNT',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
                color: DojoPartnerTheme.textSecondary,
              ),
            ),

            const SizedBox(height: 12),

            _ActionItem(
              icon: Icons.person_outline,
              title: 'Personal Details',
              onTap: () {},
            ),

            _ActionItem(
              icon: Icons.account_balance_outlined,
              title: 'Bank Details',
              onTap: () {},
            ),

            _ActionItem(
              icon: Icons.description_outlined,
              title: 'Documents & KYC',
              onTap: () {},
            ),

            _ActionItem(
              icon: Icons.support_agent_outlined,
              title: 'DOJO Support',
              onTap: () {},
            ),

            _ActionItem(
              icon: Icons.info_outline,
              title: 'About DOJO Partner',
              onTap: () {},
            ),

            const SizedBox(height: 24),

            OutlinedButton.icon(
              onPressed: () {
                _showLogoutDialog(context);
              },
              icon: const Icon(
                Icons.logout,
                color: Colors.red,
              ),
              label: const Text(
                'Logout',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(
                  double.infinity,
                  52,
                ),
                side: const BorderSide(
                  color: Color(0xFFE5E5E5),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Logout?',
            style: TextStyle(
              fontWeight: FontWeight.w800,
            ),
          ),
          content: const Text(
            'Are you sure you want to logout from DOJO Partner?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text(
                'Logout',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _VerifiedBadge extends StatelessWidget {
  const _VerifiedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF8EE),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.verified,
            size: 16,
            color: Colors.green,
          ),
          SizedBox(width: 5),
          Text(
            'Verified Partner',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileItem extends StatelessWidget {
  const _ProfileItem({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: const Color(0xFFEAEAEA),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: DojoPartnerTheme.primaryOrange,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color:
                        DojoPartnerTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionItem extends StatelessWidget {
  const _ActionItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFEAEAEA),
        ),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          icon,
          color: DojoPartnerTheme.primaryOrange,
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: DojoPartnerTheme.textSecondary,
        ),
      ),
    );
  }
}
