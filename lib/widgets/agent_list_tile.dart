import 'package:flutter/material.dart';
import 'package:ai_assistant/models/conversation.dart';
import 'package:get/get.dart';
import 'package:ai_assistant/controllers/config_controller.dart';
import 'package:ai_assistant/screens/base/kit/index.dart';

// home page的联系人列表中的agentTitle
class AgentTile extends StatelessWidget {
  final AgentRole agentRole;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final configControllerIns = Get.find<ConfigController>();

  AgentTile({super.key, required this.agentRole, this.onTap, this.onLongPress});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          onLongPress: onLongPress,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                _buildAvatar(),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Text(
                                  agentRole.agentName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                _buildTypeTag(context),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  child: Icon(
                    Icons.chevron_right,
                    color: Colors.grey.shade300,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeTag(BuildContext context) {
    String label = '语音';
    // 显示小智配置名称
    final matchingConfig = configControllerIns.xiaozhiConfigs[0];
    if (matchingConfig != null) {
      label = '${matchingConfig.name}';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 12, color: Colors.purple.shade600),
      ),
    );
  }

  Widget _buildAvatar() {
    return CircleAvatar(
      radius: 24,
      backgroundColor: Colors.purple.shade400,
      child: WcaoUtils.imageCache(agentRole.avatar),
    );
  }
}
