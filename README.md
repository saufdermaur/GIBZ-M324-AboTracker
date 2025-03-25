# Abo-Tracker

## 1. Einleitung

Dieses Dokument beschreibt die Implementierung eines webbasierten Abonnement- und Buchungssystems mit Flutter. Das System ermöglicht das Erstellen von Gruppen, die als Abonnements fungieren, und die Zuweisung von Benutzern zu diesen Gruppen. Ziel ist es, die Verwaltung von Abonnements und die Abrechnung von Buchungen effizient zu gestalten.

## 2. Funktionsumfang

* CRUD-Operationen: Erstellung, Bearbeitung, Löschung und Anzeige von Benutzern, Gruppen (Abonnements) und Buchungen.
* Gruppen (Abonnements): Jede Gruppe hat einen Preis und eine festgelegte Anzahl verfügbarer Buchungen. Beispiel: Ein Abonnement für 750 CHF erlaubt 50 Buchungen.
* Buchungen: Innerhalb einer Gruppe können Buchungen erstellt und teilnehmende Benutzer ausgewählt werden. Jede Buchung reduziert die verfügbare Anzahl der Buchungen um eins.
* Kostenverteilung: Die teilnehmenden Benutzer einer Buchung zahlen anteilig an den Kosten des Abonnements. Übersicht über die individuellen Zahlungen.

## 3. Technische Umsetzung

* Frontend: Umsetzung mit Flutter als Web-Applikation.
* Backend und Datenbank: Verwendung von Supabase für Authentifizierung, Datenhaltung und Backend-Funktionalitäten.
* Deployment:
    * Branching-Modell in GitLab: 'main' ist für das Production-Deployment zuständig.
    * Preview-Deployments und Production-Deployments erfolgen in Vercel.
* Monitoring und Logging:
    * Supabase für Datenbank-Logging.
    * Uptime Kuma für Monitoring der Erreichbarkeit.
    * Vercel für Deployment-Monitoring.
    * New Relic für detailliertes Performance-Monitoring.
* Sicherheitsanalyse: Einsatz von Snyk für statische Code-Analyse und Sicherheitsüberprüfung.

## 4. Anwendungsfälle

* Erstellen eines neuen Abonnements: Administrator legt Preis und verfügbare Buchungen fest.
* Zuweisen von Benutzern zu Abonnements: Benutzer können zu Gruppen hinzugefügt oder daraus entfernt werden.
* Durchführen einer Buchung: Benutzer initiieren eine Buchung und wählen teilnehmende Benutzer aus. Die verfügbaren Buchungen reduzieren sich um eins.
* Abrechnung: Die Kosten einer Buchung werden anteilig auf die teilnehmenden Benutzer verteilt.

## 5. Fazit

Durch die Implementierung des Systems wird eine effiziente Verwaltung von Abonnements und eine transparente Abrechnung von Buchungen ermöglicht. Der Einsatz moderner Technologien wie Flutter, Supabase und Vercel gewährleistet eine skalierbare und performante Lösung.

---

## Klassendiagramm

Damit die oben genannten Funktionalität erfolgreich umgesetzt werden können, sind folgende Tabellen und dessen Realtionen zu implementieren.

![Klassendiagramm](/Assets/class-diagram.png)

## Komponentendiagramm
![Komponentendiagramm](/Assets/component-diagram.png)

Die Kommunikation zwischen den Komponenten erfolgt über standardisierte API-Schnittstellen. Durch die Nutzung verschiedener Services unterschiedlicher Anbieter wird eine lose gekoppelte Architektur gewährleistet. Auf ein dediziertes Backend wird verzichtet, da Supabase eine Client-Library zur Verfügung stellt, die direkte Datenbankanfragen ermöglicht. Dadurch wird die Komplexität reduziert, ohne die Funktionalität einzuschränken.