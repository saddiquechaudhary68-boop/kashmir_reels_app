import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String username;
  final String email;
  final String phoneNumber;
  final String profilePic;
  final int followersCount;
  final int followingCount;
  final int userIndex; // User ka sign-up number (1st to 25th identification)
  final bool isManualVerified; // Admin dwara diya gaya blue tick
  final DateTime? verificationExpiry; // Verification ki expiry date
  final bool isAdmin; // Aapka official admin account

  UserModel({
    required this.uid,
    required this.username,
    required this.email,
    required this.phoneNumber,
    required this.profilePic,
    this.followersCount = 0,
    this.followingCount = 0,
    required this.userIndex,
    this.isManualVerified = false,
    this.verificationExpiry,
    this.isAdmin = false,
  });

  // Dynamic Blue Tick Logic Engine
  bool get hasBlueTick {
    // 1. Permanently Verified for Admin (Aapka Account)
    if (isAdmin) return true;

    // 2. Admin dwara manually diya gaya Blue Tick
    if (isManualVerified) return true;

    // 3. First 25 users gets Free Permanent Blue Tick
    if (userIndex <= 25) return true;

    // Expiry check helper
    bool isNotExpired = verificationExpiry != null && verificationExpiry!.isAfter(DateTime.now());

    // 4. 1 Million+ Followers = Lifetime Free
    if (followersCount >= 1000000) return true;

    // 5. 50k Followers = 6 Months Free (or active period)
    if (followersCount >= 50000 && isNotExpired) return true;

    // 6. 10k Followers = 3 Months Free (or active period)
    if (followersCount >= 10000 && isNotExpired) return true;

    return false;
  }

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'username': username,
        'email': email,
        'phoneNumber': phoneNumber,
        'profilePic': profilePic,
        'followersCount': followersCount,
        'followingCount': followingCount,
        'userIndex': userIndex,
        'isManualVerified': isManualVerified,
        'verificationExpiry': verificationExpiry?.toIso8601String(),
        'isAdmin': isAdmin,
      };

  static UserModel fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;
    return UserModel(
      uid: snapshot['uid'] ?? '',
      username: snapshot['username'] ?? '',
      email: snapshot['email'] ?? '',
      phoneNumber: snapshot['phoneNumber'] ?? '',
      profilePic: snapshot['profilePic'] ?? '',
      followersCount: snapshot['followersCount'] ?? 0,
      followingCount: snapshot['followingCount'] ?? 0,
      userIndex: snapshot['userIndex'] ?? 9999,
      isManualVerified: snapshot['isManualVerified'] ?? false,
      verificationExpiry: snapshot['verificationExpiry'] != null
          ? DateTime.parse(snapshot['verificationExpiry'])
          : null,
      isAdmin: snapshot['isAdmin'] ?? false,
    );
  }
}
