import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  late Animation<double> _bgScaleAnimation;
  late Animation<double> _titleFade;
  late Animation<Offset> _titleSlide;
  late Animation<double> _subtitleFade;
  late Animation<Offset> _subtitleSlide;
  late Animation<double> _buttonFade;
  late Animation<Offset> _buttonSlide;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _bgScaleAnimation = Tween<double>(begin: 1.05, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 1.0, curve: Curves.easeOutQuart),
      ),
    );

    _titleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.6, curve: Curves.easeOutCubic),
      ),
    );
    _titleSlide =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.6, curve: Curves.easeOutCubic),
      ),
    );

    _subtitleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.4, 0.8, curve: Curves.easeOutCubic),
      ),
    );
    _subtitleSlide =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.4, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _buttonFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOutCubic),
      ),
    );
    _buttonSlide =
        Tween<Offset>(begin: const Offset(0.2, 0.0), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final titleFontSize = screenWidth < 360
        ? 26.0
        : screenWidth < 400
            ? 30.0
            : 34.0;

    return Scaffold(
      backgroundColor: AppTheme.background,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _bgScaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _bgScaleAnimation.value,
                  child: Image.asset(
                    'assets/images/welcome_car.jpg',
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                  ),
                );
              },
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.background.withValues(alpha: 0.0),
                    AppTheme.background.withValues(alpha: 0.0),
                    AppTheme.background.withValues(alpha: 0.25),
                    AppTheme.background.withValues(alpha: 0.55),
                    AppTheme.background.withValues(alpha: 0.8),
                    AppTheme.background.withValues(alpha: 0.95),
                    AppTheme.background,
                  ],
                  stops: const [0.0, 0.34, 0.45, 0.55, 0.65, 0.75, 0.88],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 28.0, vertical: 40.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FadeTransition(
                    opacity: _titleFade,
                    child: SlideTransition(
                      position: _titleSlide,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: textTheme.headlineLarge?.copyWith(
                              fontSize: titleFontSize,
                              height: 1.2,
                              letterSpacing: -0.5,
                            ),
                            children: const [
                              TextSpan(text: 'SEJA BEM VINDO AO\n'),
                              TextSpan(text: 'ZANIN '),
                              TextSpan(
                                text: 'DETAILER',
                                style: TextStyle(color: AppTheme.primaryRed),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  FadeTransition(
                    opacity: _subtitleFade,
                    child: SlideTransition(
                      position: _subtitleSlide,
                      child: Text(
                        'Agende seu detalhamento automotivo de forma rápida e garanta o brilho que seu carro merece.',
                        textAlign: TextAlign.center,
                        style: textTheme.bodyLarge?.copyWith(
                          color: Colors.white60,
                          fontSize: 15,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 56),
                  FadeTransition(
                    opacity: _buttonFade,
                    child: SlideTransition(
                      position: _buttonSlide,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color:
                                    AppTheme.primaryRed.withValues(alpha: 0.2),
                                blurRadius: 15,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: FloatingActionButton(
                            onPressed: () => context.go(AppRouter.services),
                            backgroundColor: AppTheme.primaryRed,
                            elevation: 0,
                            highlightElevation: 0,
                            shape: const CircleBorder(),
                            child: const Icon(Icons.arrow_forward_ios,
                                color: Colors.white, size: 22),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
