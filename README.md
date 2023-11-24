[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)


# odsAutomationR
Mit dem `odsAutomationR` kann direkt aus R heraus auf die Automation API von Opendatasoft zugegriffen werden. Voraussetzung dafür ist, dass die API freigeschalten ist. Die ausführliche Dokumentation der API schnittstelle findet sich [hier](https://betahelp.opendatasoft.com/apis/ods-automation-v1/#tag/Datasets).

## Installation

Die Dvelopement Version des Packages kann wie folgt installiert und genutzt werden:

``` r
devtools::install_github("ogdtg/odsAutomationR")
library(odsAutomationR)
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

**EDIT:** Opendatasoft erlaubt mittlerweile auch das Erstellen von API-Keys mit entsprechenden Berechtigungen im Webinterface. Dazu einfach oben rechts auf die Schaltfläche mit dem Benutzernamen klicken. Es öffnen sich die Kontoeinstellungen. Unter *API-Keys* können benutzerdeifinierte Keys mit entsprechenden Berechtigungen erstellt werden.

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

## Metadaten

Die (Metadaten-) Struktur eines Datensatzes auf ODS folgt immer dem gleichen JSON-Aufbau:

```json

{
"dataset_id": "counties-united-states-of-america",
"is_restricted": true,
"metadata": {
  "default": {},
  "visualization": { },
  "internal": {},
  "custom_template_name": {}
  },
"default_security": {
  "is_data_visible": true,
  "visible_fields": [],
  "filter_query": "year!=2022",
  "api_calls_quota": {}
  }
}

```

Im `metadata` Teil entspricht jedes untergeordnete Element einem Metadaten Template. Das Template `default` enthält zum Beispiel folgende Metadaten:

```json


"default": {
"title": {
  "value": "Counties -  United States of America",
  "remote_value": "Counties -  United States of America",
  "override_remote_value": false
  },
"description": {},
"keyword": {},
"modified": {},
"modified_updates_on_metadata_change": {},
"modified_updates_on_data_change": {},
"geographic_reference": {},
"geographic_reference_auto": {},
"language": {},
"timezone": {},
"publisher": {},
"references": {},
"attributions": {}
```

Jedes Metadatenelement enthält dabei immer die Werte `value`, `remote_value` und `override_remote_value`. In der Regel ist für die Bearbeitung der Metadaten nur `value` relevant. Mehr Informationen [hier](https://help.opendatasoft.com/apis/ods-automation-v1/#tag/Datasets/operation/create-dataset).

Dieser JSON Aufbau liegt jedem die Metadaten betreffenden POST- und GET-Request zu Grunde.

### Metadaten eines Datensatzes erhalten

Um die Metadaten eines einzelnen Datensatzes zu erhalten, kann die `get_metadata` Funktion verwendet werden. Die Funktion gibt die Möglichkeit die Metadaten als data.frame oder als list ausgeben zu lassen. Um eine nach der oben beschriebenen JSON-Struktur formatierte Liste der Metadaten zu erhalten, setzt man `as_list=TRUE`.Bei `as_list=FALSE` erhält man einen data.frame mit den Metadaten.

[Mehr Informationen](https://help.opendatasoft.com/apis/ods-automation-v1/#tag/Datasets/operation/retrieve-dataset)


```r

metas_list <- get_metadata(dataset_uid = "da_xxxxx", as_list=TRUE)

metas_df <- get_metadata(dataset_uid = "da_xxxxx", as_list=FALSE)

```

### Datensatz aus Excel-Schema erstellen (TG spezifisch)

Um Datensätze zu erstellen und sie direkt mit den Metadaten aus dem Excel Schema zu befüllen kann die wrapper-Funktion `add_metadata_from_scheme` verwendet werden. Hierzu muss lediglich der Pfad zum ausgefüllten Schema als `filepath` angeggeben werden. Die Funktion gibt die `dataset_uid` des neu erstellten Datensatzes zurück


```r
dataset_uid <- add_metadata_from_scheme(filepath="path/to/schema.xlsx")

```

### Datensatz aus Metadaten data.frame erstellen

Wenn zum Beispiel ein Datensatz basierend auf einem anderen Datensatz erstellt werden soll (minimale Veränderungen wie z.B. Titelanpassung), kann die `create_dataset_from_df` Funktion verwendet werden.

Der Parameter `metadata_df` entspricht von der Struktur dem Ergebnis von `get_metadata("da_xxxxx",as_list = FALSE)`. Der Parameter `id_part` bezeichnet den Schlüssel Departement-Amt wie er auf data.tg.ch verwendet wird (z.B. "sk-stat"). Die laufende Nummer wird dann automatisch ergänzt.


[Mehr Informationen](https://help.opendatasoft.com/apis/ods-automation-v1/#tag/Datasets/operation/create-dataset)


```r

# Metadaten herunterladen
metadata_df <- get_metadata("da_xxxxx",as_list = FALSE)

# Titel anpassen
metadata_df$value[which(metadata_df$name=="title")] <- "Neuer Titel"

# Neuen Datensatz erstellen
create_dataset_from_df(metadata_df = metadata_df, id_part = "sk-stat")
```


### Einzelnen Metadaten-Eintrag verändern

Um bei einem bestehenden Datensatz einen einzelnen Metadaten-Eintrag zu ändern kann die `set_metadata` Funktion verwendet werden. Dazu benötigt man den Metadaten-Template-Namen `template`, den Namen des Metadaten-EIntrags `meta_name` sowie den einzutragenden Wert `meta_value`. Der Paramter `meta_value` muss ausserdem im richtigen Format angegeben werden (Liste oder einzelner Wert).

Es empfiehlt sich zuerst die `get_metadata` Funktion zu verwenden, um `template` und `meta_name` zu ermitteln.

[Mehr Informationen](https://help.opendatasoft.com/apis/ods-automation-v1/#tag/Dataset-metadata/operation/update-template-dataset-metadata)


```r

# Titel ändern
set_metadata(
  dataset_uid = "da_xxxxx",
  template = "default",
  meta_name = "title",
  meta_value = "Neuer Titel"
)


# Zuschreibungen ändern
set_metadata(
  dataset_uid = "da_xxxxx",
  template = "default",
  meta_name = "attributions",
  meta_value = list("Zuschreibung1", "Zuschreibung2")
)

```




## Daten


Bevor Daten zu einem Datensatz hinzugefügt werden können muss ein Datensatz über die Metadaten erstellt worden sein.

### Daten abspeichern

Bevor Daten hochgeladen werden sollte sichergestellt werden, dass diese in der richtigen Spezifikation abgespeichert sind.

Es empfiehlt sich Daten in R einzulesen und mit der `write_ogd2` Funktion abzuspeichern. Neben dem datensatz und dem csv Pfad sollten dafür die Parameter `na=""` und `fileEncoding="UTF-8` angegeben werden.

- `na=""`: `NA` werden als leere Strings abgespeichert. nur so kann ODS diese verarbeiten
- `fileEncoding = "UTF-8"`: Alle Files sollten im UTF-8 encoding abgespeichert werden.

```r


df <- data.frame(a = runif(200), b = runif(200))

write_ogd2(data = df,
           file = "path/to/file.csv",
           na = "",
           fileEncoding = "UTF-8")

```

### Daten hochladen und updaten

Mit der `update_resource()` Funktion können sowohl bestehende Daten aktualisert oder aber neue Daten aufegschaltet werden.
Wenn keine `resource_uid` als Parameter mitgegeben wird, checkt die Funktion ob eine Resource für den Datensatz vorhanden ist. Wenn ja, wird diese aktualisiert, wenn nein wird eine neue Resource erstellt. Sollten mehrere CSV Ressourcen zu einem Datensatz gehören, dann wird die aktuellste aktualisiert (Fall sollte i.d.R. nicht auftreten)


Wird eine `resource_uid` mitgegeben, dann wird diese explizite Resource aktualisiert. Die `resource_uid` kann über `get_dataset_resource()` ermittelt werden.

Der Parameter `encoding` entspricht dem Encoding der hochzuladenden CSV resource (i.d.R. `UTF-8`).

```r
update_resource(dataset_uid = "da_xxxxx",
                filepath = "path/to/file.csv",
                encoding = "UTF-8")


```

### Daten löschen

Zum Löschen von Resourcen kann die `delete_resource()` Funktion verwendet werden. Wenn keine `resource_uid` als Parameter mitgegeben wird, checkt die Funktion, ob eine Resource für den Datensatz vorhanden ist. Wenn ja, wird diese gelöscht. Sollten mehrere CSV Ressourcen zu einem Datensatz gehören, dann wird die aktuellste gelöscht (Fall sollte i.d.R. nicht auftreten).


```r
delete_resource(dataset_uid = "da_xxxxx")

```
### Daten herunterladen

Zum Herunterladen von Resourcen kann die `download_resource()` Funktion verwendet werden. Wenn keine `resource_uid` als Parameter mitgegeben wird, checkt die Funktion, ob eine Resource für den Datensatz vorhanden ist. Wenn ja, wird diese heruntergeladen. Sollten mehrere CSV Ressourcen zu einem Datensatz gehören, dann wird die aktuellste heruntergeladen (Fall sollte i.d.R. nicht auftreten).


```r
download_resource(dataset_uid = "da_xxxxx")

```



## Felder (Variablen)

Die Variablen selbst heissen auf ODS Felder (fields). Ihnen kann eine Beschreibung, ein Datentyp eine EInehit usw. zugeordnet werden.

### Datensatz aus Excel-Schema erstellen (TG spezifisch)

Sofern ein ausgefülltes Excel Schema voliegt, können die Felder mit der `edit_fields` Funktion bearbeitet werden. Hierbei werden Beschreibungen, Datentypen und (Zeit-) Einheiten zu den entsprechenden Variablen hinzugefügt. Ausserdem werden alle Felder sortierbar gemacht.

```r
dataset_uid <- edit_fields(dataset_uid = "da_xxxxx",filepath="path/to/schema.xlsx")

```

### Datentyp bearbeiten

Mögliche Einheiten sind `text`, `int`, `double`, `geo_point_2d`, `geo_shape`, `date`, `datetime` oder `file`.

```r
add_description(dataset_uid = "da_xxxx",
                field = "feld_name",
                unit = "double")
```

### Beschreibung hinzufügen

```r
add_description(dataset_uid = "da_xxxx",
                field = "feld_name",
                description = "Beschreibung der Variable")

```
### Datumseinheit anpassen

`timeserie` kann entweder `year`, `month` und `day`sein, wenn Datentyp `date` ist oder `hour` und `minute` wenn Datentyp `datetime` ist.

```r
add_timeserie_precision(dataset_uid = "da_xxxxx", field = "field_name", timeserie = "day")

```

### Einheit hinzufügen

`unit` kann zum Beispiel `CHF` sein.

```r
add_unit(dataset_uid = "da_xxxxx", field = "field_name", unit = "CHF")

```

### Felder sortierbar machen

Numerische Felder sind automatisch sortierbar.

```r
make_field_sortable(dataset_uid = "da_xxxxx", field = "field_name")

```



## Datensatz Aktionen


### Datensatz veröffentlichen

```r
publish_dataset("da_xxxxx")
```

### Veröffentlichung von Datensatz zurückziehen

```r
unpublish_dataset("da_xxxxx")
```

### Datensatz löschen


Wenn der Parameter `ask` nicht explizit gleich `FALSE` gesetzt wird, fordert die Funktion den User auf die Löschung in der Konsole zu bestätigen. Wenn `ask=FALSE` wird die Löschung direkt durchgeführt.

```r
delete_dataset("da_xxxxx", ask = FALSE)
```

### Datensatzsichtbarkeit ändern

Mit `change_visibility()` kann bestimmt werden ob der Datensatz öffentlich sichtbar ist oder nur für eingeloggte User.
```r
# Nur eingeloggte User
change_visibility("da_xxxxx", restrict = TRUE)

# Öffentlich sichtbar
change_visibility("da_xxxxx", restrict = FALSE)
```
### Datensatzexistenz überprüfen

Gibt `TRUE` zurück, wenn Datensatz existiert.

```r
check_dataset_exist("da_xxxxx")
```


### Datensatz kopieren

Datensatz wird kopiert und ein neuer Datensatz wird erstellt

```r
#Dataset_UID des zu kopierenden Datensatz
copy_dataset("da_xxxxx")
```


## Anhänge


### Anhänge einsehen

```r
get_dataset_attachments(dataset_uid = "da_xxxxx")
```


### Anhänge bearbeiten
```r
# Einzelnes File als Anhang aufschalten
add_attachments(dataset_uid = "da_xxxxx", files = "path/to/file")

# Alle Files aus einem Ordner als Anhang aufschalten
add_attachments(dataset_uid = "da_xxxxx", directory = "path/to/directory")


# Bestehende Anhänge löschen und neue Anhänge aufschalten
update_attachments(dataset_uid = "da_xxxxx", directory = "path/to/directory")


# Anhänge löschen
delete_attachments(dataset_uid = "da_xxxxx")

```

## Sonstige Funktionen







### Datensatzkennung erstellen

Bevor ein neuer Datensatz erstellt werden kann, muss eine passende Kennung erzeugt werden. Diese setzt sich im Kanton Thurgau wie folgt zusmamen: departement-amt-laufende Numemer (z.B. sk-stat-1). ODS erlaubt es eine Kennung für mehrere Datensätze anzulegen, da intern automatisch eine eindeutige `dataset_uid` zugewiesen wird. Daher muss darauf geachtet werden, dass die Kennungen eindeutig sind, um Verwirrungen zu vermeiden. Die `create_new_dataset_id` gewährleistet eindeutige Kennungen, indem sie einer gegebenen Teilkennung die korrekte laufende Nummer zuweist.

``` r
dataset_id <- create_new_dataset_id(part_id = "sk-stat")
## returns "sk-stat-116" 
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

## Datensatzhistorie einsehen

Wenn Datensätze zu einem früheren Zeitpunkt zurückgesetzt werden sollen, kann dies über die Datensatz Historie ermöglicht werden.

```r
# Die letzten 20 Datensatzänderungen abfragen (mehr derzeit nicht möglich)
get_dataset_changes(dataset_uid = "da_xxxxx")

# Die letzte Änderung des Datensatz abfragen
get_latest_changes(dataset_uid = "da_xxxxx")
```


## Datensatz zurücksetzen

Um die `change_uid` zu erhalten, können die im vorhergegangenen Funktionen verwendet werden

```r
restore_change(dataset_uid = "da_xxxxx", change_uid = "ch_xxxxx")
```


