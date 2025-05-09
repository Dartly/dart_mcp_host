import 'dart:async';
import 'dart:convert';
import 'package:logging/logging.dart' as logging;
import 'package:mcp_client/mcp_client.dart';

/// MCP 客户端抽象基类
abstract class BaseMCPClient {
  Client? mcpClient;
  final String name;
  final String version;
  final Map<String, String>? headers;
  final logging.Logger log;

  BaseMCPClient({
    required this.name,
    required this.version,
    this.headers,
    required String loggerName,
  }) : log = logging.Logger(loggerName);

  /// 初始化 MCP 客户端
  Future<void> initialize() async {
    log.info('Initializing $runtimeType with name: $name, version: $version');
    mcpClient ??= McpClient.createClient(
      name: name,
      version: version,
      capabilities: ClientCapabilities(
        roots: true,
        rootsListChanged: true,
        sampling: true,
      ),
    );
    log.info('MCP client created successfully');

    await createTransportAndConnect();
  }

  /// 创建传输并连接（由子类实现）
  Future<void> createTransportAndConnect();

  /// 列出可用工具
  Future<List<Tool>?> listTools() async {
    log.info('Listing available tools from MCP server');
    final tools = await mcpClient?.listTools();
    log.info('Retrieved ${tools?.length ?? 0} tools from server');
    return tools;
  }

  /// 调用工具
  Future<CallToolResult?> callTool(
    String name,
    Map<String, dynamic> toolArguments,
  ) async {
    log.info('Calling tool: $name');
    try {
      final result = await mcpClient?.callTool(name, toolArguments);
      log.info('Tool call completed successfully: $name');
      return result;
    } catch (e) {
      log.severe('Error calling tool $name: $e');
      return null;
    }
  }

  /// 列出可用提示词
  Future<List<Prompt>?> listPrompts() async {
    log.info('Listing available prompts from MCP server');
    final prompts = await mcpClient?.listPrompts();
    log.info('Retrieved ${prompts?.length ?? 0} prompts from server');
    return prompts;
  }

  /// 获取提示词
  Future<GetPromptResult?> getPrompt(
    String name, [
    Map<String, dynamic>? promptArguments,
  ]) async {
    log.info('Getting prompt: $name');
    try {
      final prompt = await mcpClient?.getPrompt(name, promptArguments);
      log.info(
        'Prompt retrieved successfully: $name promptArguments:${json.encode(promptArguments)}',
      );
      return prompt;
    } catch (e) {
      log.severe('Error getting prompt $name: $e');
    }
    return null;
  }

  /// 关闭客户端连接
  void disconnect() {
    log.info('Disconnecting from MCP server');
    mcpClient?.disconnect();
  }
}
