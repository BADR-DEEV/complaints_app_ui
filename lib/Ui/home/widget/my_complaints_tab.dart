import 'package:complaintsapp/AppClient/Services/_shared_prefs_helper.dart';
import 'package:complaintsapp/Ui/shared/constants/colors&fonts.dart';
import 'package:flutter/material.dart';


class ComplaintModel {
  final String title;
  final String description;
  final String status; // "Pending" or "Resolved"

  ComplaintModel({
    required this.title,
    required this.description,
    required this.status,
  });
}



class MyComplaintsView extends StatefulWidget {
   MyComplaintsView({super.key});

  @override
  State<MyComplaintsView> createState() => _MyComplaintsViewState();
}

class _MyComplaintsViewState extends State<MyComplaintsView> {
  String selectedFilter = 'All';

  final List<ComplaintModel> complaints = [
    ComplaintModel(
      title: 'Broken Street Light',
      description: 'The street light on 5th Avenue has been broken for weeks.',
      status: 'Pending',
    ),
    ComplaintModel(
      title: 'Garbage Collection Delay',
      description: 'No garbage truck has come for 3 days in Sector B.',
      status: 'Resolved',
    ),
    ComplaintModel(
      title: 'Water Leakage',
      description: 'Continuous water leakage near Building 21.',
      status: 'Pending',
    ),
    ComplaintModel(
      title: 'Noise Disturbance',
      description: 'Loud construction work at night.',
      status: 'Resolved',
    ),
  ];

  List<String> filters = ['All', 'Pending', 'Resolved'];

  @override
  Widget build(BuildContext context) {
    final filteredComplaints = selectedFilter == 'All' ? complaints : complaints.where((c) => c.status == selectedFilter).toList();

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: filters.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final filter = filters[index];
                  final isSelected = filter == selectedFilter;

                  return GestureDetector(
                    onTap: () => setState(() => selectedFilter = filter),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primaryColor : Colors.grey[200],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        filter,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredComplaints.length,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (context, index) {
                final complaint = filteredComplaints[index];
                final isResolved = complaint.status == 'Resolved';

                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          complaint.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          complaint.description,
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isResolved ? Colors.green.withOpacity(0.2) : Colors.orange.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              complaint.status,
                              style: TextStyle(
                                color: isResolved ? Colors.green : Colors.orange,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
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
