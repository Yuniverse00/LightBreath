// ignore_for_file: dead_code

import 'dart:async';
import 'dart:math';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:sense2quit/games/pacman/ghost.dart';
import 'package:sense2quit/games/pacman/ghost2.dart';
import 'package:sense2quit/games/pacman/ghost3.dart';
import 'package:sense2quit/games/pacman/path.dart';
import 'package:sense2quit/games/pacman/pixel.dart';
import 'package:sense2quit/games/pacman/player.dart';

class Pacman extends StatefulWidget {
  const Pacman({super.key});

  @override
  _PacmanState createState() => _PacmanState();
}

class _PacmanState extends State<Pacman> with WidgetsBindingObserver {
  static int numberInRow = 11;
  int numberOfSquares = numberInRow * 16;
  int player = numberInRow * 14 + 1;
  int ghost = numberInRow * 2 - 2;
  int ghost2 = numberInRow * 9 - 1;
  int ghost3 = numberInRow * 11 - 2;
  bool preGame = true;
  bool mouthClosed = false;
  var controller;
  int score = 0;
  bool paused = false;
  final audioInGame = AssetsAudioPlayer();
  final AssetsAudioPlayer audioPaused = AssetsAudioPlayer();
  final AssetsAudioPlayer audioMunch = AssetsAudioPlayer();
  final AssetsAudioPlayer audioDeath = AssetsAudioPlayer();
  late Timer inputTimer;
  late Timer mouthTimer;
  late Timer ghostTimer;

  List<int> barriers = [
    0,
    1,
    2,
    3,
    4,
    5,
    6,
    7,
    8,
    9,
    10,
    11,
    22,
    33,
    44,
    55,
    66,
    77,
    99,
    110,
    121,
    132,
    143,
    154,
    165,
    166,
    167,
    168,
    169,
    170,
    171,
    172,
    173,
    174,
    175,
    164,
    153,
    142,
    131,
    120,
    109,
    87,
    76,
    65,
    54,
    43,
    32,
    21,
    78,
    79,
    80,
    100,
    101,
    102,
    84,
    85,
    86,
    106,
    107,
    108,
    24,
    35,
    46,
    57,
    30,
    41,
    52,
    63,
    81,
    70,
    59,
    61,
    72,
    83,
    26,
    28,
    37,
    38,
    39,
    123,
    134,
    145,
    129,
    140,
    151,
    103,
    114,
    125,
    105,
    116,
    127,
    147,
    148,
    149,
  ];

