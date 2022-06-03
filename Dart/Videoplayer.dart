
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymfans/src/utils/constants/app_constants.dart';
import 'package:gymfans/src/utils/constants/app_constants.dart';



class VideoPlatformLayout extends StatefulWidget {

  final String url;
 // final num height;

  VideoPlatformLayout({required this.url,/*required this.height*/});

  @override
  _VideoPlatformLayoutState createState() => _VideoPlatformLayoutState();
}

class _VideoPlatformLayoutState extends State<VideoPlatformLayout> with WidgetsBindingObserver{


//  MethodChannel? _channel;
  bool isNormalScreen = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    WidgetsBinding.instance!.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        viewPlayerController.resumeVideo();
        break;
      case AppLifecycleState.paused:
        viewPlayerController.pauseVideo();
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {

    var x = 0.0;
    var y = 0.0;
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    var videoPlayer = VideoPlayer(
        onCreated: onViewPlayerCreated,
        x: x,
        y: y,
        width: width,
        height: height,
        url: widget.url,
    );

    return Platform.isAndroid
        ?Container(
      color: Colors.black,
      transform: Matrix4.translationValues(0.0, 0.0, 0),
      child: videoPlayer,
      width: width,
      height: height.toDouble(),
    ):Container(
      color: Colors.black,
      transform: Matrix4.translationValues(0.0, 0.0, 0),
      width: width,
      height: height.toDouble(),
      child: videoPlayer,
    );
      // This trailing comma makes auto-formatting nicer for build methods.
  }


  void onViewPlayerCreated(playerController) {
    viewPlayerController = playerController;
    if(viewPlayerController==null){
      viewPlayerController.loadUrl(widget.url);
    }
  }
}

class _VideoPlayerState extends State<VideoPlayer> {

  String viewType = 'NativeUI';

  @override
  void initState() {
    super.initState();

  }



  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: nativeView(),
    );
  }

  nativeView() {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidView(
        viewType: viewType,
        onPlatformViewCreated: onPlatformViewCreated,
        creationParams: <String,dynamic>{
          "x": widget.x,
          "y": widget.y,
          "width": widget.width,
          "height": widget.height,
          "videoURL":widget.url
        },

        creationParamsCodec: const StandardMessageCodec(),
      );
    } else {
      return UiKitView(
        viewType: viewType,
        onPlatformViewCreated: onPlatformViewCreated,
        creationParams: <String,dynamic>{
          "x": widget.x,
          "y": widget.y,
          "width": widget.width,
          "height": widget.height,
          "videoURL":widget.url
        },
        creationParamsCodec: const StandardMessageCodec(),
      );
    }
  }

  Future<void> onPlatformViewCreated(id) async {
    if (widget.onCreated == null) {
      return;
    }

    widget.onCreated(VideoPlayerController.init(id));
  }
}




typedef void BmsVideoPlayerCreatedCallback(VideoPlayerController controller);

class VideoPlayerController {

  MethodChannel? _channel;

  VideoPlayerController.init(int id) {
    _channel =  MethodChannel('gym_fans_video_player');
    // _channel =  new MethodChannel('bms_video_player$id');
    // _channel.invokeMethod('loadUrl', "url");
  }

  Future<void> loadUrl(String url) async {
  //  return _channel!.invokeMethod('loadUrl', url);
  }

  Future<void> pauseVideo() async {
    return _channel!.invokeMethod('pauseVideo', 'pauseVideo');
  }

  Future<void> resumeVideo() async {
    return _channel!.invokeMethod('resumeVideo', 'resumeVideo');
  }
}


class VideoPlayer extends StatefulWidget {

  final BmsVideoPlayerCreatedCallback onCreated;
  final x;
  final y;
  final width;
  final height;
  final url;

  VideoPlayer({
    required this.onCreated,
    @required this.x,
    @required this.y,
    @required this.width,
    @required this.height,
    @required this.url,
  });

  @override
  State<StatefulWidget> createState() => _VideoPlayerState();

}
