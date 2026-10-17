import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class ProfileScreen extends StatefulWidget {
  final String uid;

  const ProfileScreen({Key? key, required this.uid}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      DocumentSnapshot snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .get();

      if (snap.exists) {
        setState(() {
          userData = UserModel.fromSnap(snap);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.redAccent)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          userData?.username ?? 'Profile',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              _showSettingsBottomSheet(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Profile Picture
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey[800],
              backgroundImage: userData?.profilePic.isNotEmpty == true
                  ? NetworkImage(userData!.profilePic)
                  : null,
              child: userData?.profilePic.isEmpty != false
                  ? const Icon(Icons.person, size: 50, color: Colors.white)
                  : null,
            ),
            const SizedBox(height: 12),

            // Username with Dynamic Blue Tick
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '@${userData?.username ?? 'user'}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (userData?.hasBlueTick ?? false) ...[
                  const SizedBox(width: 5),
                  const Icon(
                    Icons.verified,
                    color: Colors.blue,
                    size: 20,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 20),

            // Followers / Following / Likes Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatColumn('Following', userData?.followingCount ?? 0),
                _buildStatColumn('Followers', userData?.followersCount ?? 0),
                _buildStatColumn('Likes', 0),
              ],
            ),
            const SizedBox(height: 20),

            const Divider(color: Colors.white24),
            const SizedBox(height: 40),

            // Grid view placeholder for user videos
            const Center(
              child: Text(
                'No Videos Uploaded Yet',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, int count) {
    return Column(
      children: [
        Text(
          '$count',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 13),
        ),
      ],
    );
  }

  void _showSettingsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Account Settings',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Divider(color: Colors.white24),
              ListTile(
                leading: const Icon(Icons.privacy_tip, color: Colors.white),
                title: const Text('Privacy Policy', style: TextStyle(color: Colors.white)),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.lock, color: Colors.white),
                title: const Text('Security & Account', style: TextStyle(color: Colors.white)),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.verified, color: Colors.blue),
                title: const Text('Verification Badge Status', style: TextStyle(color: Colors.white)),
                subtitle: Text(
                  userData?.hasBlueTick == true ? 'Verified Account' : 'Not Verified',
                  style: const TextStyle(color: Colors.grey),
                ),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.redAccent),
                title: const Text('Log Out', style: TextStyle(color: Colors.redAccent)),
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
