const String listPosts = '''
query ListPosts {
  listPosts {
    items {
      id
      content
      owner
      likes
      createdAt
    }
  }
}
''';

const String listCommentsByPost = '''
query ListCommentsByPost(\$postID: ID!) {
  listComments(filter: { postID: { eq: \$postID } }) {
    items {
      id
      content
      owner
      createdAt
    }
  }
}
''';
