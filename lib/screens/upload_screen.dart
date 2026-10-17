import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({Key? key}) : super(key: key);

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  File? _videoFile;
  final TextEditingController _captionController = TextEditingController();
  String selectedSound = 'Original Audio';
  bool isUploading = false;

  // Mock Trending Music List
  final List<Map<String, String>> trendingMusicList = [
    {'title': 'Original Audio', 'artist': 'User Sound'},
    {'title': 'Kashmiri Folk Mix - Trending', 'artist': 'Kashmir Beats'},
    {'title': 'Lo-Fi Chill Vibe 2026', 'artist': 'Acoustic Studio'},
    {'title': 'Viral Reel Audio #1', 'artist': 'Trending Sounds'},
  ];

  Future<void> _pickVideo(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickVideo(source: source);
    if (pickedFile != null) {
      setState(() {
        _videoFile = File(pickedFile.path);
      });
    }
  }

  void _showMusicPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select Trending Music',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: trendingMusicList.length,
                  itemBuilder: (context, index) {
                    final music = trendingMusicList[index];
                    return ListTile(
                      leading: const Icon(Icons.music_note, color: Colors.redAccent),
                      title: Text(music['title']!, style: const TextStyle(color: Colors.white)),
                      subtitle: Text(music['artist']!, style: const TextStyle(color: Colors.grey)),
                      onTap: () {
                        setState(() {
                          selectedSound = music['title']!;
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _uploadVideo() async {
    if (_videoFile == null) return;

    setState(() {
      isUploading = true;
    });

    try {
      String uid = FirebaseAuth.instance.currentUser?.uid ?? 'guest';
      String videoId = DateTime.now().millisecondsSinceEpoch.toString();

      // 1. Storage me video upload
      Reference ref = FirebaseStorage.instance.ref().child('videos').child(videoId);
      UploadTask uploadTask = ref.putFile(_videoFile!);
      TaskSnapshot snap = await uploadTask;
      String videoUrl = await snap.ref.getDownloadURL();

      // 2. Initial Auto-Boost Algorithm (400 to 500 initial views boost)
      int initialViews = 400 + (DateTime.now().millisecond % 100);

      // 3. Firestore DB me save
      await FirebaseFirestore.instance.collection('videos').doc(videoId).set({
        'videoId': videoId,
        'uid': uid,
        'videoUrl': videoUrl,
        'caption': _captionController.text.trim(),
        'soundName': selectedSound,
        'likes': [],
        'commentsCount': 0,
        'sharesCount': 0,
        'viewsCount': initialViews, // Initial Boost Views!
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reel Uploaded Successfully with Initial Boost!')),
      );

      setState(() {
        _videoFile = null;
        _captionController.clear();
        isUploading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: $e')),
      );
      setState(() {
        isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('New Reel'),
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              if (_videoFile == null)
                Container(
                  height: 300,
                  width: double.infinity,
                  color: Colors.white10,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.videocam, color: Colors.white, size: 50),
                        onPressed: () => _pickVideo(ImageSource.camera),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () => _pickVideo(ImageSource.gallery),
                        child: const Text('Select Video from Gallery'),
                      ),
                    ],
                  ),
                )
              else
                Column(
                  children: [
                    Container(
                      height: 250,
                      width: double.infinity,
                      color: Colors.grey[800],
                      child: const Center(
                        child: Icon(Icons.check_circle, color: Colors.green, size: 60),
                      ),
                    ),
                    const SizedBox(height: 15),
                    ListTile(
                      tileColor: Colors.white10,
                      leading: const Icon(Icons.music_note, color: Colors.redAccent),
                      title: Text(selectedSound, style: const TextStyle(color: Colors.white)),
                      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
                      onTap: _showMusicPicker,
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: _captionController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Add caption & hashtags #kashmir #reels...',
                        hintStyle: TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: Colors.white10,
                      ),
                    ),
                    const SizedBox(height: 20),
                    isUploading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: _uploadVideo,
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                            child: const Text('Post Reel'),
                          ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