  List<int> food = [];
  String direction = "right";
  String ghostLast = "left";
  String ghostLast2 = "left";
  String ghostLast3 = "down";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    audioInGame.open(Audio('lib/games/pacman/assets/pacman_beginning.wav'),
        autoStart: false, loopMode: LoopMode.single, respectSilentMode: true);
    audioInGame.setVolume(0.6);
    audioPaused.open(Audio('lib/games/pacman/assets/pacman_intermission.wav'),
        autoStart: false, loopMode: LoopMode.single, respectSilentMode: true);
    audioPaused.setVolume(0.6);
    audioDeath.open(Audio('lib/games/pacman/assets/pacman_death.wav'),
        autoStart: false, respectSilentMode: true);
    audioMunch.open(Audio('lib/games/pacman/assets/pacman_chomp.wav'),
        autoStart: false, respectSilentMode: true);
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    inputTimer.cancel();
    ghostTimer.cancel();
    mouthTimer.cancel();
    WidgetsBinding.instance.removeObserver(this);
    audioInGame.dispose();
    audioDeath.dispose();
    audioMunch.dispose();
    audioPaused.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    safePrint(state);
    // if (state == AppLifecycleState.play()d) {
    //   if (paused) {
    //     audioPaused.play()();
    //   } else {
    //     audioInGame.play()();
    //   }
    // } else
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      paused = true;
      audioInGame.pause();
      audioPaused.pause();
    } else if (state == AppLifecycleState.resumed) {
      if (player != -1) {
        audioPaused.playOrPause();
        safePrint('190');
      }
    }
  }

  void startGame() {
    if (preGame) {
      // audioInGame = new AudioPlayer();
      // // audioInGame = new AudioPlayer();
      // // audioPaused = new AudioPlayer();
      if (!audioInGame.isPlaying.value) {
        audioInGame.play();
      }
      safePrint('186');
      preGame = false;
      getFood();

      inputTimer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
        if (paused) {
        } else {
          // audioInGame.play(AssetSource('pacman/pacman_beginning.wav'));
          if (player != -1 && !audioInGame.isPlaying.value) {
            audioInGame.play();
            safePrint('211');
          }
        }
        if (player == ghost || player == ghost2 || player == ghost3) {
          audioInGame.pause();
          audioDeath.play();
          safePrint('217');
          setState(() {
            player = -1;
          });
          showDialog(
              barrierDismissible: false,
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Center(child: Text("Game Over!")),
                  content: Text("Your Score : $score"),
                  actions: [
                    ElevatedButton(
                      onPressed: () {
                        // audioInGame
                        //     .play(AssetSource('pacman/pacman_beginning.wav'));
                        // audioInGame.play();
                        safePrint('234');
                        setState(() {
                          player = numberInRow * 14 + 1;
                          ghost = numberInRow * 2 - 2;
                          ghost2 = numberInRow * 9 - 1;
                          ghost3 = numberInRow * 11 - 2;
                          paused = false;
                          preGame = false;
                          mouthClosed = false;
                          direction = "right";
                          food.clear();
                          getFood();
                          score = 0;
                          
                        });
                        Navigator.pop(context);
                      },
                      // textColor: Colors.white,
                      // padding: const EdgeInsets.all(0.0),
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: <Color>[
                              Color(0xFF0D47A1),
                              Color(0xFF1976D2),
                              Color(0xFF42A5F5),
                            ],
                          ),
                        ),
                        padding: const EdgeInsets.all(10.0),
                        child: const Text(
                          'Restart',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    )
                  ],
                );
              });
        }
      });
      ghostTimer = Timer.periodic(const Duration(milliseconds: 190), (timer) {
        if (!paused) {
          moveGhost();
          moveGhost2();
          moveGhost3();
        }
      });
      mouthTimer = Timer.periodic(const Duration(milliseconds: 170), (timer) {
        setState(() {
          mouthClosed = !mouthClosed;
        });
        if (food.contains(player)) {
          audioMunch.play();
          safePrint('287');
          setState(() {
            food.remove(player);
          });
          score++;
        }

        // if (player == ghost || player == ghost2 || player == ghost3) {
        //   setState(() {
        //     player = -1;
        //   });
        //   showDialog(
        //       context: context,
        //       builder: (BuildContext context) {
        //         return AlertDialog(
        //           title: Center(child: Text("Game Over!")),
        //           content: Text("Your Score : " + (score).toString()),
        //           actions: [
        //             RaisedButton(
        //               onPressed: () {
        //                 setState(() {
        //                   player = numberInRow * 14 + 1;
        //                   ghost = numberInRow * 2 - 2;
        //                   ghost2 = numberInRow * 9 - 1;
        //                   ghost3 = numberInRow * 11 - 2;
        //                   preGame = false;
        //                   mouthClosed = false;
        //                   direction = "right";
        //                   food.clear();
        //                   getFood();
        //                   score = 0;
        //                   Navigator.pop(context);
        //                 });
        //               },
        //               textColor: Colors.white,
        //               padding: const EdgeInsets.all(0.0),
        //               child: Container(
        //                 decoration: const BoxDecoration(
        //                   gradient: LinearGradient(
        //                     colors: <Color>[
        //                       Color(0xFF0D47A1),
        //                       Color(0xFF1976D2),
        //                       Color(0xFF42A5F5),
        //                     ],
        //                   ),
        //                 ),
        //                 padding: const EdgeInsets.all(10.0),
        //                 child: const Text('Restart'),
        //               ),
        //             )
        //           ],
        //         );
        //       });
        // }
        switch (direction) {
          case "left":
            if (!paused) moveLeft();
            break;
          case "right":
            if (!paused) moveRight();
            break;
          case "up":
            if (!paused) moveUp();
            break;
          case "down":
            if (!paused) moveDown();
            break;
        }
      });
    }
  }

  void restart() {
    startGame();
  }

  void getFood() {
    for (int i = 0; i < numberOfSquares; i++) {
      if (!barriers.contains(i)) {
        food.add(i);
      }
    }
  }

  void moveLeft() {
    if (!barriers.contains(player - 1)) {
      setState(() {
        player--;
      });
    }
  }

  void moveRight() {
    if (!barriers.contains(player + 1)) {
      setState(() {
        player++;
      });
    }
  }

  void moveUp() {
    if (!barriers.contains(player - numberInRow)) {
      setState(() {
        player -= numberInRow;
      });
    }
  }

  void moveDown() {
    if (!barriers.contains(player + numberInRow)) {
      setState(() {
        player += numberInRow;
      });
    }
  }

  void moveGhost() {
    switch (ghostLast) {
      case "left":
        if (!barriers.contains(ghost - 1)) {
          setState(() {
            ghost--;
          });
        } else {
          if (!barriers.contains(ghost + numberInRow)) {
            setState(() {
              ghost += numberInRow;
              ghostLast = "down";
            });
          } else if (!barriers.contains(ghost + 1)) {
            setState(() {
              ghost++;
              ghostLast = "right";
            });
          } else if (!barriers.contains(ghost - numberInRow)) {
            setState(() {
              ghost -= numberInRow;
              ghostLast = "up";
            });
          }
        }
        break;
      case "right":
        if (!barriers.contains(ghost + 1)) {
          setState(() {
            ghost++;
          });
        } else {
          if (!barriers.contains(ghost - numberInRow)) {
            setState(() {
              ghost -= numberInRow;
              ghostLast = "up";
            });
          } else if (!barriers.contains(ghost + numberInRow)) {
            setState(() {
              ghost += numberInRow;
              ghostLast = "down";
            });
          } else if (!barriers.contains(ghost - 1)) {
            setState(() {
              ghost--;
              ghostLast = "left";
            });
          }
        }
        break;
      case "up":
        if (!barriers.contains(ghost - numberInRow)) {
          setState(() {
            ghost -= numberInRow;
            ghostLast = "up";
          });
        } else {
          if (!barriers.contains(ghost + 1)) {
            setState(() {
              ghost++;
              ghostLast = "right";
            });
          } else if (!barriers.contains(ghost - 1)) {
            setState(() {
              ghost--;
              ghostLast = "left";
            });
          } else if (!barriers.contains(ghost + numberInRow)) {
            setState(() {
              ghost += numberInRow;
              ghostLast = "down";
            });
          }
        }
        break;
      case "down":
        if (!barriers.contains(ghost + numberInRow)) {
          setState(() {
            ghost += numberInRow;
            ghostLast = "down";
          });
        } else {
          if (!barriers.contains(ghost - 1)) {
            setState(() {
              ghost--;
              ghostLast = "left";
            });
          } else if (!barriers.contains(ghost + 1)) {
            setState(() {
              ghost++;
              ghostLast = "right";
            });
          } else if (!barriers.contains(ghost - numberInRow)) {
            setState(() {
              ghost -= numberInRow;
              ghostLast = "up";
            });
          }
        }
        break;
    }
  }

  void moveGhost2() {
    switch (ghostLast2) {
      case "left":
        if (!barriers.contains(ghost2 - 1)) {
          setState(() {
            ghost2--;
          });
        } else {
          if (!barriers.contains(ghost2 + numberInRow)) {
            setState(() {
              ghost2 += numberInRow;
              ghostLast2 = "down";
            });
          } else if (!barriers.contains(ghost2 + 1)) {
            setState(() {
              ghost2++;
              ghostLast2 = "right";
            });
          } else if (!barriers.contains(ghost2 - numberInRow)) {
            setState(() {
              ghost2 -= numberInRow;
              ghostLast2 = "up";
            });
          }
        }
        break;
      case "right":
        if (!barriers.contains(ghost2 + 1)) {
          setState(() {
            ghost2++;
          });
        } else {
          if (!barriers.contains(ghost2 - numberInRow)) {
            setState(() {
              ghost2 -= numberInRow;
              ghostLast2 = "up";
            });
          } else if (!barriers.contains(ghost2 + numberInRow)) {
            setState(() {
              ghost2 += numberInRow;
              ghostLast2 = "down";
            });
          } else if (!barriers.contains(ghost2 - 1)) {
            setState(() {
              ghost2--;
              ghostLast2 = "left";
            });
          }
        }
        break;
      case "up":
        if (!barriers.contains(ghost2 - numberInRow)) {
          setState(() {
            ghost2 -= numberInRow;
            ghostLast2 = "up";
          });
        } else {
          if (!barriers.contains(ghost2 + 1)) {
            setState(() {
              ghost2++;
              ghostLast2 = "right";
            });
          } else if (!barriers.contains(ghost2 - 1)) {
            setState(() {
              ghost2--;
              ghostLast2 = "left";
            });
          } else if (!barriers.contains(ghost2 + numberInRow)) {
            setState(() {
              ghost2 += numberInRow;
              ghostLast2 = "down";
            });
          }
        }
        break;
      case "down":
        if (!barriers.contains(ghost2 + numberInRow)) {
          setState(() {
            ghost2 += numberInRow;
            ghostLast2 = "down";
          });
        } else {
          if (!barriers.contains(ghost2 - 1)) {
            setState(() {
              ghost2--;
              ghostLast2 = "left";
            });
          } else if (!barriers.contains(ghost2 + 1)) {
            setState(() {
              ghost2++;
              ghostLast2 = "right";
            });
          } else if (!barriers.contains(ghost2 - numberInRow)) {
            setState(() {
              ghost2 -= numberInRow;
              ghostLast2 = "up";
            });
          }
        }
        break;
    }
  }

  void moveGhost3() {
    switch (ghostLast) {
      case "left":
        if (!barriers.contains(ghost3 - 1)) {
          setState(() {
            ghost3--;
          });
        } else {
          if (!barriers.contains(ghost3 + numberInRow)) {
            setState(() {
              ghost3 += numberInRow;
              ghostLast3 = "down";
            });
          } else if (!barriers.contains(ghost3 + 1)) {
            setState(() {
              ghost3++;
              ghostLast3 = "right";
            });
          } else if (!barriers.contains(ghost3 - numberInRow)) {
            setState(() {
              ghost3 -= numberInRow;
              ghostLast3 = "up";
            });
          }
        }
        break;
      case "right":
        if (!barriers.contains(ghost3 + 1)) {
          setState(() {
            ghost3++;
          });
        } else {
          if (!barriers.contains(ghost3 - numberInRow)) {
            setState(() {
              ghost3 -= numberInRow;
              ghostLast3 = "up";
            });
          } else if (!barriers.contains(ghost3 - 1)) {
            setState(() {
              ghost3--;
              ghostLast3 = "left";
            });
          } else if (!barriers.contains(ghost3 + numberInRow)) {
            setState(() {
              ghost3 += numberInRow;
              ghostLast3 = "down";
            });
          }
        }
        break;
      case "up":
        if (!barriers.contains(ghost3 - numberInRow)) {
          setState(() {
            ghost3 -= numberInRow;
            ghostLast3 = "up";
          });
        } else {
          if (!barriers.contains(ghost3 + 1)) {
            setState(() {
              ghost3++;
              ghostLast3 = "right";
            });
          } else if (!barriers.contains(ghost3 - 1)) {
            setState(() {
              ghost3--;
              ghostLast3 = "left";
            });
          } else if (!barriers.contains(ghost3 + numberInRow)) {
            setState(() {
              ghost3 += numberInRow;
              ghostLast3 = "down";
            });
          }
        }
        break;
      case "down":
        if (!barriers.contains(ghost3 + numberInRow)) {
          setState(() {
            ghost3 += numberInRow;
            ghostLast3 = "down";
          });
        } else {
          if (!barriers.contains(ghost3 - 1)) {
            setState(() {
              ghost3--;
              ghostLast3 = "left";
            });
          } else if (!barriers.contains(ghost3 + 1)) {
            setState(() {
              ghost3++;
              ghostLast3 = "right";
            });
          } else if (!barriers.contains(ghost3 - numberInRow)) {
            setState(() {
              ghost3 -= numberInRow;
              ghostLast3 = "up";
            });
          }
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex:
                  (MediaQuery.of(context).size.height.toInt() * 0.0139).toInt(),
              child: GestureDetector(
                onVerticalDragUpdate: (details) {
                  if (details.delta.dy > 0) {
                    direction = "down";
                  } else if (details.delta.dy < 0) {
                    direction = "up";
                  }
                  // print(direction);
                },
                onHorizontalDragUpdate: (details) {
                  if (details.delta.dx > 0) {
                    direction = "right";
                  } else if (details.delta.dx < 0) {
                    direction = "left";
                  }
                  // print(direction);
                },
                child: Container(
                  child: GridView.builder(
                    padding:
                        (MediaQuery.of(context).size.height.toInt() * 0.0139)
                                    .toInt() >
                                10
                            ? const EdgeInsets.only(top: 80)
                            : const EdgeInsets.only(top: 20),
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: numberOfSquares,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: numberInRow),
                    itemBuilder: (BuildContext context, int index) {
                      if (mouthClosed && player == index) {
                        return Padding(
                          padding: const EdgeInsets.all(4),
                          child: Container(
                            decoration: const BoxDecoration(
                                color: Colors.yellow, shape: BoxShape.circle),
                          ),
                        );
                      } else if (player == index) {
                        switch (direction) {
                          case "left":
                            return Transform.rotate(
                              angle: pi,
                              child: const MyPlayer(),
                            );
                          case "right":
                            return const MyPlayer();
                            break;
                          case "up":
                            return Transform.rotate(
                              angle: 3 * pi / 2,
                              child: const MyPlayer(),
                            );
                            break;
                          case "down":
                            return Transform.rotate(
                              angle: pi / 2,
                              child: const MyPlayer(),
                            );
                            break;
                          default:
                            return const MyPlayer();
                        }
                      } else if (ghost == index) {
                        return const MyGhost();
                      } else if (ghost2 == index) {
                        return const MyGhost2();
                      } else if (ghost3 == index) {
                        return const MyGhost3();
                      } else if (barriers.contains(index)) {
                        return MyPixel(
                          innerColor: Colors.blue[900],
                          outerColor: Colors.blue[800],
                          // child: Text(index.toString()),
                        );
                      } else if (preGame || food.contains(index)) {
                        return const MyPath(
                          innerColor: Colors.yellow,
                          outerColor: Colors.black,
                          // child: Text(index.toString()),
                        );
                      } else {
                        return const MyPath(
                          innerColor: Colors.black,
                          outerColor: Colors.black,
                        );
                      }
                    },
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      " Score : $score",
                      // // (MediaQuery.of(context).size.height.toInt() * 0.0139)
                      //     .toInt()
                      //     .toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 23),
                    ),
                    GestureDetector(
                      onTap: startGame,
                      child: const Text("P L A Y",
                          style: TextStyle(color: Colors.white, fontSize: 23)),
                    ),
                    if (!paused)
                      GestureDetector(
                        child: const Icon(
                          Icons.pause,
                          color: Colors.white,
                        ),
                        onTap: () => {
                          if (!paused)
                            {
                              paused = true,
                              audioInGame.pause(),
                              audioPaused.play(),
                              safePrint('844'),
                            }
                          else
                            {
                              paused = false,
                              audioPaused.pause(),
                            },
                          const Icon(
                            Icons.play_arrow,
                            color: Colors.white,
                          )
                        },
                      ),
                    if (paused)
                      GestureDetector(
                        child: const Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                        ),
                        onTap: () => {
                          if (paused)
                            {paused = false, audioPaused.pause()}
                          else
                            {
                              paused = true,
                              audioInGame.pause(),
                              audioPaused.play(),
                              safePrint('870'),
                            },
                        },
                      ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
