import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:just_audio/just_audio.dart';
import 'package:sense2quit/bloc/cubit/tips_cubit.dart';
import 'package:sense2quit/widgets/expandableTile.dart.dart';

// 只使用这一个配置类，确保名称完全不同
class VideoConfig {
  final String stage;
  final String videoUrl;
  final String title;

  VideoConfig({
    required this.stage,
    required this.videoUrl,
    required this.title,
  });
}

class TipsPage extends StatefulWidget {
  const TipsPage({Key? key}) : super(key: key);

  @override
  _TipsPageState createState() => _TipsPageState();
}

class _TipsPageState extends State<TipsPage> {
  // 使用全新的配置列表
  final List<VideoConfig> videoList = [
    VideoConfig(
      stage: "准备阶段",
      videoUrl: "https://flv1.gmw.cn/gma/20230526/20230526154717509_0065.mp4",
      title: "戒烟准备：认知与规划",
    ),
    VideoConfig(
      stage: "戒断阶段",
      videoUrl: "https://pqnoss.kepuchina.cn/declaration/2024/11/30/15/1732862921373.mp4",
      title: "戒断反应：应对与坚持",
    ),
    VideoConfig(
      stage: "维持阶段",
      videoUrl: "https://che.fzu.edu.cn/__local/A/02/06/2FF6273E1B2725149E6911ABE40_2A397976_2738D3.mp4?e=.mp4",
      title: "长期维持：防复吸与收益",
    ),
  ];

  late VideoPlayerController _videoController;
  ChewieController? _chewieController;

  late AudioPlayer _audioPlayer;
  String? _currentPlayingStage;
  bool _isAudioPlaying = false;

  final Map<String, String> _stageAudio = {
    "准备阶段": "lib/assets/preparation_v2.mp3",
    "戒断阶段": "lib/assets/withdrawal.mp3",
    "维持阶段": "lib/assets/maintenance.mp3",
  };

  // 使用全新的变量名，避免任何可能的冲突
  VideoConfig currentVideo = VideoConfig(
    stage: "准备阶段",
    videoUrl: "https://flv1.gmw.cn/gma/20230526/20230526154717509_0065.mp4",
    title: "戒烟准备：认知与规划",
  );

