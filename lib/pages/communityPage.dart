import 'dart:convert';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sense2quit/bloc/cubit/amplify_auth_cubit.dart';
import 'package:sense2quit/constants.dart';
import 'package:sense2quit/services/community_service.dart';

/// =======================
/// 数据模型
/// =======================

class Comment {
  final String id;
  final String postId;
  final String userId;
  final String content;
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.content,
    required this.createdAt,
  });

  static Future<Comment> fromMessageAsync(Map<String, dynamic> json) async {
    final userId = json['senduser']?.toString() ?? 'unknown';

    return Comment(
      id: json['id']?.toString() ?? '',
      postId: json['receiveuser']?.toString() ?? '',
      userId: userId,
      content: json['content']?.toString() ?? '',
      createdAt: _parseDateTime(json['date']),
    );
  }

  static DateTime _parseDateTime(dynamic dateValue) {
    try {
      if (dateValue is String) {
        return DateTime.parse(dateValue);
      }
    } catch (e) {
      debugPrint('⚠️ 日期解析失败: $dateValue, 错误: $e');
    }
    return DateTime.now();
  }
}

class CommunityPost {
  final String id;
  final String userId;
  final String content;
  final DateTime createdAt;
  List<Comment> comments;

  CommunityPost({
    required this.id,
    required this.userId,
    required this.content,
    required this.createdAt,
    this.comments = const [],
  });

  static Future<CommunityPost> fromMessageAsync(Map<String, dynamic> json) async {
    final userId = json['senduser']?.toString() ?? 'unknown';

    return CommunityPost(
      id: json['id']?.toString() ?? '',
      userId: userId,
      content: json['content']?.toString() ?? '',
      createdAt: Comment._parseDateTime(json['date']),
      comments: const [],
    );
  }
}

/// 辅助函数
int min(int a, int b) => a < b ? a : b;

