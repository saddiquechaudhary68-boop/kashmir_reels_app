import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool isSearching = false;
  QuerySnapshot? searchSnapshot;

  void _performSearch(String query) async {
    if (query.isEmpty) return;

    setState(() {
      isSearching = true;
    });

    // Firestore search for users by username
    QuerySnapshot snap = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isGreaterThanOrEqualTo: query)
        .where('username', isLessThanOrEqualTo: '$query\zf8ff')
        .get();

    setState(() {
      searchSnapshot = snap;
      isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: TextFormField(
          controller: _searchController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Search users, hashtags, videos...',
            hintStyle: TextStyle(color: Colors.grey),
            border: InputBorder.none,
            prefixIcon: Icon(Icons.search, color: Colors.grey),
          ),
          onFieldSubmitted: _performSearch,
        ),
      ),
      body: isSearching
          ? const Center(child: CircularProgressIndicator(color: Colors.redAccent))
          : searchSnapshot == null
              ? _buildTrendingHashtags()
              : _buildSearchResults(),
    );
  }

  Widget _buildTrendingHashtags() {
    final List<String> trendingHashtags = [
      '#KashmirReels',
      #KashmirBeauty',
      '#Viral2026',
      '#TrendingMusic',
      '#ParadiseOnEarth',
    ];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAlignment.start,
        children: [
          const Text(
            'Trending Hashtags',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: trendingHashtags.map((tag) {
              return Chip(
                backgroundColor: Colors.white12,
                label: Text(tag, style: const TextStyle(color: Colors.redAccent)),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (searchSnapshot!.docs.isEmpty) {
      return const Center(
        child: Text('No users found', style: TextStyle(color: Colors.grey)),
      );
    }

    return ListView.builder(
      itemCount: searchSnapshot!.docs.length,
      itemBuilder: (context, index) {
        var user = searchSnapshot!.docs[index];
        bool hasBlueTick = user['isManualVerified'] ?? false;

        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.grey,
            backgroundImage: (user['profilePic'] as String).isNotEmpty
                ? NetworkImage(user['profilePic'])
                : null,
            child: (user['profilePic'] as String).isEmpty
                ? const Icon(Icons.person, color: Colors.white)
                : null,
          ),
          title: Row(
            children: [
              Text(
                user['username'],
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              if (hasBlueTick) ...[
                const SizedBox(width: 5),
                const Icon(Icons.verified, color: Colors.blue, size: 16),
              ],
            ],
          ),
          subtitle: Text(
            '${user['followersCount'] ?? 0} followers',
            style: const TextStyle(color: Colors.grey),
          ),
        );
      },
    );
  }
}
