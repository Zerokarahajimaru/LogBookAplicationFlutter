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
            // Memanggil fungsi slider kamu di sini
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
              child: Text('Menu', style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              leading: const Icon(Icons.refresh),
              title: Text('Reset Counter'),
              onTap: () {
                setState(() {
                  _controller.reset();
                });
                Navigator.pop(context); // Tutup drawer setelah reset
              },
            ),
          ],
        ),
      ),


      floatingActionButton: FloatingActionButton(
        // Increment sekarang menggunakan nilai step
        onPressed: () => setState(() => _controller.increment()),
        child: const Icon(Icons.add),
      ),
    );
  }

  // Fungsi slider dipindahkan ke dalam class agar bisa pakai setState
  Widget _sliderbuild() {
    return Slider(
      // Slider butuh double, jadi int kita konversi dulu
      value: _controller.step.toDouble(), 
      label: 'Step: ${_controller.step}',
      min: 1,
      max: 20,
      divisions: 19,
      activeColor: Colors.blue,
      inactiveColor: Colors.grey[300],
      thumbColor: const Color.fromARGB(255, 32, 104, 155),
      onChanged: (double newValue) {
        // Update state agar UI berubah saat digeser
        setState(() {
          _controller.setStep(newValue.toInt());
        });
      },
    );
  }


  // Widget _history
}