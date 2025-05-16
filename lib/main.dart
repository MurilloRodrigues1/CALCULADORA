import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

void main() {
  runApp(CalculadoraApp());
}

class CalculadoraApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculadora',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
      ),
      home: Calculadora(),
    );
  }
}

class Calculadora extends StatefulWidget {
  @override
  _CalculadoraState createState() => _CalculadoraState();
}

class _CalculadoraState extends State<Calculadora> {
  String expressao = '';
  String resultado = '';

  final List<String> botoes = [
    'C', '()', '%', '÷',
    '7', '8', '9', '×',
    '4', '5', '6', '-',
    '1', '2', '3', '+',
    '+/-', '0', '.', '='
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        final crossAxisCount = isMobile ? 4 : 6;
        final fontSize = isMobile ? 26.0 : 32.0;

        return Scaffold(
          body: Column(
            children: [
              // Display
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(isMobile ? 20 : 40),
                  alignment: Alignment.bottomRight,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                          _formatarExpressao(expressao),
                          style: TextStyle(fontSize: fontSize, color: Colors.white70),
                        ),
                      SizedBox(height: 10),
                      Text(
                        resultado,
                        style: TextStyle(fontSize: fontSize + 12, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
              // Botões
              Expanded(
                flex: 2,
                child: GridView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: botoes.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: 1.1,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                  ),
                  itemBuilder: (context, index) {
                    final botao = botoes[index];
                    return BotaoCalculadora(
                      texto: botao,
                      corTexto: _corTexto(botao),
                      corFundo: _corFundo(botao),
                      aoPressionar: () => _acaoBotao(botao),
                      fontSize: fontSize,
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

  void _acaoBotao(String texto) {
    setState(() {
      if (texto == 'C') {
        expressao = '';
        resultado = '';
      } else if (texto == '=') {
        try {
          String finalExp = expressao.replaceAll('×', '*').replaceAll('÷', '/');
          Parser p = Parser();
          Expression exp = p.parse(finalExp);
          ContextModel cm = ContextModel();
          double eval = exp.evaluate(EvaluationType.REAL, cm);
          resultado = eval.toString();
        } catch (e) {
          resultado = 'Erro';
        }
      } else if (texto == '+/-') {
        if (expressao.isNotEmpty) {
          if (expressao.startsWith('-')) {
            expressao = expressao.substring(1);
          } else {
            expressao = '-' + expressao;
          }
        }
      } else {
        expressao += texto;
      }
    });
  }

  Color _corFundo(String texto) {
    if (texto == 'C') return Colors.red;
    if (texto == '=') return Colors.green;
    if (['+', '-', '×', '÷', '%'].contains(texto)) return Colors.grey.shade800;
    return Colors.grey.shade900;
  }

  Color _corTexto(String texto) {
    if (['+', '-', '×', '÷', '=', '%'].contains(texto)) return Colors.greenAccent;
    if (texto == 'C') return Colors.white;
    return Colors.white70;
  }

  String _formatarExpressao(String exp) {
  return exp
      .replaceAllMapped(RegExp(r'([\d.]+|[+\-×÷%()])'), (match) => '${match.group(0)} ')
      .trim();
  }
}

class BotaoCalculadora extends StatelessWidget {
  final String texto;
  final Color corTexto;
  final Color corFundo;
  final VoidCallback aoPressionar;
  final double fontSize;

  const BotaoCalculadora({
    required this.texto,
    required this.corTexto,
    required this.corFundo,
    required this.aoPressionar,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: aoPressionar,
      style: ElevatedButton.styleFrom(
        backgroundColor: corFundo,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          texto,
          style: TextStyle(fontSize: fontSize, color: corTexto),
        ),
      ),
    );
  }
}