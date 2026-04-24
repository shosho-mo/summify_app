import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoSummaryWidget extends StatefulWidget {
  final String videoUrl;
  const VideoSummaryWidget({super.key, required this.videoUrl});

  @override
  State<VideoSummaryWidget> createState() => _VideoSummaryWidgetState();
}

class _VideoSummaryWidgetState extends State<VideoSummaryWidget> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();

    // استخراج الـ ID الخاص بالفيديو من الرابط
    final videoId = YoutubePlayer.convertUrlToId(widget.videoUrl);

    _controller = YoutubePlayerController(
      initialVideoId: videoId ?? '',
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
        disableDragSeek: false,
        loop: false,
        isLive: false,
        forceHD: false,
      ),
    );
  }

  @override
  void deactivate() {
    // إيقاف المشغل عند الخروج من الصفحة
    _controller.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.videoUrl.isEmpty) {
      return const Center(
        child: Text('لا يوجد فيديو متاح لهذا الكتاب',
            style: TextStyle(color: Colors.white70)),
      );
    }

    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        progressIndicatorColor: const Color(0xFFFACC15),
        progressColors: const ProgressBarColors(
          playedColor: Color(0xFFFACC15),
          handleColor: Color(0xFFFACC15),
        ),
      ),
      builder: (context, player) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // المشغل نفسه
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: player,
              ),
              const SizedBox(height: 20),
              const Text(
                'مشاهدة ملخص الفيديو',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'هذا الفيديو يشرح الأفكار الرئيسية للكتاب بشكل مرئي سريع.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white60),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
