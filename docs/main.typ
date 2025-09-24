
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

#pagebreak()


= Anforderungen
== Funktional

*Honeypot-Interaktion:*
- SSH-Sessions (Befehle, Login-Versuche, Transfers) aufzeichnen.
- Mehrere Honeypots parallel betreiben.

*Log-Verarbeitung:*
- Alle Honeypot-Logs automatisch an einen zentralen Sammelpunkt (z. B. Filebeat → Logstash -> Elastic Search) senden.
- Parsing und Anreicherung mit Nutzung von GeoIP.

*Analysten-Schnittstelle:*
- Frontend zur Visualisierung mit Hilfe eines Dashboards.

*Loadbalancer-Funktion:*
- Verteilung von Nutzeranfragen (Analysten) über mehrere Front- und Backend-Komponenten.
- Sicherstellung von hoher Verfügbarkeit.

== Nicht Funktional

*Sicherheit:* 
- Strikte Isolation der Honeypot-Systeme vom produktiven Netz.
- Nur kontrollierter Datentransfer (Logs, Metadaten) über das Gateway.
- Zugriff aup API nur als Autorisierte Person möglich.

*Skalierbarkeit:*
- Einfache Erweiterbarkeit durch Hinzufügen weiterer Honeypots.
- Erweitrebarkeit des Front und Backends für Lastenverteilung 

*Verfügbarkeit:*
- Loadbalancer verhindert Single Point of Failure.

#pagebreak()

= Architektur & Konzept
== Allgemeiner Aufbau

#image("assets/honeypotharbor-architecture.png",)

== Architektonische Entscheidungen


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
- Multi-instance DB schema race condition 
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

@Schmidt2023 so gehen verweise ...

#pagebreak()
#bibliography("bibliograpy.bib")