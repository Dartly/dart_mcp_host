

// import 'package:langchain/langchain.dart';
// import 'package:langchain_chroma/langchain_chroma.dart';
// import 'package:langchain_openai/langchain_openai.dart';
// import 'package:logging/logging.dart';

// void main() async {
//   // Initialize logging
//   Logger.root.level = Level.INFO;
//   Logger.root.onRecord.listen((record) {
//     print('${record.time}: ${record.level.name}: ${record.message}');
//   });
  
//   final log = Logger('VectorStoreExample');
//   // final client = OpenAIClient(
//   //   apiKey: 'sk-vmpbsmqzbiaxyhnzgsfqgasguziwmnghuyrizlznnmrgncua',
//   //   baseUrl: 'https://api.siliconflow.cn/v1/',
//   // );

//   // final res = await client.createEmbedding(
//   //   request: CreateEmbeddingRequest(
//   //     model: EmbeddingModel.modelId('BAAI/bge-large-zh-v1.5'),
//   //     input: EmbeddingInput.string('The food was delicious and the waiter...'),
//   //   ),
//   // );
//   // print(res.data.first.embeddingVector);

//   log.info('Initializing OpenAI embeddings...');
//   final embeddings = OpenAIEmbeddings(
//     apiKey: 'sk-vmpbsmqzbiaxyhnzgsfqgasguziwmnghuyrizlznnmrgncua',
//     baseUrl: 'https://api.siliconflow.cn/v1/',
//     model: 'BAAI/bge-large-zh-v1.5',
//   );
//   log.info('OpenAI embeddings initialized successfully.');
//   log.info('Connecting to Chroma vector store...');
//   final vectorStore = Chroma(embeddings: embeddings,
//     baseUrl: 'http://database-chroma-7jhbmr-811d26-149-104-25-116.traefik.me'
//   );
//   log.info('Connected to Chroma vector store successfully.');

//   log.info('Adding documents to vector store...');
//   // 批量添加结构化的MCP服务信息，包含丰富的元数据
//   await vectorStore.addDocuments(
//     documents: const [
//       Document(
//         id: 'get_localtion',
//         pageContent: '获取当前位置信息，包括经纬度、地址等。',
//         metadata: {
//           'service': 'location',
//           'endpoint': '/current',
//           'description': '获取当前位置信息',
//           'category': '位置',
//         },
//       ),
//   //     Document(
//   //       id: 'weather_forecast',
//   //       pageContent: '获取指定城市未来15天的天气预报，包含白天和夜间的天气状况、温度等信息。',
//   //       metadata: {
//   //         'service': 'weather',
//   //         'endpoint': '/forecast',
//   //         'parameters': ['city', 'days'],
//   //         'description': '获取未来天气预报',
//   //         'category': '天气',
//   //       },
//   //     ),
//   //     Document(
//   //       id: 'weather_alert',
//   //       pageContent: '获取指定城市的气象灾害预警信息。',
//   //       metadata: {
//   //         'service': 'weather',
//   //         'endpoint': '/alert',
//   //         'parameters': ['city'],
//   //         'description': '获取气象灾害预警',
//   //         'category': '天气',
//   //       },
//   //     ),
//   //     Document(
//   //       id: 'air_quality',
//   //       pageContent: '获取指定城市的空气质量信息，包括AQI、PM2.5、PM10等。',
//   //       metadata: {
//   //         'service': 'air',
//   //         'endpoint': '/quality',
//   //         'parameters': ['city'],
//   //         'description': '获取空气质量',
//   //         'category': '环境',
//   //       },
//   //     ),
//   //     Document(
//   //       id: 'weather_history',
//   //       pageContent: '获取指定城市过去24小时历史天气。',
//   //       metadata: {
//   //         'service': 'weather',
//   //         'endpoint': '/history',
//   //         'parameters': ['city', 'hours'],
//   //         'description': '获取历史天气',
//   //         'category': '天气',
//   //       },
//   //     ),
//   //     // 可继续添加更多服务
//     ],
//   );

//   log.info('Documents added successfully.');

//   // Query the vector store
//   log.info('Performing similarity search with query: "北京明天会下雨吗?"');
//   final res = await vectorStore.similaritySearch(
//     query: '现在天气怎么样?',
//     config: const ChromaSimilaritySearch(
//       k: 2,
//       scoreThreshold: 0.4,
//     ),
//   );
//   log.info('Similarity search completed.');
//   log.info('Search results: $res');
// }
