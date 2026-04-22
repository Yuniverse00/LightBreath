const String createPost = '''
mutation CreatePost(\$content: String!) {
  createPost(input: {
    content: \$content,
    likes: 0
  }) {
    id
    content
    owner
    likes
    createdAt
  }
}
''';

const String deletePost = '''
mutation DeletePost(\$id: ID!) {
  deletePost(input: { id: \$id }) {
    id
  }
}
''';

const String likePost = '''
mutation LikePost(\$id: ID!, \$likes: Int!) {
  updatePost(input: {
    id: \$id,
    likes: \$likes
  }) {
    id
    likes
  }
}
''';

const String createComment = '''
mutation CreateComment(\$postID: ID!, \$content: String!) {
  createComment(input: {
    postID: \$postID,
    content: \$content
  }) {
    id
    content
    owner
    createdAt
  }
}
''';
