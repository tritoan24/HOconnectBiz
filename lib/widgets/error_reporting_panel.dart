import 'package:flutter/material.dart';
import '../core/utils/app_logger.dart';
import '../core/utils/error_reporter.dart';
import '../providers/send_error_log.dart';

/// Widget hiển thị và quản lý lỗi (chỉ nên sử dụng trong môi trường phát triển)
class ErrorReportingPanel extends StatefulWidget {
  final bool showInProduction;
  
  const ErrorReportingPanel({
    Key? key,
    this.showInProduction = false,
  }) : super(key: key);

  @override
  State<ErrorReportingPanel> createState() => _ErrorReportingPanelState();
}

class _ErrorReportingPanelState extends State<ErrorReportingPanel> {
  bool _isExpanded = false;
  String _lastTestResult = '';
  bool _isLoading = false;
  List<String> _logEntries = [];
  
  @override
  Widget build(BuildContext context) {
    // Không hiển thị trong sản phẩm trừ khi được yêu cầu rõ ràng
    if (!widget.showInProduction && const bool.fromEnvironment('dart.vm.product')) {
      return const SizedBox.shrink();
    }
    
    return Positioned(
      bottom: 0,
      right: 0,
      child: SafeArea(
        child: Card(
          color: Colors.black.withOpacity(0.8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 300,
            height: _isExpanded ? 400 : 50,
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '🐞 Công cụ gỡ lỗi',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(
                        _isExpanded
                            ? Icons.keyboard_arrow_down
                            : Icons.keyboard_arrow_up,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
                if (_isExpanded) ...[
                  const SizedBox(height: 8),
                  const Divider(color: Colors.white30),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView(
                      children: [
                        _buildTestButton(),
                        const SizedBox(height: 12),
                        _buildSimulateErrorButtons(),
                        const SizedBox(height: 12),
                        _buildLogViewer(),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildTestButton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton(
          onPressed: _isLoading
              ? null
              : () async {
                  setState(() {
                    _isLoading = true;
                  });
                  try {
                    final result = await ErrorReporter.testErrorReporting();
                    setState(() {
                      _lastTestResult = result
                          ? '✅ Kiểm tra báo cáo lỗi thành công'
                          : '❌ Kiểm tra báo cáo lỗi thất bại';
                      _addLogEntry('Test báo cáo lỗi: ${result ? 'Thành công' : 'Thất bại'}');
                    });
                  } catch (e) {
                    setState(() {
                      _lastTestResult = '❌ Lỗi: $e';
                      _addLogEntry('Test báo cáo lỗi lỗi: $e');
                    });
                  } finally {
                    setState(() {
                      _isLoading = false;
                    });
                  }
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.send, size: 16),
              const SizedBox(width: 8),
              const Text('Kiểm tra báo cáo lỗi'),
            ],
          ),
        ),
        if (_lastTestResult.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            _lastTestResult,
            style: TextStyle(
              color: _lastTestResult.contains('✅')
                  ? Colors.green
                  : Colors.red,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }
  
  Widget _buildSimulateErrorButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mô phỏng lỗi:',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildErrorButton(
              'API',
              () {
                _simulateApiError();
              },
            ),
            _buildErrorButton(
              'Dữ liệu',
              () {
                _simulateDataError();
              },
            ),
            _buildErrorButton(
              'Nghiêm trọng',
              () {
                _simulateCriticalError();
              },
            ),
            _buildErrorButton(
              'Hiệu suất',
              () {
                _simulatePerformanceIssue();
              },
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildErrorButton(String label, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red.shade800,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        minimumSize: const Size(0, 32),
        textStyle: const TextStyle(fontSize: 12),
      ),
      child: Text(label),
    );
  }
  
  Widget _buildLogViewer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Nhật ký:',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.clear_all, color: Colors.white, size: 16),
              onPressed: () {
                setState(() {
                  _logEntries.clear();
                });
              },
              tooltip: 'Xóa nhật ký',
              constraints: const BoxConstraints(),
              padding: const EdgeInsets.all(4),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          height: 150,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black,
            border: Border.all(color: Colors.white24),
            borderRadius: BorderRadius.circular(4),
          ),
          child: _logEntries.isEmpty
              ? const Center(
                  child: Text(
                    'Chưa có nhật ký',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                )
              : ListView.builder(
                  itemCount: _logEntries.length,
                  itemBuilder: (context, index) {
                    final entry = _logEntries[_logEntries.length - 1 - index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        entry,
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
  
  void _simulateApiError() {
    ErrorReporter.reportApiError(
      'api/test/endpoint',
      Exception('Lỗi kết nối API mô phỏng'),
      StackTrace.current,
    );
    _addLogEntry('Đã gửi báo cáo lỗi API mô phỏng');
  }
  
  void _simulateDataError() {
    ErrorReporter.reportDataError(
      'TestProvider',
      'Lỗi phân tích dữ liệu JSON',
      FormatException('Định dạng JSON không hợp lệ'),
      StackTrace.current,
    );
    _addLogEntry('Đã gửi báo cáo lỗi dữ liệu mô phỏng');
  }
  
  void _simulateCriticalError() {
    ErrorReporter.reportCritical(
      'AuthService',
      'Lỗi xác thực nghiêm trọng',
      StateError('Phiên hết hạn đột ngột'),
      StackTrace.current,
    );
    _addLogEntry('Đã gửi báo cáo lỗi nghiêm trọng mô phỏng');
  }
  
  void _simulatePerformanceIssue() {
    ErrorReporter.reportPerformanceIssue(
      'LoadUserProfile',
      5500,
      details: 'Tải dữ liệu người dùng quá chậm',
    );
    _addLogEntry('Đã gửi báo cáo vấn đề hiệu suất mô phỏng');
  }
  
  void _addLogEntry(String entry) {
    setState(() {
      final timestamp = DateTime.now().toString().split('.').first;
      _logEntries.add('[$timestamp] $entry');
    });
  }
} 