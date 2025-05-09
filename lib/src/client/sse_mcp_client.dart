import 'dart:convert';

import 'package:dart_mcp_host/src/client/base_client.dart';
import 'package:mcp_client/mcp_client.dart';

class SseMCPClient extends BaseMCPClient {
  final String serverUrl;

  SseMCPClient({
    required this.serverUrl,
    super.name = 'example client',
    super.version = '1.0.0',
    super.headers,
  }) : super(
         loggerName: 'SseMCPClient',
       );

  @override
  Future<void> createTransportAndConnect() async {
    log.info('Creating SSE transport with serverUrl: $serverUrl');
    final transport = await McpClient.createSseTransport(
      serverUrl: serverUrl,
      headers: headers,
    );
    log.info('SSE transport created successfully');

    log.info('Connecting to MCP server...');
    await mcpClient?.connect(transport);
    await Future.delayed(Duration(seconds: 1));
    log.info('Connected to MCP server successfully');
  }

  @override
  Future<CallToolResult?> callTool(
    String name,
    Map<String, dynamic> toolArguments,
  ) async {
    log.info(
      'Calling tool: $name with arguments: ${json.encode(toolArguments)}',
    );
    try {
      final result = await mcpClient?.callTool(name, toolArguments);
      log.info('Tool call completed successfully: $name');
      return result;
    } catch (e) {
      log.severe('Error calling tool $name: $e');
    }
    return null;
  }
}
