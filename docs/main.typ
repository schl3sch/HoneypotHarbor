
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