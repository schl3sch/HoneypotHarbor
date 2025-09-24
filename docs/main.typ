
#import "@preview/basic-report:0.3.1": *

#show: it => basic-report(
  doc-category: "Dokumentation",
  doc-title: "Honeypot Harbor",
  author: "Simon Egger, Patrick Rais, Joel Schlegel",
  affiliation: "INF2023 - Verteilte Systeme",
  logo: image("assets/dhbw-logo.png", width: 5cm),
  language: "de",
  compact-mode: false,
  it
)


= Einleitung

Durch die IoT-Revolution ist es für Hacker zunehmend lukrativ geworden, automatisierte Skripte zu entwickeln, die das Internet durchsuchen und versuchen, Geräte zu kompromittieren @Chopra_2020. Unternehmen hingegen werden oft gezielter angegriffen. Sowohl für digital bewusste Privatpersonen als auch für Unternehmen ist es daher interessant, Einblicke in die Vorgehensweise von Angreifern zu gewinnen, um geeignete Schutzmaßnahmen zu implementieren.

Vor diesem Hintergrund wurde im Rahmen der Praxisarbeit der Vorlesung "Verteilte Systeme" entschieden, ein Honeypot-Netzwerk aufzubauen sowie das dazugehörige Monitoring-Netzwerk zu entwickeln. Die Arbeit verfolgt dabei zwei Hauptziele: Ausfallsicherheit und Skalierbarkeit. Gleichzeitig bot das Projekt die Gelegenheit, sich mit neuen Technologien vertraut zu machen und praktische Erfahrungen im Aufbau sicherer und skalierbarer Netzwerkinfrastrukturen zu sammeln.

#pagebreak()

= Anforderungen
== Funktional

*Honeypot-Interaktion:*
- SSH-Sessions (Befehle, Login-Versuche, Transfers) aufzeichnen.
- Mehrere Honeypots parallel betreiben.

*Log-Verarbeitung:*
- Alle Honeypot-Logs automatisch an einen zentralen Sammelpunkt senden.
- Parsing und Anreicherung der Logs mit Nutzung von GeoIP.

*Analysten-Schnittstelle:*
- Frontend zur Visualisierung mit Hilfe eines Dashboards.
- Backend-API für Abfragen und Reports.

*Loadbalancer-Funktion:*
- Verteilung von Nutzeranfragen (Analysten) über mehrere Front- und Backend-Komponenten.
- Sicherstellung von hoher Verfügbarkeit.

*Rollensystem:*
- Verschiedene Rollen mit bestimmten Berechtigungen um Zugriffe zu kontrollieren.
- Ein Admin sollte diese Rollen klar verwalten können.

== Nicht Funktional

*Sicherheit:* 
- Strikte Isolation der Honeypot-Systeme vom produktiven Netz.
- Nur kontrollierter Datentransfer (Logs, Metadaten) über das Gateway.
- Zugriff aup API nur als Autorisierte Person möglich.

*Skalierbarkeit:*
- Einfache Erweiterbarkeit durch Hinzufügen weiterer Honeypots.
- Erweitrebarkeit des Front und Backends für Lastenverteilung 

*Ausfallsicherheit:*
- Loadbalancer verhindert Single Point of Failure.

#pagebreak()

= Architektur & Konzept
== Allgemeiner Aufbau

#image("assets/honeypotharbor-architecture.png",)

== Architektur Entscheidungen


== Systemkomponenten
=== Cowrie
=== Filebeat, Logstash, Elastic Search
=== Springboot
=== PostgreSQL
=== Vue JS
=== NGINX

#pagebreak()


= Umsetzung
== Implementierung
=== Security
#image("assets/spring-security.png")

== Schwierigkeiten & Lösungen
- vue - nginx SPA
- Race Condition beim gleichzeitigen Schreiben in die Datenbank.
- macvlan veth interface
- macvlan shim net
== Mögliche Alternativen


#pagebreak()

= Reflektion
== Lessons Learned
== Herausforderungen

#pagebreak()

= Fazit

#pagebreak()
#bibliography("bibliograpy.bib")