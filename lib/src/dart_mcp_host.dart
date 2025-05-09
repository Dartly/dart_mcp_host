import 'dart:convert';

import 'package:dart_mcp_host/src/config/mcp_config.dart';
import 'package:dart_mcp_host/src/client/base_client.dart';
import 'package:logging/logging.dart' as logging;
import 'package:mcp_client/mcp_client.dart';

import 'client/mcp_client_factory.dart';

class DartMCPHost {
  final MCPConfig config;
  final logging.Logger _log = logging.Logger('MCPHost');

  DartMCPHost({required this.config});

  /// 获取所有可用工具
  Future<Map<String, List<Tool>>> getAllTools() async {
    _log.info('Getting all available tools from configured servers');
    final Map<String, List<Tool>> allTools = {};
    for (final entry in config.servers.entries) {
      final String serverName = entry.key;
      final ServerConfig serverConfig = entry.value;
      _log.info('Creating client for server: $serverName');
      final client = await _createClient(serverConfig);
      try {
        _log.info('Initializing client for server: $serverName');
        await client.initialize();
        _log.info('Listing tools from server: $serverName');
        final tools = await client.listTools();
        allTools[serverName] = tools ?? [];
        _log.info(
          'Retrieved ${tools?.length ?? 0} tools from server: $serverName',
        );
      } catch (e) {
        _log.warning('Failed to get tools from server $serverName: $e');
        allTools[serverName] = [];
      } finally {
        _log.info('Disconnecting client for server: $serverName');
        client.disconnect();
      }
    }
    _log.info('Retrieved tools from ${allTools.length} servers');
    return allTools;
  }

  /// 客户端工厂方法
  Future<BaseMCPClient> _createClient(ServerConfig serverConfig) async {
    _log.info(
      'Creating client using factory with config type: ${serverConfig.runtimeType}',
    );
    return McpClientFactory.createClient(serverConfig);
  }

  /// 调用工具
  Future<CallToolResult?> callTool(
    String serverName,
    String toolName,
    Map<String, dynamic> arguments,
  ) async {
    _log.info('Calling tool: $toolName on server: $serverName');
    final serverConfig = config.servers[serverName];
    if (serverConfig == null) {
      _log.severe('Server not found: $serverName');
      throw Exception('Server not found: $serverName');
    }
    _log.info('Creating client for server: $serverName');
    final client = await _createClient(serverConfig);
    try {
      _log.info('Initializing client for server: $serverName');
      await client.initialize();
      _log.info(
        'Executing tool call: $toolName with arguments: ${json.encode(arguments)}',
      );
      final result = await client.callTool(toolName, arguments);
      _log.info('Tool call completed:$toolName  result:${json.encode(result)}');
      return result;
    } catch (e) {
      _log.severe('Error calling tool $toolName on server $serverName: $e');
      rethrow;
    } finally {
      _log.info('Disconnecting client for server: $serverName');
      client.disconnect();
    }
  }

  /// 获取所有可用提示词
  Future<Map<String, List<Prompt>>> getAllPrompts() async {
    _log.info('Getting all available prompts from configured servers');
    final Map<String, List<Prompt>> allPrompts = {};
    for (final entry in config.servers.entries) {
      final String serverName = entry.key;
      final ServerConfig serverConfig = entry.value;
      _log.info('Creating client for server: $serverName');
      final client = await _createClient(serverConfig);
      try {
        _log.info('Initializing client for server: $serverName');
        await client.initialize();
        _log.info('Listing prompts from server: $serverName');
        final prompts = await client.listPrompts();
        allPrompts[serverName] = prompts ?? [];
        _log.info(
          'Retrieved ${prompts?.length ?? 0} prompts from server: $serverName',
        );
      } catch (e) {
        _log.warning('Failed to get prompts from server $serverName: $e');
        allPrompts[serverName] = [];
      } finally {
        _log.info('Disconnecting client for server: $serverName');
        client.disconnect();
      }
    }
    _log.info('Retrieved prompts from ${allPrompts.length} servers');
    return allPrompts;
  }

  /// 获取提示词
  Future<GetPromptResult?> getPrompt(
    String serverName,
    String promptName, [
    Map<String, dynamic>? promptArguments,
  ]) async {
    _log.info('Getting prompt: $promptName from server: $serverName');
    final serverConfig = config.servers[serverName];
    if (serverConfig == null) {
      _log.severe('Server not found: $serverName');
      throw Exception('Server not found: $serverName');
    }
    _log.info('Creating client for server: $serverName');
    final client = await _createClient(serverConfig);
    try {
      _log.info('Initializing client for server: $serverName');
      await client.initialize();
      final result = await client.getPrompt(promptName, promptArguments);
      _log.info('Prompt retrieved: $promptName');
      return result;
    } catch (e) {
      _log.severe(
        'Error getting prompt $promptName from server $serverName: $e',
      );
      rethrow;
    } finally {
      _log.info('Disconnecting client for server: $serverName');
      client.disconnect();
    }
  }
}
