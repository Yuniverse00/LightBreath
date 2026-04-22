import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:record/record.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'dart:convert';

class FamilyMessage {
  final String id;
  String senderName;
  final String? textContent;
  final String? imagePath;
  final String? videoPath;
  final String? audioPath;
  final DateTime timestamp;

  FamilyMessage({
    required this.id,
    required this.senderName,
    this.textContent,
    this.imagePath,
    this.videoPath,
    this.audioPath,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderName': senderName,
      'textContent': textContent,
      'imagePath': imagePath,
      'videoPath': videoPath,
      'audioPath': audioPath,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  factory FamilyMessage.fromJson(Map<String, dynamic> json) {
    return FamilyMessage(
      id: json['id'],
      senderName: json['senderName'],
      textContent: json['textContent'],
      imagePath: json['imagePath'],
      videoPath: json['videoPath'],
      audioPath: json['audioPath'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp']),
    );
  }
}

class AudioPlayerItem extends StatefulWidget {
  final String audioPath;
  final String senderName;

  const AudioPlayerItem({
    Key? key,
    required this.audioPath,
    required this.senderName,
  }) : super(key: key);

  @override
  State<AudioPlayerItem> createState() => _AudioPlayerItemState();
}

class _AudioPlayerItemState extends State<AudioPlayerItem> {
  late AudioPlayer _audioPlayer;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _initListeners();
  }

  void _initListeners() {
    _audioPlayer.onDurationChanged.listen((duration) {
      if (mounted) {
        setState(() => _duration = duration);
      }
    });

    _audioPlayer.onPositionChanged.listen((position) {
      if (mounted) {
        setState(() => _position = position);
      }
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _position = Duration.zero;
        });
      }
    });

    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() => _isPlaying = state == PlayerState.playing);
      }
    });
  }

  Future<void> _togglePlay() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play(DeviceFileSource(widget.audioPath));
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              _isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.green,
            ),
            onPressed: _togglePlay,
          ),
          Expanded(
            child: LinearProgressIndicator(
              value: _duration.inSeconds == 0
                  ? 0
                  : _position.inSeconds / _duration.inSeconds,
              backgroundColor: Colors.grey[200]!,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${_formatDuration(_position)} / ${_formatDuration(_duration)}',
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class VideoPreviewPage extends StatefulWidget {
  final String videoPath;
  final String senderName;

  const VideoPreviewPage({
    Key? key,
    required this.videoPath,
    required this.senderName,
  }) : super(key: key);

  @override
  State<VideoPreviewPage> createState() => _VideoPreviewPageState();
}

class _VideoPreviewPageState extends State<VideoPreviewPage> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.videoPath))
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() {
          _isInitialized = true;
        });
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.pause();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isPlaying = _isInitialized && _controller.value.isPlaying;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          '${widget.senderName}的视频',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Center(
        child: _isInitialized
            ? InteractiveViewer(
          minScale: 1.0,
          maxScale: 3.0,
          child: AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          ),
        )
            : const CircularProgressIndicator(
          color: Colors.green,
        ),
      ),
      floatingActionButton: _isInitialized
          ? FloatingActionButton(
        backgroundColor: Colors.green[600],
        onPressed: () {
          setState(() {
            if (_controller.value.isPlaying) {
              _controller.pause();
            } else {
              _controller.play();
            }
          });
        },
        child: Icon(
          isPlaying ? Icons.pause : Icons.play_arrow,
          color: Colors.white,
        ),
      )
          : null,
    );
  }
}

class FamilySupportPage extends StatefulWidget {
  const FamilySupportPage({super.key});

  @override
  State<FamilySupportPage> createState() => _FamilySupportPageState();
}

class _FamilySupportPageState extends State<FamilySupportPage> {
  final TextEditingController _messageController = TextEditingController();
  late List<FamilyMessage> _familyMessages;
  final ImagePicker _picker = ImagePicker();

