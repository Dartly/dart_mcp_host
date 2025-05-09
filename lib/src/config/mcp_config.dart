import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;

/// MCP 配置
class MCPConfig {
  final Map<String, ServerConfig> servers;

  MCPConfig({required this.servers});

  factory MCPConfig.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> serversJson = json['mcpServers'] ?? {};
    final Map<String, ServerConfig> servers = {};

    serversJson.forEach((key, value) {
      if (value.containsKey('url')) {
        servers[key] = SseServerConfig.fromJson(value);
      } else {
        servers[key] = StdioServerConfig.fromJson(value);
      }
    });

    return MCPConfig(servers: servers);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> serversJson = {};

    servers.forEach((key, value) {
      serversJson[key] = value.toJson();
    });

    return {'mcpServers': serversJson};
  }
}

/// 服务器配置接口
abstract class ServerConfig {
  String get type;
  Map<String, dynamic> toJson();
}

/// STDIO 服务器配置
class StdioServerConfig implements ServerConfig {
  final String command;
  final List<String> args;
  final Map<String, String>? env;

  StdioServerConfig({required this.command, this.args = const [], this.env});

  @override
  String get type => 'stdio';

  factory StdioServerConfig.fromJson(Map<String, dynamic> json) {
    return StdioServerConfig(
      command: json['command'],
      args: json['args'] != null ? List<String>.from(json['args']) : [],
      env: json['env'] != null ? Map<String, String>.from(json['env']) : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> result = {'command': command, 'args': args};
    if (env != null) result['env'] = env;
    return result;
  }
}

/// SSE 服务器配置
class SseServerConfig implements ServerConfig {
  final String url;
  final List<String>? headers;

  SseServerConfig({required this.url, this.headers});

  @override
  String get type => 'sse';

  factory SseServerConfig.fromJson(Map<String, dynamic> json) {
    return SseServerConfig(
      url: json['url'],
      headers:
          json['headers'] != null ? List<String>.from(json['headers']) : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> result = {'url': url};
    if (headers != null) result['headers'] = headers;
    return result;
  }
}

/// MCP 配置管理器
class MCPConfigManager {
  static const String defaultConfigFileName = '.mcp.json';

  /// 加载 MCP 配置
  static Future<MCPConfig> loadConfig([String? configPath]) async {
    final String filePath = configPath ?? _getDefaultConfigPath();
    final File configFile = File(filePath);

    // 检查配置文件是否存在
    if (!await configFile.exists()) {
      // 创建默认配置
      final defaultConfig = MCPConfig(servers: {});
      await saveConfig(defaultConfig, filePath);
      return defaultConfig;
    }

    // 读取现有配置
    final String configData = await configFile.readAsString();
    final Map<String, dynamic> json = jsonDecode(configData);
    return MCPConfig.fromJson(json);
  }

  /// 保存 MCP 配置
  static Future<void> saveConfig(MCPConfig config, [String? configPath]) async {
    final String filePath = configPath ?? _getDefaultConfigPath();
    final File configFile = File(filePath);

    final String configData = jsonEncode(config.toJson());
    await configFile.writeAsString(configData);
  }

  static String _getDefaultConfigPath() {
    final String homeDir =
        Platform.environment['HOME'] ??
        Platform.environment['USERPROFILE'] ??
        '.';
    return path.join(homeDir, defaultConfigFileName);
  }
}
