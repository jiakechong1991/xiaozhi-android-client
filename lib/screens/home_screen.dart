import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:ai_assistant/providers/conversation_provider.dart';
import 'package:ai_assistant/models/conversation.dart';
import 'package:ai_assistant/screens/chat_screen.dart';
import 'package:ai_assistant/screens/settings_screen.dart';
// import 'package:ai_assistant/screens/conversation_type_screen.dart';
import 'package:ai_assistant/screens/conversation_create.dart';
import 'package:ai_assistant/widgets/conversation_tile.dart';
import 'package:ai_assistant/widgets/slidable_delete_tile.dart';
import 'package:ai_assistant/widgets/discovery_screen.dart';
import 'package:ai_assistant/state/token.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // 当前选中的底部导航栏索引
  final FocusNode _searchFocusNode = FocusNode(); // 搜索框焦点管理器

  void _checkToken(String token) {
    if (token.isEmpty) {
      print("token为空,跳转到登录页面");
      // 延迟到下一帧，避免在 initState 中直接导航的潜在问题
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.toNamed('/login/password');
      });
    } else {
      print("token有效，留在当前页面");
      // 不跳转，留在首页
    }
  }

  @override
  void initState() {
    super.initState();
    // 👇 立即检查当前 token 状态
    _checkToken(TokenController.to.token.value);

    // 👇 监听后续变化
    ever(TokenController.to.token, (token) {
      _checkToken(token);
    });
  }

  @override
  void dispose() {
    _searchFocusNode.dispose(); // 释放焦点管理器
    super.dispose(); // 一种内存释放？
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // 用户轻触屏幕时，调用这个函数
        // 点击页面任何地方时，让搜索框失去焦点
        _searchFocusNode.unfocus();
        // 同时关闭所有打开的删除按钮
        SlidableController.instance.closeCurrentTile();
      },
      child: Scaffold(
        extendBody: true, //让 body 内容延伸到底部导航栏下方
        extendBodyBehindAppBar: true,
        backgroundColor: const Color(0xFFF8F9FA), // 设置背景颜色
        appBar: // 顶部导航栏
            _selectedIndex == 1
                ? null
                : AppBar(
                  // 通常位于屏幕顶部，用于显示当前页面的标题和导航按钮，设置按钮等
                  title: const Text(
                    '消息哈哈1',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                      color: Colors.black,
                    ),
                  ),
                  elevation: 0, // 设置导航栏阴影
                  scrolledUnderElevation: 0, // 设置导航栏在滚动时的高度
                  backgroundColor: const Color(0xFFF8F9FA), // 设置导航栏背景颜色
                  centerTitle: false, // 设置标题是否居中
                  titleSpacing: 20, //
                  toolbarHeight: 65, // 设置导航栏的高度
                  actions: [
                    //右侧的操作按钮列表（如搜索、更多选项等）， 每个元素就是一个按钮
                    Padding(
                      // 按钮1
                      padding: const EdgeInsets.only(right: 16),
                      child: Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          splashColor: Colors.grey.withOpacity(0.1),
                          highlightColor: Colors.grey.withOpacity(0.1),
                          // 如果点击这个 齿轮符号，将导航到 这个页面
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SettingsScreen(),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Icon(
                              // 齿轮icon
                              Icons.settings,
                              size: 26,
                              color: Colors.grey.shade700,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 0.5,
                                  offset: const Offset(0, 0.5),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        body:
            _selectedIndex == 1
                ? const SafeArea(bottom: false, child: DiscoveryScreen())
                : SafeArea(
                  bottom: false,
                  child: Column(
                    children: [
                      _buildSearchBar(),
                      Expanded(child: _buildBody()),
                    ],
                  ),
                ),
        floatingActionButton: // 悬浮按钮
            _selectedIndex == 0
                ? Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        spreadRadius: 0,
                        offset: const Offset(0, 4),
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        spreadRadius: -2,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: FloatingActionButton(
                    // 这是一个圆形悬浮在界面上的按钮, 一般在右下角
                    onPressed: () {
                      // 如果点击这个按钮，将回调 这个函数
                      Navigator.push(
                        // 切换到另一个页面
                        context,
                        MaterialPageRoute(
                          // 一种Material风格过渡动画的路由（页面）
                          // 要跳转的目标页面（必须是 StatelessWidget 或 StatefulWidget）
                          builder: (context) => const ConversationTypeCreate(),
                        ),
                      );
                    },
                    backgroundColor: Colors.black, // 背景颜色
                    child: const Icon(
                      Icons.add,
                      size: 30,
                      color: Colors.white,
                    ), // 子组件，这里是一个"+"图标
                    elevation: 0, // 阴影高度，达到 按钮凸起的感觉， 0表示没有阴影
                    shape: const CircleBorder(), // 按钮的形状，这里是一个圆形
                  ),
                )
                : null,
        // 底部导航栏
        bottomNavigationBar: ClipRRect(
          //裁减圆角矩形
          borderRadius: const BorderRadius.only(
            // 圆角半径
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          //需要被裁减的子组件
          child: Theme(
            // 主题组件，可以约束子组件的样式
            data: ThemeData(
              // 这是一个主题数据配置类，可以表示 一种样式
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                    spreadRadius: 0,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).padding.bottom / 2,
                ),
                child: BottomNavigationBar(
                  currentIndex: _selectedIndex, // 当前被选中的索引
                  onTap: (index) {
                    // 点击该组件的某个item时的 回调函数， index表示被点击的索引
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  selectedItemColor: Colors.black, // 选中时的颜色
                  unselectedItemColor: Colors.grey.shade600, // 未选中时的颜色
                  showSelectedLabels: true, // 是否显示 选中时的label（文字）
                  showUnselectedLabels: true, // 是否显示 未选中时的label（文字）
                  backgroundColor: Colors.white, // 背景颜色
                  elevation: 0, // 阴影
                  type: BottomNavigationBarType.fixed,
                  // BottomNavigationBarType.fixed: 所有item的尺寸相同,适合<=3的item数量
                  // BottomNavigationBarType.shifting: 选中的item的尺寸会变大，其他会变小，适合多个item的情况
                  selectedLabelStyle: const TextStyle(
                    // 选中时的label样式(你可以实现 选中是 字体改变效果)
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    // 未选中时的label样式
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                  iconSize: 26, // item中 图标的 大小
                  items: [
                    // 底部导航栏的选项列表
                    BottomNavigationBarItem(
                      icon: Material(
                        color: Colors.transparent,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color:
                                _selectedIndex == 0
                                    ? Colors.grey.shade100
                                    : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow:
                                _selectedIndex == 0
                                    ? [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 4,
                                        spreadRadius: 0,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                    : null,
                          ),
                          child: Icon(
                            _selectedIndex == 0
                                ? Icons.chat_bubble
                                : Icons.chat_bubble_outline,
                          ),
                        ),
                      ),
                      label: '消息',
                    ),
                    BottomNavigationBarItem(
                      icon: Material(
                        color: Colors.transparent,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color:
                                _selectedIndex == 1
                                    ? Colors.grey.shade100
                                    : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow:
                                _selectedIndex == 1
                                    ? [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 4,
                                        spreadRadius: 0,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                    : null,
                          ),
                          child: Icon(
                            _selectedIndex == 1
                                ? Icons.search
                                : Icons.search_outlined,
                          ),
                        ),
                      ),
                      label: '社区',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    if (_selectedIndex == 1) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 6,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.white,
          child: TextField(
            // 文本输入框
            focusNode: _searchFocusNode, // 控制文本输入框的 焦点状态
            decoration: InputDecoration(
              // 定义文本输入框的样式
              hintText: '搜索对话', // 当输入框为空时显示的提示文字
              hintStyle: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 16,
              ), // 设置提示文字的样式
              // 在输入框左侧添加一个 搜索图标
              prefixIcon: Container(
                padding: const EdgeInsets.all(12),
                child: Icon(
                  Icons.search, // 搜索图标
                  color: Colors.grey.shade500,
                  size: 22,
                ),
              ),
              // 在输入框右侧添加一个 麦克风图标
              suffixIcon: Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(right: 4),
                child: Icon(
                  Icons.mic_none_outlined, // 麦克风图标
                  color: Colors.grey.shade500,
                  size: 22,
                ),
              ),
              filled: true,
              fillColor: Colors.white,
              focusColor: Colors.white,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    // Messages tab
    // 这是fluter中 “状态管理+动态UI构建”的 典型用法：
    // Consumer 是 provider 包提供的组件，作用是监听 ConversationProvider 中的数据变化
    // 当 ConversationProvider 中的对话数据（新增 / 删除 / 置顶状态改变）发生变化并
    //      调用 notifyListeners() 时，builder 方法会重新执行，UI 随之刷新
    return Consumer<ConversationProvider>(
      // builder回调的三个参数：
      //    context：当前上下文，
      //    provider：ConversationProvider 实例，用于获取对话数据（核心）
      //    child：可选的 “静态子组件”（这里未使用，用于优化性能）
      builder: (context, provider, child) {
        final pinnedConversations = provider.pinnedConversations; // 获取置顶对话
        final unpinnedConversations = provider.unpinnedConversations; // 获取未置顶对话

        return ListView(
          // 滚动容器
          padding: EdgeInsets.only(
            // 填充留白
            // 16是基础留白 ，MediaQuery.of(context).padding.bottom是
            // 设备底部安全区域（如全面屏的底部刘海 / 导航栏高度），避免对话项被设备边缘遮挡
            bottom: 16 + MediaQuery.of(context).padding.bottom,
          ),
          children: [
            // 这个列表是支持 条件判断的，动态确定显示哪些组件

            // 置顶对话的区域
            if (pinnedConversations.isNotEmpty) ...[
              // ... 将后面list的元素平铺到外层list中
              const Padding(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 8,
                  bottom: 8,
                ),
                child: Text(
                  '置顶对话',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                    fontSize: 15,
                    shadows: [
                      Shadow(
                        color: Color(0x40000000),
                        blurRadius: 0.5,
                        offset: Offset(0, 0.5),
                      ),
                    ],
                  ),
                ),
              ),
              // 集合展开语法... ，将list中的元素逐个展开，添加到外层list中
              // 将pinnedConversations中的元素，逐个作为conversation，然后调用
              //    _buildConversationTile(conversation)方法，返回一个组件，然后添加到列表中
              ...pinnedConversations.map(
                (conversation) => _buildConversationTile(conversation),
              ),
            ],
            // 非置顶对话的区域
            if (unpinnedConversations.isNotEmpty) ...[
              Padding(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: pinnedConversations.isEmpty ? 8 : 16,
                  bottom: 8,
                ),
                child: const Text(
                  '全部对话',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                    fontSize: 15,
                    shadows: [
                      Shadow(
                        color: Color(0x40000000),
                        blurRadius: 0.5,
                        offset: Offset(0, 0.5),
                      ),
                    ],
                  ),
                ),
              ),
              ...unpinnedConversations.map(
                (conversation) => _buildConversationTile(conversation),
              ),
            ],
            // 如果为空，显示的区域
            if (pinnedConversations.isEmpty && unpinnedConversations.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(64.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              spreadRadius: 0,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.chat_bubble_outline, // 对话图标
                          size: 48,
                          color: Colors.grey.shade300,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        '没有对话',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade500,
                          shadows: const [
                            Shadow(
                              color: Color(0x40000000),
                              blurRadius: 0.5,
                              offset: Offset(0, 0.5),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 5,
                              spreadRadius: 0,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.add_circle_outline,
                              size: 18,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '点击 + 创建新对话',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildConversationTile(Conversation conversation) {
    return SlidableDeleteTile(
      // 这是一个封装了 滑动删除功能的 组件
      key: Key(conversation.id), // 为每个对话项设置唯一标识
      // 滑动删除的回调函数
      onDelete: () {
        // 删除对话
        Provider.of<ConversationProvider>(
          context,
          listen: false,
        ).deleteConversation(conversation.id);

        // 显示撤销消息
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${conversation.title} 已删除'),
            backgroundColor: Colors.grey.shade800,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
            margin: EdgeInsets.only(bottom: 70, left: 20, right: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            action: SnackBarAction(
              label: '撤销',
              textColor: Colors.white,
              onPressed: () {
                // 恢复被删除的对话
                Provider.of<ConversationProvider>(
                  context,
                  listen: false,
                ).restoreLastDeletedConversation();
              },
            ),
          ),
        );
      },
      // 点击的回调函数
      onTap: () {
        // 直接导航到聊天页面
        Navigator.push(
          // 将一个新的页面push到栈顶部,作为显示页面
          context,
          // 这是一个路由包装器，定义了 新页面，以及页面切换的过渡动画(提供符合 Material Design 风格的页面过渡动画)
          MaterialPageRoute(
            // builder 是一个函数，用于定义 新页面的内容()
            builder: (context) => ChatScreen(conversation: conversation),
          ),
        );
      },
      // 长按的回调函数
      onLongPress: () {
        // 显示置顶等选项
        _showConversationOptions(conversation);
      },
      child: ConversationTile(
        conversation: conversation,
        onTap: null, // 不再需要处理点击
        onLongPress: null, // 不再需要处理长按
      ),
    );
  }

  void _showConversationOptions(Conversation conversation) {
    // showModalBottomSheet 是 Flutter 用于显示底部弹窗的[官方方法]，
    //    函数通过配置其参数和构建弹窗内容，实现了美观且交互友好的操作菜单
    showModalBottomSheet(
      context: context, // 上下文
      backgroundColor: Colors.white, // 弹窗背景色
      elevation: 20, // 弹窗阴影高度
      barrierColor: Colors.black.withOpacity(0.5), // 遮罩层颜色
      shape: const RoundedRectangleBorder(
        // 弹窗形状
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 5,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 1,
                      spreadRadius: 0,
                      offset: const Offset(0, 0.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 10,
                        spreadRadius: 0,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 4,
                      ),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 4,
                              spreadRadius: 0,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          conversation.isPinned
                              ? Icons.push_pin
                              : Icons.push_pin_outlined,
                          color: Colors.black,
                          size: 24,
                        ),
                      ),
                      title: Text(
                        conversation.isPinned ? '取消置顶' : '置顶对话',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        Provider.of<ConversationProvider>(
                          context,
                          listen: false,
                        ).togglePinConversation(conversation.id);
                      },
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 10,
                        spreadRadius: 0,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 4,
                      ),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.1),
                              blurRadius: 4,
                              spreadRadius: 0,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.delete,
                          color: Colors.red,
                          size: 24,
                        ),
                      ),
                      title: const Text(
                        '删除对话',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                        ),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      onTap: () {
                        // 关闭对话框, pop(context)会将当前页面从堆栈中移除，相当于关闭这个页面/弹窗。
                        //     将之后的栈顶 弹窗/页面 显示出俩
                        Navigator.pop(context);
                        // 从全局状态中获取 ConversationProvider 实例
                        Provider.of<ConversationProvider>(
                          context,
                          listen: false, // 只获取实例并调用方法，不监听状态变化，
                          // 这个ListTile-widget就不要 在更新自己的UI了。因为此刻仅关注数据变化，不关注UI变换
                        ).deleteConversation(conversation.id); //从数据源中移除该对话
                        // 显示一个 SnackBar，告知用户对话已删除
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${conversation.title} 已删除'),
                            backgroundColor: Colors.grey.shade800,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}
