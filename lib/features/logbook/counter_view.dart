import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/features/auth/login_view.dart';
import 'package:flutter_application_1/features/logbook/counter_controller.dart';

class CounterView extends StatefulWidget {
  final String? username;

  const CounterView({super.key, this.username});

  @override
  State<CounterView> createState() => _CounterViewState();
}

class _CounterViewState extends State<CounterView> {
  final CounterController _controller = CounterController();
  late Future<void> _initControllerFuture;

  @override
  void initState() {
    super.initState();
    // Inisialisasi controller dengan username dari widget
    _initControllerFuture = _initializeController(widget.username);
  }

  Future<void> _initializeController(String? username) async {
    await _controller.init(username);
    if (mounted) {
      setState(() {});
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Logout'),
          content: const Text('Apakah Anda yakin ingin keluar?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Tidak'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Ya'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginView()),
                  (Route<dynamic> route) => false,
                );
              },
            ),
          ],
        );
      },
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    final username = widget.username ?? 'User';

    if (hour >= 6 && hour < 11) {
      return "Selamat Pagi, $username";
    } else if (hour >= 11 && hour < 15) {
      return "Selamat Siang, $username";
    } else if (hour >= 15 && hour < 18) {
      return "Selamat Sore, $username";
    } else {
      return "Selamat Malam, $username";
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initControllerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        } else {
          return Scaffold(
            appBar: AppBar(
              title: Text("LogBook: ${widget.username ?? 'Proyek 4'}",
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              backgroundColor: const Color.fromARGB(255, 177, 208, 255),
              foregroundColor: const Color.fromARGB(255, 111, 103, 103),
              elevation: 6,
              shadowColor: Colors.black.withAlpha(77),
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: _showLogoutDialog,
                ),
              ],
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      _getGreeting(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    Card(
                      elevation: 10,
                      shadowColor: Colors.blue.withAlpha(51),
                      color: const Color(0xFFE8F5E9),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(30),
                        child: Column(
                          children: [
                            Text(
                              "TOTAL HITUNGAN",
                              style: TextStyle(
                                  color: Colors.green[800],
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              '${_controller.value}',
                              style: TextStyle(
                                  fontSize: 70,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.blue[900]),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    Card(
                      elevation: 4,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Step",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                CircleAvatar(
                                  radius: 15,
                                  backgroundColor: Colors.blue[800],
                                  child: Text('${_controller.step}',
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 12)),
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
                              });
                            }),
                        _actionButton(
                            icon: Icons.add,
                            color:
                                Colors.greenAccent[700] ?? Colors.greenAccent,
                            onPressed: () {
                              HapticFeedback.mediumImpact();
                              setState(() {
                                _controller.increment();
                              });
                            }),
                      ],
                    )
                  ],
                ),
              ),
            ),
            drawer: _buildDrawer(context),
          );
        }
      },
    );
  }

  Widget _actionButton(
      {required IconData icon,
      required Color color,
      required VoidCallback onPressed}) {
    return Container(
      decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
                color: color.withAlpha(102),
                blurRadius: 10,
                offset: const Offset(0, 5))
          ]),
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
            decoration: const BoxDecoration(color: Color(0xFFE3F2FD)),
            child: Text('Menu Aktivitas',
                style: TextStyle(
                    color: Colors.blue[900],
                    fontSize: 24,
                    fontWeight: FontWeight.bold)),
          ),
          ListTile(
            leading: const Icon(Icons.refresh, color: Colors.red),
            title: const Text('Reset Data'),
            onTap: () => _showResetDialog(),
          ),
          const Divider(),
          ..._controller.history.map((log) {
            return ListTile(
              title: Text(log.message,
                  style: TextStyle(
                      color: log.color, fontWeight: FontWeight.bold)),
              trailing: Text(log.time,
                  style: const TextStyle(fontSize: 12)),
            );
          }).toList(),
        ],
      ),
    );
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Reset?"),
        content: const Text("Semua data hitungan dan riwayat untuk user ini akan dihapus. Lanjutkan?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal")),
          TextButton(
              onPressed: () {
                setState(() {
                  _controller.reset();
                });
                Navigator.pop(context);
              },
              child: const Text("Ya", style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }

  Widget _sliderbuild() {
    return Slider(
      value: _controller.step.toDouble(),
      min: 1,
      max: 5,
      divisions: 4,
      activeColor: Colors.blue[800],
      onChanged: (double newValue) {
        setState(() {
          _controller.setStep(newValue.toInt());
        });
      },
    );
  }
}