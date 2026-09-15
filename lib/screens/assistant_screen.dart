import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/shilpi_ai_service.dart';
import 'voice_capture_dialog.dart';
import '../services/tts_service.dart';
import '../theme/colors.dart';

class AssistantScreen extends StatefulWidget {
  final Product? productContext;
  final bool isSellerContext;

  const AssistantScreen({
    super.key,
    this.productContext,
    this.isSellerContext = false,
  });

  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

class _ChatMessage {
  final String text;
  final bool isUser;

  _ChatMessage(this.text, this.isUser);
}

class _AssistantScreenState extends State<AssistantScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<_ChatMessage> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final greeting = widget.isSellerContext
        ? "Namaste! I'm Shilpi AI. How can I help you grow your artisan business today?"
        : widget.productContext != null
            ? "Namaste! I'm Shilpi AI. I see you're looking at the ${widget.productContext!.name}. What would you like to know?"
            : "Namaste! I'm Shilpi AI. I can help you discover beautiful crafts or answer questions about our artisans.";
    _messages.add(_ChatMessage(greeting, false));
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    
    setState(() {
      _messages.add(_ChatMessage(text, true));
      _isLoading = true;
    });
    _controller.clear();

    final mode = widget.isSellerContext
        ? AiContextMode.artisan
        : widget.productContext != null
            ? AiContextMode.product
            : AiContextMode.buyer;

    try {
      final response = await ShilpiAiService.instance.ask(
        text,
        mode,
        currentProduct: widget.productContext,
      );
      if (!mounted) return;
      setState(() {
        _messages.add(_ChatMessage(response.text, false));
        _isLoading = false;
      });
      TtsService.instance.speak(response.text);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _messages.add(_ChatMessage("I'm sorry, I couldn't connect right now. Please try again.", false));
        _isLoading = false;
      });
    }
  }

  Future<void> _startVoice() async {
    final result = await showDialog<VoiceResult>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const VoiceCaptureDialog(
        title: 'Speak to Shilpi AI',
        instruction: 'Ask a question using your voice.',
      ),
    );
    if (result != null && result.text.isNotEmpty) {
      _sendMessage(result.text);
    }
  }

  List<String> get _suggestions {
    if (widget.isSellerContext) {
      return ["Improve my listing", "Analyze my sales", "What's in demand?"];
    } else if (widget.productContext != null) {
      return ["How is this made?", "Tell me about the artisan", "Is this a good gift?"];
    }
    return ["Show me pottery", "Eco-friendly crafts", "Gifts under ₹1000"];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.auto_awesome, color: ShilpiColors.primary),
            SizedBox(width: 8),
            Text('Shilpi AI', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _buildBubble(msg);
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(Icons.auto_awesome, color: ShilpiColors.primary, size: 20),
                  SizedBox(width: 8),
                  Text('Shilpi AI is typing...', style: TextStyle(color: ShilpiColors.textSecondary, fontStyle: FontStyle.italic)),
                ],
              ),
            ),
          
          if (!_isLoading)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: _suggestions.map((s) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ActionChip(
                    label: Text(s),
                    onPressed: () => _sendMessage(s),
                    backgroundColor: ShilpiColors.surface,
                    side: const BorderSide(color: ShilpiColors.border),
                  ),
                )).toList(),
              ),
            ),
            
          Container(
            padding: const EdgeInsets.all(16).copyWith(bottom: 32),
            decoration: BoxDecoration(
              color: ShilpiColors.surface,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Ask Shilpi AI...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                      filled: true,
                      fillColor: ShilpiColors.surfaceMuted,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    onSubmitted: _sendMessage,
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: ShilpiColors.primaryLight,
                  child: IconButton(
                    icon: const Icon(Icons.mic, color: ShilpiColors.primary),
                    onPressed: _startVoice,
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: ShilpiColors.primary,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: () => _sendMessage(_controller.text),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBubble(_ChatMessage msg) {
    return Align(
      alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        decoration: BoxDecoration(
          color: msg.isUser ? ShilpiColors.primaryDark : ShilpiColors.surface,
          borderRadius: BorderRadius.circular(16).copyWith(
            bottomRight: msg.isUser ? Radius.zero : const Radius.circular(16),
            bottomLeft: msg.isUser ? const Radius.circular(16) : Radius.zero,
          ),
          border: msg.isUser ? null : Border.all(color: ShilpiColors.border),
        ),
        child: Text(
          msg.text,
          style: TextStyle(
            color: msg.isUser ? Colors.white : ShilpiColors.textPrimary,
            fontSize: 15,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}
