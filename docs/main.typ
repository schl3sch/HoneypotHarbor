
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
== Nicht Funktional

#pagebreak()

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

#pagebreak()


= Umsetzung
== Implementierung
=== Security
#image("assets/spring-security.png",)


#pagebreak()

== Schwierigkeiten & Lösungen
== Mögliche Alternativen


#pagebreak()
= Reflektion
== Lessons Learned
== Herausforderungen


#pagebreak()
= Fazit

#pagebreak()
#bibliography("bibliograpy.bib")