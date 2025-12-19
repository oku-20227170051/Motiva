import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import '../models/conversation_model.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';
import 'chat_screen.dart';

class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({super.key});

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  final _firestoreService = FirestoreService();
  List<ConversationModel> _conversations = [];
  Map<String, UserModel> _users = {}; // userId -> UserModel
  bool _isLoading = true;
  
  String? get _currentUserId => FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    if (_currentUserId == null) return;
    
    setState(() => _isLoading = true);
    
    final conversations = await _firestoreService.getConversations(_currentUserId!);
    
    // Konuşma katılımcılarının bilgilerini al
    Map<String, UserModel> users = {};
    for (var conversation in conversations) {
      for (var userId in conversation.participants) {
        if (userId != _currentUserId && !users.containsKey(userId)) {
          final user = await _firestoreService.getUser(userId);
          if (user != null) {
            users[userId] = user;
          }
        }
      }
    }
    
    setState(() {
      _conversations = conversations;
      _users = users;
      _isLoading = false;
    });
  }

  UserModel? _getOtherUser(ConversationModel conversation) {
    final otherUserId = conversation.participants.firstWhere(
      (id) => id != _currentUserId,
      orElse: () => '',
    );
    return _users[otherUserId];
  }

  int _getUnreadCount(ConversationModel conversation) {
    return conversation.unreadCount[_currentUserId] ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mesajlar'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _conversations.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadConversations,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                    itemCount: _conversations.length,
                    itemBuilder: (context, index) {
                      final conversation = _conversations[index];
                      final otherUser = _getOtherUser(conversation);
                      
                      if (otherUser == null) return const SizedBox.shrink();
                      
                      return _buildConversationCard(conversation, otherUser);
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 100,
              color: AppColors.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'Henüz Mesaj Yok',
              style: AppTextStyles.h2.copyWith(
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Arkadaşlarınla mesajlaşmaya başla!',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConversationCard(ConversationModel conversation, UserModel otherUser) {
    final unreadCount = _getUnreadCount(conversation);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: Text(
                otherUser.name[0].toUpperCase(),
                style: AppTextStyles.h3.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
            if (unreadCount > 0)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 20,
                    minHeight: 20,
                  ),
                  child: Text(
                    unreadCount > 9 ? '9+' : '$unreadCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
        title: Text(
          otherUser.name,
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.w600,
          ),
        ),
        subtitle: Text(
          conversation.lastMessage,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
            fontWeight: unreadCount > 0 ? FontWeight.w600 : FontWeight.normal,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _formatTime(conversation.lastMessageTime),
              style: AppTextStyles.caption.copyWith(
                color: unreadCount > 0 ? AppColors.primary : AppColors.textLight,
                fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ChatScreen(otherUser: otherUser),
            ),
          ).then((_) => _loadConversations()); // Geri dönünce listeyi yenile
        },
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inDays == 0) {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Dün';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} gün önce';
    } else {
      return '${time.day}/${time.month}/${time.year}';
    }
  }
}
