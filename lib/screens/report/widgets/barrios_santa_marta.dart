import 'package:flutter/material.dart';
// barrios list and search field are defined in this file


const List<String> barriosSantaMarta = [
  "1º de Mayo",
  "Acacias",
  "Boulevard de la 19",
  "Cañaveral",
  "Ciudadela 29 de Julio",
  "Corea",
  "Daniel Sánchez",
  "El Piñon I",
  "El Piñon II",
  "El Trébol",
  "La Lucha",
  "Las Américas",
  "Las Colinas del Pando",
  "Loma Fresca",
  "Los Faroles",
  "Los Laureles",
  "Loteo Graciela Riascos",
  "Manzanares",
  "María Eugenia",
  "Martinete",
  "Murallas",
  "Pando",
  "Pando I",
  "Pastrana",
  "Privilegio",
  "San José Del S",
  "San Pablo",
  "Villas de Alejandría",
  "Veinte de Enero",
  "Villa del Carmen",
  "Villa del Mar",
  "Villa Marbella",
  "20 de Octubre",
  "Av. Libertador",
  "Bolivariana",
  "Conjunto Residencial Canarias",
  "Cantilito I",
  "Cantilito II",
  "Cantilito III",
  "Cantilito IV",
  "El Bosque",
  "El Carmen",
  "El Cisne",
  "El Refugio",
  "Invasión Nueva La Rosalía",
  "Los Trupillos",
  "Las Malvinas",
  "Mamatoco",
  "Nueva Colombia",
  "Nueva Mansión",
  "Nueva Venecia",
  "Nuevo Milenio",
  "Once de Noviembre",
  "Quebrada M.",
  "Rodrigo Ahumada",
  "San Tropel",
  "Timayui I",
  "Timayui II",
  "Timayui III",
  "Tres Puentes",
  "Urb. Alejandrina",
  "Boulevard del Rio",
  "Garagoa",
  "Villa del Mar",
  "Villa Campo",
  "Villa Dania",
  "Villa Ely",
  "Villa Italia",
  "Villa Marina",
  "Villa Mercedes",
  "Villa Sara",
  "Villa Toledo",
  "Villa Trinidad",
  "Villa U",
  "Yucal 1",
  "Yucal 2",
  "Acodis",
  "Altos Santa Cruz",
  "Andrea Carolina",
  "Asocom Corintio",
  "Curinca",
  "La Concepción II",
  "La Concepción III",
  "La Concepción IV",
  "La Concepción V",
  "La Lucha",
  "Líbano 2000",
  "Los Nogales",
  "Los Pinos",
  "Luz del Mundo",
  "Montpellier",
  "Santa Clara",
  "Alto de Santa Cruz",
  "Santa Cruz",
  "Santa Lucía",
  "Tamacá",
  "Tejares del Libertador",
  "Urbanización El Parque",
  "Urbanización Mayorga",
  "Villas de Santa Cruz",
  "Philadelfia",
  "Brisas de La Sierra",
  "Zona Franca Industrial",
  "Ciudad del Sol",
  "Alambique",
  "Bavaria",
  "Bavaria Reservado",
  "Bellavista",
  "Bolívar",
  "Boston",
  "Centro",
  "Centro Histórico",
  "Costa Verde",
  "El Mayor",
  "El Prado",
  "El Pueblito",
  "El Territorial",
  "Urbanización Colón",
  "La Esperanza",
  "La Gran Vía",
  "La Logia",
  "La Tenería",
  "Los Ángeles",
  "Los Troncos",
  "Minuto de Dios",
  "Miramar",
  "Obrero",
  "Puerto Mosquito",
  "Santa Cecilia",
  "Santa Veronica",
  "Taminaca 1",
  "Taminaca 2",
  "Tierra Baja",
  "Trece de Junio",
  "Urbanización El Refugio",
  "Villa del Rosario",
  "Zona del Mercado",
  "Alfonso López",
  "Almendro",
  "Betania",
  "César Mendoza",
  "20 de Julio",
  "Barrio Obrero",
  "Cristo Rey",
  "Nacho Vives",
  "El Pradito",
  "El Recreo",
  "Ensenada Juan XXIII 1",
  "Ensenada Juan XXIII 2",
  "Ensenada",
  "Olaya",
  "Los Almendros",
  "Manguitos",
  "Miraflores",
  "Olaya Herrera",
  "Pescaito",
  "San Fernando",
  "San Jorge",
  "San Martín",
  "Urbanización Berlín",
  "Urbanización Campo Alegre",
  "Urbanización Guido",
  "Urbanización Hábitat",
  "Urbanización Pérez Dávila",
  "Urbanización Riascos",
  "Urbanización Veracruz",
  "Veracruz",
  "13 de Junio",
  "Altos de Santa Rita",
  "El Olivo",
  "7 de Agosto",
  "Los Alcázares",
  "Alto Jardín",
  "Andrea Doria",
  "AV. Del Río III Etapa",
  "Boston Caribe Inn",
  "El Cundí",
  "Elvira María",
  "Jardín",
  "Libertador",
  "Los Cocos",
  "Mercado Público",
  "Modelo",
  "Municipal",
  "Nueva Granada",
  "Urbanización Las Delicias",
  "Nuevo Jardín",
  "Pepe Hurtado",
  "Perehuétano",
  "Porvenir",
  "Postobón",
  "Recreo",
  "Salamanca",
  "San Francisco",
  "San José",
  "Santa Catalina",
  "Santa Catalina 2000",
  "Santa Helena",
  "Urb. Benjamín Alzate",
  "Urbanización Autopista",
  "Urbanización Bavaria Country",
  "Urbanización Caracas",
  "Urbanización El Río",
  "Urbanización Elvia Mejía",
  "Urbanización Guerrero",
  "Urbanización Los Cerros",
  "Urbanización Nuevo Jardín",
  "Urbanización Pradera",
  "Urbanización Reposo",
  "Urbanización San Carlos",
  "Urbanización Santa Elena",
  "Urbanización Santa Rita",
  "Urbanización Silvia Rosa",
  "17 de Diciembre",
  "8 de Diciembre",
  "8 de Febrero",
  "8 de Noviembre",
  "Altos Delicias",
  "Altos Simón Bolívar",
  "Altos Villa Concha",
  "Balcones del Libertador",
  "Bastidas",
  "Belén",
  "Benjamín Alzate",
  "Buenos Aires",
  "Cardonales",
  "Chimila 1",
  "Chimila 2",
  "Divino Niño",
  "El Pantano",
  "Esmeralda",
  "Florida",
  "Galán",
  "Galicia",
  "La Estrella",
  "La Unión",
  "Las Vegas",
  "Los Fundadores",
  "Luis R. Calvo",
  "Miguel Pinedo",
  "Nueva Galicia",
  "Nuevo Armero",
  "Oasis",
  "Ondas del Caribe",
  "Pamplonita",
  "Paraíso",
  "San Ramón",
  "Santa Mónica",
  "Santafé",
  "Simón Bolívar",
  "Tayrona 1",
  "Tayrona 2",
  "Urbanización Santa Lucía",
  "Villa Aurora",
  "Villa Betel",
  "Villa del Carmen",
  "Villa del Río",
  "Brisas del Lago",
  "Cerro Intermedio",
  "Cerro La Llorona",
  "Cerro La Virgen",
  "Cerro M Cristal",
  "Doce de Octubre",
  "Eduardo Gutiérrez",
  "El Carmen",
  "El Socorro",
  "El Valle de Gaira",
  "Gaira Centro",
  "La Magdalena",
  "La Quemada",
  "La Quinina",
  "Lago Dulcino",
  "Las Colinas",
  "Las Palmeras",
  "Nueva Betel",
  "Rodadero Tradicional",
  "Sarabanda",
  "Vereda Mosquito",
  "Villa Berlín",
  "Villa Tanga",
  "Puente Arhuacos",
  "Bella Vista",
  "Bello",
  "Sol Cristalina",
  "Cristo Rey",
  "Don Jaca",
  "Alto El Mango",
  "Gauchovand",
  "La Chivera",
  "La Eva",
  "La Paz",
  "Limón",
  "Los Lirios",
  "Sircasia",
  "Totumo",
  "Villa Taroa",
  "Vista del Mar",
  "Vista Hermosa",
  "Bonda",
  "Bello horizonte",
  "La Concepción I"
];


