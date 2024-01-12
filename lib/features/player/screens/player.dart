import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:lottie/lottie.dart';
import 'package:meditation_app/features/home/model/recommendation_model.dart';

import '../../home/data/recommendations.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key, required this.model});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();

  final RecommendationModel model;
}

class _PlayerScreenState extends State<PlayerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progress;
  late AudioPlayer _audioPlayer;
  late RecommendationModel _currentModel;
  // Cờ để theo dõi liệu thời lượng của âm thanh đã được đặt chưa
  bool _isAudioDurationSet = false;

  Future<void> playPause() async {
    if (_controller.status == AnimationStatus.completed) {
      _controller.reverse();
      await _audioPlayer.pause();
    } else {
      _controller.forward();
      try {
        if (_audioPlayer.playing) {
          await _audioPlayer.pause();
        } else {
          await _audioPlayer.setAsset(widget.model.sound);
          await _audioPlayer.play();
          print("Đang chạy âm thanh ${widget.model.sound}");
        }
      } catch (e) {
        print("Lỗi tải âm thanh: $e");
      }
    }
  }

  Future<void> playNext() async {
    if (RecommendationsData.all.isEmpty) {
      return;
    }

    await _audioPlayer.stop();

    int currentIndex = RecommendationsData.all.indexOf(_currentModel);
    int nextIndex = (currentIndex + 1) % RecommendationsData.all.length;
    RecommendationModel nextModel = RecommendationsData.all[nextIndex];

    setState(() {
      _currentModel = nextModel;
    });

    await _audioPlayer.setAsset(nextModel.sound);

    // Đặt thời gian phát về đầu
    await _audioPlayer.seek(Duration.zero);

    // Đặt thanh tua nhạc về vị trí bắt đầu
    _player.value = 0;

    await _audioPlayer.play();
  }

  Future<void> playPrevious() async {
    if (RecommendationsData.all.isEmpty) {
      return;
    }

    await _audioPlayer.stop();

    int currentIndex = RecommendationsData.all.indexOf(_currentModel);
    int previousIndex =
        (currentIndex - 1 + RecommendationsData.all.length) %
            RecommendationsData.all.length;
    RecommendationModel previousModel = RecommendationsData.all[previousIndex];

    setState(() {
      _currentModel = previousModel;
    });

    await _audioPlayer.setAsset(previousModel.sound);

    // Đặt thời gian phát về đầu
    await _audioPlayer.seek(Duration.zero);
    // Đặt thanh tua nhạc về vị trí bắt đầu
    _player.value = 0;

    await _audioPlayer.play();
  }


  final ValueNotifier<double> _player = ValueNotifier<double>(0);
  bool _isDark = false;

  controllerListener() {
    if (_controller.status == AnimationStatus.forward ||
        _controller.status == AnimationStatus.completed) {
      increasePlayer();
    }
  }

  increasePlayer() async {
    if (_controller.status == AnimationStatus.forward ||
        _controller.status == AnimationStatus.completed) {
      if ((_player.value + .0005) > 1) {
        _player.value = 1;
        _controller.reverse();
      } else {
        _player.value += .00005;
      }

      await Future.delayed(
        const Duration(milliseconds: 100),
      );
      if (_player.value < 1) {
        increasePlayer();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }


  @override
  void initState() {
    super.initState();
    _currentModel = widget.model; // Initialize the current model
    // Khởi tạo trình phát âm thanh
    _audioPlayer = AudioPlayer();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _progress = Tween<double>(begin: 0, end: 1).animate(_controller)
      ..addListener(() {
        setState(() {});
      });

    _controller.addListener(() {
      controllerListener();
    });

    // Listen for processing state events
    _audioPlayer.processingStateStream.listen((ProcessingState state) {
      if (state == ProcessingState.loading || state == ProcessingState.buffering) {
        // Handle buffering state, for example, show a loading indicator
        print("Buffering...");
      } else if (state == ProcessingState.ready) {
        // Handle ready state, for example, hide the loading indicator
        print("Ready...");
      }
    });

    _audioPlayer.playerStateStream.listen((PlayerState playerState) {
      if (playerState.processingState == ProcessingState.completed) { // Sửa điều kiện ở đây
        // Nhạc đã phát hết, tự động chuyển sang bài tiếp theo
        playNext();
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return Material(
      color: _isDark ? Colors.black : Colors.white,
      child: Scaffold(
        backgroundColor: _currentModel.color.withOpacity(.1),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 70),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    highlightColor: _currentModel.color.withOpacity(.2),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(
                      Icons.keyboard_backspace_rounded,
                      color: _currentModel.color.shade300,
                    ),
                  ),
                  IconButton(
                    highlightColor: _currentModel.color.withOpacity(.2),
                    onPressed: () {
                      setState(() {
                        _isDark = !_isDark;
                      });
                    },
                    icon: Icon(
                      _isDark
                          ? CupertinoIcons.sun_max_fill
                          : CupertinoIcons.moon_stars_fill,
                      color: _currentModel.color.shade300,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              SizedBox.square(
                dimension: MediaQuery.sizeOf(context).width - 40,
                child: Stack(
                  children: [
                    Positioned.fill(
                      left: 30,
                      top: 30,
                      bottom: 30,
                      right: 30,
                      child: ValueListenableBuilder(
                          valueListenable: _player,
                          builder: (context, value, _) {
                            return CircularProgressIndicator(
                              color: _currentModel.color.shade300,
                              value: value,
                              strokeCap: StrokeCap.round,
                              strokeWidth: 10,
                              backgroundColor:
                              _currentModel.color.withOpacity(.4),
                            );
                          }),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(1000),
                        child: Container(
                          padding: const EdgeInsets.only(top: 120, left: 20),
                          height: 200,
                          width: 200,
                          color: _currentModel.color.shade300,
                          child: Transform.scale(
                            scale: 3,
                            child: Lottie.asset('assets/lottie/yoga.json'),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                _currentModel.title,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  color: _currentModel.color.shade300,
                ),
              ),
              Text(
                _currentModel.author,
                style: TextStyle(
                  fontSize: 16,
                  color: _currentModel.color.shade300,
                ),
              ),
              const SizedBox(height: 40),
              Row(
                children: [
                  const Spacer(),
                  IconButton(
                    highlightColor: _currentModel.color.withOpacity(.2),
                    onPressed: () { playPrevious(); },
                    icon: Icon(
                      Icons.skip_previous_rounded,
                      size: 50,
                      color: _currentModel.color.withOpacity(.3),
                    ),
                  ),
                  const SizedBox(width: 30),
                  IconButton(
                    highlightColor: _currentModel.color.withOpacity(.2),
                    onPressed: playPause,
                    icon: AnimatedIcon(
                      icon: AnimatedIcons.play_pause,
                      progress: _progress,
                      size: 50,
                      color: _currentModel.color.shade300,
                    ),
                  ),
                  const SizedBox(width: 30),
                  IconButton(
                    highlightColor: _currentModel.color.withOpacity(.2),
                    onPressed: () { playNext(); },
                    icon: Icon(
                      Icons.skip_next_rounded,
                      size: 50,
                      color: _currentModel.color.withOpacity(.3),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
              ValueListenableBuilder(
                valueListenable: _player,
                builder: (context, value, _) {
                  double bufferedPosition = (_audioPlayer?.bufferedPosition?.inMilliseconds ?? 0).toDouble();
                  double duration = (_audioPlayer?.duration?.inMilliseconds ?? 1).toDouble();
                  bool isPlaying = _audioPlayer?.playing ?? false;


                  return Slider(
                    thumbColor: _currentModel.color.shade300,
                    activeColor: _currentModel.color.shade300,
                    inactiveColor: _currentModel.color.withOpacity(.4),
                    secondaryActiveColor: _currentModel.color.withOpacity(.4),
                    secondaryTrackValue: (_audioPlayer?.bufferedPosition?.inMilliseconds ?? 0) /
                        (_audioPlayer?.duration?.inMilliseconds ?? 1),
                    value: (_audioPlayer?.position?.inMilliseconds ?? 0) /
                        (_audioPlayer?.duration?.inMilliseconds ?? 1),
                    onChanged: (value) {
                      _controller.reverse();
                      _player.value = value;

                      if (_audioPlayer != null && _audioPlayer!.duration != null) {
                        _audioPlayer!.seek(
                          Duration(milliseconds: (value * _audioPlayer!.duration!.inMilliseconds).toInt()),
                        );

                        // Ensure play/pause animation doesn't change while seeking
                        if (_audioPlayer!.playing) {
                          _controller.forward();
                        }
                      }
                    },
                  );



                },
              ),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  _currentModel.slogan,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _currentModel.color.shade300,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

}
