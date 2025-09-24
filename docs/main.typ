
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
Als Honeypots wurde *Cowrie* (#link("github.com/cowrie/cowrie")) gewählt, da es speziell auf SSH-Angriffe ausgelegt ist und damit besonders gut zur Analyse von Angreifermethoden geeignet ist. IIm Vergleich zu Web-Honeypots wie Glastopf (#link("github.com/mushorg/glastopf")) ist Cowrie deutlich einfacher einzurichten und zu betreiben, insbesondere da bereits ein fertiges Docker-Image verfügbar ist. Außerdem mussten wir den Umfang des Monitorings begrenzen, weshalb die Unterstützung eines einzelnen Honeypot-Typs sinnvoll erschien. Cowrie erlaubt so eine fokussierte Untersuchung von Angriffsmustern bei gleichzeitig überschaubarem Aufwand.

Für die Verarbeitung und Analyse der Honeypot-Logs wurden Teile des ELK-Stacks bestehend aus *Filebeat*, *Logstash* und *Elasticsearch* eingesetzt. Zum einen geschah dies aus eigenem Interesse, da der ELK-Stack häufig in Unternehmensumgebungen verwendet wird, zum anderen ermöglicht die "für einanander bestimmte" Zusammenlegung der einzelnen Komponenten eine effiziente Erfassung, Verarbeitung und Strukturierung der Logs innerhalb eines konsistenten Systems.

Das Frontend wurde mit *Vue.js* umgesetzt, da dieses Framework im Vergleich zu Angular und React besonders einsteigerfreundlich und übersichtlich strukturiert ist. Vue.js ermöglicht eine schnelle Umsetzung von Komponenten bei gleichzeitig geringem Einarbeitungsaufwand, was die Entwicklung effizient gestaltet. Zudem wurden durch positive Erfahrungsberichte aus dem Bekanntenkreis Neugier und Interesse geweckt, während Angular und ähnliche Frameworks aufgrund ihrer Komplexität zunächst eher abschreckend wirkten.

Das Backend wurde mit *Spring Boot* umgesetzt, da es in Enterprise Umgebungen weit verbreitet ist und damit die Möglichkeit bietet, praktische Erfahrungen zu sammeln sowie Kenntnisse in Java zu vertiefen. Durch das Maven-Plugin-System lässt sich Spring Boot problemlos mit Elasticsearch integrieren, sodass Logs aus dem Honeypot-System effizient verarbeitet und analysiert werden können. Darüber hinaus bietet Spring Boot umfangreiche Sicherheitsfunktionen, durch Spring Security, die eine einfache Umsetzung von Authentifizierung, Autorisierung und Rollenmanagement ermöglichen. 

*PostgreSQL* wurde als Datenbank gewählt, da bereits in früheren Projekten praktische Erfahrungen mit diesem System gesammelt wurden. Es dient als zentrale Komponente für das User-Management sowie das Handling von Tokens und ermöglicht eine zuverlässige, relationale Speicherung und Verwaltung der entsprechenden Daten.

Als Reverse Proxy und Loadbalancer wurde *NGINX* eingesetzt, da es sich durch einfache Konfiguration, hohe Performance und breite Verbreitung in Enterprise-Umgebungen auszeichnet. Es ermöglicht die Verteilung von Anfragen auf mehrere Backend-Instanzen, erhöht die Verfügbarkeit und unterstützt somit direkt die beiden nicht-funktionalen Anforderungen Ausfallsicherheit und Skalierbarkeit des Systems.

== Systemkomponenten
=== Cowrie
=== Filebeat, Logstash, Elastic Search
=== Vue.js
=== Springboot
=== PostgreSQL
=== NGINX

#pagebreak()


= Umsetzung
== Implementierung
=== Security
#image("assets/spring-security.png")

== Schwierigkeiten & Lösungen

=== Vue.js SPA - NGINX
Bei der Bereitstellung der Vue.js-Frontend-Applikation als Single Page Application (SPA) in Kombination mit NGINX traten typische Routing-Probleme auf: Standardmäßig versucht NGINX, Anfragen direkt auf Dateien im Dateisystem zuzuordnen, was bei SPA-Routen zu „404 Not Found“-Fehlern führen kann. Dieses Problem wurde durch eine angepasste NGINX-Konfiguration gelöst, die innerhalb des Vue Docker-Images genutzt wird:

```nginx
server {
    listen 80;
    root /usr/share/nginx/html;
    index index.html;
    location / {
        try_files $uri $uri/ /index.html;
    }
}
```
Die try_files Direktive sorgt dafür, dass alle nicht vorhandenen Pfade auf index.html umgeleitet werden, sodass das Vue-Routing korrekt funktioniert. Dadurch konnten die SPA-Routen zuverlässig aufgelöst und die Frontend-Anwendung wie vorgesehen bereitgestellt werden.

=== Datenbank-Initialisierung Race Condition

Beim Betrieb von drei Spring-Boot-Instanzen gleichzeitig kam es zu einer Race Condition: Alle Instanzen versuchten beim Start die Datenbank in PostgreSQL zu initialisieren. Dadurch konnten Inkonsistenzen oder Fehler beim Anlegen von Tabellen und Schemata entstehen.

Die Lösung bestand darin, ein SQL-Initialisierungsfile beim Start des PostgreSQL-Docker-Containers zu verwenden, das das benötigte Schema einmalig anlegt. Auf diese Weise wird die Datenbank sauber initialisiert, ohne das dies von Spring Boots Seite aus geschieht.

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