class BarrioSearchField extends StatefulWidget {
  final TextEditingController controller;
  final bool pillStyle; // when true, render the rounded pill style like register's inputs
  final Color? pillColor;
  final double? pillRadius;

  const BarrioSearchField({super.key, required this.controller, this.pillStyle = false, this.pillColor, this.pillRadius});

  @override
  State<BarrioSearchField> createState() => _BarrioSearchFieldState();
}

class _BarrioSearchFieldState extends State<BarrioSearchField> {
  List<String> filtered = [];
  bool showList = false;

  @override
  void initState() {
    super.initState();
    filtered = barriosSantaMarta;
  }

  void updateSearch(String query) {
    setState(() {
      final q = query.trim().toLowerCase();
      if (q.isEmpty) {
        filtered = barriosSantaMarta;
        showList = false;
      } else if (q.length == 1) {
        // single-character search: match only prefixes (startsWith)
        filtered = barriosSantaMarta.where((b) => b.toLowerCase().startsWith(q)).toList();
        showList = true;
      } else {
        // longer queries: allow contains
        filtered = barriosSantaMarta.where((b) => b.toLowerCase().contains(q)).toList();
        showList = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // show only one row to avoid layout overflow; item height ~56
    const double itemHeight = 56.0;
    final double listHeight = itemHeight;

    return Column(
      children: [
        // Support two visual modes: pillStyle (rounded blue pill) used by Register,
        // and default outlined field used elsewhere.
        if (widget.pillStyle)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: widget.pillColor ?? const Color(0xFFA9EEFF),
              borderRadius: BorderRadius.circular(widget.pillRadius ?? 30),
            ),
            child: TextField(
              controller: widget.controller,
              onChanged: updateSearch,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: "Escribe el barrio...",
                hintStyle: TextStyle(fontFamily: 'Poppins'),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 14),
                prefixIcon: Icon(Icons.search),
              ),
            ),
          )
        else
          TextField(
            controller: widget.controller,
            onChanged: updateSearch,
            decoration: InputDecoration(
              hintText: "Escribe el barrio...",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.search),
            ),
          ),

        // Lista desplegable de resultados (height adjusts to content, up to max)
        if (showList)
          Container(
            margin: const EdgeInsets.only(top: 5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: SizedBox(
              height: listHeight,
              child: ListView.builder(
                  padding: EdgeInsets.zero,
                  // always show only one visible row to prevent spacing issues
                  itemCount: filtered.isEmpty ? 1 : 1,
                  itemBuilder: (context, index) {
                    if (filtered.isEmpty) {
                      return const ListTile(title: Text('Sin resultados'));
                    }
                    final barrio = filtered.first;
                    return ListTile(
                      title: Text(barrio),
                      onTap: () {
                        widget.controller.text = barrio;
                        setState(() => showList = false);
                        // dismiss keyboard and collapse list
                        FocusScope.of(context).unfocus();
                      },
                    );
                  },
                ),
            ),
          ),
      ],
    );
  }
}



