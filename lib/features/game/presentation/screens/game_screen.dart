// lib/features/game/presentation/screens/game_screen.dart

import 'package:chat_noir/features/game/logic/game_logic.dart';
import 'package:chat_noir/features/game/presentation/widgets/hex_board.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  // Listener para reagir às mudanças de estado do jogo
  void _gameStatusListener() {
    final game = context.read<GameLogic>();
    if (game.gameStatus != GameStatus.playing) {
      // Atraso para garantir que a UI se reconstruiu antes de mostrar o diálogo
      Future.delayed(const Duration(milliseconds: 100), () {
        _showEndGameDialog(game.gameStatus);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // Adiciona o listener quando o widget é criado
    context.read<GameLogic>().addListener(_gameStatusListener);
  }

  @override
  void dispose() {
    // Remove o listener para evitar memory leaks
    context.read<GameLogic>().removeListener(_gameStatusListener);
    super.dispose();
  }

  void _showEndGameDialog(GameStatus status) {
    showDialog(
      context: context,
      barrierDismissible: false, // O utilizador não pode fechar clicando fora
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(status == GameStatus.playerWon ? 'Você Venceu!' : 'O Gato Escapou!'),
          content: Text(status == GameStatus.playerWon
              ? 'Parabéns, você encurralou o gato!'
              : 'Mais sorte para a próxima vez.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Jogar Novamente'),
              onPressed: () {
                Navigator.of(context).pop(); // Fecha o diálogo
                context.read<GameLogic>().resetGame(); // Reinicia o jogo
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Noir'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Consumer<GameLogic>(
                builder: (context, game, child) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text('Jogador: ${game.playerScore}'),
                      Text('Gato: ${game.cpuScore}'),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),
              const Expanded(
                child: Center(
                  child: HexBoard(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  context.read<GameLogic>().resetGame();
                },
                child: const Text('Resetar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
