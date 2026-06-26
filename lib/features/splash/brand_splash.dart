import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:dranyen/features/tuner/tuner_screen.dart';

const _cream = Color(0xFFF4ECD9);
const _maroon = Color(0xFF7D1D1D);

/// Launch splash for the Terma Heritage Foundation — the maroon seal on
/// parchment cream. Fades in, holds briefly, then settles into the tuner.
class BrandSplash extends StatefulWidget {
  const BrandSplash({super.key});

  @override
  State<BrandSplash> createState() => _BrandSplashState();
}

class _BrandSplashState extends State<BrandSplash> {
  double _opacity = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _opacity = 1);
    });
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 500),
          pageBuilder: (_, _, _) => const TunerScreen(),
          transitionsBuilder: (_, anim, _, child) => FadeTransition(opacity: anim, child: child),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      body: Center(
        child: AnimatedOpacity(
          opacity: _opacity,
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeOut,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/branding/main-logo-trim.png',
                  width: 168, errorBuilder: (_, _, _) => const SizedBox(height: 168)),
              const SizedBox(height: 34),
              Image.asset('assets/branding/main-logo-tibetan-text-trim.png',
                  width: 250, errorBuilder: (_, _, _) => const SizedBox(height: 60)),
              const SizedBox(height: 18),
              Text(
                'Terma Heritage Foundation',
                style: GoogleFonts.spaceGrotesk(
                    color: _maroon, fontSize: 16, fontWeight: FontWeight.w500, letterSpacing: 0.3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
