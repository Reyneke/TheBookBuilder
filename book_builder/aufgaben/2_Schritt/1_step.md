Aufgabe: Die Funktionen "loadToDoList" und "saveToDoList" werden refactored. Dabei ist das Tabellenschema unter "tabellenschema.md" zu beachten.

Für "saveToDoList":
1. Jeder Eintrag in der "_headerList" aus "provider_book_items" erzeugt eine neue Zeile.
2. Header werden in der "chapters" Spalte abgespeichert. Die "sub_chapters" Spalte eines Headers bleibt leer.
3. Subtopics werden in der "sub_chapters" Spalte hinterlegt und die ID des dazugehörigen Headers in der "chapters" Spalte.

Für "loadToDoList":
1. Jeder Eintrag wird zeilenweise eingelesen.
2. Headers werden aus der "chapters" Spalte eines Eintrags zurückgelesen. Sie zeichnen sich dadurch aus, dass die "sub_chapters" Spalte leer ist.
3. Subheader werden aus der "sub_chapters" Spalte gelesen. Sie ID des zugehörigen Headers findet sich in der "headers" Spalte.