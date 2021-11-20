import 'package:flutter/material.dart';
import 'package:smartwind/V/Home/Tickets/ProductionPool/TicketList.dart';

class ProductionPool extends StatefulWidget {
  ProductionPool({Key? key}) : super(key: key);

  @override
  _ProductionPoolState createState() {
    return _ProductionPoolState();
  }
}

class _ProductionPoolState extends State<ProductionPool> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TicketList();
  }
}