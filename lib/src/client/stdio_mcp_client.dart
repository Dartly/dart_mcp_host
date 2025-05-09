import 'package:dart_mcp_host/src/client/base_client.dart';
import 'package:mcp_client/mcp_client.dart';

class StdioMCPClient extends BaseMCPClient {
  final String command;
  final List<String> args;
  final Map<String, String>? env;

  StdioMCPClient({
    required this.command,
    required this.args,
    super.name = 'example client',
    super.version = '1.0.0',
    super.headers,
    this.env = const {},
  }) : super(loggerName: 'StdioMCPClient');

  @override
  Future<void> createTransportAndConnect() async {
    log.info('Creating stdio transport with command: $command, args: $args');
    final transport = await McpClient.createStdioTransport(
      command: command,
      arguments: args,
      environment: env,
    );
    log.info('Stdio transport created successfully');

    log.info('Connecting to MCP server...');
    await mcpClient?.connect(transport);
    log.info('Connected to MCP server successfully');
  }
}