  // 各阶段详细知识点
  final Map<String, String> _stageContent = {
    "准备阶段": """一、吸烟的危害（中国人群重点）
1. 健康风险：中国吸烟者肺癌发病率是不吸烟者的10到20倍，二手烟每年导致10万中国人死亡
2. 尼古丁成瘾机制：尼古丁10秒进入大脑，刺激多巴胺分泌，形成心理依赖
3. 本土化触发因素：
   - 社交场景：酒局、牌局、饭后递烟的社交习惯
   - 情绪触发：压力大、无聊、熬夜加班时的吸烟冲动
   - 习惯触发：晨起第一支烟、开车或如厕时吸烟

二、戒烟准备要点
1. 设定明确戒烟日：选择无压力的日期，例如周末或假期，告知家人朋友寻求监督
2. 清理吸烟相关物品：香烟、打火机、烟灰缸，避免视觉触发
3. 记录吸烟日记：连续3天记录吸烟时间、场景、原因，找到核心触发点
4. 准备替代物：无糖口香糖、瓜子、减压球，应对手部动作依赖
5. 寻求专业支持：加入戒烟社群或医院戒烟门诊，中国多地已开通免费戒烟服务""",

    "戒断阶段": """一、戒断反应及应对（中国吸烟者常见症状）
1. 生理反应（1到2周最明显）：
   - 烦躁易怒、注意力不集中、失眠、食欲增加
   - 应对：保证睡眠、多喝水，每天1500到2000毫升，补充维生素B族

2. 心理渴求（最核心挑战）：
   - 5分钟法则：烟瘾来袭时，延迟5分钟再决定，可大幅降低复吸率
   - 呼吸法：4秒吸气，7秒屏息，8秒呼气，重复3次快速平复冲动
   - 替代行为：散步、洗手、拉伸、嚼无糖薄荷糖

3. 本土化缓解方法：
   - 中医穴位按压：按揉合谷穴（虎口）、内关穴（手腕内侧）各1分钟，缓解烟瘾
   - 茶饮调理：薄荷茶、金银花茶清热降火，缓解戒断期口干烦躁
   - 传统养生：八段锦、太极拳等轻运动，调节情绪和身体状态

二、戒断期注意事项
- 避免高风险场景：酒局、熬夜、压力大的工作时段
- 每天记录进步：用打卡和分享方式强化成就感
- 允许破例：单次复吸不代表失败，立即回归戒烟计划""",

    "维持阶段": """一、长期维持策略
1. 建立新习惯：
   - 饭后：散步10分钟，替代饭后吸烟
   - 压力大：深呼吸加冥想5分钟，替代吸烟解压
   - 社交场合：提前告知亲友“我在戒烟”，拒绝递烟

2. 防复吸关键：
   - 识别复吸信号：连续2天情绪低落、开始怀念吸烟的感觉
   - 应对“破功”：单次吸烟后不要放弃，分析原因并调整计划
   - 定期奖励：戒烟1个月、3个月、6个月给自己小奖励，例如购物或旅行

二、纠正常见误区（中国吸烟者高频认知）
1. “饭后吸烟助消化”
   错误：饭后吸烟会抑制胃肠蠕动，反而降低消化效率，增加胃癌风险
   正确：饭后散步或喝温水才是真正助消化的方式

2. “偶尔抽一支没关系”
   错误：单次吸烟即可重建尼古丁依赖，导致戒断失败
   正确：戒烟需彻底，“偶尔”是复吸的开始

3. “吸烟能缓解压力”
   错误：尼古丁只会短暂麻痹神经，长期反而加剧焦虑
   正确：运动、倾诉、冥想才是健康的减压方式

三、长期收益（中国人群数据）
- 戒烟1年：冠心病风险降低50%
- 戒烟5年：中风风险降至非吸烟者水平
- 戒烟10年：肺癌风险降低50%
- 戒烟15年：冠心病风险与非吸烟者无异"""
  };

  @override
  void initState() {
    super.initState();
    _videoController = VideoPlayerController.network(currentVideo.videoUrl);
    _initVideoPlayer();

    _audioPlayer = AudioPlayer();

    _audioPlayer.playerStateStream.listen((playerState) {
      if (!mounted) return;

      final isPlayingNow = playerState.playing &&
          playerState.processingState != ProcessingState.completed;

      if (playerState.processingState == ProcessingState.completed) {
        setState(() {
          _isAudioPlaying = false;
          _currentPlayingStage = null;
        });
      } else {
        setState(() {
          _isAudioPlaying = isPlayingNow;
        });
      }
    });
  }

