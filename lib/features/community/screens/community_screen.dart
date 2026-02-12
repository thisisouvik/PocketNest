import 'package:flutter/material.dart';
import 'package:pocketnest/core/theme/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CommunityTab extends StatefulWidget {
  const CommunityTab({super.key, required this.userId});

  final String userId;

  @override
  State<CommunityTab> createState() => _CommunityTabState();
}

class _CommunityTabState extends State<CommunityTab> {
  static const List<String> _categories = [
    'All',
    'Groceries',
    'Saving',
    'Growth',
    'Mindset',
    'Family Finance',
  ];

  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  String _selectedCategory = 'All';
  List<Map<String, dynamic>> _posts = [];

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPosts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final supabase = Supabase.instance.client;
      var query = supabase
          .from('community_posts')
          .select(
            'id, title, content, category, created_at, upvotes, comments_count',
          );

      if (_selectedCategory != 'All') {
        query = query.eq('category', _selectedCategory);
      }

      final search = _searchController.text.trim();
      if (search.isNotEmpty) {
        query = query.ilike('title', '%$search%');
      }

      final response = await query.order('created_at', ascending: false);

      setState(() {
        _posts = List<Map<String, dynamic>>.from(response as List);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _posts = [];
        _isLoading = false;
      });
    }
  }

  void _openCreatePost() async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => _CreatePostScreen(userId: widget.userId),
      ),
    );

    if (created == true) {
      _loadPosts();
    }
  }

  void _openPostDetail(Map<String, dynamic> post) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _PostDetailScreen(post: post, userId: widget.userId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreatePost,
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Start a conversation',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Community',
                    style: TextStyle(
                      fontFamily: 'Alkalami',
                      fontSize: 28,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Learn, share, and grow together.',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onSubmitted: (_) => _loadPosts(),
                          decoration: InputDecoration(
                            hintText: 'Search discussions...',
                            hintStyle: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                            prefixIcon: const Icon(Icons.search),
                            filled: true,
                            fillColor: AppTheme.cardBackground,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.cardBackground,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.tune,
                          size: 20,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 34,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final category = _categories[index];
                        final isActive = category == _selectedCategory;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedCategory = category;
                            });
                            _loadPosts();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? AppTheme.primaryColor.withOpacity(0.12)
                                  : AppTheme.cardBackground,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: isActive
                                    ? AppTheme.primaryColor
                                    : AppTheme.borderColor.withOpacity(0.4),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              category,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 11,
                                fontWeight: isActive
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                                color: isActive
                                    ? AppTheme.primaryColor
                                    : AppTheme.textSecondary,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildPremiumRow(),
                  const SizedBox(height: 6),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.primaryColor,
                        ),
                      ),
                    )
                  : _posts.isEmpty
                  ? _buildEmptyState()
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                      itemBuilder: (context, index) {
                        final post = _posts[index];
                        return _PostCard(
                          post: post,
                          onTap: () => _openPostDetail(post),
                        );
                      },
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemCount: _posts.length,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumRow() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8F0),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFE0B2), width: 1),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.lock_outline,
            size: 16,
            color: AppTheme.textSecondary,
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Premium: AI summaries, saved threads, expert highlights.',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            ),
            child: const Text(
              'See perks',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.forum_outlined,
              size: 42,
              color: AppTheme.textSecondary,
            ),
            const SizedBox(height: 12),
            const Text(
              'No conversations yet',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Start a calm, practical money discussion.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: _openCreatePost,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Start a conversation',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  const _PostCard({required this.post, required this.onTap});

  final Map<String, dynamic> post;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final title = (post['title'] ?? '').toString();
    final preview = (post['content'] ?? '').toString();
    final category = (post['category'] ?? 'General').toString();
    final createdAt = post['created_at']?.toString() ?? '';
    final upvotes = (post['upvotes'] ?? 0).toString();
    final comments = (post['comments_count'] ?? 0).toString();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              preview,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    category,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
                const Spacer(),
                _MetaItem(icon: Icons.thumb_up_outlined, value: upvotes),
                const SizedBox(width: 10),
                _MetaItem(icon: Icons.chat_bubble_outline, value: comments),
                const SizedBox(width: 10),
                _MetaItem(
                  icon: Icons.schedule,
                  value: _formatTimeAgo(createdAt),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimeAgo(String raw) {
    if (raw.isEmpty) return '';
    final timestamp = DateTime.tryParse(raw);
    if (timestamp == null) return '';
    final difference = DateTime.now().difference(timestamp);
    if (difference.inMinutes < 60) return '${difference.inMinutes}m';
    if (difference.inHours < 24) return '${difference.inHours}h';
    return '${difference.inDays}d';
  }
}

class _MetaItem extends StatelessWidget {
  const _MetaItem({required this.icon, required this.value});

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppTheme.textSecondary),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _PostDetailScreen extends StatefulWidget {
  const _PostDetailScreen({required this.post, required this.userId});

  final Map<String, dynamic> post;
  final String userId;

  @override
  State<_PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<_PostDetailScreen> {
  bool _isLoading = true;
  bool _isUpvoted = false;
  int _upvoteCount = 0;
  List<Map<String, dynamic>> _comments = [];
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _upvoteCount = widget.post['upvotes'] ?? 0;
    _loadComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('community_comments')
          .select('id, content, created_at')
          .eq('post_id', widget.post['id'])
          .order('created_at', ascending: true);

      setState(() {
        _comments = List<Map<String, dynamic>>.from(response as List);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _comments = [];
        _isLoading = false;
      });
    }
  }

  Future<void> _submitComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    try {
      final supabase = Supabase.instance.client;
      await supabase.from('community_comments').insert({
        'post_id': widget.post['id'],
        'user_id': widget.userId,
        'content': text,
      });

      _commentController.clear();
      _loadComments();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not post comment. Try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = (widget.post['title'] ?? '').toString();
    final category = (widget.post['category'] ?? 'General').toString();
    final content = (widget.post['content'] ?? '').toString();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        title: const Text(
          'Discussion',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        iconTheme: const IconThemeData(color: AppTheme.textPrimary),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Alkalami',
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      category,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Divider(color: AppTheme.borderColor.withOpacity(0.4)),
                  const SizedBox(height: 12),
                  Text(
                    content,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.textSecondary,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _isUpvoted = !_isUpvoted;
                            _upvoteCount += _isUpvoted ? 1 : -1;
                          });
                        },
                        icon: Icon(
                          _isUpvoted ? Icons.thumb_up : Icons.thumb_up_outlined,
                          color: AppTheme.primaryColor,
                          size: 18,
                        ),
                        label: Text(
                          '$_upvoteCount',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${_comments.length} comments',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Comments',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_isLoading)
                    const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.primaryColor,
                        ),
                      ),
                    )
                  else if (_comments.isEmpty)
                    const Text(
                      'Be the first to share a thought.',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.textSecondary,
                      ),
                    )
                  else
                    Column(
                      children: _comments
                          .map((comment) => _CommentCard(comment: comment))
                          .toList(),
                    ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            decoration: BoxDecoration(
              color: AppTheme.cardBackground,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    minLines: 1,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Share your thoughts...',
                      hintStyle: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                      filled: true,
                      fillColor: AppTheme.backgroundColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _submitComment,
                  icon: const Icon(Icons.send, color: AppTheme.primaryColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentCard extends StatelessWidget {
  const _CommentCard({required this.comment});

  final Map<String, dynamic> comment;

  @override
  Widget build(BuildContext context) {
    final content = (comment['content'] ?? '').toString();
    final createdAt = comment['created_at']?.toString() ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Member',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            content,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _formatTimeAgo(createdAt),
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 10,
              fontWeight: FontWeight.w400,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(String raw) {
    if (raw.isEmpty) return '';
    final timestamp = DateTime.tryParse(raw);
    if (timestamp == null) return '';
    final difference = DateTime.now().difference(timestamp);
    if (difference.inMinutes < 60) return '${difference.inMinutes}m';
    if (difference.inHours < 24) return '${difference.inHours}h';
    return '${difference.inDays}d';
  }
}

class _CreatePostScreen extends StatefulWidget {
  const _CreatePostScreen({required this.userId});

  final String userId;

  @override
  State<_CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<_CreatePostScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  bool _isSubmitting = false;
  String _category = 'Saving';

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _submitPost() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a title and content.')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final supabase = Supabase.instance.client;
      await supabase.from('community_posts').insert({
        'title': title,
        'content': content,
        'category': _category,
        'user_id': widget.userId,
      });

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not post. Try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        title: const Text(
          'Start a conversation',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        iconTheme: const IconThemeData(color: AppTheme.textPrimary),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Title',
                hintStyle: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
                filled: true,
                fillColor: AppTheme.cardBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _category,
              items: _CommunityTabState._categories
                  .where((value) => value != 'All')
                  .map(
                    (value) => DropdownMenuItem(
                      value: value,
                      child: Text(
                        value,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _category = value;
                });
              },
              decoration: InputDecoration(
                filled: true,
                fillColor: AppTheme.cardBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: TextField(
                controller: _contentController,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: InputDecoration(
                  hintText: 'Share your thoughts...',
                  hintStyle: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                  filled: true,
                  fillColor: AppTheme.cardBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitPost,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  _isSubmitting ? 'Posting...' : 'Post',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
