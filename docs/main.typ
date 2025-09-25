
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

#figure(
  image("assets/honeypotharbor-architecture.png", width: 100%),
  caption: [Data Flow Honeypot Harbor],
) <data-flow>

== Architektur Entscheidungen
Als Honeypots wurde *Cowrie* (#link("github.com/cowrie/cowrie")) gewählt, da es speziell auf SSH-Angriffe ausgelegt ist und damit besonders gut zur Analyse von Angreifermethoden geeignet ist. Im Vergleich zu Web-Honeypots wie Glastopf (#link("github.com/mushorg/glastopf")) ist Cowrie deutlich einfacher einzurichten und zu betreiben, insbesondere da bereits ein fertiges Docker-Image verfügbar ist. Außerdem mussten wir den Umfang des Monitorings begrenzen, weshalb die Unterstützung eines einzelnen Honeypot-Typs sinnvoll erschien. Cowrie erlaubt so eine fokussierte Untersuchung von Angriffsmustern bei gleichzeitig überschaubarem Aufwand.

Für die Verarbeitung und Analyse der Honeypot-Logs wurden Teile des ELK-Stacks bestehend aus *Filebeat*, *Logstash* und *Elasticsearch* eingesetzt. Zum einen geschah dies aus eigenem Interesse, da der ELK-Stack häufig in Unternehmensumgebungen verwendet wird, zum anderen ermöglicht die "für einanander bestimmte" Zusammenlegung der einzelnen Komponenten eine effiziente Erfassung, Verarbeitung und Strukturierung der Logs innerhalb eines konsistenten Systems.

Das Frontend wurde mit *Vue.js* umgesetzt, da dieses Framework im Vergleich zu Angular und React besonders einsteigerfreundlich und übersichtlich strukturiert ist. Vue.js ermöglicht eine schnelle Umsetzung von Komponenten bei gleichzeitig geringem Einarbeitungsaufwand, was die Entwicklung effizient gestaltet. Zudem wurden durch positive Erfahrungsberichte aus dem Bekanntenkreis Neugier und Interesse geweckt, während Angular und ähnliche Frameworks aufgrund ihrer Komplexität zunächst eher abschreckend wirkten.

Das Backend wurde mit *Spring Boot* umgesetzt, da es in Enterprise Umgebungen weit verbreitet ist und damit die Möglichkeit bietet, praktische Erfahrungen zu sammeln sowie Kenntnisse in Java zu vertiefen. Durch das Maven-Plugin-System lässt sich Spring Boot problemlos mit Elasticsearch integrieren, sodass Logs aus dem Honeypot-System effizient verarbeitet und analysiert werden können. Darüber hinaus bietet Spring Boot umfangreiche Sicherheitsfunktionen, durch Spring Security, die eine einfache Umsetzung von Authentifizierung, Autorisierung und Rollenmanagement ermöglichen. 

*PostgreSQL* wurde als Datenbank gewählt, da bereits in früheren Projekten praktische Erfahrungen mit diesem System gesammelt wurden. Es dient als zentrale Komponente für das User-Management sowie das Handling von Tokens und ermöglicht eine zuverlässige, relationale Speicherung und Verwaltung der entsprechenden Daten.

Als Reverse Proxy und Loadbalancer wurde *NGINX* eingesetzt, da es sich durch einfache Konfiguration, hohe Performance und breite Verbreitung in Enterprise-Umgebungen auszeichnet. Es ermöglicht die Verteilung von Anfragen auf mehrere Backend-Instanzen, erhöht die Verfügbarkeit und unterstützt somit direkt die beiden nicht-funktionalen Anforderungen Ausfallsicherheit und Skalierbarkeit des Systems.

== Systemkomponenten
=== Cowrie
Cowrie als Honeypot bietet einige Konfigurationsmöglichkeiten. Standardmäßig würde Cowrie eine Standardkonfiguration (cowrie.cfg), sowie eine Standarddatei für zugelassene Anmeldeinformationen (userdb.txt) verwenden. In der cowrie.cfg können unter anderem Hostname, Betriebssystemname, SSH-Version, IP-Adresse, Ports und andere Variablen definiert werden @cabral2021advanced. Mithilfe von mounts im docker-compose.yml können diese Dateien überschrieben werden. Beim Hochfahren einer Cowrie-Instanz werden die konfigurierten Dateien gelesen und es können ssh-Verbindungen zum Honeypot hergestellt werden. Durch den Befehl ssh -p 2222 \<username\>\@\<IPvonHoneypot\> kann sich mit einem der Honeypots verbunden werden. 
Unmittelbar nach Eingabe des Befehl wird eine Eingabe von Benutzername und Passwort gefordert. Welche Benutzernamen und Passwörter zugelassen sind, wird in der userdb.txt festgehalten. Im Honeypot können dann Befehle, wie z.B. whoami ausgeführt werden. 

Während dem Prozess des Anmeldens oder des Verbindungsversuches des Angreifers werden selbst nur die Verbindungsversuche schon geloggt. Alles was danach passiert, wird ebenfalls geloggt und in einer JSON-Datei (cowrie.json) gespeichert. Die Ausgabe als JSON-Datei anstelle von tty-Logs muss vorher explizit in der cowrie.cfg erlaubt werden.

=== Filebeat, Logstash, Elastic Search
Um die Logs des Honeypots zu sammeln und weiterzuleiten wurde sich für Filebeat, Logstash und ElasticSearch entschieden. Filebeat kümmert sich darum die entstandenen Logs von Cowrie zu sammeln. Dies geschieht durch den mount der Cowrie Logs mit den darin vorhandenen cowrie.json Dateien in Kombination mit der Filebeat Konfiguration (filebeat.yml).
In der filebeat.yml wird konfiguriert, dass die Logs in Echtzeit gelesen werden (über den typ filestream) und jeder Cowrie Honeypot eine unterschiedliche id hat, um die Logs im späteren Verlauf unterscheiden zu können. In der filebeat.yml wird ebenso der Output angegeben, wohin die Logs weitergeleitet werden sollen. Als Output wird der Host angegeben, in diesem Fall Logstash. Außerdem fungiert Filebeat als Gateway zwischen dem Attacker-Netzwerk und dem Internal-Netzwerk und ist daher in beiden Netzwerken angebunden, um die Logs weiterzuleiten.

Logstash ist ein Datenverarbeitungs-Pipeline-Tool, das Daten transformiert und an Zielsysteme wie in diesem Fall ElasticSearch weiterleitet. Mittels der Erweiterung GeoIP können zusätzlich IP Adressen in den aufgelöst werden und Geodaten, wie Koordinaten oder Stadt, in die Logs hinzufügen. Konfiguriert wird Logstash in einer Konfigurationsdatei (logstash.conf).
In der logstash.conf können unter anderem Filter angegeben werden, dass z.B. nur aktuelle Logs und nur Logs, die von Cowrie stammen, genommen werden. Am Ende der Konfigurationsdatei wird wieder der Output angegeben. Als Output wird in diesem Fall der Host von ElasticSearch angegeben.

ElasticSearch speichert die gesammelten und transformierten Daten nahezu in Echtzeit. Mithilfe von ElasticSearch können die Logs der Cowrie-Honeypots einfach durchsucht und abgerufen werden.


=== Vue.js

Das Frontend wurde mit Vue.js unter Nutzung der Composition API umgesetzt. Es dient in erster Linie der Visualisierung und Verwaltung der im System gesammelten Daten. Über verschiedene Dashboards können Honeypot Logs eingesehen und ausgewertet werden. Zusätzlich bietet das Frontend ein User-Management, bei dem Rollen und Zugriffsrechte berücksichtigt werden. Da die Anwendungslogik bewusst im Backend gekapselt wurde, besteht die Hauptaufgabe des Frontends im regelmäßigen Polling der Backend API, um aktuelle Daten (Logs, User-Informationen) darzustellen. Dadurch bleibt das Frontend schlank und übersichtlicher, während die eigentliche Logik zentralisiert im Backend abgebildet ist.

=== Springboot

Das Backend wurde mit Spring Boot umgesetzt und fungiert als zentrale Schnittstelle zu den beiden Datenbanken. Neben der Weiterleitung von Logdaten aus Elasticsearch ist es für das gesamte User-Management verantwortlich. Hierbei kommt ein rollenbasiertes Zugriffssystem (Role-Based Access Control) zum Einsatz, welches durch Spring Security realisiert wird. Die Architektur folgt einem klassischen Domain-Ansatz mit klar getrennten Schichten d.h. Controller, DTOs, und Services. Somit bleibt die Logik wartbar, erweiterbar und klar strukturiert.

=== PostgreSQL

PostgreSQL wird ausschließlich für das User-Management und die Verwaltung von Tokens verwendet. Durch die Anbindung an Spring Security lassen sich Authentifizierung und Autorisierung effizient und sicher umsetzen. Diese klare Trennung zwischen Logdaten (Elasticsearch) und Benutzerdaten (PostgreSQL) ermöglicht eine saubere Rollenverteilung zwischen Analyse- und Verwaltungsaufgaben und erhöht die Sicherheit des Gesamtsystems.

=== NGINX

Als Reverse Proxy und Load Balancer übernimmt NGINX mehrere zentrale Aufgaben in der Architektur. Zum einen verteilt es Anfragen auf mehrere Backend Instanzen und sorgt so für Lastverteilung und Failover. Zum anderen übernimmt es das Routing: Frontend Anfragen werden an Vue.js weitergeleitet, API-Calls gezielt an das Spring Boot Backend. Darüber hinaus werden auch Logstash Instanzen über NGINX angebunden, sodass die Last der eingehenden Logs effizient auf drei Instanzen verteilt wird. Damit trägt NGINX sowohl zur Skalierbarkeit als auch zur Ausfallsicherheit des Gesamtsystems bei.

#pagebreak()


= Umsetzung
== Implementierung
=== Security
Die Gewährleistung der Sicherheit und die Verhinderung unautorisierter Datenexfiltration bei der API wurde in Spring Boot durch mehrere Mechanismen umgesetzt. Drei zentrale Maßnahmen werden im Folgenden näher erläutert.

Zunächst wurde ein API-Filter implementiert, der prüft, dass nur Requests mit einem gültigen "X-API-KEY" im Header weitergeleitet werden. Dadurch können ausschließlich autorisierte Clients, die über diesen Schlüssel verfügen, Anfragen an das Backend stellen.

Drauf aufbauend wurde ein weiterer Filter realisiert, der sicherstellt, dass nur Requests mit einem gültigen JWT (JSON Web Token) akzeptiert werden. Auf diese Weise werden alle Endpunkte, die nicht direkt für Login- oder Registrierungsvorgänge zuständig sind, effektiv geschützt. Der JWT-Prozess wird in @spring-jwt abgebildet, welche die Architektur und Funktionsweise veranschaulicht.

#figure(
  image("assets/spring-security.png", width: 100%),
  caption: [Spring Security JWT @spring-sec],
) <spring-jwt>

