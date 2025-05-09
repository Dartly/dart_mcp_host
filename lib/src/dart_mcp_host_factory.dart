import 'package:dart_mcp_host/src/config/mcp_config.dart';
import 'package:dart_mcp_host/src/dart_mcp_host.dart';
import 'package:logging/logging.dart' as logging;

/// MCP主机工厂类
/// 提供从配置文件创建MCP主机实例的方法
class DartMCPHostFactory {
  static final logging.Logger _log = logging.Logger('MCPHostFactory');

  /// 从默认配置文件创建MCP主机实例
  /// 
  /// 如果未指定配置文件路径，将使用默认路径（用户主目录下的.mcp.json）
  static Future<DartMCPHost> createFromConfigFile([String? configPath]) async {
    _log.info('Creating MCPHost from config file: ${configPath ?? "<default>"}');
    final config = await MCPConfigManager.loadConfig(configPath);
    _log.info('Loaded configuration with ${config.servers.length} servers');
    return DartMCPHost(config: config);
  }

  /// 从指定工作目录的配置文件创建MCP主机实例
  /// 
  /// [workingDirectory] 工作目录路径
  /// [configFileName] 配置文件名，默认为.mcp.json
  static Future<DartMCPHost> createFromWorkingDirectory(
    String workingDirectory, {
    String configFileName = MCPConfigManager.defaultConfigFileName,
  }) async {
    final configPath = '$workingDirectory/$configFileName';
    _log.info('Creating MCPHost from working directory config: $configPath');
    return createFromConfigFile(configPath);
  }
}