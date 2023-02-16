import 'dart:math' as math;

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

class Video extends StatefulWidget {
  Video({Key? key, required this.url}) : super(key: key);
  String? url;

  @override
  _VideoState createState() => _VideoState();
}

class _VideoState extends State<Video> {
  ChewieController? _chewieController;
  VideoPlayerController? _controller;
  bool? isPortrait;
  static const List<Duration> _exampleCaptionOffsets = <Duration>[
    Duration(seconds: -10),
    Duration(seconds: -3), Duration(seconds: -1, milliseconds: -500), Duration(milliseconds: -250), Duration.zero,
    Duration(milliseconds: 250), Duration(seconds: 1, milliseconds: 500), Duration(seconds: 3), Duration(seconds: 10),
  ];
  static const List<double> _examplePlaybackRates = <double>[0.25, 0.5, 1.0, 1.5, 2.0,];

  pushFullScreenVideo() {
//This will help to hide the status bar and bottom bar of Mobile
//also helps you to set preferred device orientations like landscape

    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    SystemChrome.setEnabledSystemUIOverlays([]);
    SystemChrome.setPreferredOrientations(
      [
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ],
    );

//This will help you to push fullscreen view of video player on top of current page

    Navigator.of(context)
        .push(
      PageRouteBuilder(
        settings: RouteSettings(),
        pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            ) {
          return Scaffold(
              backgroundColor: Colors.transparent,
              resizeToAvoidBottomInset: false,
              body: Container(
                height: MediaQuery.of(context).size.height,
                color: Colors.black,
                child: OrientationBuilder(
                  builder: (context, orientation) {
                    isPortrait = orientation == Orientation.portrait;
                    return Center(
                      child: Stack(
                        //This will help to expand video in Horizontal mode till last pixel of screen
                        fit: isPortrait! ? StackFit.loose : StackFit.expand,
                        children: [
                          AspectRatio(
                            aspectRatio: _controller!.value.aspectRatio,
                            child: VideoPlayer(_controller!),
                          ),
                          Stack(
                            children: <Widget>[
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 50),
                                reverseDuration: const Duration(milliseconds: 200),
                                child: _controller!.value.isPlaying
                                    ? const SizedBox.shrink()
                                    : Container(
                                  color: Colors.black26,
                                  child: const Center(
                                    child: Icon(
                                      Icons.play_arrow,
                                      color: Colors.white,
                                      size: 100.0,
                                      semanticLabel: 'Play',
                                    ),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _controller!.value.isPlaying ? _controller!.pause() : _controller!.play();
                                  });
                                },
                              ),
                              Align(
                                alignment: Alignment.topLeft,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                  child: GestureDetector(
                                      onTap: () {
                                        // Navigator.push(
                                        //     context,
                                        //     MaterialPageRoute(
                                        //         builder: (context) =>
                                        //             FullScreenVideoPlayer(controller: widget.controller)));
                                        Navigator.pop(context);
                                      },
                                      child: const Icon(Icons.fullscreen)),
                                ),
                              ),
                              Align(
                                alignment: Alignment.topRight,
                                child: PopupMenuButton<double>(
                                  initialValue: _controller!.value.playbackSpeed,
                                  tooltip: 'Playback speed',
                                  onSelected: (double speed) {
                                    _controller!.setPlaybackSpeed(speed);
                                  },
                                  itemBuilder: (BuildContext context) {
                                    return <PopupMenuItem<double>>[
                                      for (final double speed in _ControlsOverlay._examplePlaybackRates)
                                        PopupMenuItem<double>(
                                          value: speed,
                                          child: Text('${speed}x'),
                                        )
                                    ];
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      // Using less vertical padding as the text is also longer
                                      // horizontally, so it feels like it would need more spacing
                                      // horizontally (matching the aspect ratio of the video).
                                      vertical: 12,
                                      horizontal: 16,
                                    ),
                                    child: Container(
                                      width: 52,
                                      child: Row(
                                        children: [
                                          Icon(Icons.speed),
                                          Text('${_controller!.value.playbackSpeed}x')
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                  bottom: 10,
                                  left: 10,
                                  right: 10,
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          const Spacer(),
                                          Padding(
                                            padding:
                                            const EdgeInsets.only(top: 5, bottom: 20),
                                            child: GestureDetector(
                                                onTap: () async {
                                                  setState(() {
                                                    _controller!.seekTo(
                                                        _controller!.value.position -
                                                            const Duration(seconds: 10));
                                                  });
                                                },
                                                child: Transform(
                                                  alignment: Alignment.center,
                                                  transform: Matrix4.rotationY(math.pi),
                                                  child: Icon(Icons.update,
                                                      color: Colors.grey[300], size: 25),
                                                )),
                                          ),
                                          const Spacer(),
                                          Padding(
                                            padding:
                                            const EdgeInsets.only(top: 5, bottom: 20),
                                            child: GestureDetector(
                                              onTap: () async {
                                                setState(() {
                                                  _controller!.value.isPlaying
                                                      ? _controller!.pause()
                                                      : _controller!.play();
                                                });
                                              },
                                              child: Icon(
                                                _controller!.value.isPlaying
                                                    ? Icons.pause
                                                    : Icons.play_arrow,
                                                color: Colors.white,
                                                size: MediaQuery.of(context).size.width / 12,
                                              ),
                                            ),
                                          ),
                                          const Spacer(),
                                          Padding(
                                            padding:
                                            const EdgeInsets.only(top: 5, bottom: 20),
                                            child: GestureDetector(
                                              onTap: () async {
                                                setState(() {
                                                  _controller!.seekTo(_controller!.value.position +
                                                      const Duration(seconds: 10));
                                                });
                                              },
                                              child: Icon(Icons.update,
                                                  color: Colors.grey[300], size: 25),
                                            ),
                                          ),
                                          const Spacer(),
                                        ],
                                      ),
                                      Slider(
                                        value: _controller!.value.position.inSeconds.toDouble(),
                                        min: 0,
                                        max: _controller!.value.duration.inSeconds.toDouble(),
                                        onChanged: (value) {
                                          // setState(() {
                                          _controller!.seekTo(Duration(seconds: value.toInt()));
                                          // });// share this function too
                                        },
                                        activeColor: Colors.blue,
                                        inactiveColor: Colors.grey,
                                        thumbColor: Colors.blue,
                                      ),
                                    ],
                                  )),
                            ],
                          )
                        ],
                      ),
                    );
                  },
                ),
              )
          );
        },
      ),
    )
        .then(
          (value) {
//This will help you to set previous Device orientations of screen so App will continue for portrait mode

        SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
        SystemChrome.setPreferredOrientations(
          [
            DeviceOrientation.portraitUp,
            DeviceOrientation.portraitDown,
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(
      widget.url!,
      // closedCaptionFile: _loadCaptions(),
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    );

    _controller!.addListener(() {
      setState(() {});
    });
    _controller!.setLooping(true);
    _controller!.initialize();
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height / 2,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          AspectRatio(
            aspectRatio: _controller!.value.aspectRatio,
            child: VideoPlayer(_controller!),
          ),
          Stack(
            children: <Widget>[
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 50),
                reverseDuration: const Duration(milliseconds: 200),
                child: _controller!.value.isPlaying
                    ? const SizedBox.shrink()
                    : Container(
                  color: Colors.black26,
                  child: const Center(
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 100.0,
                      semanticLabel: 'Play',
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _controller!.value.isPlaying ? _controller!.pause() : _controller!.play();
                  });
                },
              ),
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  child: GestureDetector(
                      onTap: () {
                        // Navigator.push(
                        //     context,
                        //     MaterialPageRoute(
                        //         builder: (context) =>
                        //             FullScreenVideoPlayer(controller: widget.controller)));
                        pushFullScreenVideo();
                      },
                      child: const Icon(Icons.fullscreen)),
                ),
              ),
              Align(
                alignment: Alignment.topRight,
                child: PopupMenuButton<double>(
                  initialValue: _controller!.value.playbackSpeed,
                  tooltip: 'Playback speed',
                  onSelected: (double speed) {
                    _controller!.setPlaybackSpeed(speed);
                  },
                  itemBuilder: (BuildContext context) {
                    return <PopupMenuItem<double>>[
                      for (final double speed in _ControlsOverlay._examplePlaybackRates)
                        PopupMenuItem<double>(
                          value: speed,
                          child: Text('${speed}x'),
                        )
                    ];
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      // Using less vertical padding as the text is also longer
                      // horizontally, so it feels like it would need more spacing
                      // horizontally (matching the aspect ratio of the video).
                      vertical: 12,
                      horizontal: 16,
                    ),
                    child: Container(
                      width: 52,
                      child: Row(
                        children: [
                          Icon(Icons.speed),
                          Text('${_controller!.value.playbackSpeed}x')
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                  bottom: 10, left: 10, right: 10,
                  child: Column(
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 50),
                        reverseDuration: const Duration(milliseconds: 200),
                        child: _controller!.value.isPlaying
                            ? const SizedBox.shrink()
                            : Row(
                          children: [
                            const Spacer(),
                            Padding(
                              padding:
                              const EdgeInsets.only(top: 5, bottom: 20),
                              child: GestureDetector(
                                  onTap: () async {
                                    setState(() {
                                      _controller!.seekTo(
                                          _controller!.value.position -
                                              const Duration(seconds: 10));
                                    });
                                  },
                                  child: Transform(
                                    alignment: Alignment.center,
                                    transform: Matrix4.rotationY(math.pi),
                                    child: Icon(Icons.update,
                                        color: Colors.grey[300], size: 25),
                                  )),
                            ),
                            const Spacer(),
                            Padding(
                              padding:
                              const EdgeInsets.only(top: 5, bottom: 20),
                              child: GestureDetector(
                                onTap: () async {
                                 setState(() {
                                   _controller!.value.isPlaying
                                       ? _controller!.pause()
                                       : _controller!.play();
                                 });
                                },
                                child: Icon(
                                  _controller!.value.isPlaying
                                      ? Icons.pause
                                      : Icons.play_arrow,
                                  color: Colors.white,
                                  size: MediaQuery.of(context).size.width / 12,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Padding(
                              padding:
                              const EdgeInsets.only(top: 5, bottom: 20),
                              child: GestureDetector(
                                onTap: () async {
                                  setState(() {
                                    _controller!.seekTo(_controller!.value.position +
                                        const Duration(seconds: 10));
                                  });
                                },
                                child: Icon(Icons.update,
                                    color: Colors.grey[300], size: 25),
                              ),
                            ),
                            const Spacer(),
                          ],
                        ),
                      ),
                      Slider.adaptive(
                        value: _controller!.value.position.inSeconds.toDouble(),
                        min: 0,
                        max: _controller!.value.duration.inSeconds.toDouble(),
                        onChanged: (value) {
                          setState(() {
                          _controller!.seekTo(Duration(seconds: value.toInt()));
                          });// share this function too
                        },
                        activeColor: Colors.lightBlue,
                        inactiveColor: Colors.grey,
                        thumbColor: Colors.lightBlue,
                      ),
                    ],
                  )),
            ],
          )
          // Container(
          //   margin: EdgeInsets.only(top: 10.0),
          //   color: Colors.white,
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          //     children: [
          //       IconButton(
          //         icon: Icon(Icons.skip_previous),
          //         onPressed: () {
          //           _videoPlayerController!.seekTo(
          //               _videoPlayerController!.value.position - Duration(seconds: 10));
          //         },
          //       ),
          //       IconButton(
          //         icon: Icon(
          //             _videoPlayerController!.value.isPlaying
          //                 ? Icons.pause
          //                 : Icons.play_arrow),
          //         onPressed: () {
          //           setState(() {
          //             _videoPlayerController!.value.isPlaying
          //                 ? _videoPlayerController!.pause()
          //                 : _videoPlayerController!.play();
          //           });
          //         },
          //       ),
          //       IconButton(
          //         icon: Icon(Icons.skip_next),
          //         onPressed: () {
          //           _videoPlayerController!.seekTo(
          //               _videoPlayerController!.value.position + Duration(seconds: 10));
          //         },
          //       ),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }
}

class _ControlsOverlay extends StatefulWidget {
  const _ControlsOverlay({Key? key, required this.controller})
      : super(key: key);

  static const List<Duration> _exampleCaptionOffsets = <Duration>[
    Duration(seconds: -10),
    Duration(seconds: -3),
    Duration(seconds: -1, milliseconds: -500),
    Duration(milliseconds: -250),
    Duration.zero,
    Duration(milliseconds: 250),
    Duration(seconds: 1, milliseconds: 500),
    Duration(seconds: 3),
    Duration(seconds: 10),
  ];
  static const List<double> _examplePlaybackRates = <double>[
    0.25,
    0.5,
    1.0,
    1.5,
    2.0,
  ];

  final VideoPlayerController controller;

  @override
  State<_ControlsOverlay> createState() => _ControlsOverlayState();
}

class _ControlsOverlayState extends State<_ControlsOverlay> {

  bool isPortrait = false;

  pushFullScreenVideo() {
//This will help to hide the status bar and bottom bar of Mobile
//also helps you to set preferred device orientations like landscape

    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    SystemChrome.setEnabledSystemUIOverlays([]);
    SystemChrome.setPreferredOrientations(
      [
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ],
    );

//This will help you to push fullscreen view of video player on top of current page

    Navigator.of(context)
        .push(
      PageRouteBuilder(
        opaque: false,
        settings: RouteSettings(),
        pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            ) {
          return Scaffold(
              backgroundColor: Colors.transparent,
              resizeToAvoidBottomInset: false,
              body: Dismissible(
                  key: const Key('key'),
                  direction: DismissDirection.vertical,
                  onDismissed: (_) => Navigator.of(context).pop(),
                  child: OrientationBuilder(
                    builder: (context, orientation) {
                      isPortrait = orientation == Orientation.portrait;
                      return Center(
                        child: Stack(
                          //This will help to expand video in Horizontal mode till last pixel of screen
                          fit: isPortrait ? StackFit.loose : StackFit.expand,
                          children: [
                            AspectRatio(
                              aspectRatio: widget.controller.value.aspectRatio,
                              child: VideoPlayer(widget.controller),
                            ),
                          ],
                        ),
                      );
                    },
                  )));
        },
      ),
    )
        .then(
          (value) {
//This will help you to set previous Device orientations of screen so App will continue for portrait mode

        SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
        SystemChrome.setPreferredOrientations(
          [
            DeviceOrientation.portraitUp,
            DeviceOrientation.portraitDown,
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 50),
          reverseDuration: const Duration(milliseconds: 200),
          child: widget.controller.value.isPlaying
              ? const SizedBox.shrink()
              : Container(
                  color: Colors.black26,
                  child: const Center(
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 100.0,
                      semanticLabel: 'Play',
                    ),
                  ),
                ),
        ),
        GestureDetector(
          onTap: () {
            widget.controller.value.isPlaying ? widget.controller.pause() : widget.controller.play();
          },
        ),
        Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: GestureDetector(
                onTap: () {
                  // Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //         builder: (context) =>
                  //             FullScreenVideoPlayer(controller: widget.controller)));
                  pushFullScreenVideo();
                },
                child: const Icon(Icons.fullscreen)),
          ),
        ),
        Align(
          alignment: Alignment.topRight,
          child: PopupMenuButton<double>(
            initialValue: widget.controller.value.playbackSpeed,
            tooltip: 'Playback speed',
            onSelected: (double speed) {
              widget.controller.setPlaybackSpeed(speed);
            },
            itemBuilder: (BuildContext context) {
              return <PopupMenuItem<double>>[
                for (final double speed in _ControlsOverlay._examplePlaybackRates)
                  PopupMenuItem<double>(
                    value: speed,
                    child: Text('${speed}x'),
                  )
              ];
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                // Using less vertical padding as the text is also longer
                // horizontally, so it feels like it would need more spacing
                // horizontally (matching the aspect ratio of the video).
                vertical: 12,
                horizontal: 16,
              ),
              child: Container(
                width: 52,
                child: Row(
                  children: [
                    Icon(Icons.speed),
                    Text('${widget.controller.value.playbackSpeed}x')
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
            bottom: 10,
            left: 10,
            right: 10,
            child: Column(
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 50),
                  reverseDuration: const Duration(milliseconds: 200),
                  child: widget.controller.value.isPlaying
                      ? const SizedBox.shrink()
                      : Row(
                          children: [
                            const Spacer(),
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 5, bottom: 20),
                              child: GestureDetector(
                                  onTap: () async {
                                    widget.controller.seekTo(
                                        widget.controller.value.position -
                                            const Duration(seconds: 10));
                                  },
                                  child: Transform(
                                    alignment: Alignment.center,
                                    transform: Matrix4.rotationY(math.pi),
                                    child: Icon(Icons.update,
                                        color: Colors.grey[300], size: 25),
                                  )),
                            ),
                            const Spacer(),
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 5, bottom: 20),
                              child: GestureDetector(
                                onTap: () async {
                                  widget.controller.value.isPlaying
                                      ? widget.controller.pause()
                                      : widget.controller.play();
                                },
                                child: Icon(
                                  widget.controller.value.isPlaying
                                      ? Icons.pause
                                      : Icons.play_arrow,
                                  color: Colors.white,
                                  size: MediaQuery.of(context).size.width / 12,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 5, bottom: 20),
                              child: GestureDetector(
                                onTap: () async {
                                  widget.controller.seekTo(widget.controller.value.position +
                                      const Duration(seconds: 10));
                                },
                                child: Icon(Icons.update,
                                    color: Colors.grey[300], size: 25),
                              ),
                            ),
                            const Spacer(),
                          ],
                        ),
                ),
                Slider(
                  value: widget.controller.value.position.inSeconds.toDouble(),
                  min: 0,
                  max: widget.controller.value.duration.inSeconds.toDouble(),
                  onChanged: (value) {
                    // setState(() {
                    widget.controller.seekTo(Duration(seconds: value.toInt()));
                    // });// share this function too
                  },
                  activeColor: Colors.blue,
                  inactiveColor: Colors.grey,
                  thumbColor: Colors.blue,
                ),
              ],
            )),
      ],
    );
  }
}