Als dritte Sicherheitsmaßnahme wurde Role-Based Access Control (RBAC) umgesetzt, die mit Hilfe der Annotation "\@PreAuthorize" in Spring Security implementiert ist. Dadurch können Endpunkte gezielt basierend auf Benutzerrollen geschützt werden. @springMethodSecurity

=== Loadbalancing und Failover

Die Verteilung der Anfragen auf mehrere Frontend- und Backend-Instanzen wurde durch NGINX als Reverse Proxy und Loadbalancer verwirklicht. Im HTTP-Bereich werden die Requests für das Frontend mit Round Robin auf drei Server verteilt, während die Backend-Anfragen mit der "Least Connections Strategie" an drei Spring-Boot-Instanzen weitergeleitet werden. Untersuchungen zeigen, dass Round Robin bei Anfragen mit meist ähnlicher Last effizient ist was bei Frontend Anfragen der Fall ist, während Least Connections für Backend-Server mit unterschiedlich großen und variierenden Requests die Antwortzeiten optimiert und die Ressourcennutzung verbessert. @article @geeksforgeeksNetworkLoad

Für die Backend Upstream Gruppe sorgt NGINX-Failover dafür, dass Anfragen automatisch auf andere Instanzen weitergeleitet werden, wenn eine Backend-Instanz fehlschlägt oder nicht antwortet:
```conf
location /api/ {
    proxy_pass http://backend;
    proxy_next_upstream error timeout invalid_header http_500 http_502 http_503 http_504;
    proxy_next_upstream_tries 3;
    proxy_connect_timeout 2s;
    proxy_read_timeout 15s;
}
```
Damit wird die Verfügbarkeit der API auch bei Ausfällen einzelner Backend-Server gewährleistet.

