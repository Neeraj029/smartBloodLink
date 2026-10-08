import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../utils/constants.dart';
import '../../widgets/animated_card.dart';
import '../../widgets/blood_group_chip.dart';

/// Screen allowing patients and hospitals to query real-time stock availability across the city
class HospitalBloodSearchScreen extends StatefulWidget {
  const HospitalBloodSearchScreen({super.key});

  @override
  State<HospitalBloodSearchScreen> createState() =>
      _HospitalBloodSearchScreenState();
}

class _HospitalBloodSearchScreenState extends State<HospitalBloodSearchScreen> {
  String _selectedGroup = 'O+';

  final List<Map<String, dynamic>> _hospitalStock = [
    {
      'name': 'City Apex Blood Center & Research',
      'address': 'JM Road, Shivajinagar, Pune',
      'distance': '3.2 km',
      'phone': '+91 20 2567 8900',
      'stock': {'O+': 8, 'O-': 2, 'A+': 5, 'B+': 7, 'AB+': 4, 'B-': 1},
      'tempStatus': 'Normal (3.8°C)',
    },
    {
      'name': 'Ruby Hall Clinic Transfusion Services',
      'address': 'Dhole Patil Road, Pune',
      'distance': '4.8 km',
      'phone': '+91 20 6645 5100',
      'stock': {'O+': 4, 'O-': 1, 'A+': 3, 'B+': 6, 'AB+': 2, 'B-': 0},
      'tempStatus': 'Normal (4.0°C)',
    },
    {
      'name': 'Sassoon General Hospital Red Cross Bank',
      'address': 'Near Pune Railway Station, Pune',
      'distance': '5.5 km',
      'phone': '+91 20 2612 8000',
      'stock': {'O+': 12, 'O-': 4, 'A+': 9, 'B+': 11, 'AB+': 5, 'B-': 3},
      'tempStatus': 'Normal (4.1°C)',
    },
    {
      'name': 'Deenanath Mangeshkar Hospital Blood Bank',
      'address': 'Erandwane, Pune',
      'distance': '7.1 km',
      'phone': '+91 20 4015 1000',
      'stock': {'O+': 6, 'O-': 0, 'A+': 4, 'B+': 8, 'AB+': 3, 'B-': 2},
      'tempStatus': 'Normal (3.9°C)',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('City Blood Availability Map'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Filter by Blood Group',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: BloodConstants.groups.map((group) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: BloodGroupChip(
                          bloodGroup: group,
                          isSelected: _selectedGroup == group,
                          onTap: () {
                            setState(() {
                              _selectedGroup = group;
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          const Divider(),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _hospitalStock.length,
              itemBuilder: (context, index) {
                final hospital = _hospitalStock[index];
                final stockMap = hospital['stock'] as Map<String, dynamic>;
                final availableUnits = stockMap[_selectedGroup] ?? 0;

                return AnimatedCard(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              hospital['name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: availableUnits > 2
                                  ? AppColors.success.withOpacity(0.12)
                                  : AppColors.error.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '$availableUnits Units',
                              style: TextStyle(
                                color: availableUnits > 2
                                    ? AppColors.success
                                    : AppColors.error,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        hospital['address'],
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.near_me_outlined,
                              size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            hospital['distance'],
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(width: 14),
                          const Icon(Icons.thermostat_outlined,
                              size: 14, color: AppColors.success),
                          const SizedBox(width: 4),
                          Text(
                            hospital['tempStatus'],
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.success,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.phone_outlined,
                                color: AppColors.primary, size: 20),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Contacting ${hospital['name']} at ${hospital['phone']}'),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
