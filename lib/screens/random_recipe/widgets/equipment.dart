import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../models/equipment.dart';
import 'package:google_fonts/google_fonts.dart';

class EquipmentsListView extends StatelessWidget {
  final List<Equipment> equipments;

  const EquipmentsListView({super.key, required this.equipments});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: equipments.length,
        itemBuilder: (context, index) {
          final equipment = equipments[index];
          return Padding(
            padding: EdgeInsets.only(
              left: index == 0 ? 20 : 10,
              right: index == equipments.length - 1 ? 20 : 10,
            ),
            child: Container(
              width: 150,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(15)),
                    child: CachedNetworkImage(
                      imageUrl:
                          "https://spoonacular.com/cdn/equipment_250x250/${equipment.image}",
                      height: 120,
                      width: 150,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          const Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      equipment.name ?? '',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.chivo(
                        textStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
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
    );
  }
}
