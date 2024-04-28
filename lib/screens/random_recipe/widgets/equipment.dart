import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../models/equipment.dart';
import 'package:google_fonts/google_fonts.dart';

///Displaying Widget for Equipments List
class EquipmentsListView extends StatelessWidget {
  final List<Equipment> equipments;

  const EquipmentsListView({super.key, required this.equipments});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 170,
      child: ListView(
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        children: [
          const SizedBox(
            width: 26,
          ),
          ...equipments.map((equipment) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: const [
                        BoxShadow(
                          offset: Offset(2, 2),
                          blurRadius: 5,
                          color: Color.fromRGBO(0, 0, 0, 0.20),
                        )
                      ],
                      image: DecorationImage(
                        fit: BoxFit.contain,
                        image: CachedNetworkImageProvider(
                          "https://spoonacular.com/cdn/equipment_100x100/${equipment.image}",
                          maxWidth: 556,
                          maxHeight: 370,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: 100,
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text:
                                equipment.name!.characters.first.toUpperCase(),
                            style: GoogleFonts.chivo(
                              textStyle: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          TextSpan(
                            text: equipment.name!.substring(1),
                            style: GoogleFonts.chivo(
                              textStyle: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
