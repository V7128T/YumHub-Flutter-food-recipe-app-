import 'package:flutter/material.dart';
import '../../../models/nutrients.dart';
import 'expandable.dart';
import 'package:google_fonts/google_fonts.dart';

class NutrientsWidgets extends StatelessWidget {
  final Nutrient nutrient;

  const NutrientsWidgets({Key? key, required this.nutrient}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: ExpandableGroup(
          isExpanded: false,
          collapsedIcon: const Icon(Icons.arrow_drop_down),
          header: Text(
            "Nutrients",
            style: GoogleFonts.workSans(
              textStyle: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          items: [
            ListTile(
                contentPadding: const EdgeInsets.all(10),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.fireplace,
                    size: 35,
                    color: Colors.orange,
                  ),
                ),
                title: Text(
                  "Calories(kcal)",
                  style: GoogleFonts.workSans(
                    textStyle: const TextStyle(
                      fontSize: 15.0,
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                trailing: Text(
                  nutrient.calories,
                  style: GoogleFonts.workSans(
                    textStyle: const TextStyle(
                      fontSize: 18.0,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )),
            ListTile(
                contentPadding: const EdgeInsets.all(10),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.face_outlined,
                    size: 35,
                    color: Colors.orange,
                  ),
                ),
                title: Text(
                  "Fat",
                  style: GoogleFonts.workSans(
                    textStyle: const TextStyle(
                      fontSize: 15.0,
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                trailing: Text(
                  nutrient.fat,
                  style: GoogleFonts.workSans(
                    textStyle: const TextStyle(
                      fontSize: 18.0,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )),
            ListTile(
                contentPadding: const EdgeInsets.all(10),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.bakery_dining,
                    size: 35,
                    color: Colors.orange,
                  ),
                ),
                title: Text(
                  "Carbohydrates",
                  style: GoogleFonts.workSans(
                    textStyle: const TextStyle(
                      fontSize: 15.0,
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                trailing: Text(
                  nutrient.carbs,
                  style: GoogleFonts.workSans(
                    textStyle: const TextStyle(
                      fontSize: 18.0,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )),
            ListTile(
              contentPadding: const EdgeInsets.all(10),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.bolt_outlined,
                  size: 35,
                  color: Colors.orange,
                ),
              ),
              title: Text(
                "Protein",
                style: GoogleFonts.workSans(
                  textStyle: const TextStyle(
                    fontSize: 15.0,
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              trailing: Text(
                nutrient.protein,
                style: GoogleFonts.workSans(
                  textStyle: const TextStyle(
                    fontSize: 18.0,
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NutrientsbadWidget extends StatelessWidget {
  final Nutrient nutrient;

  const NutrientsbadWidget({Key? key, required this.nutrient})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: ExpandableGroup(
          isExpanded: false,
          collapsedIcon: const Icon(Icons.arrow_drop_down),
          header: Text(
            "Bad Nutrients Scores",
            style: GoogleFonts.workSans(
              textStyle: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          items: [
            ...nutrient.bad.map((nutri) {
              return ListTile(
                contentPadding: const EdgeInsets.all(10),
                subtitle: Text("${nutri.percentOfDailyNeeds}% of Daily needs."),
                title: Text(
                  nutri.name.toString(),
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold),
                ),
                trailing: Text(
                  nutri.amount,
                  style: const TextStyle(
                      fontSize: 18,
                      color: Colors.green,
                      fontWeight: FontWeight.bold),
                ),
              );
            }).toList()
          ],
        ),
      ),
    );
  }
}

class NutrientsgoodWidget extends StatelessWidget {
  final Nutrient nutrient;

  const NutrientsgoodWidget({Key? key, required this.nutrient})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(10),
            bottomRight: Radius.circular(10),
          ),
        ),
        child: ExpandableGroup(
          isExpanded: false,
          collapsedIcon: const Icon(Icons.arrow_drop_down),
          header: Text(
            "Good Nutrients Scores",
            style: GoogleFonts.workSans(
              textStyle: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          items: [
            ...nutrient.good.map((nutri) {
              return ListTile(
                contentPadding: const EdgeInsets.all(10),
                subtitle: Text("${nutri.percentOfDailyNeeds}% of Daily needs."),
                title: Text(
                  nutri.name.toString(),
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold),
                ),
                trailing: Text(
                  nutri.amount,
                  style: const TextStyle(
                      fontSize: 18,
                      color: Colors.green,
                      fontWeight: FontWeight.bold),
                ),
              );
            }).toList()
          ],
        ),
      ),
    );
  }
}
