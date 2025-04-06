import 'package:flutter/material.dart';

class OrderHistoryPage extends StatefulWidget {
  @override
  _OrderHistoryPageState createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  List<Map<String, String>> historyItems = [
    {'foodName': 'Biryani', 'foodUrl': 'assets/icons/biryani.png'},
    {'foodName': 'Special Nashta', 'foodUrl': 'assets/icons/egg.png'},
    {'foodName': 'Luxury House', 'foodUrl': 'assets/icons/house1.png'},
    {'foodName': 'Dall rooti', 'foodUrl': 'assets/icons/khana.png'},
  ];

  void clearHistory() {
    setState(() {
      historyItems.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('All history cleared')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            UserPhoto(),
            SizedBox(height: 10.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Your History',
                    style: TextStyle(
                      fontSize: 20.0,
                      color: Colors.grey[800],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (String choice) {
                      if (choice == 'Clear All') {
                        clearHistory();
                      }
                    },
                    itemBuilder: (BuildContext context) {
                      return [
                        PopupMenuItem<String>(
                          value: 'Clear All',
                          child: Text('Clear All'),
                        ),
                      ];
                    },
                    icon:
                        Icon(Icons.more_vert_outlined, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
            historyItems.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      'No history available',
                      style: TextStyle(fontSize: 16.0, color: Colors.grey[600]),
                    ),
                  )
                : Column(
                    children: historyItems
                        .map((item) => History(
                              foodName: item['foodName']!,
                              foodUrl: item['foodUrl']!,
                            ))
                        .toList(),
                  ),
          ],
        ),
      ),
    );
  }
}

class History extends StatelessWidget {
  final String foodUrl;
  final String foodName;

  const History({Key? key, required this.foodUrl, required this.foodName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
      child: Row(
        children: [
          Container(
            height: 120.0,
            width: 120.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.0),
              image: DecorationImage(
                image: AssetImage(foodUrl),
                fit: BoxFit.fill,
              ),
            ),
          ),
          SizedBox(width: 10.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(foodName,
                  style:
                      TextStyle(fontSize: 20.0, fontWeight: FontWeight.w500)),
              SizedBox(height: 5.0),
              Text('Get on Nov 21,2021',
                  style: TextStyle(fontSize: 16.0, color: Colors.grey[600])),
            ],
          ),
        ],
      ),
    );
  }
}

class UserPhoto extends StatelessWidget {
  const UserPhoto({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Stack(
      children: [
        Container(
          height: size.height * 0.3,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(70.0),
              bottomRight: Radius.circular(70.0),
            ),
            color: Colors.orange.shade900,
          ),
        ),
        Positioned(
          top: 40,
          left: 15,
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white, size: 28),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              SizedBox(width: 8),
              Text(
                'Your History',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 130.0, right: 220.0),
          child: Container(
            height: size.height * 0.15,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2.5),
              image: DecorationImage(
                image: AssetImage('assets/icons/girl.jfif'),
                fit: BoxFit.fill,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.shade900,
                  offset: Offset(1.5, 1.5),
                  spreadRadius: 2.5,
                  blurRadius: 2.5,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
