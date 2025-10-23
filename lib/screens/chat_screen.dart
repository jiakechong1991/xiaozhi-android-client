import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'dart:math';
import 'dart:io';
import 'package:ai_assistant/models/conversation.dart';
import 'package:ai_assistant/models/message.dart';
import 'package:ai_assistant/models/xiaozhi_config.dart';
import 'package:ai_assistant/controllers/conversation_controller.dart';
import 'package:ai_assistant/controllers/config_controller.dart';
import 'package:ai_assistant/services/xiaozhi_service.dart';
import 'package:ai_assistant/widgets/message_bubble.dart';
import 'package:ai_assistant/screens/voice_call_screen.dart';
import 'dart:async';
import 'package:ai_assistant/screens/base/kit/index.dart';

class ChatScreen extends StatefulWidget {
  final GroupChat groupConversation; //  agent_conversation,代表一个agent的对话

  const ChatScreen({super.key, required this.groupConversation});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

// 对话page的主体：
class _ChatScreenState extends State<ChatScreen> {
  final conversationControllerIns = Get.find<GroupChatController>();
  final configControllerIns = Get.find<ConfigController>();

  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  XiaozhiService? _xiaozhiService; // 保持XiaozhiService实例

  Timer? _connectionCheckTimer; // 添加定时器检查连接状态
  Timer? _autoReconnectTimer; // 自动重连定时器

  // 语音输入相关
  bool _isVoiceInputMode = false;
  bool _isRecording = false;
  bool _isCancelling = false;
  double _startDragY = 0.0;
  final double _cancelThreshold = 50.0; // 上滑超过这个距离认为是取消
  Timer? _waveAnimationTimer;
  final List<double> _waveHeights = List.filled(20, 0.0);
  double _minWaveHeight = 5.0;
  double _maxWaveHeight = 30.0;
  final Random _random = Random();

  @override
  void initState() {
    super.initState(); // 框架要求，必须这样写

    // 设置状态栏为透明并使图标为黑色
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
    );