Die Log Weiterleitung von Filebeat zu Logstash wurde der Stream-Modus von NGINX verwendet, wodurch eingehende TCP Verbindungen ebenfalls auf mehrere Logstash Instanzen verteilt werden.

=== Vue.js Composition API

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
"try_files" sorgt dafür, dass alle nicht vorhandenen Pfade auf index.html umgeleitet werden, sodass das Vue-Routing korrekt funktioniert. Dadurch konnten die SPA-Routen zuverlässig aufgelöst und die Frontend-Anwendung wie vorgesehen bereitgestellt werden. @shapeOptimizingNginx

=== Datenbank-Initialisierung Race Condition

Beim Betrieb von drei Spring-Boot-Instanzen gleichzeitig kam es zu einer Race Condition: Alle Instanzen versuchten beim Start die Datenbank in PostgreSQL zu initialisieren. Dadurch konnten Inkonsistenzen oder Fehler beim Anlegen von Tabellen und Schemata entstehen.

Die Lösung bestand darin, ein SQL-Initialisierungsfile beim Start des PostgreSQL-Docker-Containers zu verwenden, das das benötigte Schema einmalig anlegt. Auf diese Weise wird die Datenbank sauber initialisiert, ohne das dies von Spring Boots Seite aus geschieht.

=== Kommunikation mit Macvlan-Netzwerken

