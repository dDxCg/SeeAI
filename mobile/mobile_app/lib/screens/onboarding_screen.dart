import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_colors.dart';
import 'home_screen.dart';
import 'package:audioplayers/audioplayers.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer(); 
  bool _hasUserInteracted = false;

  @override
  void initState() {
    super.initState();
  }

  void _playSoundGuide() async {
    await _audioPlayer.stop();
    await _audioPlayer.play(AssetSource('../sounds/instruction.mp3'));
  }

  void _finishOnboarding() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('first_time', false);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: GestureDetector(
          onTapDown: (_) {
            if (!_hasUserInteracted) {
              setState(() {
                _hasUserInteracted = true;
              });
              _playSoundGuide();
            }
          },
          child: Column(
            children: [
              Expanded(
                child: _buildGuidePage(),
              ),
              _buildNavigationControls(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGuidePage() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.accessibility_new, 
            size: 100, 
            color: AppColors.primaryColor
          ),
          SizedBox(height: 20),
          Text(
            'Hướng dẫn sử dụng',
            style: TextStyle(
              fontSize: 24, 
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColor
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Chạm vào màn hình để nghe hướng dẫn. Vuốt màn hình để chụp ảnh. Ứng dụng sẽ tự động mô tả những gì bạn chụp được.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationControls() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton(
            onPressed: _finishOnboarding,
            child: Text('Bắt đầu'),
          ),
        ],
      ),
    );
  }
}