    // 在帧绘制后再次设置系统UI样式，避免被覆盖
    // 使用 addPostFrameCallback：在第一帧绘制完成后再执行一次设置
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: Brightness.dark,
          systemNavigationBarDividerColor: Colors.transparent,
        ),
      );

      // 编辑该会话ID已读
      conversationControllerIns.markConversationAsRead(
        widget.groupConversation.groupId,
      );

      // 如果是小智对话，初始化服务
      if (true) {
        _initXiaozhiService();
        // 添加定时器，定期检查连接状态
        // 调用方法是： Timer.periodic(Duration interval, void Function(Timer) callback)
        // (timer) { ... } 这是一种匿名函数的写法
        _connectionCheckTimer = Timer.periodic(const Duration(seconds: 2), (
          timer,
        ) {
          // mounted，widget提供的属性，判断自己是否已经 挂在了widget树上
          if (mounted && _xiaozhiService != null) {
            final wasConnected = _xiaozhiService!.isConnected;

            // 刷新UI
            // setState是State-widget的内部函数， 一旦调用就会通知flutter重新绘制所在的widget-UI
            // 顺序是： 先调用入参的函数，然后通知flutter重新绘制UI
            setState(() {});

            // 如果状态从连接变为断开，尝试自动重连
            if (wasConnected &&
                !_xiaozhiService!.isConnected &&
                _autoReconnectTimer == null) {
              print('检测到连接断开，准备自动重连');
              _scheduleReconnect();
            }
          }
        });

        // 默认启用语音输入模式 (针对小智对话)
        setState(() {
          _isVoiceInputMode = true;
        });
      }
    });
  }

  // 安排自动重连
  void _scheduleReconnect() {
    // 取消现有重连定时器
    _autoReconnectTimer?.cancel();

    // 创建新的重连定时器，5秒后尝试重连
    _autoReconnectTimer = Timer(const Duration(seconds: 5), () async {
      print('正在尝试自动重连...');
      if (_xiaozhiService != null && !_xiaozhiService!.isConnected && mounted) {
        try {
          await _xiaozhiService!.disconnect();
          await _xiaozhiService!.connect();

          setState(() {});
          print('自动重连 ${_xiaozhiService!.isConnected ? "成功" : "失败"}');

          // 如果重连失败，则继续尝试重连
          if (!_xiaozhiService!.isConnected) {
            _scheduleReconnect();
          } else {
            _autoReconnectTimer = null;
          }
        } catch (e) {
          print('自动重连出错: $e');
          _scheduleReconnect(); // 出错后继续尝试
        }
      } else {
        _autoReconnectTimer = null;
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    // 取消所有定时器
    _connectionCheckTimer?.cancel();
    _autoReconnectTimer?.cancel();
    _waveAnimationTimer?.cancel();
    print("我要准备销毁小智service了");
    // 在销毁前确保停止所有音频播放
    if (_xiaozhiService != null) {
      _xiaozhiService!.stopPlayback();
      _xiaozhiService!.disconnect();
      _xiaozhiService!.dispose();
      print("我要done1销毁小智service了");
    }
    print("我要done2销毁小智service了");
    super.dispose();
  }

  // 初始化小智服务
  Future<void> _initXiaozhiService() async {
    // print('agentName from conversation: ${widget.groupConversation.agentName}');
    // print('userName from conversation: ${widget.groupConversation.userName}');
    // print('agentId from conversation: ${widget.groupConversation.agentId}');

    print(
      '可用的 xiaozhi_server configs: ${configControllerIns.xiaozhiConfigs.map((c) => c.id)}',
    );
    final xiaozhiConfig = configControllerIns.xiaozhiConfigs[0];

    // 创建一个XiaozhiService实例
    _xiaozhiService = XiaozhiService(
      groupID: widget.groupConversation.groupId,
      websocketUrl: xiaozhiConfig.websocketUrl,
      macAddress: xiaozhiConfig.macAddress,
      userName: widget.groupConversation.userName,
      agentID: widget.groupConversation.groupId,
      agentName: widget.groupConversation.createHumanAgentName,
      accessToken: "kkkkhahah",
    );

    // 添加消息监听器 ---> 通知展示层，有消息来了
    _xiaozhiService!.addListener(_handleXiaozhiMessage);

    // 连接服务
    await _xiaozhiService!.connect();

    // 连接后刷新UI状态
    if (mounted) {
      setState(() {});
    }
  }

  // 处理小智消息
  void _handleXiaozhiMessage(XiaozhiServiceEvent event) {
    if (!mounted) return;

    if (event.type == XiaozhiServiceEventType.textMessage) {
      // 直接使用文本内容
      String content = event.data as String;
      print('收到消息内容: $content');

      // 忽略空消息
      if (content.isNotEmpty) {
        conversationControllerIns.addMessage(
          conversationId: widget.groupConversation.groupId,
          role: MessageRole.assistant,
          content: content,
        );
      }
    } else if (event.type == XiaozhiServiceEventType.userMessage) {
      // 处理用户的语音识别文本
      String content = event.data as String;
      print('收到用户语音识别内容: $content');

      // 只有在语音输入模式下才添加用户消息
      if (content.isNotEmpty && _isVoiceInputMode) {
        // 语音消息可能有延迟，使用Future.microtask确保UI已更新
        Future.microtask(() {
          conversationControllerIns.addMessage(
            conversationId: widget.groupConversation.groupId,
            role: MessageRole.user,
            content: content,
          );
        });
      }
    } else if (event.type == XiaozhiServiceEventType.connected ||
        event.type == XiaozhiServiceEventType.disconnected) {
      // 当连接状态发生变化时，更新UI
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    // 确保状态栏设置正确
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        toolbarHeight: 70,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: _navigateToVoiceCall,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.phone, color: Colors.black, size: 16),
                  ),
                ),
              ),
            ),
          ),
        ],
        // 前面的导航返回按钮
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 26),
          onPressed: () {
            // 返回前停止播放
            if (_xiaozhiService != null) {
              _xiaozhiService!.stopPlayback();
            }
            // 导航到home界面（上一页）
            Get.back();
          },
        ),
        title: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 0,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey.shade700,
                child: WcaoUtils.imageCache(widget.groupConversation.avator),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.groupConversation.title, // 与xx的对话
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 1,
                        spreadRadius: 0,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // 页面的主要widget组件（他们会形成大的部分）
          _buildXiaozhiInfo(), // 上面部分 （小智连接信息）
          Expanded(child: _buildMessageList()), // 中间部分（消息列表）
          _buildInputArea(), // 下面部分（信息输入区域）
        ],
      ),
    );
  }

  // 构建小智 连接信息 区域
  Widget _buildXiaozhiInfo() {
    final xiaozhiConfig = configControllerIns.xiaozhiConfigs[0];

    final bool isConnected = _xiaozhiService?.isConnected ?? false;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 连接状态指示器 一个红点/绿点
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isConnected ? Colors.green : Colors.red,
              boxShadow: [
                BoxShadow(
                  color: (isConnected ? Colors.green : Colors.red).withOpacity(
                    0.4,
                  ),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            isConnected ? '已连接' : '未连接',
            style: TextStyle(
              fontSize: 13,
              color: isConnected ? Colors.green : Colors.red,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 12),

          // 分隔线
          Container(width: 1, height: 16, color: Colors.grey.withOpacity(0.3)),
          const SizedBox(width: 12),

          // WebSocket信息
          Expanded(
            child: Text(
              '${xiaozhiConfig.websocketUrl}',
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // MAC地址信息
          if (xiaozhiConfig.macAddress.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 4,
                      spreadRadius: 0,
                      offset: const Offset(0, 1),
                    ),
                    BoxShadow(
                      color: Colors.white.withOpacity(0.9),
                      blurRadius: 3,
                      spreadRadius: 0,
                      offset: const Offset(0, -1),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.devices, size: 12, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Text(
                      '${xiaozhiConfig.macAddress}',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    // 绘制消息列表
    return Obx(() {
      // 获得该agent的所有消息
      final messages = conversationControllerIns.getMessages(
        widget.groupConversation.groupId,
      );

      if (messages.isEmpty) {
        return Center(
          child: Text(
            '开始新对话',
            style: TextStyle(color: Colors.grey.shade400, fontSize: 16),
          ),
        );
      }
      // ListView经常用于构建 长列表/聊天界面 等动态内容，是懒加载方式，只构建当前可见的列表部分
      return ListView.builder(
        controller: _scrollController, // 滚动控制器
        padding: const EdgeInsets.all(16), // 列表item的内边距，给所有 item 外围留出空白
        reverse: true, // 新消息在下面，而非上面
        itemCount: messages.length + (_isLoading ? 1 : 0), // item列表 总数
        cacheExtent: 1000.0, // 预加载范围：上下各预渲染 1000 像素范围内的 item，提升滚动流畅性
        addRepaintBoundaries: true,
        addAutomaticKeepAlives: true,
        physics: const ClampingScrollPhysics(), // 滚动效果（到边界就停，不回弹）
        itemBuilder: (context, index) {
          // 根据index动态构建item
          if (_isLoading && index == 0) {
            return MessageBubble(
              message: Message(
                messageId: 'loading',
                conversationId: '',
                role: MessageRole.assistant,
                content: '思考中...',
                timestamp: DateTime.now(),
              ),
              isThinking: true,
              avatarImgUrl: widget.groupConversation.avator,
            );
          }

          final adjustedIndex = _isLoading ? index - 1 : index;
          // 获得对应的msg
          final message = messages[messages.length - 1 - adjustedIndex];

          return RepaintBoundary(
            // 通知flutter,它包含的widget，是需要经常 重新绘制的，提升性能用
            child: MessageBubble(
              key: ValueKey(
                message.messageId,
              ), //从message.id初始化一个key，作为 listView比较多个item的id_key
              message: message,
              avatarImgUrl: widget.groupConversation.avator,
            ),
          );
        },
      );
    });
  }

  Widget _buildInputArea() {
    final bool hasText = _textController.text.trim().isNotEmpty;

    // 根据状态决定显示文本输入还是语音输入
    if (_isVoiceInputMode) {
      return _buildVoiceInputArea();
    } else {
      return _buildTextInputArea(hasText);
    }
  }

  // 文本输入区域
  Widget _buildTextInputArea(bool hasText) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        left: 16,
        top: 16,
        right: 16,
        bottom: 16 + MediaQuery.of(context).padding.bottom,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.85,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F7F9),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.07),
                  blurRadius: 8,
                  spreadRadius: 0,
                  offset: const Offset(0, 3),
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(0.8),
                  blurRadius: 5,
                  spreadRadius: 0,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      hintText: '输入消息...',
                      hintStyle: TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 16,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                    ),
                    style: const TextStyle(
                      color: Color(0xFF1F2937),
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    textInputAction: TextInputAction.send, // 发送按钮
                    onSubmitted: (_) => _sendMessage(),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                _buildSendButton(hasText),
                if (!hasText)
                  IconButton(
                    icon: const Icon(
                      Icons.mic,
                      color: Color.fromARGB(255, 108, 108, 112),
                      size: 24,
                    ),
                    onPressed: () {
                      setState(() {
                        _isVoiceInputMode = true;
                      });
                    },
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    constraints: const BoxConstraints(),
                    splashRadius: 22,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 语音输入区域
  Widget _buildVoiceInputArea() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        left: 16,
        top: 16,
        right: 16,
        bottom: 16 + MediaQuery.of(context).padding.bottom,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: GestureDetector(
              onLongPressStart: (details) {
                setState(() {
                  _isRecording = true;
                  _isCancelling = false;
                  _startDragY = details.globalPosition.dy;
                });
                _startRecording();
                _startWaveAnimation();
              },
              onLongPressMoveUpdate: (details) {
                // 计算垂直移动距离
                final double dragDistance =
                    _startDragY - details.globalPosition.dy;

                // 如果上滑超过阈值，标记为取消状态
                if (dragDistance > _cancelThreshold && !_isCancelling) {
                  setState(() {
                    _isCancelling = true;
                  });
                  // 震动反馈
                  HapticFeedback.mediumImpact();
                } else if (dragDistance <= _cancelThreshold && _isCancelling) {
                  setState(() {
                    _isCancelling = false;
                  });
                  // 震动反馈
                  HapticFeedback.lightImpact();
                }
              },
              onLongPressEnd: (details) {
                final wasRecording = _isRecording;
                final wasCancelling = _isCancelling;

                setState(() {
                  _isRecording = false;
                });

                _stopWaveAnimation();

                if (wasRecording) {
                  if (wasCancelling) {
                    _cancelRecording();
                  } else {
                    _stopRecording();
                  }
                }
              },
              child: Container(
                height: 54,
                decoration: BoxDecoration(
                  color:
                      _isRecording
                          ? _isCancelling
                              ? Colors.red.shade50
                              : Colors.blue.shade50
                          : const Color(0xFFF5F7F9),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.07),
                      blurRadius: 8,
                      spreadRadius: 0,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // 波纹动画效果
                    if (_isRecording && !_isCancelling)
                      _buildWaveAnimationIndicator(),

                    // 文字提示
                    Center(
                      child: Text(
                        _isRecording
                            ? _isCancelling
                                ? "松开手指，取消发送"
                                : "松开发送，上滑取消"
                            : "按住说话",
                        style: TextStyle(
                          color:
                              _isRecording
                                  ? _isCancelling
                                      ? Colors.red
                                      : Colors.blue.shade700
                                  : const Color.fromARGB(255, 9, 9, 9),
                          fontSize: 16,
                          fontWeight:
                              _isRecording
                                  ? FontWeight.w500
                                  : FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // 键盘按钮 (切换回文本模式)
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  spreadRadius: 0,
                  offset: const Offset(0, 2),
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(0.8),
                  blurRadius: 4,
                  spreadRadius: 0,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              shape: CircleBorder(),
              child: InkWell(
                borderRadius: BorderRadius.circular(25),
                onTap: () {
                  // 如果正在录音，先取消录音
                  if (_isRecording) {
                    _cancelRecording();
                    _stopWaveAnimation();
                  }
                  // 切换回文本输入模式
                  setState(() {
                    _isVoiceInputMode = false;
                    _isRecording = false;
                    _isCancelling = false;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Icon(
                    Icons.keyboard,
                    color: Colors.grey.shade700,
                    size: 22,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSendButton(bool hasText) {
    return IconButton(
      key: const ValueKey('send_button'),
      icon: Icon(
        Icons.send_rounded,
        color: hasText ? Colors.black : const Color(0xFFC4C9D2),
        size: 24,
      ),
      onPressed: hasText ? _sendMessage : null,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      constraints: const BoxConstraints(),
      splashRadius: 22,
    );
  }

  // 开始录音
  void _startRecording() async {
    // if (widget.conversation.type != ConversationType.xiaozhi ||
    //     _xiaozhiService == null) {
    //   _showCustomSnackbar('语音功能仅适用于小智对话');
    //   setState(() {
    //     _isVoiceInputMode = false;
    //   });
    //   return;
    // }

    try {
      // 震动反馈
      HapticFeedback.mediumImpact();

      // 开始录音
      await _xiaozhiService!.startListening();
    } catch (e) {
      print('开始录音失败: $e');
      _showCustomSnackbar('无法开始录音: ${e.toString()}');
      setState(() {
        _isRecording = false;
        _isVoiceInputMode = false;
      });
    }
  }

  // 停止录音并发送
  void _stopRecording() async {
    try {
      setState(() {
        _isLoading = true;
        _isRecording = false;
        // 不要立即关闭语音输入模式，让用户可以看到识别结果
        // _isVoiceInputMode = false;
      });

      // 震动反馈
      HapticFeedback.mediumImpact();

      // 停止录音
      await _xiaozhiService?.stopListening();

      _scrollToBottom();
    } catch (e) {
      print('停止录音失败: $e');
      _showCustomSnackbar('语音发送失败: ${e.toString()}');

      // 出错时关闭语音输入模式
      setState(() {
        _isVoiceInputMode = false;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 取消录音
  void _cancelRecording() async {
    try {
      setState(() {
        _isRecording = false;
      });

      // 震动反馈
      HapticFeedback.heavyImpact();

      // 取消录音
      await _xiaozhiService?.abortListening();

      // 使用自定义的拟物化提示，显示在顶部且带有圆角
      _showCustomSnackbar('已取消发送');
    } catch (e) {
      print('取消录音失败: $e');
    }
  }

  // 显示自定义Snackbar
  void _showCustomSnackbar(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    final snackBar = SnackBar(
      content: Text(
        message,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.black.withOpacity(0.7),
      duration: const Duration(seconds: 2),
      margin: EdgeInsets.only(
        bottom: MediaQuery.of(context).size.height - 120,
        left: 16,
        right: 16,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  // 向着服务器发送msg
  void _sendMessage() async {
    final message = _textController.text.trim(); // 获取输入框中的文本
    if (message.isEmpty || _isLoading) return;

    _textController.clear();

    // Add user message
    await conversationControllerIns.addMessage(
      conversationId: widget.groupConversation.groupId,
      role: MessageRole.user,
      content: message,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    _scrollToBottom();

    try {
      // 确保服务已连接
      if (_xiaozhiService == null) {
        await _initXiaozhiService();
      } else if (!_xiaozhiService!.isConnected) {
        // 如果未连接，尝试重新连接
        print('聊天屏幕: 服务未连接，尝试重新连接');
        await _xiaozhiService!.connect();

        // 如果重连失败，提示用户
        if (!_xiaozhiService!.isConnected) {
          throw Exception("无法连接到小智服务，请检查网络或服务配置");
        }

        // 刷新UI显示连接状态
        setState(() {});
      }

      // 向着服务器发送msg消息
      await _xiaozhiService!.sendTextMessage(message);
    } catch (e) {
      print('聊天屏幕: 发送消息错误: $e');

      if (!mounted) return;

      // Add error message
      await conversationControllerIns.addMessage(
        conversationId: widget.groupConversation.groupId,
        role: MessageRole.assistant,
        content: '发生错误: ${e.toString()}',
      );
    } finally {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _navigateToVoiceCall() {
    final xiaozhiConfig = configControllerIns.xiaozhiConfigs[0];

    // 导航前停止当前音频播放
    if (_xiaozhiService != null) {
      _xiaozhiService!.stopPlayback();
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => VoiceCallScreen(
              conversation: widget.groupConversation,
              xiaozhiConfig: xiaozhiConfig,
            ),
      ),
    ).then((_) {
      // 页面返回后，确保重新初始化服务以恢复正常对话功能
      if (_xiaozhiService != null) {
        // 重新连接服务
        _xiaozhiService!.connect();
      }
    });
  }

  // 启动波形动画
  void _startWaveAnimation() {
    _waveAnimationTimer?.cancel();
    _waveAnimationTimer = Timer.periodic(const Duration(milliseconds: 100), (
      timer,
    ) {
      if (_isRecording && !_isCancelling) {
        setState(() {
          for (int i = 0; i < _waveHeights.length; i++) {
            _waveHeights[i] = 0.5 + _random.nextDouble() * 0.5;
          }
        });
      }
    });
  }

  // 停止波形动画
  void _stopWaveAnimation() {
    _waveAnimationTimer?.cancel();
    _waveAnimationTimer = null;
  }

  // 构建波形动画指示器
  Widget _buildWaveAnimationIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(
          16,
          (index) => AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            width: 3,
            height: 20 * _waveHeights[index],
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.6),
              borderRadius: BorderRadius.circular(1.5),
            ),
            curve: Curves.easeInOut,
          ),
        ),
      ),
    );
  }
}
