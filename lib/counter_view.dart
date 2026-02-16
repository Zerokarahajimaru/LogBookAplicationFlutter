import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      appBar: AppBar(
        title: const Text("LogBook: Proyek 4", style: TextStyle(fontWeight: FontWeight.bold)), 
        backgroundColor: const Color.fromARGB(255, 177, 208, 255),
        foregroundColor: const Color.fromARGB(255, 111, 103, 103),
        elevation: 6,
        shadowColor: Colors.black.withOpacity(0.3),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Card(
                elevation: 10,
                shadowColor: Colors.blue.withOpacity(0.2),
                color: const Color(0xFFE8F5E9), 
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(30),
                  child: Column(
                    children: [
                      Text(
                        "TOTAL HITUNGAN",
                        style: TextStyle(color: Colors.green[800], fontWeight: FontWeight.bold, letterSpacing: 1.2),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${_controller.value}',
                        style: TextStyle(fontSize: 70, fontWeight: FontWeight.w900, color: Colors.blue[900]),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 25),
              Card(
                elevation: 4,
                color: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Step", style: TextStyle(fontWeight: FontWeight.bold)),
                          CircleAvatar(
                            radius: 15,
                            backgroundColor: Colors.blue[800],
                            child: Text('${_controller.step}', style: const TextStyle(color: Colors.white, fontSize: 12)),
                          ),
                        ],
                      ),
                      _sliderbuild(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _actionButton(
                    icon: Icons.remove, 
                    color: Colors.redAccent, 
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      setState(() {
                        _controller.decrement();
                        _controller.history("menekan tombol -${_controller.step}");
                      });
                    }
                  ),
                  _actionButton(
                    icon: Icons.add, 
                    color: Colors.greenAccent[700]!, 
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      setState(() {
                        _controller.increment();
                        _controller.history("menekan tombol +${_controller.step}");
                      });
                    }
                  ),
                ],
              )
            ],
          ),
        ),
      ),
      drawer: _buildDrawer(context),
    );
  }

  Widget _actionButton({required IconData icon, required Color color, required VoidCallback onPressed}) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 5))]
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 30),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: const Color(0xFFE3F2FD)),
            child: Text('Menu Aktivitas', style: TextStyle(color: Colors.blue[900], fontSize: 24, fontWeight: FontWeight.bold)),
          ),
          ListTile(
            leading: const Icon(Icons.refresh, color: Colors.red),
            title: const Text('Reset Data'),
            onTap: () => _showResetDialog(),
          ),
          const Divider(),
          ...List.generate(_controller.history_private_var.length, (index) {
            return ListTile(
              title: Text(_controller.history_private_var[index], 
                style: TextStyle(color: _controller.color_history_private_var[index], fontWeight: FontWeight.bold)),
              trailing: Text(_controller.time_history_private_var[index].format(context), style: const TextStyle(fontSize: 12)),
            );
          }),
        ],
      ),
    );
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Reset?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          TextButton(
            onPressed: () {
              setState(() => _controller.reset());
              _controller.history("mereset counter");
              Navigator.pop(context); Navigator.pop(context);
            }, 
            child: const Text("Ya", style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    );
  }

  Widget _sliderbuild() {
    return Slider(
      value: _controller.step.toDouble(),
      min: 1, max: 5, divisions: 4,
      activeColor: Colors.blue[800],
      onChanged: (double newValue) {
        setState(() {
          _controller.setStep(newValue.toInt());
          _controller.history("menggeser slider ke ${newValue.toInt()}");
        });
      },
    );
  }
}