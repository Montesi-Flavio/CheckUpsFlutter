# Font per CheckUps

Questa cartella contiene i font utilizzati nell'applicazione CheckUps.

## Font inclusi

- Montserrat (Regular, Bold, Italic)
- Roboto (Regular, Bold)

## Come aggiungere i font

Per utilizzare questi font nell'applicazione, è necessario:

1. Scaricare i file TTF dei font da Google Fonts o altre fonti ufficiali
2. Posizionarli in questa cartella
3. Assicurarsi che i nomi dei file corrispondano a quelli specificati nel file pubspec.yaml

I font sono già configurati nel file pubspec.yaml e possono essere utilizzati nell'applicazione.

## Esempio di utilizzo

```dart
Text(
  'Testo di esempio',
  style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold),
)
```