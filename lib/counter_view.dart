import 'package:flutter/material.dart';
import 'counter_controller.dart';

class CounterView extends StatefulWidget {
  const CounterView({super.key});

  @override
  State<CounterView> createState() => _CounterViewState();
}

class _CounterViewState extends State<CounterView> {
  final CounterController _controller = CounterController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("LogBook: Versi SRP")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Total Hitungan:"),
            Text('${_controller.value}', style: const TextStyle(fontSize: 40)),
            const SizedBox(height: 20),
            const Text("Step Per Klik:"),
            _sliderbuild(),
            Text('${_controller.step}'),
          ],
        ),
      ),

      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.refresh),
              title: Text('Reset Counter'),
              onTap: () {
                setState(() {
                  _controller.reset();
                });
                Navigator.pop(context); 
                _controller.history("mereset counter");
              },
            ),ListTile(
              title: const Text('Riwayat Aktivitas'),
             
              subtitle: Column(
                children: List.generate(_controller.history_private_var.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween, 
                      children: [
                        
                        Text(_controller.history_private_var[index]),
                        
                        Text(
                          _controller.time_history_private_var[index].format(context),
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        
        onPressed: () => setState(() {
          _controller.increment();
          _controller.history("menekan tombol +" + _controller.step.toString());
        }),

        child: const Icon(Icons.add),
      ),
    );
  }

  
  Widget _sliderbuild() {
    return Slider(
      
      value: _controller.step.toDouble(),
      label: 'Step: ${_controller.step}',
      min: 1,
      max: 5,
      divisions: 4,
      activeColor: Colors.blue,
      inactiveColor: Colors.grey[300],
      thumbColor: const Color.fromARGB(255, 32, 104, 155),
      onChanged: (double newValue) {
      
        setState(() {
          _controller.setStep(newValue.toInt());
          _controller.history("menggeser slider + " + newValue.toInt().toString());
        });
      },
    );
  }

  }
