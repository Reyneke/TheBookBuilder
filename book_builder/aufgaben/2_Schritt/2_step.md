Es soll, zur Sicherheit der Einträge in der Datenbank, ein Semaphorenkonzept erzeugt werden.
    
1. Die ID eines Nutzers, der einen header oder ein subtopic bearbeitet (die Funktion "toDoBottomSheet" wurde aufgerufen), wird im Onlinemodus in der Spalte "in_use_by" hinterlegt. Im Offlinemodus übernimmt eine Sperrvariable diese Funktion.
2. Ist der Nutzer mit der Bearbeitung fertig (der "Bottom Sheet wurde dismissed), wird der Eintrag wieder entfernt. Zeitgleich ist sicherzustellen, etwa durch einen Timer, dass ein Livelock oder Deadlock vermieden wird.
3. Solange ein header / subtopic gesperrt ist, kann es nur gelesen, aber nicht bearbeitet werden.