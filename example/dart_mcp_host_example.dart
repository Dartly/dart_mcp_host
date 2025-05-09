import 'dart:convert';

import 'package:dart_mcp_host/dart_mcp_host.dart';
import 'package:logging/logging.dart';

void main() async {
  Logger.root.level = Level.INFO;
  Logger.root.onRecord.listen((record) {
    print('${record.time}: ${record.level.name}: ${record.message}');
  });

  final log = Logger('MCPHostExample');
  log.info('Initializing MCPHost...');
  //使用配置文件加载配置
  // final config = await MCPConfigManager.loadConfig('example/.mcp.json');
  final host = DartMCPHost(
    config: MCPConfig(
      servers: {
        'Weather': SseServerConfig(
          url: 'https://mcp.api-inference.modelscope.cn/sse/46d1d90ae7984a',
        ),
        'Time': SseServerConfig(url: 'http://localhost:8999/sse'),
      },
    ),
  );
  log.info('MCPHost initialized successfully.');

  // 获取所有工具
  log.info('Getting all tools...');
  final allTools = await host.getAllTools();
  log.info('All tools: ${json.encode(allTools)}');

  // 获取所有提示词
  log.info('Getting all prompts...');
  final allPrompts = await host.getAllPrompts();
  log.info('All prompts: ${json.encode(allPrompts)}');

  //调用工具示例
  log.info('Calling tool...');
  final result = await host.callTool('Weather', 'get-weather', {
    'location': '116.40,39.90',
    'day': 'now',
  });
  log.info('Tool call result: ${json.encode(result)}');

  //调用提示词示例 - 获取提示词元数据
  log.info('Getting prompt metadata...');
  final promptName = 'greeting';
  try {
    final promptResult = await host.getPrompt('Time', promptName, {
      'name': 'John',
      'formal': true,
    });
    if (promptResult != null) {
      log.info('Prompt metadata: ${json.encode(promptResult.description)}');
      log.info('Prompt content: ${json.encode(promptResult.messages)}');
    } else {
      log.warning('Prompt not found: $promptName');
    }
  } catch (e) {
    log.severe('Error getting prompt: $e');
  }

  log.info('Example completed.');
}
