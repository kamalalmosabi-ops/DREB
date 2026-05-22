import 'package:flutter/material.dart';
import 'package:darb/features/onboarding/presentation/screens/welcome_screen.dart';
import 'package:darb/features/onboarding/data/models/onboarding_model.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final List<OnboardingContent> _pages = OnboardingData.contents;

  void _navigateToWelcome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const WelcomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _navigateToWelcome,
                child: const Text("تخطي", style: TextStyle(color: Colors.grey, fontSize: 16)),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemCount: _pages.length,
                itemBuilder: (context, index) => Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(_pages[index].image, height: 300, fit: BoxFit.contain),
                    const SizedBox(height: 40),
                    Text(_pages[index].title, 
                      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(_pages[index].description, 
                        textAlign: TextAlign.center, 
                        style: const TextStyle(fontSize: 16, color: Colors.black54, height: 1.5)),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(40.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_pages.length, (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 8,
                      width: _currentPage == index ? 24 : 8,
                      margin: const EdgeInsets.only(right: 5),
                      decoration: BoxDecoration(
                        color: _currentPage == index ? const Color(0xFFE6A440) : Colors.grey[300],
                        borderRadius: BorderRadius.circular(5),
                      ),
                    )),
                  ),
                  const SizedBox(height: 40),
                  GestureDetector(
                    onTap: () {
                      if (_currentPage < _pages.length - 1) {
                        _pageController.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
                      } else {
                        _navigateToWelcome();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      decoration: const BoxDecoration(color: Color(0xFFE6A440), shape: BoxShape.circle),
                      child: Icon(_currentPage == _pages.length - 1 ? Icons.done : Icons.arrow_forward, color: Colors.white, size: 30),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}