[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)


# odsAutomationR
Mit dem `odsAutomationR` kann direkt aus R heraus auf die Automation API von Opendatasoft zugegriffen werden. Voraussetzung dafür ist, dass die API freigeschalten ist. Die ausführliche Dokumentation der API schnittstelle findet sich [hier](https://betahelp.opendatasoft.com/apis/ods-automation-v1/#tag/Datasets).

## Installation

Die Dvelopement Version des Packages kann wie folgt installiert und genutzt werden:

``` r
devtools::install_github("ogdtg/odsAutomationR")
library(odsManagementR)
```

## Variablen initialisieren

Um Zugang zum jeweiligen ODS Portal zu bekommen und die Funktionalitäten der API nutzen zu können, muss zuerst `api_type`,`domain`, `path` und `key` initialisiert werden. Dazu können die entsprechnenden set Funktionen verwendet werden.

```r

setKey("XXXXXXXXXXXXX") # API Key mit den entsprechenden berechtigungen
setDomain("data.tg.ch") # Domain der Datenplattform
setApiType("automation/v1.0") # Falls neue Versionen der API ersheinen, kann hier z.b. automation/v1.1 gesetzt werden
setPath("path/to/data_catalog.csv") # OPTIONAL: Ort, an dem Metadaten Katalog lokal gespeichert werden soll bei get_dataset_info

```
Um zu verhindern, dass diese Variablen jedes mal aufs neue gesetzt werden müssen, können diese mit `usethis::edit_r_environ()` ins globale R environment eingetragen werden. Nach dem ausführen der Funktion öffnet sich ebenjenes und man kann die Variablen in folgendem Schema eintragen:

```r
ODS_DOMAIN=data.tg.ch
ODS_APITYPE=automation/v1.0
ODS_KEY=XXXXXXXXXXXXXX
ODS_PATH=path/to/data_catalog.csv

```
Um auf diese Variablen zugreifen zu können, muss R einmal neu gestartet werden. Danach werden die `set` Funktionen nur benötigt, wenn eine Änderung gewünscht ist.

## API Key erstellen

Ein API Key kann direkt über die `create_key` Funktion erstellt werden. Hier können auch Keys erstellt werden, die nur benutzerdefinierte Berechtigungen besitzen. Dies kann nützlich sein, wenn man zum Beispiel einer Person aus einem Amt Zugang zur API geben möchte, ohne dieser direkt alle Berechtigungen zu erteilen.

Gibt man keine benutzerdefinierte Liste für das Argument `permissions` an, werden per default alle Berechtigungen erteilt.

```r
key <- create_key(
            key_name="Name des Keys",
            username="max.mustermann@tg.ch",
            password = "xxxxxxxxx",
             domain = "data.tg.ch",
            permissions = list(
              "edit_dataset",
              "publish_dataset"
              )
)

```

## Liste aller Datensätze und ihrer Metadaten erhalten

Mit der Funktion `get_dataset_info` wird der aktuelle Metdata Katalog heruntergeladen. Dieser beinhaltet die Metadaten aller Datensätze, die sich derzeit auf dem Datenportal befinden. Hierzu zählen auch unveröffentlichte Datensätze sowie Datenkataloge. Die Funktion erzeugt automatisch eine Environment Variable `metadata_catalog`, die die Daten erhält. Die Funktion wird von mehreren anderen Funktionen verwendet, um sicher zugehen, dass der Katalog immer auf dem neuesten Stand ist. Ausserdem wird der Katalog jedes mal auf dem Lokalen Pfad, der bei `path` angegeben ist gespeichert.

*Der Parameter `path` ist standardmässig auf einen lokalen Order des Kantons gesetzt, kann aber geändert werden.*

``` r
get_dataset_info(path=path)
## creates variable "metadata_catalog" and saves it under path 
```

## Titel, UID und ID sowie einzelne Vraiablen erhalten

Mit der `get_catalog` können Metadaten von veröffentlichten Datensätzen bezogen werden. Veröffentlicht heisst in diesem Falle nicht, dass die Datensätze für alle User sichtbar und zugänglich sind, sondern lediglich, dass der "Veröffentlichen" Prozess ausgeführt wurde. 

Ohne Argumente liefert die Funktion `dataset_id`, `dataset_uid` sowie `title`. Über das Argument `variables` können weitere Metadaten-Variablen in einem Vektor spezifiziert werden. Gibt man ausserdem die entsprechende `dataset_uid` mit, erhält man die Daten nur für den spezifizierten Datensatz.

Im Vergleich zur `get_dataset_info` Funktion ist diese Funktion wesentlich schneller und einfacher anpassbar, liefert allerdings keine Daten von unveröffentlichten Datensätzen. Die Funktion verwendet ausserdem nicht die Automation API sondern die Explore API.

```r

# Alle Datensätze ohne weitere Variablen
get_catalog()

# Standardvariablen aller Datensätze plus publisher und keyword
get_catalog(variables = c("publisher","keyword"))

# Standardvariablen für da_xxxx plus publisher und keyword  
get_catalog(dataset_uid = "da_xxxx",variables = c("publisher","keyword"))


```



## Neuen Datensatz erstellen

### Wrapper Funktion

Um Datensätze zu erstellen und sie direkt mit den Metadaten aus dem Excel Schema zu befüllen kann die wrapper-Funktion `add_metadata_from_scheme` verwendet werden. Hierzu muss lediglich der Pfad zum ausgefüllten Schema als `filepath` angeggeben werden. Die Funktion gibt die `dataset_uid` des neu erstellten Datensatzes zurück

Die einzelnen Schritte innerhalb der Funktion werden nachfolgend kurz beschrieben.

```r
dataset_uid <- add_metadata_from_scheme(filepath="path/to/schema.xlsx")

```

### Datensatzkennung erstellen
Bevor ein neuer Datensatz erstellt werden kann, muss eine passende Kennung erzeugt werden. Diese setzt sich im Kanton Thurgau wie folgt zusmamen: departement-amt-laufende Numemer (z.B. sk-stat-1). ODS erlaubt es eine Kennung für mehrere Datensätze anzulegen, da intern automatisch eine eindeutige `dataset_uid` zugewiesen wird. Daher muss darauf geachtet werden, dass die Kennungen eindeutig sind, um Verwirrungen zu vermeiden. Die `create_new_dataset_id` gewährleistet eindeutige Kennungen, indem sie einer gegebenen Teilkennung die korrekte laufende Nummer zuweist.

``` r
dataset_id <- create_new_dataset_id(part_id = "sk-stat")
## returns "sk-stat-116" 
```


### Metadaten einfügen
Metadate können mithilfe der `set_metadata` Funktion eingefügt werden. Beim Parameter `dataset_id` muss die `dataset_uid` in Form `da-xxxxxx` anegeben werden. Dieser Parameter gibt an, für welchen Datensatz Metadaten gesetzt werden sollen. Die verfügbaren Werte für `template` können den Metadaten eines Datensatzes entnommen werden (Funktion `get_metadata(dataset_uid)`). Für data.tg.ch sind dies `custom`,`visualization`,`dcat`,`default`,`dcat_ap_ch` oder `internal`. Diese Werte sind als eine Art Übergruppe der einzelnen Metadaten zu verstehen und tauchen so teilweise auch im ODS Backend auf. Als `meta_name` muss der entsprechende Wert des Metadaten FelDes angegeben werden (z.B. `title`). Schliesslich muss der Wert, der gesetzt werden soll als `meta_value` angegeben werden. Für manche Metadaten Felder muss eine Liste als `meta_value` angegeben werden. Innerhalb der `add_metadata_from_scheme` Funktion wird für diesen Umstand kontrolliert und es werden automatisch listen erzeugt, wo es notwendig ist. Weitere Informatioenn können der offiziellen [Dokumentation der ODS Management API](https://betahelp.opendatasoft.com/management-api/#dataset-metadata) entnommen werden.

```r
set_metadata(dataset_id = "da-xxxxxx",
             template="default",
             meta_name="title",
             meta_value = "New Title for Dataset")

```

## Metadaten und Field Configuration updaten

Um einen bestehenden Datensatz updaten zu könenn, kann die `update_metadata_and_fields` Funktion verwendet werden.

```r
update_metadata_and_fields(dataset_uid = "da_xxxxx", filepath = "path/to/schema.xlsx")

```

## Daten hinzufügen

### CSV-File zu Datensatz hinzufügen

Um CSV Dateien vom lokalen System ins ODS zu laden, den im vorherigen Schritt erstellten Metadatensatz mit der Datenresource zu verbinden und die Spaltenbeschreibungen und Datentypen zu bearbeiten, kann die `add_file_to_dataset` Funktion verwendet werden. Als Parameter muss hier die `dataset_uid` anegegeben werden, die `add_metadata_from_scheme` zurück gibt. Ausserdem muss der Pfad zum lokalen CSV File mit den Daten angegeben werden sowie das entsprechende Encoding. 

```r
add_file_to_dataset(filepath "path/to/csv_file.csv",dataset_uid = "da_xxxx",encoding = "utf-8"){

```

### Spaltennamen und -beschreibungen sowie Datentypen ergänzen

Abschliessend müsssen noch die Spaltennamen bearbeitet, die Spaltenbeschreibungen hinzugefügt und die entsprechenden Datentypen zugewiesen werden. Wenn vorhanden, können ausserdem noch Einheiten hinzugefügt werden, was eine verbesserte Anzeige im ODS zur Folge hat, die Daten selbst aber nicht verändert. Für diese Aktionen werden die folgenden Funktionen verwendet:

* `rename_field`
* `add_description_to_field`
* `add_type`
* `add_unit`
* `add_timeserie_precision`
* `make_fields_sortable`


Mit der `edit_fields()` Funktion kann dies direkt aus dem Schema heraus erledigt werden (alle Funktionen können aber auch einzeln ausgeführt werden). Benötigt wird lediglich der Pfad zum Schema sowie die `dataset_uid`

```r

edit_fields(dataset_uid = dataset_uid, 
            schema = "path/to/schema.xlsx")

```

## Datensatz veröffentlichen

Datensätze können mithilfe der `publish_dataset` veröffentlicht werden. Dazu muss lediglich die `dataset_uid` Datensatzes angegeben werden. Es ist zu beachten, dass die Sicherheitseinstellungen (wer kann den Datensatz sehen) mit dieser Funktion NICHT verändert werden. 

```r

publish_dataset("da-xxxxxx")

```


## Datensatz löschen

Datensätze können mithilfe der `delete_dataset` gelöscht werden. Dazu muss lediglich die `dataset_uid`, die `dataset_id` oder der Titel des Datensatzes angegeben werden. Vor der Löschung wird ausserdem noch einmal nach einer Bestätigung gefragt, um versehentliche Löschungen zu vermeiden. Um dies zu deaktivierne kann `ask=FALSE` gesetzt werden.

```r

delete_dataset("da-xxxxxx", ask = FALSE)


```