/// =======================
/// 页面
/// =======================

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  final CommunityService _communityService = CommunityService();

  final TextEditingController _postController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final Map<String, TextEditingController> _commentControllers = {};

  List<CommunityPost> _posts = [];
  bool _isLoading = false;
  bool _isPosting = false;

  String _currentUserId = '';
  String _currentUserNickname = '匿名用户';

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    debugPrint('🔄 [CommunityPage] 初始化开始');
    await _getCurrentUserInfo();
    await _fetchPosts();
    debugPrint('✅ [CommunityPage] 初始化完成');
  }

  Future<void> _getCurrentUserInfo() async {
    try {
      // 获取用户ID
      final user = await Amplify.Auth.getCurrentUser();
      _currentUserId = user.userId;
      debugPrint('👤 [CommunityPage] 当前用户ID: $_currentUserId');

      // 获取用户昵称（匿名模式下保留，用于发布时标识，但不显示）
      final prefs = await SharedPreferences.getInstance();
      _currentUserNickname = prefs.getString('profile_username') ?? '匿名用户';
      debugPrint('👤 [CommunityPage] 当前用户昵称: $_currentUserNickname');
    } catch (e) {
      _currentUserId = 'unknown';
      _currentUserNickname = '匿名用户';
      debugPrint('⚠️ [CommunityPage] 获取用户信息失败: $e');
    }
  }

  /// =======================
  /// 数据操作
  /// =======================

  Future<void> _fetchPosts() async {
    if (_isLoading) {
      debugPrint('⚠️ [CommunityPage] 正在加载中，跳过重复请求');
      return;
    }

    debugPrint('🔄 [CommunityPage] 开始获取帖子列表');
    setState(() => _isLoading = true);

    try {
      debugPrint('📡 [CommunityPage] 调用 CommunityService.fetchPosts()...');
      final rawPosts = await _communityService.fetchPosts();

      debugPrint('📄 [CommunityPage] 处理 ${rawPosts.length} 个原始帖子数据');

      final List<CommunityPost> posts = [];
      for (int i = 0; i < rawPosts.length; i++) {
        final rawPost = rawPosts[i];

        // 检查是否是 Map 类型
        if (rawPost is! Map<String, dynamic>) {
          debugPrint('⚠️ [CommunityPage] 跳过非Map类型的数据 [$i]: ${rawPost.runtimeType}');
          continue;
        }

        // 检查是否是社区帖子
        final receiveuser = rawPost['receiveuser']?.toString() ?? '';
        if (receiveuser != 'community') {
          debugPrint('⏭️ [CommunityPage] 跳过非社区消息 [$i]: receiveuser=$receiveuser');
          continue;
        }

        try {
          final post = await CommunityPost.fromMessageAsync(rawPost);

          final contentPreview = post.content.length > 30
              ? '${post.content.substring(0, min(30, post.content.length))}...'
              : post.content;
          debugPrint('📝 [CommunityPage] 处理帖子 [$i]: ${post.id} - "$contentPreview"');

          // 获取该帖子的评论
          try {
            debugPrint('💬 [CommunityPage] 获取帖子 ${post.id} 的评论...');
            final rawComments = await _communityService.fetchComments(post.id);

            final List<Comment> comments = [];
            for (final commentData in rawComments) {
              if (commentData is Map<String, dynamic>) {
                final commentReceiveUser = commentData['receiveuser']?.toString() ?? '';
                if (commentReceiveUser == post.id) {
                  final comment = await Comment.fromMessageAsync(commentData);
                  comments.add(comment);
                }
              }
            }

            post.comments = comments;
            debugPrint('✅ [CommunityPage] 帖子 ${post.id} 有 ${post.comments.length} 条评论');
          } catch (e) {
            debugPrint('⚠️ [CommunityPage] 获取评论失败：$e');
            post.comments = [];
          }

          posts.add(post);
        } catch (e) {
          debugPrint('❌ [CommunityPage] 处理帖子数据失败 [$i]: $e');
          debugPrint('❌ [CommunityPage] 原始数据: $rawPost');
        }
      }

      // 按创建时间排序（最新的在前）
      posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      debugPrint('📊 [CommunityPage] 排序完成，共 ${posts.length} 个帖子');

      setState(() {
        _posts = posts;
        _isLoading = false;
      });

      debugPrint('✅ [CommunityPage] 页面状态更新完成');

    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('❌ [CommunityPage] 加载社区失败：$e');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('加载失败: ${e.toString()}'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _publishPost() async {
    final content = _postController.text.trim();
    if (content.isEmpty) {
      debugPrint('⚠️ [CommunityPage] 帖子内容为空，不发布');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入帖子内容')),
      );
      return;
    }

    if (_isPosting) {
      debugPrint('⚠️ [CommunityPage] 正在发布中，跳过重复请求');
      return;
    }

    if (_currentUserId == 'unknown') {
      debugPrint('❌ [CommunityPage] 用户未登录，无法发布帖子');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先登录')),
      );
      return;
    }

    debugPrint('🚀 [CommunityPage] 开始发布帖子: "$content"');

    setState(() => _isPosting = true);

    try {
      debugPrint('📤 [CommunityPage] 调用 CommunityService.addPost()...');
      final success = await _communityService.addPost(content);

      if (success) {
        debugPrint('✅ [CommunityPage] 发布请求完成，清除输入框');
        _postController.clear();

        debugPrint('🔄 [CommunityPage] 重新获取帖子列表...');
        await _fetchPosts();
        debugPrint('✅ [CommunityPage] 帖子列表更新完成');

        // 滚动到顶部查看新发布的帖子
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }

        // 显示成功提示
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('发布成功！'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('发布失败，请重试'),
            backgroundColor: Colors.red,
          ),
        );
      }

    } catch (e) {
      debugPrint('❌ [CommunityPage] 发布帖子过程中发生错误: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('发布失败: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      debugPrint('🔄 [CommunityPage] 结束发布状态');
      setState(() => _isPosting = false);
    }
  }

  /// =======================
  /// 评论相关
  /// =======================

  Future<void> _publishComment(int postIndex) async {
    if (postIndex < 0 || postIndex >= _posts.length) return;

    final post = _posts[postIndex];
    final controller =
    _commentControllers.putIfAbsent(post.id, () => TextEditingController());

    final content = controller.text.trim();
    if (content.isEmpty) {
      debugPrint('⚠️ [CommunityPage] 评论内容为空');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入评论内容')),
      );
      return;
    }

    if (_currentUserId == 'unknown') {
      debugPrint('❌ [CommunityPage] 用户未登录，无法评论');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先登录')),
      );
      return;
    }

    debugPrint('💬 [CommunityPage] 发布评论到帖子 [$postIndex]: ${post.id}');
    debugPrint('📝 [CommunityPage] 评论内容: "$content"');

    try {
      final success = await _communityService.addComment(post.id, content);
      if (success) {
        controller.clear();

        debugPrint('✅ [CommunityPage] 评论发布成功，重新获取数据...');
        await _fetchPosts();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('评论成功！'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('评论失败，请重试'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ [CommunityPage] 评论发布失败: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('评论失败: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// =======================
  /// UI 构建
  /// =======================

  Widget _buildPostList() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.green),
            SizedBox(height: 16),
            Text('正在加载社区内容...'),
          ],
        ),
      );
    }

    if (_posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.forum_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text(
              '互动留言板空空如也',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              '快来分享你的戒烟经验或给他人留言吧～',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _fetchPosts,
              icon: const Icon(Icons.refresh),
              label: const Text('刷新'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _posts.length,
      itemBuilder: (context, index) {
        final post = _posts[index];
        return _buildPostItem(post, index);
      },
    );
  }

  Widget _buildPostItem(CommunityPost post, int index) {
    final commentController =
    _commentControllers.putIfAbsent(post.id, () => TextEditingController());

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Colors.white, // 卡片背景设置为白色
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 头部 - 匿名显示
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50, // 改为浅绿色背景
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          '匿名用户',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.green,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('MM-dd HH:mm').format(post.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            /// 内容
            Text(
              post.content,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),

            const SizedBox(height: 16),

            /// 评论数量指示器
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.green.shade300),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.comment_outlined,
                    size: 18,
                    color: Colors.green,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${post.comments.length} 条留言',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            /// 评论列表 - 每条留言背景改为白色，匿名显示
            if (post.comments.isNotEmpty) ...[
              const Divider(height: 32),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      '留言 (${post.comments.length})',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  ...post.comments.map(
                        (c) => Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      color: Colors.white,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  '匿名',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.green,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                DateFormat('MM-dd HH:mm').format(c.createdAt),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(c.content),
                        ],
                      ),
                    ),
                  ).toList(),
                ],
              ),
            ],

            /// 评论输入
            const Divider(height: 32),
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Colors.green.shade300),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: commentController,
                            decoration: const InputDecoration(
                              hintText: '写下你的留言...',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: IconButton(
                    onPressed: () => _publishComment(index),
                    icon: const Icon(Icons.send, color: Colors.white, size: 20),
                    padding: const EdgeInsets.all(12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// =======================
  /// 生命周期
  /// =======================

  @override
  void dispose() {
    _postController.dispose();
    _scrollController.dispose();
    for (final c in _commentControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  /// =======================
  /// Scaffold
  /// =======================

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AmplifyAuthCubit, AmplifyAuthState>(
      listener: (context, state) {
        if (state.status == Constants.LOGOUT_SUCCEEDED) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/login',
                (_) => false,
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.green[50],
          appBar: AppBar(
            title: const Text('吸烟社区互助'),
            centerTitle: true,
            backgroundColor: Colors.green[600],
            titleTextStyle: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              IconButton(
                onPressed: _fetchPosts,
                icon: const Icon(Icons.refresh, color: Colors.white),
                tooltip: '刷新',
              ),
            ],
          ),
          body: Column(
            children: [
              /// 顶部提示语 - 改为更浅的绿色
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50, // 改为与留言背景相同的浅绿色
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.green[700], size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '💬 欢迎友好分享与讨论',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[800],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '本留言板为匿名交流，暂时不支持自己删除发言。如遇不当言论需删除，请联系：wxysy0903@gmail.com',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.green[700],
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await _fetchPosts();
                  },
                  color: Colors.green,
                  child: _buildPostList(),
                ),
              ),

              /// 发布输入框
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Colors.green.shade200)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(color: Colors.green.shade300),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _postController,
                                decoration: const InputDecoration(
                                  hintText: '分享你的戒烟经验或想说的话...',
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                ),
                                maxLines: null,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: _isPosting ? Colors.grey.shade300 : Colors.green,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: IconButton(
                        onPressed: _isPosting ? null : _publishPost,
                        icon: _isPosting
                            ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                            : const Icon(Icons.send, color: Colors.white),
                        padding: const EdgeInsets.all(12),
                        tooltip: '发布',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}