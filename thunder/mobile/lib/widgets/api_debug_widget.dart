import "package:flutter/material.dart";
import "package:http/http.dart" as http;
import "../services/api_client.dart";

class ApiDebugWidget extends StatefulWidget {
  const ApiDebugWidget({super.key});

  @override
  State<ApiDebugWidget> createState() => _ApiDebugWidgetState();
}

class _ApiDebugWidgetState extends State<ApiDebugWidget> {
  bool _expanded = false;
  String _status = "Unknown";
  bool _testing = false;

  Future<void> _testConnection() async {
    setState(() {
      _testing = true;
      _status = "Testing...";
    });
    try {
      final response = await http.get(Uri.parse("${ApiClient.baseUrl.replaceFirst("/api/v1", "")}/health"))
          .timeout(const Duration(seconds: 5));
      setState(() {
        _status = response.statusCode == 200 ? "Online" : "Status: ${response.statusCode}";
      });
    } catch (e) {
      setState(() {
        _status = "Offline: ${e.toString().split(":").last}";
      });
    } finally {
      setState(() => _testing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 100,
      right: 16,
      child: Material(
        color: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (_expanded)
              Container(
                width: 250,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("API Debug Tool", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    const Divider(color: Colors.white24),
                    Text("Base URL:", style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 10)),
                    Text(ApiClient.baseUrl, style: const TextStyle(color: Colors.white, fontSize: 11)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Status: $_status", style: TextStyle(color: _status == "Online" ? Colors.greenAccent : Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                        if (_testing)
                          const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _testing ? null : _testConnection,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.white10, foregroundColor: Colors.white, padding: EdgeInsets.zero, minimumSize: const Size(0, 32)),
                        child: const Text("Test Connection", style: TextStyle(fontSize: 12)),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            FloatingActionButton.small(
              onPressed: () => setState(() => _expanded = !_expanded),
              backgroundColor: _expanded ? Colors.redAccent : Colors.indigoAccent,
              child: Icon(_expanded ? Icons.close : Icons.bug_report, color: Colors.white),
            )
          ],
        ),
      ),
    );
  }
}
