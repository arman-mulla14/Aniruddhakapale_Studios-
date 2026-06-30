import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> imgList = [
      'https://images.unsplash.com/photo-1519225421980-715cb0215aed?q=80&w=2070&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1606800052052-a08af7148866?q=80&w=2070&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1511285560929-80b456fea0bc?q=80&w=2069&auto=format&fit=crop'
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('AK Studios Pro Manager', style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Carousel Slider
            CarouselSlider(
              options: CarouselOptions(
                height: 200.0,
                autoPlay: true,
                enlargeCenterPage: true,
                viewportFraction: 0.9,
              ),
              items: imgList.map((item) => Container(
                margin: const EdgeInsets.all(5.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  image: DecorationImage(
                    image: NetworkImage(item),
                    fit: BoxFit.cover,
                  ),
                ),
              )).toList(),
            ),
            
            const SizedBox(height: 20),
            
            // Real-Time Stats StreamBuilder
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('orders').snapshots(),
              builder: (context, snapshot) {
                double totalPending = 0;
                int activeBookings = 0;

                if (snapshot.hasData) {
                  activeBookings = snapshot.data!.docs.length;
                  for (var doc in snapshot.data!.docs) {
                    final data = doc.data() as Map<String, dynamic>;
                    totalPending += (data['pendingAmount'] ?? 0);
                  }
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      _buildStatCard('Pending Amt', '₹${totalPending.toStringAsFixed(0)}', Icons.account_balance_wallet, Colors.orange),
                      const SizedBox(width: 10),
                      _buildStatCard('Active Bookings', '$activeBookings', Icons.calendar_month, Colors.blue),
                      const SizedBox(width: 10),
                      _buildStatCard('Reminders', '0', Icons.notifications_active, Colors.red),
                    ],
                  ),
                );
              }
            ),
            
            const SizedBox(height: 24),
            
            // Order History Live Data
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text('Recent Order History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
            const SizedBox(height: 10),
            
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('orders').orderBy('date', descending: true).limit(5).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37)));
                }
                
                final orders = snapshot.data?.docs ?? [];
                
                if (orders.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('No orders yet. Accept a booking request to see it here!', style: TextStyle(color: Colors.white54)),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: orders.length,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemBuilder: (context, index) {
                    final order = orders[index].data() as Map<String, dynamic>;
                    return Card(
                      color: const Color(0xFF171717),
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: const CircleAvatar(backgroundColor: Color(0xFF202020), child: Icon(Icons.check_circle, color: Colors.green)),
                        title: Text('${order['clientName']} - ${order['location']}', style: const TextStyle(color: Colors.white)),
                        subtitle: Text('Pending: ₹${order['pendingAmount']}', style: const TextStyle(color: Colors.orange)),
                        trailing: Text('₹${order['totalAmount']}', style: const TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold)),
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF202020),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF333333)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(fontSize: 10, color: Colors.white54)),
          ],
        ),
      ),
    );
  }
}
