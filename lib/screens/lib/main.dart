import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/upload_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const KashmirReelsApp());
}

class KashmirReelsApp extends StatelessWidget {
  const KashmirReelsApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kashmir Reels',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
      ),
      home: const MainFeedScreen(),
    );
  }
}

class MainFeedScreen extends StatefulWidget {
  const MainFeedScreen({Key? key}) : super(key: key);

  @override
  State<MainFeedScreen> createState() => _MainFeedScreenState();
}

class _MainFeedScreenState extends State<MainFeedScreen> {
  final PageController _pageController = PageController(initialPage: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        children: [
          // Page 1: For You Page (FYP) with Reels & Upload Button
          Stack(
            children: [
              const Center(
                child: Text(
                  '🔥 For You Feed (FYP)\nSwipe Left for Friends',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
              Positioned(
                bottom: 30,
                right: 20,
                child: FloatingActionButton(
                  backgroundColor: Colors.redAccent,
                  child: const Icon(Icons.add, color: Colors.white),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const UploadScreen()),
                    );
                  },
                ),
              ),
            ],
          ),

          // Page 2: Friends Feed (Left Swipe View)
          const Center(
            child: Text(
              '👥 Friends Feed\nOnly people you follow',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}
