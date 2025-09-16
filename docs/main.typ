
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

= Anforderungen
== Funktional
== Nicht Funktional

= Architektur & Konzept
== Allgemeiner Aufbau
== Architektonische Entscheidungen
== Systemkomponenten
=== Cowrie
=== Filebeat, Logstash, Elastic Search
=== Springboot
=== PostgreSQL
=== Vue JS
=== NGINX

= Umsetzung
== Implementierung
== Schwierigkeiten & Lösungen
== Mögliche Alternativen

= Reflektion
== Lessons Learned
== Herausforderungen

= Fazit

#pagebreak()
#bibliography("bibliograpy.bib")