  void _initVideoPlayer() {
    _videoController.initialize().then((_) {
      if (mounted) {
        setState(() {
          _chewieController = ChewieController(
            videoPlayerController: _videoController,
            autoPlay: false,
            looping: false,
            fullScreenByDefault: false,
            showControls: true,
            showControlsOnInitialize: true,
            aspectRatio: 16 / 9,
            placeholder: const Center(
              child: CircularProgressIndicator(
                color: Colors.green,
              ),
            ),
            errorBuilder: (context, errorMessage) {
              print("视频加载错误: $errorMessage");
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 50),
                    const Text(
                      "视频加载失败",
                      style: TextStyle(color: Colors.red, fontSize: 16),
                    ),
                    Text(
                      errorMessage,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          );
        });
      }
    }).catchError((error) {
      print('视频初始化失败: $error');
    });
  }

  Future<void> _playStageAudio(String stage) async {
    try {
      if (_currentPlayingStage == stage && _isAudioPlaying) {
        await _audioPlayer.stop();
        if (mounted) {
          setState(() {
            _currentPlayingStage = null;
            _isAudioPlaying = false;
          });
        }
        return;
      }

      await _audioPlayer.stop();

      if (mounted) {
        setState(() {
          _currentPlayingStage = stage;
          _isAudioPlaying = false;
        });
      }

      await _audioPlayer.setAsset(_stageAudio[stage]!);
      await _audioPlayer.play();
    } catch (e) {
      print("音频播放失败: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("音频播放失败，请检查素材路径是否正确"),
          ),
        );
      }
    }
  }

  Future<void> _stopAudio() async {
    await _audioPlayer.stop();
    if (mounted) {
      setState(() {
        _currentPlayingStage = null;
        _isAudioPlaying = false;
      });
    }
  }

  void _switchVideo(VideoConfig config) {
    _stopAudio();

    setState(() {
      currentVideo = config;
      _videoController.dispose();
      _chewieController?.dispose();
      _chewieController = null;
      _videoController = VideoPlayerController.network(config.videoUrl);
      _initVideoPlayer();
    });
  }

  @override
  Widget build(BuildContext context) => BlocConsumer<TipsCubit, TipsState>(
    listener: (context, state) {},
    builder: (context, state) {
      return state.tips == null
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : Scaffold(
        backgroundColor: Colors.green[50],
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.green[600],
          title: const Text(
            "戒烟知识库",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              '科学戒烟全指南',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // 视频容器
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                  )
                ],
              ),
              child: Column(
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      double maxHeight = 220;
                      double calculatedHeight =
                          constraints.maxWidth * 9 / 16;
                      double finalHeight = calculatedHeight > maxHeight
                          ? maxHeight
                          : calculatedHeight;

                      return SizedBox(
                        height: finalHeight,
                        width: double.infinity,
                        child: _chewieController != null
                            ? ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                          child: Chewie(controller: _chewieController!),
                        )
                            : Container(
                          color: Colors.green[50],
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Colors.green,
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  // 视频标题
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                    child: Text(
                      currentVideo.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  // 阶段切换按钮
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: videoList
                          .map((config) => _buildVideoButton(config))
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            _buildExpandableTileWithGreenHeader(
              emoji: '📋',
              stage: '准备阶段',
              subTitle: '认知与规划',
              content: _stageContent["准备阶段"]!,
            ),

            const SizedBox(height: 10),

            _buildExpandableTileWithGreenHeader(
              emoji: '💪',
              stage: '戒断阶段',
              subTitle: '应对与坚持',
              content: _stageContent["戒断阶段"]!,
            ),

            const SizedBox(height: 10),

            _buildExpandableTileWithGreenHeader(
              emoji: '🏆',
              stage: '维持阶段',
              subTitle: '防复吸与长期收益',
              content: _stageContent["维持阶段"]!,
            ),
          ],
        ),
      );
    },
  );

  Widget _buildExpandableTileWithGreenHeader({
    required String emoji,
    required String stage,
    required String subTitle,
    required String content,
  }) {
    final bool isCurrentStagePlaying =
        _currentPlayingStage == stage && _isAudioPlaying;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
          )
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          unselectedWidgetColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          childrenPadding: EdgeInsets.zero,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(12),
              bottom: Radius.circular(12),
            ),
          ),
          collapsedShape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          backgroundColor: Colors.green[600],
          collapsedBackgroundColor: Colors.green[600],
          title: Text(
            '$emoji $stage：$subTitle',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          trailing: const Icon(
            Icons.keyboard_arrow_down,
            color: Colors.white,
          ),
          collapsedIconColor: Colors.white,
          iconColor: Colors.white,
          children: [
            GestureDetector(
              onDoubleTap: () => _playStageAudio(stage),
              onLongPress: () => _playStageAudio(stage),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 未播放时的提示
                    if (!isCurrentStagePlaying)
                      Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.grey.shade300,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.touch_app,
                              color: Colors.grey[600],
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '双击或长按正文可朗读内容',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // 正在播放提示
                    if (isCurrentStagePlaying)
                      Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.green.shade200,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.volume_up,
                              color: Colors.green[700],
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '正在播放，双击或长按可停止',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.green[700],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    Text(
                      content,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.6,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoButton(VideoConfig config) {
    return TextButton(
      onPressed: () => _switchVideo(config),
      style: TextButton.styleFrom(
        backgroundColor: currentVideo.stage == config.stage
            ? Colors.green[600]
            : Colors.green[100],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      child: Text(
        config.stage,
        style: TextStyle(
          color: currentVideo.stage == config.stage
              ? Colors.white
              : Colors.green[800],
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _videoController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }
}