import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Circuit Delivery',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// ─────────────────────────────────────────────────────
// MODELS (tout dans un seul fichier)
// ─────────────────────────────────────────────────────

class User {
  final String id;
  final String email;
  final String role; // 'admin', 'rider'

  User({required this.id, required this.email, required this.role});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'role': role,
    };
  }
}

class Rider {
  final String id;
  final String name;
  final String phone;
  final String? vehicle;

  Rider({required this.id, required this.name, required this.phone, this.vehicle});

  factory Rider.fromJson(Map<String, dynamic> json) {
    return Rider(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      vehicle: json['vehicle'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'vehicle': vehicle,
    };
  }
}

class Delivery {
  final String id;
  final String address;
  final double lat;
  final double lng;
  final String clientName;
  final String? instructions;

  Delivery({
    required this.id,
    required this.address,
    required this.lat,
    required this.lng,
    required this.clientName,
    this.instructions,
  });

  factory Delivery.fromJson(Map<String, dynamic> json) {
    return Delivery(
      id: json['id'],
      address: json['address'],
      lat: json['lat'],
      lng: json['lng'],
      clientName: json['clientName'],
      instructions: json['instructions'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'address': address,
      'lat': lat,
      'lng': lng,
      'clientName': clientName,
      'instructions': instructions,
    };
  }
}

class Stop {
  final String id;
  final int index;
  final String deliveryId;
  final String status; // 'pending', 'en route', 'delivered', 'failed'

  Stop({
    required this.id,
    required this.index,
    required this.deliveryId,
    this.status = 'pending',
  });

  factory Stop.fromJson(Map<String, dynamic> json) {
    return Stop(
      id: json['id'],
      index: json['index'],
      deliveryId: json['deliveryId'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'index': index,
      'deliveryId': deliveryId,
      'status': status,
    };
  }
}

import 'stop.dart'; // Stop est déjà défini au-dessus

class RoutePlan {
  final String id;
  final String creatorId;
  final String riderId; // null = pas assigné
  final DateTime date;
  final List<Stop> stops;

  RoutePlan({
    required this.id,
    required this.creatorId,
    required this.riderId,
    required this.date,
    required this.stops,
  });

  factory RoutePlan.fromJson(Map<String, dynamic> json) {
    final List<Stop> stopsList =
        (json['stops'] as List).map((e) => Stop.fromJson(e)).toList();

    return RoutePlan(
      id: json['id'],
      creatorId: json['creatorId'],
      riderId: json['riderId'],
      date: DateTime.parse(json['date']),
      stops: stopsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'creatorId': creatorId,
      'riderId': riderId,
      'date': date.toIso8601String(),
      'stops': stops.map((s) => s.toJson()).toList(),
    };
  }
}

// ─────────────────────────────────────────────────────
// ÉCRAN LOGIN
// ─────────────────────────────────────────────────────

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _login() {
    final String email = _emailController.text;
    final String role = email.contains('admin') ? 'admin' : 'rider';

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => role == 'admin'
            ? AdminDashboardScreen()
            : RiderHomeScreen(riderId: '1'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Circuit Delivery')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
        children: [
        TextField(
        controller: _emailController,
        decoration: InputDecoration(labelText: 'Email'),
        ),
        SizedBox(height: 16),
        TextField(
        controller: _passwordController,
        decoration: InputDecoration(labelText: 'Mot de passe'),
        obscureText: true,
        ),
        SizedBox(height: 24),
        ElevatedButton(
        onPressed: _login,
        child: Text('Se connecter'),
        ),
        ],
        ),
        ),
        );
        }
        }


// ─────────────────────────────────────────────────────
// ÉCRAN ADMIN (Dashboard + gestion livreurs + tournée)
// ─────────────────────────────────────────────────────

class AdminDashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Admin Dashboard')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ManageRidersScreen()),
                );
              },
              child: Text('Gérer les livreurs'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CreateRouteScreen()),
                );
              },
              child: Text('Créer une tournée'),
            ),
          ],
        ),
      ),
    );
  }
}

class ManageRidersScreen extends StatefulWidget {
  @override
  _ManageRidersScreenState createState() => _ManageRidersScreenState();
}

class _ManageRidersScreenState extends State<ManageRidersScreen> {
  List<Rider> riders = [
    Rider(id: '1', name: 'Alex', phone: '+33123456789'),
    Rider(id: '2', name: 'Youpla', phone: '+33987654321'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Gérer les livreurs')),
      body: ListView.builder(
        itemCount: riders.length,
        itemBuilder: (context, i) {
          final rider = riders[i];
          return ListTile(
            title: Text(rider.name),
            subtitle: Text(rider.phone),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                setState(() => riders.removeAt(i));
              },
            ),
          );
        },
      ),
    );
  }
}

class CreateRouteScreen extends StatefulWidget {
  @override
  _CreateRouteScreenState createState() => _CreateRouteScreenState();
}

class _CreateRouteScreenState extends State<CreateRouteScreen> {
  final _deliveries = <Delivery>[];
  final _addressController = TextEditingController();
  final _clientController = TextEditingController();

  void _addDelivery() {
    final delivery = Delivery(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      address: _addressController.text,
      lat: 50.8503,
      lng: 4.3517,
      clientName: _clientController.text,
    );
    setState(() {
      _deliveries.add(delivery);
      _addressController.clear();
      _clientController.clear();
    });
  }

  void _optimizeRoute() async {
    // Simule l’optimisation (dans la vraie vie, tu connectes une API de cartes)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Route optimisée (simulée)')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Créer une tournée')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _addressController,
              decoration: InputDecoration(labelText: 'Adresse'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _clientController,
              decoration: InputDecoration(labelText: 'Client'),
            ),
            SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _addDelivery,
              icon: Icon(Icons.add),
              label: Text('Ajouter livraison'),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _deliveries.length,
                itemBuilder: (context, i) {
                  final d = _deliveries[i];
                  return ListTile(
                    title: Text(d.clientName),
                    subtitle: Text(d.address),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        setState(() => _deliveries.removeAt(i));
                      },
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: _optimizeRoute,
              child: Text('Optimiser la route'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────
// ÉCRAN LIVREUR (tournée du jour)
// ─────────────────────────────────────────────────────

class RiderHomeScreen extends StatelessWidget {
  final String riderId;

  RiderHomeScreen({required this.riderId});

  final List<RoutePlan> mockRoutes = [
    RoutePlan(
      id: '1',
      creatorId: '1',
      riderId: '1',
      date: DateTime.now(),
      stops: [
        Stop(id: 's1', index: 0, deliveryId: 'd1'),
        Stop(id: 's2', index: 1, deliveryId: 'd2'),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Ma tournée')),
      body: ListView.builder(
        itemCount: mockRoutes.length,
        itemBuilder: (context, i) {
          final r = mockRoutes[i];
          return ListTile(
            title: Text('${r.date.day}/${r.date.month}/${r.date.year}'),
            subtitle: Text('${r.stops.length} livraisons'),
            trailing: Icon(Icons.arrow_forward),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RouteDetailScreen(route: r),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class RouteDetailScreen extends StatelessWidget {
  final RoutePlan route;

  RouteDetailScreen({required this.route});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Détail de la tournée')),
      body: ListView.builder(
        itemCount: route.stops.length,
        itemBuilder: (context, i) {
          final stop = route.stops[i];
          return ListTile(
            leading: CircleAvatar(child: Text('${i + 1}')),
            title: Text('Stop ${i + 1}'),
            subtitle: Text('Status: ${stop.status}'),
            trailing: IconButton(
              icon: Icon(Icons.navigation),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Ouvrir la navigation (Apple Maps / Google Maps)')),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
