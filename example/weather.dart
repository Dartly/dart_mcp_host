import 'dart:async';
import 'dart:io';
import 'package:mcp_server/mcp_server.dart';

final Logger _logger = Logger.getLogger('weather-mcp');

void main(List<String> args) async {
  _logger.setLevel(LogLevel.debug);

  int port = 8990;
  await startMcpServer(mode: 'sse', port: port);
}

Future<void> startMcpServer({required String mode, int port = 8080}) async {
  try {
    // Create server with capabilities
    final server = McpServer.createServer(
      name: 'Weather MCP Server',
      version: '1.0.0',
      capabilities: ServerCapabilities(
        tools: true,
        toolsListChanged: true,
        resources: true,
        resourcesListChanged: true,
        prompts: true,
        promptsListChanged: true,
      ),
    );

    _registerTools(server);

    // Create transport based on mode
    ServerTransport transport;

    _logger.debug('Starting server in SSE mode on port $port');
    transport = McpServer.createSseTransport(
      endpoint: '/sse',
      messagesEndpoint: '/message',
      port: port,
      fallbackPorts: [
        port + 1,
        port + 2,
        port + 3,
      ], // Try additional ports if needed
    );

    // Set up transport closure handling
    transport.onClose.then((_) {
      _logger.debug('Transport closed, shutting down.');
      exit(0);
    });

    // Connect server to transport
    server.connect(transport);

    // Send initial log message
    server.sendLog(McpLogLevel.info, 'Flutter MCP Server started successfully');

    _logger.debug('SSE Server is running on:');
    _logger.debug('- SSE endpoint:     http://localhost:$port/sse');
    _logger.debug('- Message endpoint: http://localhost:$port/message');
    _logger.debug('Press Ctrl+C to stop the server');
  } catch (e, stackTrace) {
    _logger.debug('Error initializing MCP server: $e');
    _logger.debug(stackTrace as String);
    exit(1);
  }
}

void _registerTools(Server server) {
  // Hello world tool
  // server.addTool(
  //   name: 'hello',
  //   description: 'Says hello to someone',
  //   inputSchema: {
  //     'type': 'object',
  //     'properties': {
  //       'name': {'type': 'string', 'description': 'Name to say hello to'},
  //     },
  //     'required': [],
  //   },
  //   handler: (args) async {
  //     final name = args['name'] ?? 'world';
  //     return CallToolResult([TextContent(text: 'Hello, $name!')]);
  //   },
  // );

  // // Calculator tool
  // server.addTool(
  //   name: 'calculator',
  //   description: 'Perform basic arithmetic operations',
  //   inputSchema: {
  //     'type': 'object',
  //     'properties': {
  //       'operation': {
  //         'type': 'string',
  //         'enum': ['add', 'subtract', 'multiply', 'divide'],
  //         'description': 'Mathematical operation to perform',
  //       },
  //       'a': {'type': 'number', 'description': 'First operand'},
  //       'b': {'type': 'number', 'description': 'Second operand'},
  //     },
  //     'required': ['operation', 'a', 'b'],
  //   },
  //   handler: (args) async {
  //     final operation = args['operation'] as String;
  //     final a =
  //         (args['a'] is int)
  //             ? (args['a'] as int).toDouble()
  //             : args['a'] as double;
  //     final b =
  //         (args['b'] is int)
  //             ? (args['b'] as int).toDouble()
  //             : args['b'] as double;

  //     double result;
  //     switch (operation) {
  //       case 'add':
  //         result = a + b;
  //         break;
  //       case 'subtract':
  //         result = a - b;
  //         break;
  //       case 'multiply':
  //         result = a * b;
  //         break;
  //       case 'divide':
  //         if (b == 0) {
  //           throw McpError('Cannot divide by zero');
  //         }
  //         result = a / b;
  //         break;
  //       default:
  //         throw McpError('Unknown operation: $operation');
  //     }

  //     return CallToolResult([TextContent(text: 'Result: $result')]);
  //   },
  // );

  // Date and time tool
  // Date and time tool
  server.addTool(
    name: 'currentDateTime',
    description: 'Get the current date and time',
    inputSchema: {
      'type': 'object',
      'properties': {
        'format': {
          'type': 'string',
          'description': 'Output format (full, date, time)',
          'default': 'full',
        },
      },
      'required': [],
    },
    handler: (args) async {
      try {
        _logger.debug("[DateTime Tool] Received args: $args");

        String format;
        if (args['format'] == null) {
          format = 'full';
        } else if (args['format'] is String) {
          format = args['format'] as String;
        } else {
          format = args['format'].toString();
        }

        _logger.debug("[DateTime Tool] Using format: $format");

        final now = DateTime.now();
        _logger.debug("[DateTime Tool] Current DateTime: $now");

        String result;
        switch (format) {
          case 'date':
            result =
                '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
            break;
          case 'time':
            try {
              final hour = now.hour.toString().padLeft(2, '0');
              final minute = now.minute.toString().padLeft(2, '0');
              final second = now.second.toString().padLeft(2, '0');
              result = '$hour:$minute:$second';
            } catch (e) {
              _logger.debug("[DateTime Tool] Error formatting time: $e");
              result = "Error formatting time: $e";
            }
            break;
          case 'full':
          default:
            try {
              result = now.toIso8601String();
            } catch (e) {
              _logger.debug("[DateTime Tool] Error with ISO format: $e");
              result =
                  "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} " +
                  "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";
            }
            break;
        }

        _logger.debug("[DateTime Tool] Result: $result");
        return CallToolResult([TextContent(text: result)]);
      } catch (e, stackTrace) {
        _logger.debug("[DateTime Tool] Unexpected error: $e");
        _logger.debug("[DateTime Tool] Stack trace: $stackTrace");
        return CallToolResult([
          TextContent(text: "Error getting date/time: $e"),
        ], isError: true);
      }
    },
  );
}