  final AudioRecorder _audioRecorder = AudioRecorder();
  String? _recordedFilePath;
  final ScrollController _scrollController = ScrollController();
  late SharedPreferences _prefs;
  static const String _kMessageKey = 'family_support_messages';
  final TextEditingController _senderNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    _prefs = await SharedPreferences.getInstance();
    final String? jsonStr = _prefs.getString(_kMessageKey);
    if (jsonStr != null) {
      final List<dynamic> jsonList = jsonDecode(jsonStr);
      _familyMessages = jsonList.map((e) => FamilyMessage.fromJson(e)).toList();
    } else {
      _familyMessages = [
        FamilyMessage(
          id: '1',
          senderName: '妻子',
          textContent: '老公，看到你努力戒烟的样子真为你骄傲！坚持住，我们一起加油！',
          timestamp: DateTime.now().subtract(const Duration(days: 2)),
        ),
        FamilyMessage(
          id: '2',
          senderName: '女儿',
          textContent: '爸爸不要抽烟啦，我想让你陪我久一点～',
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ];
    }
    setState(() {});
  }

  Future<void> _saveMessages() async {
    final List<Map<String, dynamic>> jsonList =
    _familyMessages.map((msg) => msg.toJson()).toList();
    final String jsonStr = jsonEncode(jsonList);
    await _prefs.setString(_kMessageKey, jsonStr);
  }

