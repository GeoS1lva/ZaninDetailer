import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/booking_provider.dart';
import '../providers/service_selection_provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';

class BookingPage extends StatefulWidget {
  final ServiceModel service;
  const BookingPage({super.key, required this.service});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookingProvider>().setService(widget.service);
    });
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    final bookingProvider = context.watch<BookingProvider>();
    final service = widget.service;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
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
                      child: Image.asset(
                        service.imageUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
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
                            AppTheme.background,
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
                            color: AppTheme.primaryRed.withValues(alpha: 0.3),
                            shape: BoxShape.circle,
                          ),
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
                      Text(
                        service.title,
                        style:
                            Theme.of(context).textTheme.displayLarge?.copyWith(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Duração: ~${service.duration} • R\$ ${service.price}.',
                        style: const TextStyle(
                            color: AppTheme.textSecondary, fontSize: 14),
                      ),
                      const SizedBox(height: 40),
                      Text(
                        'Data e Horario',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 100,
                        child: _buildHorizontalCalendar(bookingProvider),
                      ),
                      const SizedBox(height: 30),
                      if (bookingProvider.isLoadingHours)
                        const Center(
                            child: CircularProgressIndicator(
                                color: AppTheme.primaryRed))
                      else if (bookingProvider.availableHours.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Text('Nenhum horário disponível.',
                              style: TextStyle(color: AppTheme.textSecondary)),
                        )
                      else
                        _buildTimeSlots(context, bookingProvider),
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
                  ],
                ),
              ),
              child: _buildCustomCTAButton(bookingProvider),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalCalendar(BookingProvider provider) {
    final today = DateTime.now();
    final days = List.generate(14, (index) => today.add(Duration(days: index)));

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
          child: Container(
            width: 70,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.primaryRed : Colors.transparent,
              borderRadius: BorderRadius.circular(40),
              border: isSelected
                  ? null
                  : Border.all(
                      color: Colors.white.withValues(alpha: 0.2), width: 1),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(dayNumber,
                    style: TextStyle(
                        fontSize: 22,
                        color: Colors.white,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w600)),
                const SizedBox(height: 4),
                Text(dayOfWeek,
                    style: TextStyle(
                        fontSize: 16,
                        color:
                            isSelected ? Colors.white : AppTheme.textSecondary,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimeSlots(BuildContext context, BookingProvider provider) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double buttonWidth = (screenWidth - 48 - 16) / 2;

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: provider.availableHours.map<Widget>((time) {
        final isSelected = time == provider.selectedTime;

        return GestureDetector(
          onTap: () => provider.selectTime(time),
          child: Container(
            width: buttonWidth,
            padding: const EdgeInsets.symmetric(vertical: 16),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.primaryRed : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: isSelected
                  ? null
                  : Border.all(
                      color: Colors.white.withValues(alpha: 0.2), width: 1),
            ),
            child: Text(
              time,
              style: TextStyle(
                color: Colors.white,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 16,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCustomCTAButton(BookingProvider provider) {
    final bool isActive = provider.selectedTime != null;

    return GestureDetector(
      onTap: isActive
          ? () {
              debugPrint(
                  "Avançar clicado: ${provider.selectedDate} as ${provider.selectedTime}");
            }
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 65,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          boxShadow: isActive
              ? [
                  BoxShadow(
                      color: AppTheme.primaryRed.withValues(alpha: 0.2),
                      blurRadius: 15,
                      spreadRadius: 1)
                ]
              : [],
        ),
        child: Opacity(
          opacity: isActive ? 1.0 : 0.4,
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                  color: AppTheme.primaryRed,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_forward_ios,
                    color: Colors.white, size: 20),
              ),
              const Expanded(
                child: Center(
                  child: Text(
                    'Avançar',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward_ios,
                  color: Colors.white54, size: 16),
              Transform.translate(
                offset: const Offset(-8, 0),
                child: const Icon(Icons.arrow_forward_ios,
                    color: Colors.white54, size: 16),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }
}
