import 'package:dart_mcp_host/src/config/mcp_config.dart';
import 'package:dart_mcp_host/src/client/base_client.dart';
import 'package:dart_mcp_host/src/client/sse_mcp_client.dart';
import 'package:dart_mcp_host/src/client/stdio_mcp_client.dart';

/// 客户端工厂类
class McpClientFactory {
  static BaseMCPClient createClient(ServerConfig config) {
    if (config is SseServerConfig) {
      return SseMCPClient(
        serverUrl: config.url,
        headers: config.headers != null
            ? Map<String, String>.fromEntries(
                config.headers!.map((e) => MapEntry(e, '')),
              )
            : null,
      );
    } else if (config is StdioServerConfig) {
      return StdioMCPClient(
        command: config.command,
        args: config.args,
        env: config.env,
      );
    } else {
      throw UnsupportedError('Unsupported ServerConfig type: ${config.runtimeType}');
    }
  }
}