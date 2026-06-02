import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/router/app_router.dart';
import '../providers/booking_provider.dart';
import '../../../../features/client_booking/data/models/service_model.dart';
import '../widgets/booking_confirmation_step.dart';

class BookingPage extends StatefulWidget {
  final ServiceModel service;
  const BookingPage({super.key, required this.service});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookingProvider>().setService(widget.service);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  List<DateTime> _getUpcomingSaturdays() {
    List<DateTime> saturdays = [];
    DateTime date = DateTime.now();
    while (saturdays.length < 6) {
      if (date.weekday == DateTime.saturday) saturdays.add(date);
      date = date.add(const Duration(days: 1));
    }
    return saturdays;
  }

  Future<void> _openFullCalendar(
      BuildContext context, BookingProvider provider) async {
    final DateTime now = DateTime.now();
    final DateTime lastDayOfNextMonth = DateTime(now.year, now.month + 2, 0);

    final DateTime? picked = await showDatePicker(
      context: context,
      locale: const Locale('pt', 'BR'),
      initialDate: provider.selectedDate.weekday == DateTime.saturday
          ? provider.selectedDate
          : _getUpcomingSaturdays().first,
      firstDate: now,
      lastDate: lastDayOfNextMonth,
      selectableDayPredicate: (DateTime day) =>
          day.weekday == DateTime.saturday,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
                primary: AppTheme.primaryRed,
                onPrimary: Colors.white,
                surface: AppTheme.surface,
                onSurface: Colors.white),
            dialogBackgroundColor: AppTheme.background,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) provider.selectDate(picked);
  }

  @override
  Widget build(BuildContext context) {
    final bookingProvider = context.watch<BookingProvider>();
    final service = widget.service;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        SizedBox(
                            height: 380,
                            width: double.infinity,
                            child: Image.asset(service.imageUrl,
                                fit: BoxFit.cover)),
                        Container(
                          height: 380,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.3),
                                Colors.transparent,
                                AppTheme.background.withValues(alpha: 0.8),
                                AppTheme.background
                              ],
                              stops: const [0.0, 0.4, 0.8, 1.0],
                            ),
                          ),
                        ),
                        Positioned(
                          top: 50,
                          left: 20,
                          child: GestureDetector(
                            onTap: () => context.go(AppRouter.services),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                  color: AppTheme.primaryRed
                                      .withValues(alpha: 0.3),
                                  shape: BoxShape.circle),
                              child: const Icon(Icons.arrow_back_ios_new,
                                  color: Colors.white, size: 18),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(service.title,
                              style: textTheme.headlineLarge
                                  ?.copyWith(fontSize: 26)),
                          const SizedBox(height: 8),
                          Text(
                              'Duração: ~${service.duration} • R\$ ${service.price.toStringAsFixed(2).replaceAll('.', ',')}',
                              style: textTheme.bodyMedium),
                          const SizedBox(height: 40),
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Positioned.fill(
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Container(
                                    height: 200,
                                    decoration: BoxDecoration(
                                        color: Colors.transparent,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                              color: AppTheme.primaryRed
                                                  .withValues(alpha: 0.05),
                                              blurRadius: 80,
                                              spreadRadius: 20)
                                        ]),
                                  ),
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Data e Horário',
                                          style: textTheme.titleLarge),
                                      IconButton(
                                        icon: const Icon(Icons.calendar_month,
                                            color: AppTheme.primaryRed,
                                            size: 26),
                                        onPressed: () => _openFullCalendar(
                                            context, bookingProvider),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  SizedBox(
                                      height: 130,
                                      child: _buildHorizontalCalendar(
                                          bookingProvider, textTheme)),
                                  const SizedBox(height: 30),
                                  if (bookingProvider.isLoadingHours)
                                    const Center(
                                        child: CircularProgressIndicator(
                                            color: AppTheme.primaryRed))
                                  else if (bookingProvider
                                      .availableHours.isEmpty)
                                    Padding(
                                      padding: const EdgeInsets.all(20.0),
                                      child: Text('Nenhum horário disponível.',
                                          style: textTheme.bodyMedium),
                                    )
                                  else
                                    _buildTimeSlots(
                                        context, bookingProvider, textTheme),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 120),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                        AppTheme.background.withValues(alpha: 0.0),
                        AppTheme.background
                      ])),
                  child: SwipeToProceedButton(
                    isActive: bookingProvider.selectedTime != null,
                    textTheme: textTheme,
                    onSwipe: () {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          if (bookingProvider.selectedTime != null)
            SafeArea(
              child: BookingConfirmationStep(
                service: widget.service,
                selectedDate: bookingProvider.selectedDate,
                selectedTime: bookingProvider.selectedTime!,
                onBack: () {
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHorizontalCalendar(
      BookingProvider provider, TextTheme textTheme) {
    final List<DateTime> days = _getUpcomingSaturdays();
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: days.length,
      itemBuilder: (context, index) {
        final date = days[index];
        final isSelected = DateUtils.isSameDay(date, provider.selectedDate);
        final dayNumber = DateFormat('d').format(date);
        final dayOfWeek = _capitalize(
            DateFormat('E', 'pt_BR').format(date).replaceAll('.', ''));

        return GestureDetector(
          onTap: () => provider.selectDate(date),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 85,
            margin: const EdgeInsets.only(right: 16, bottom: 10, top: 10),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.primaryRed : const Color(0xFF121212),
              borderRadius: BorderRadius.circular(30),
              border: isSelected
                  ? null
                  : Border.all(color: const Color(0xFF888888), width: 1.5),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                          color: AppTheme.primaryRed.withValues(alpha: 0.5),
                          blurRadius: 15,
                          spreadRadius: 2,
                          offset: const Offset(0, 0))
                    ]
                  : [],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(dayNumber,
                    style: textTheme.headlineLarge?.copyWith(
                        fontSize: 28,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w600,
                        color: Colors.white)),
                const SizedBox(height: 6),
                Text(dayOfWeek,
                    style: textTheme.bodyLarge?.copyWith(
                        fontSize: 18,
                        color: isSelected ? Colors.white : Colors.grey[400])),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimeSlots(
      BuildContext context, BookingProvider provider, TextTheme textTheme) {
    final double buttonWidth =
        (MediaQuery.of(context).size.width - 48 - 16) / 2;
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: provider.availableHours.map<Widget>((time) {
        final isSelected = time == provider.selectedTime;
        return GestureDetector(
          onTap: () => provider.selectTime(time),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: buttonWidth,
            padding: const EdgeInsets.symmetric(vertical: 10),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.primaryRed : const Color(0xFF121212),
              borderRadius: BorderRadius.circular(12),
              border: isSelected
                  ? null
                  : Border.all(color: const Color(0xFF888888), width: 1.5),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                          color: AppTheme.primaryRed.withValues(alpha: 0.4),
                          blurRadius: 12,
                          spreadRadius: 1)
                    ]
                  : [],
            ),
            child: Text(time,
                style: textTheme.bodyLarge?.copyWith(
                    color: isSelected ? Colors.white : Colors.grey[300],
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 17)),
          ),
        );
      }).toList(),
    );
  }
}

