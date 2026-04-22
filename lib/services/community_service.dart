import 'dart:convert';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/foundation.dart';

class CommunityService {

  /// 获取社区帖子
  Future<List<dynamic>> fetchPosts() async {
    final request = GraphQLRequest<String>(
      document: r'''
        query ListCommunityPosts {
          listMessages(filter: {
            receiveuser: {eq: "community"}
          }) {
            items {
              id
              content
              senduser
              date
              receiveuser
            }
          }
        }
      ''',
    );

    debugPrint('📡 [CommunityService] 正在获取社区帖子...');

    try {
      final response = await Amplify.API.query(request: request).response;

      debugPrint('📊 [CommunityService] 响应类型: ${response.data.runtimeType}');

      if (response.data == null) {
        debugPrint('❌ [CommunityService] 获取帖子失败: 数据为空');
        if (response.errors != null) {
          for (final error in response.errors!) {
            debugPrint('❌ [CommunityService] GraphQL错误: ${error.message}');
          }
        }
        return [];
      }

      // 处理响应
      dynamic data;
      if (response.data is String) {
        try {
          data = jsonDecode(response.data as String);
          debugPrint('✅ [CommunityService] 成功解析字符串响应为 JSON');
        } catch (e) {
          debugPrint('❌ [CommunityService] JSON 解析失败: $e');
          debugPrint('❌ [CommunityService] 原始响应: ${response.data}');
          return [];
        }
      } else {
        data = response.data;
      }

      if (data is Map<String, dynamic>) {
        final listMessages = data['listMessages'];
        if (listMessages is Map<String, dynamic>) {
          final items = listMessages['items'] as List<dynamic>? ?? [];
          debugPrint('✅ [CommunityService] 成功获取 ${items.length} 个帖子');

          // 调试输出每个帖子的详细信息
          for (int i = 0; i < items.length; i++) {
            final post = items[i];
            if (post is Map<String, dynamic>) {
              final contentPreview = post['content']?.toString() ?? '';
              final preview = contentPreview.length > 30
                  ? '${contentPreview.substring(0, 30)}...'
                  : contentPreview;
              debugPrint('📊 帖子 [$i]: ID=${post['id']}, 内容="$preview"');
            }
          }

          return items;
        }
      }

      debugPrint('⚠️ [CommunityService] 响应数据结构不符合预期');
      return [];
    } catch (e) {
      debugPrint('❌ [CommunityService] 查询异常: $e');
      debugPrint('❌ [CommunityService] 异常堆栈: ${e.toString()}');
      return [];
    }
  }

  /// 发布帖子
  Future<bool> addPost(String content) async {
    try {
      final user = await Amplify.Auth.getCurrentUser();
      final now = DateTime.now().toIso8601String();

      final request = GraphQLRequest<String>(
        document: r'''
          mutation CreatePost($content: String!, $author: String!, $date: String!) {
            createMessage(input: {
              content: $content
              senduser: $author
              receiveuser: "community"
              date: $date
              readed: "false"
            }) {
              id
              content
              senduser
              date
              receiveuser
            }
          }
        ''',
        variables: {
          'content': content,
          'author': user.userId,
          'date': now,
        },
      );

      debugPrint('📤 [CommunityService] 正在发布帖子: "$content"');

      final response = await Amplify.API.mutate(request: request).response;

      // 调试输出
      debugPrint('📤 [CommunityService] 发布响应: ${response.data}');
      debugPrint('📤 [CommunityService] 发布错误: ${response.errors}');

      // 首先检查是否有错误
      if (response.errors != null && response.errors!.isNotEmpty) {
        debugPrint('❌ [CommunityService] 发布失败: ${response.errors}');
        return false;
      }

      if (response.data != null) {
        debugPrint('✅ [CommunityService] 帖子发布成功');
        return true;
      } else {
        debugPrint('❌ [CommunityService] 帖子发布失败: 响应数据为空');
        return false;
      }
    } catch (e) {
      debugPrint('❌ [CommunityService] 发布异常: $e');
      debugPrint('❌ [CommunityService] 异常堆栈: ${e.toString()}');
      return false;
    }
  }

  /// 获取评论
  Future<List<dynamic>> fetchComments(String postId) async {
    try {
      final request = GraphQLRequest<String>(
        document: r'''
          query ListCommentsByPost($postId: String!) {
            listMessages(filter: {
              receiveuser: {eq: $postId}
            }) {
              items {
                id
                content
                senduser
                date
                receiveuser
              }
            }
          }
        ''',
        variables: {
          'postId': postId,
        },
      );

      debugPrint('💬 [CommunityService] 正在获取帖子 $postId 的评论...');

      final response = await Amplify.API.query(request: request).response;

      debugPrint('💬 [CommunityService] 评论查询响应类型: ${response.data.runtimeType}');

      if (response.data == null) {
        debugPrint('❌ [CommunityService] 获取评论失败: 数据为空');
        if (response.errors != null) {
          for (final error in response.errors!) {
            debugPrint('❌ [CommunityService] GraphQL错误: ${error.message}');
          }
        }
        return [];
      }

      // 处理响应
      dynamic data;
      if (response.data is String) {
        try {
          data = jsonDecode(response.data as String);
          debugPrint('💬 [CommunityService] 成功解析评论响应为 JSON');
        } catch (e) {
          debugPrint('❌ [CommunityService] JSON 解析失败: $e');
          debugPrint('❌ [CommunityService] 原始响应: ${response.data}');
          return [];
        }
      } else {
        data = response.data;
      }

      if (data is Map<String, dynamic>) {
        final listMessages = data['listMessages'];
        if (listMessages is Map<String, dynamic>) {
          final items = listMessages['items'] as List<dynamic>? ?? [];
          debugPrint('✅ [CommunityService] 成功获取 ${items.length} 条评论');

          // 调试输出评论内容
          for (int i = 0; i < items.length; i++) {
            final comment = items[i];
            if (comment is Map<String, dynamic>) {
              final contentPreview = comment['content']?.toString() ?? '';
              final preview = contentPreview.length > 30
                  ? '${contentPreview.substring(0, 30)}...'
                  : contentPreview;
              debugPrint('📝 评论 [$i]: "$preview" (作者: ${comment['senduser']})');
            }
          }

          return items;
        } else {
          debugPrint('⚠️ [CommunityService] listMessages 字段不是 Map 类型');
          return [];
        }
      } else {
        debugPrint('⚠️ [CommunityService] 响应数据不是 Map 类型');
        return [];
      }
    } catch (e) {
      debugPrint('❌ [CommunityService] 获取评论异常: $e');
      debugPrint('❌ [CommunityService] 异常堆栈: ${e.toString()}');
      return [];
    }
  }

