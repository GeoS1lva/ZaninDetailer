// Caminho: lib/features/client_booking/presentation/pages/welcome_page.dart
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1ª Camada: Sua Nova Imagem de Fundo (BMW refletindo) como Asset
          Positioned.fill(
            child: Image.asset(
              'assets/images/welcome_car.jpg', // Caminho que definimos
              fit: BoxFit.cover,
            ),
          ),
          
          // 2ª Camada: Degradê Refinado de Dupla Proteção (ToT Decision)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    // Topo: Sutilmente escurecido para blindar o título da luminária
                    Colors.black.withOpacity(0.3),
                    // Meio-Topo: Transparência para o carro brilhar
                    Colors.transparent,
                    // Meio-Baixo: Começa a escurecer para segurar o subtítulo
                    AppTheme.background.withOpacity(0.8),
                    // Base: Totalmente sólida (Preto Zanin)
                    AppTheme.background, 
                  ],
                  stops: const [0.0, 0.45, 0.75, 1.0], // Ajuste fino da transição
                ),
              ),
            ),
          ),

          // 3ª Camada: Conteúdo (Textos e Botão com SafeArea)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end, // Alinha tudo na base
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            fontSize: 32, // Montserrat Bold
                            height: 1.2,
                          ),
                      children: const [
                        TextSpan(text: 'SEJA BEM VINDO AO\nZANIN '),
                        TextSpan(
                          text: 'DETAILER',
                          style: TextStyle(color: AppTheme.primaryRed), // Vermelho da marca
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16), // Espaço Urbanist
                  
                  Text(
                    'Agende seu detalhamento automotivo de forma rápida e garanta o brilho que seu carro merece.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppTheme.textSecondary, // Urbanist Regular Cinza
                          fontSize: 16,
                          height: 1.5,
                        ),
                  ),
                  const SizedBox(height: 48), // Espaçamento maior para o CTA
                  
                  // Botão de Avançar alinhado à direita
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      FloatingActionButton(
                        onPressed: () {
                          // TODO: Implementar navegação para a tela de Escolha de Serviço
                          print("Navegar para serviços");
                        },
                        // Usando o primaryRed e as configurações conceituais de opacidade anteriores
                        backgroundColor: AppTheme.primaryRed.withOpacity(0.9), 
                        elevation: 0, 
                        highlightElevation: 0,
                        shape: const CircleBorder(),
                        child: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 20),
                      ),
                    ],
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