class SwipeToProceedButton extends StatefulWidget {
  final bool isActive;
  final VoidCallback onSwipe;
  final TextTheme textTheme;

  const SwipeToProceedButton({
    super.key,
    required this.isActive,
    required this.onSwipe,
    required this.textTheme,
  });

  @override
  State<SwipeToProceedButton> createState() => _SwipeToProceedButtonState();
}

class _SwipeToProceedButtonState extends State<SwipeToProceedButton> {
  double _dragPosition = 0.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxDrag = constraints.maxWidth - 50 - 16;

        return Container(
          height: 65,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            boxShadow: widget.isActive
                ? [
                    BoxShadow(
                        color: AppTheme.primaryRed.withValues(alpha: 0.3),
                        blurRadius: 15,
                        spreadRadius: 1)
                  ]
                : [],
          ),
          child: Opacity(
            opacity: widget.isActive ? 1.0 : 0.4,
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Deslize para Avançar',
                          style: widget.textTheme.labelLarge),
                      const SizedBox(width: 8),
                      const Icon(Icons.keyboard_double_arrow_right,
                          color: Colors.white54, size: 20),
                    ],
                  ),
                ),
                Positioned(
                  left: _dragPosition,
                  child: GestureDetector(
                    onHorizontalDragUpdate: (details) {
                      if (!widget.isActive) return;
                      setState(() {
                        _dragPosition += details.delta.dx;

                        if (_dragPosition < 0) _dragPosition = 0;
                        if (_dragPosition > maxDrag) _dragPosition = maxDrag;
                      });
                    },
                    onHorizontalDragEnd: (details) {
                      if (!widget.isActive) return;

                      if (_dragPosition > maxDrag * 0.75) {
                        setState(() => _dragPosition = maxDrag);
                        widget.onSwipe();

                        Future.delayed(const Duration(milliseconds: 500), () {
                          if (mounted) setState(() => _dragPosition = 0);
                        });
                      } else {
                        setState(() => _dragPosition = 0);
                      }
                    },
                    child: Container(
                        width: 50,
                        height: 50,
                        decoration: const BoxDecoration(
                            color: AppTheme.primaryRed, shape: BoxShape.circle),
                        child: const Icon(Icons.arrow_forward_ios,
                            color: Colors.white, size: 20)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