  Future<String?> _copyFileToAppDir(File sourceFile) async {
    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${path.basename(sourceFile.path)}';
      final File destFile = File(path.join(appDir.path, fileName));
      await sourceFile.copy(destFile.path);
      return destFile.path;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('文件保存失败：$e')),
      );
      return null;
    }
  }

  void _sendTextMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      _familyMessages.add(FamilyMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        senderName: _getCurrentSender(),
        textContent: _messageController.text.trim(),
        timestamp: DateTime.now(),
      ));
    });

    _messageController.clear();
    _saveMessages();
    _scrollToBottom();
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      final File sourceFile = File(pickedFile.path);
      final String? destPath = await _copyFileToAppDir(sourceFile);
      if (destPath != null) {
        setState(() {
          _familyMessages.add(FamilyMessage(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            senderName: _getCurrentSender(),
            imagePath: destPath,
            timestamp: DateTime.now(),
          ));
        });
        _saveMessages();
        _scrollToBottom();
      }
    }
  }

  Future<void> _pickVideo(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickVideo(source: source);
    if (pickedFile != null) {
      final File sourceFile = File(pickedFile.path);
      final String? destPath = await _copyFileToAppDir(sourceFile);
      if (destPath != null) {
        setState(() {
          _familyMessages.add(FamilyMessage(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            senderName: _getCurrentSender(),
            videoPath: destPath,
            timestamp: DateTime.now(),
          ));
        });
        _saveMessages();
        _scrollToBottom();
      }
    }
  }

  Future<void> _recordAudio() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final Directory appDir = await getApplicationDocumentsDirectory();
        final String audioPath =
        path.join(appDir.path, '${DateTime.now().millisecondsSinceEpoch}.m4a');

        await _audioRecorder.start(
          const RecordConfig(),
          path: audioPath,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('开始录音...点击停止完成录制')),
        );

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('正在录音'),
            content: const Text('点击“停止”完成录制'),
            actions: [
              TextButton(
                onPressed: () async {
                  await _audioRecorder.stop();
                  Navigator.pop(context);

                  setState(() {
                    _familyMessages.add(FamilyMessage(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      senderName: _getCurrentSender(),
                      audioPath: audioPath,
                      timestamp: DateTime.now(),
                    ));
                  });
                  _saveMessages();
                  _scrollToBottom();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('录音完成！')),
                  );
                },
                child: const Text('停止'),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('未获取到麦克风权限')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('录音失败：$e')),
      );
    }
  }

  Future<void> _editSenderName(int index) async {
    final FamilyMessage targetMsg = _familyMessages[index];
    _senderNameController.text = targetMsg.senderName;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('修改发送者名称'),
        content: TextField(
          controller: _senderNameController,
          decoration: const InputDecoration(
            hintText: '输入家人称呼（如：妈妈、儿子）',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              if (_senderNameController.text.trim().isEmpty) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('名称不能为空！')),
                );
                return;
              }

              setState(() {
                _familyMessages[index].senderName =
                    _senderNameController.text.trim();
              });
              _saveMessages();
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('已修改为：${_senderNameController.text.trim()}')),
              );
            },
            child: const Text('确认'),
          ),
        ],
      ),
    );

    _senderNameController.clear();
  }

  Future<void> _deleteMessage(int index) async {
    final bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('是否确定删除这条消息？删除后无法恢复！'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final FamilyMessage targetMsg = _familyMessages[index];

        if (targetMsg.imagePath != null &&
            File(targetMsg.imagePath!).existsSync()) {
          await File(targetMsg.imagePath!).delete();
        }
        if (targetMsg.videoPath != null &&
            File(targetMsg.videoPath!).existsSync()) {
          await File(targetMsg.videoPath!).delete();
        }
        if (targetMsg.audioPath != null &&
            File(targetMsg.audioPath!).existsSync()) {
          await File(targetMsg.audioPath!).delete();
        }

        setState(() {
          _familyMessages.removeAt(index);
        });
        await _saveMessages();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('消息已成功删除！')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('删除失败：$e')),
          );
        }
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  String _getCurrentSender() {
    return '家庭成员';
  }

  @override
  void dispose() {
    _messageController.dispose();
    _senderNameController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('家庭支持'),
        backgroundColor: Colors.green[600],
        centerTitle: true,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.green[50],
            child: Text(
              '家人的鼓励是戒烟路上的重要动力。在这里，可以收集家人发送的鼓励话语、视频或音频，一起见证你的进步！\n点击发送者名称可修改称呼 | 点击删除图标可删除消息',
              style: TextStyle(color: Colors.green[800]!, fontSize: 14),
            ),
          ),
          Expanded(
            child: _familyMessages.isEmpty
                ? const Center(child: Text('暂无家人鼓励，快来添加吧～'))
                : ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              itemCount: _familyMessages.length,
              itemBuilder: (context, index) {
                final message = _familyMessages[index];
                return _buildMessageItem(message, index);
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 5,
                  spreadRadius: 1,
                )
              ],
            ),
            child: Column(
              children: [
                TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: '输入鼓励的话...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.send, color: Colors.green),
                      onPressed: _sendTextMessage,
                    ),
                  ),
                  maxLines: null,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.photo_library, color: Colors.green),
                      onPressed: () => _pickImage(ImageSource.gallery),
                      tooltip: '选择图片',
                    ),
                    IconButton(
                      icon: const Icon(Icons.camera_alt, color: Colors.green),
                      onPressed: () => _pickImage(ImageSource.camera),
                      tooltip: '拍摄图片',
                    ),
                    IconButton(
                      icon: const Icon(Icons.video_library, color: Colors.green),
                      onPressed: () => _pickVideo(ImageSource.gallery),
                      tooltip: '选择视频',
                    ),
                    IconButton(
                      icon: const Icon(Icons.videocam, color: Colors.green),
                      onPressed: () => _pickVideo(ImageSource.camera),
                      tooltip: '拍摄视频',
                    ),
                    IconButton(
                      icon: const Icon(Icons.mic, color: Colors.green),
                      onPressed: _recordAudio,
                      tooltip: '录制语音',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageItem(FamilyMessage message, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => _editSenderName(index),
                child: Row(
                  children: [
                    Text(
                      message.senderName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.edit, size: 14, color: Colors.green),
                  ],
                ),
              ),
              Row(
                children: [
                  Text(
                    DateFormat('MM-dd HH:mm').format(message.timestamp),
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _deleteMessage(index),
                    child: const Icon(
                      Icons.delete_outline,
                      size: 18,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (message.textContent != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                message.textContent!,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ),
          if (message.imagePath != null && File(message.imagePath!).existsSync())
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                File(message.imagePath!),
                width: MediaQuery.of(context).size.width * 0.9,
                fit: BoxFit.contain,
              ),
            ),
          if (message.videoPath != null && File(message.videoPath!).existsSync())
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => VideoPreviewPage(
                      videoPath: message.videoPath!,
                      senderName: message.senderName,
                    ),
                  ),
                );
              },
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                padding:
                const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.play_circle_fill,
                      color: Colors.green,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '你有一条来自${message.senderName}的视频',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.green[800],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (message.audioPath != null && File(message.audioPath!).existsSync())
            AudioPlayerItem(
              audioPath: message.audioPath!,
              senderName: message.senderName,
            ),
        ],
      ),
    );
  }
}