Ein weiteres Problem trat beim Einsatz von Docker-Macvlan Netzwerken auf. Standardmäßig können Container in einem Macvlan Netz nicht direkt mit dem Host kommunizieren. Dies liegt daran, dass Macvlan eine separate virtuelle Netzwerkschnittstelle erstellt, die auf Ebene von Layer 2 arbeitet und dem Container eine eigene MAC-Adresse zuweist. Der Host selbst ist dabei jedoch nicht Teil der gleichen Broadcast Domaine, da er die Pakete lediglich weiterleitet, aber keine eigene Präsenz im Macvlan Segment besitzt. Für die Container wirkt der Host daher wie ein externer Knoten außerhalb des Netzes, was die direkte Kommunikation verhindert.

Diese Einschränkung erschwerte die Integration der Honeypot-Umgebung erheblich. So war es beispielsweise nicht möglich, von außen (vom Host) auf die Honeypots zuzugreifen oder das Frontend im Browser zu öffnen. Praktisch bedeutete dies, dass die Container zwar untereinander kommunizieren konnten, die Interaktion mit dem Host jedoch blockiert war.

Die Lösung bestand darin, ein sogenanntes Shim-Netzwerk zu konfigurieren, um die Kommunikation zwischen Host und Macvlan-Containern zu ermöglichen. Dabei wurden die Macvlan-Netzwerke so erweitert, dass der Host explizit eine eigene Adresse innerhalb des jeweiligen Subnetzes erhielt. In Docker wurde dies über die Option --aux-address umgesetzt:

```sh
# Shim net für internal-net (Frontend/Backend) 
docker network create -d macvlan \
  --subnet=192.168.1.0/25 \
  --gateway=192.168.1.1 \
  --aux-address 'host=192.168.1.126' \
  -o parent=veth0 \
  honeypotharbor-internal-network 
```
Die --aux-address reserviert dabei eine feste IP-Adresse für den Host im Macvlan-Subnetz, sodass er wie ein regulärer Netzwerkteilnehmer behandelt wird. Zusätzlich wurde auf dem Host eine direkte Macvlan-Schnittstelle eingerichtet, um sicherzustellen, dass Pakete korrekt geroutet werden:
```sh
echo "Create internal Macvlan shim for Host-access."
sudo ip link add internal-net link veth0 type macvlan mode bridge
sudo ip addr add 192.168.1.126/25 dev internal-net 
sudo ip link set internal-net up
sudo ip route add 192.168.1.0/25 dev internal-net
```

- ip link add erstellt das virtuelle Interface auf Basis des Host-Interfaces.
- ip addr add weist die reservierte IP-Adresse zu.
- ip link set ... up aktiviert die Schnittstelle.
- ip route add sorgt dafür, dass alle Pakete an das Macvlan-Subnetz korrekt über das neue Interface laufen.

Durch diese Maßnahmen konnte der Host sowohl Anfragen an die Honeypots als auch an das Monitoring-Frontend weiterleiten. Die zuvor bestehende Kommunikationsbarriere zwischen Host und Containern wurde aufgehoben, sodass die Infrastruktur konsistent nutzbar war. @oddbitUsingDocker



=== Problematik fehlender Netzwerkkarte


== Mögliche Alternativen


#pagebreak()

= Reflektion
== Lessons Learned
== Herausforderungen

#pagebreak()

= Fazit

#pagebreak()
#bibliography("bibliograpy.bib")