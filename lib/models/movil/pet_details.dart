class PetDetails {
  const PetDetails({
    required this.species,
    required this.breed,
    required this.gender,
    required this.birthDate,
    required this.notes,
  });

  final String species;
  final String breed;
  final String gender;
  final String birthDate;
  final String notes;

  factory PetDetails.fromDescription(String description) {
    String value(String label) {
      final prefix = '$label: ';
      for (final line in description.split('\n')) {
        if (line.startsWith(prefix))
          return line.substring(prefix.length).trim();
      }
      return '';
    }

    final notesMarker = 'Notas: ';
    final notesIndex = description.indexOf(notesMarker);
    return PetDetails(
      species: value('Especie'),
      breed: value('Raza'),
      gender: value('Género'),
      birthDate: value('Nacimiento'),
      notes: notesIndex < 0
          ? description
          : description.substring(notesIndex + notesMarker.length).trim(),
    );
  }

  String toDescription() => <String>[
    'Especie: $species',
    'Raza: $breed',
    'Género: $gender',
    'Nacimiento: $birthDate',
    if (notes.trim().isNotEmpty) 'Notas: ${notes.trim()}',
  ].join('\n');
}
