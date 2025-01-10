import 'package:flutter/material.dart';
import 'package:turbo_response/turbo_response.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TurboResponse Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TurboResponse<String>? _response;
  bool _isLoading = false;

  Future<TurboResponse<String>> _simulateNetworkCall(bool shouldSucceed) async {
    await Future.delayed(const Duration(seconds: 1));
    if (shouldSucceed) {
      return const TurboResponse.success(
        result: 'Operation completed successfully!',
        title: 'Success',
        message: 'The network call was successful',
      );
    } else {
      return const TurboResponse.fail(
        error: 'Network error occurred',
        title: 'Error',
        message: 'The network call failed',
      );
    }
  }

  void _performOperation(bool shouldSucceed) async {
    setState(() {
      _response = null;
      _isLoading = true;
    });

    final response = await _simulateNetworkCall(shouldSucceed);

    setState(() {
      _response = response;
      _isLoading = false;
    });
  }

  void _setEmptySuccess() {
    setState(() => _response = const TurboResponse.success(
          result: 'Empty success',
        ));
  }

  void _setEmptyFail() {
    setState(() => _response = const TurboResponse.fail(
          error: 'Empty fail',
        ));
  }

  void _throwError() {
    try {
      _response?.throwWhenFail();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Caught error: $e')),
      );
    }
  }

  Widget _buildResponseWidget(TurboResponse<String> response) {
    return response.when<Widget>(
      success: (success) => Column(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 48),
          const SizedBox(height: 16),
          Text(
            success.title ?? 'Success',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(success.result),
          if (success.message != null) ...[
            const SizedBox(height: 8),
            Text(
              success.message!,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
      fail: (fail) => Column(
        children: [
          const Icon(Icons.error, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          Text(
            fail.title ?? 'Error',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(fail.error.toString()),
          if (fail.message != null) ...[
            const SizedBox(height: 8),
            Text(
              fail.message!,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('TurboResponse Demo'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isLoading)
                const Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading...'),
                  ],
                )
              else if (_response == null)
                const Text('Press a button to start an operation')
              else
                _buildResponseWidget(_response!),
              const SizedBox(height: 32),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed:
                        _isLoading ? null : () => _performOperation(true),
                    child: const Text('Simulate Success'),
                  ),
                  ElevatedButton(
                    onPressed:
                        _isLoading ? null : () => _performOperation(false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade100,
                    ),
                    child: const Text('Simulate Failure'),
                  ),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _setEmptySuccess,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade100,
                    ),
                    child: const Text('Empty Success'),
                  ),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _setEmptyFail,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade100,
                    ),
                    child: const Text('Empty Fail'),
                  ),
                  if (_response?.error != null)
                    ElevatedButton(
                      onPressed: _isLoading ? null : _throwError,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple.shade100,
                      ),
                      child: const Text('Throw Error'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