  /// 发布评论
  Future<bool> addComment(String postId, String content) async {
    try {
      final user = await Amplify.Auth.getCurrentUser();
      final now = DateTime.now().toIso8601String();

      debugPrint('💬 准备发布评论:');
      debugPrint('💬 帖子ID: $postId');
      debugPrint('💬 评论内容: "$content"');
      debugPrint('💬 用户ID: ${user.userId}');
      debugPrint('💬 时间: $now');

      final request = GraphQLRequest<String>(
        document: r'''
          mutation CreateComment($postId: String!, $content: String!, $author: String!, $date: String!) {
            createMessage(input: {
              content: $content
              senduser: $author
              receiveuser: $postId
              date: $date
              readed: "false"
            }) {
              id
              content
              senduser
              date
              receiveuser
            }
          }
        ''',
        variables: {
          'postId': postId,
          'content': content,
          'author': user.userId,
          'date': now,
        },
      );

      debugPrint('💬 [CommunityService] 正在发布评论到帖子 $postId: "$content"');

      final response = await Amplify.API.mutate(request: request).response;

      // 调试输出响应
      debugPrint('💬 [CommunityService] 评论发布响应: ${response.data}');
      debugPrint('💬 [CommunityService] 评论发布错误: ${response.errors}');

      // 首先检查是否有错误
      if (response.errors != null && response.errors!.isNotEmpty) {
        debugPrint('❌ [CommunityService] 评论发布失败: ${response.errors}');
        return false;
      }

      if (response.data != null) {
        debugPrint('✅ [CommunityService] 评论发布成功');
        return true;
      } else {
        debugPrint('❌ [CommunityService] 评论发布失败: 响应数据为空');
        return false;
      }
    } catch (e) {
      debugPrint('❌ [CommunityService] 评论发布异常: $e');
      debugPrint('❌ [CommunityService] 异常堆栈: ${e.toString()}');
      return false;
    }
  }

  /// 验证数据是否在云端（调试用）
  Future<void> verifyDataInCloud() async {
    debugPrint('🔍 [CommunityService] 验证云端数据...');

    try {
      // 验证帖子
      final postsRequest = GraphQLRequest<String>(
        document: r'''
          query VerifyPosts {
            listMessages(filter: {receiveuser: {eq: "community"}}) {
              items {
                id
                content
                senduser
                date
                receiveuser
              }
            }
          }
        ''',
      );

      final postsResponse = await Amplify.API.query(request: postsRequest).response;

      if (postsResponse.data != null) {
        debugPrint('✅ [CommunityService] 云端帖子验证成功');
        if (postsResponse.data is String) {
          try {
            final data = jsonDecode(postsResponse.data as String);
            final items = data['listMessages']['items'] as List<dynamic>? ?? [];
            debugPrint('📊 云端帖子数量: ${items.length}');
          } catch (e) {
            debugPrint('📊 原始帖子数据: ${postsResponse.data}');
          }
        }
      } else {
        debugPrint('❌ [CommunityService] 云端验证失败: 无数据返回');
      }

    } catch (e) {
      debugPrint('❌ [CommunityService] 云端验证异常: $e');
    }
  }

  /// 获取单个帖子的详细信息（调试用）
  Future<Map<String, dynamic>?> getPostDetail(String postId) async {
    try {
      final request = GraphQLRequest<String>(
        document: r'''
          query GetPostDetail($id: ID!) {
            getMessage(id: $id) {
              id
              content
              senduser
              date
              receiveuser
            }
          }
        ''',
        variables: {
          'id': postId,
        },
      );

      debugPrint('🔍 [CommunityService] 获取帖子详情: $postId');

      final response = await Amplify.API.query(request: request).response;

      if (response.data != null) {
        if (response.data is String) {
          try {
            final data = jsonDecode(response.data as String);
            final post = data['getMessage'];
            if (post != null) {
              debugPrint('📋 帖子详情: $post');
              return Map<String, dynamic>.from(post);
            } else {
              debugPrint('📋 帖子不存在: $postId');
            }
          } catch (e) {
            debugPrint('❌ [CommunityService] 解析帖子详情失败: $e');
            debugPrint('❌ [CommunityService] 原始响应: ${response.data}');
          }
        }
      } else {
        debugPrint('❌ [CommunityService] 获取帖子详情失败: 数据为空');
      }

      return null;
    } catch (e) {
      debugPrint('❌ [CommunityService] 获取帖子详情异常: $e');
      debugPrint('❌ [CommunityService] 异常堆栈: ${e.toString()}');
      return null;
    }
  }
}