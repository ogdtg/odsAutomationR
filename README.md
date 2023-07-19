[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)


# odsAutomationR
With this package you can access the Automation API of Opendatasoft via R


## Installation

Die Dvelopement Version des Packages kann wie folgt installiert und genutzt werden:

``` r
devtools::install_github("ogdtg/odsManagementR")
library(odsManagementR)
```

## User initialisieren

Um Zugang zum jeweiligen ODS Portal zu bekommen und die Funktionalitäten der API nutzen zu können, muss zuerst ein User initialisiert werden. Dazu wird die `initialize_user` Funktion verwendet.
Diese Funktion sollte nur dann benutzt werden, wenn noch kein API Key mit den entsprechenden Berechtigungen erstellt wurde.

***ACHTUNG:*** *Die API Keys die man über das Frontend von ODS erstellen kann haben NICHT die ausreichenden Berechtigungen um die Management API nutzen zu können. Stand jetzt muss der API Key daher zwingend über einen API Call erstellt werden, auch wenn dies in der Dokumentation anders beschrieben wird.*

Mit der `initialize_user` wird ein API Key erstellt und dieser direkt initialisiert, sodass das Package funktionsfähig wird.

```r
initialize_user(username = "max.mustermann@tg.ch",
                password = "xxxxxxxxx",
                domain = "data.tg.ch")
```
Der Key kann sowohl im Frontend unter `https://{domain}/account/api-keys/` als auch über `getKey()` abgerufen werden. Am Besten speichert man den Key als Variable in einem `.Renviron` File, sodass man ihn beim erneuten Nutzen des Packages erneut einlesen kann. Dann sollte man anstelle der `initialize_user` Funktion die Domain und den Key separat über `setDomain` bzw.`setKey` setzen.

Die Nutzung des API Keys wird gegenüber der Nutzung von Passwort und Username bevorzugt, da API Keys einfach und schnell wieder gelöscht werden können.

Ein neuer API Key kann auch direkt über die `create_key` Funktion erstellt werden. Hier könenn auch Keys erstellt werden, die nur benutzerdefinierte Berechtigungen besitzen. Dies kann nützlich sein, wenn man zum Beispiel einer Person aus einem Amt Zugang zur API geben möcte, ohne dieser direkt alle Berechtigungen zu erteilen.

Gibt man keine benutzerdefinierte Liste für das Argument `permissions` an, werden per default alle Berechtigungen erteilt.

```r
apikey <- create_key(
            key_name="Name des Keys",
            username="max.mustermann@tg.ch",
            password = "xxxxxxxxx",
             domain = "data.tg.ch",
            permissions = list(
              "edit_dataset",
              "publish_dataset"
              )
)

#User initialisieren
setkey(apikey)
setDomain("data.tg.ch")
setPath("lokaler/Pfad/zu/data_catalog.csv")
# Package ist nun funktionsfähig

```

Die Daten werden dann in einem Environment namens `User` gespeichert und tauchen somit nicht im Global Environment auf. Abgerufen werden können die Daten mit get-Funktionen (z.B. `getKey()`, `getDomain()`)


## Liste aller Datensätze erhalten

Mit der Funktion `get_dataset_info` wird der aktuelle Metdata Katalog heruntergeladen. Dieser beinhaltet die Metadaten aller Datensätze, die sich derzeit auf dem Datenportal befinden. Hierzu zählen auch unveröffentlichte Datensätze sowie Datenkataloge. Die Funktion erzeugt automatisch eine Environment Variable `metadata_catalog`, die die Daten erhält. Die Funktion wird von mehreren anderen Funktionen verwendet, um sicher zugehen, dass der Katalog immer auf dem neuesten Stand ist. Ausserdem wird der Katalog jedes mal auf dem Lokalen Pfad, der bei `path` angegeben ist gespeichert.

*Der Parameter `path` ist standardmässig auf einen lokalen Order des Kantons gesetzt, kann aber geändert werden.*

``` r
get_dataset_info(path=path)
## creates variable "metadata_catalog" and saves it under path 
```

## Ermittlung der dataset_uid

Für viele der aufgeführten Funktionen wird die `dataset_uid` benötigt. Diese unterscheidet sich von der technischen Kennung (`dataset_id`, z.b. `sk-stat-1`). Um diese ODS-interne ID zu ermitteln kann entweder im `metadata_catalog` direkt nachgeschaut werden, oder es kann die `lookup_dataset_uid` Funktion verwendet werden.
Hier kann einfach der Titel des Datensatzes oder die `dataset_id` als Argument angegeben werden. Die Funktion lädt dann den aktuellen Katalog herunter und ermittelt die entsprechende `dataset_uid` und gibt diese zurück.

```r
lookup_dataset_uid(id_or_title="dek-gs-4")
# returns da_1aqp73

lookup_dataset_uid(id_or_title = "Bildungsstatistik Kanton Thurgau")
# returns da_1aqp73
```


## Neuen Datensatz erstellen

### Wrapper Funktion

Um Datensätze zu erstellen und sie direkt mit den Metadaten aus dem Excel Schema zu befüllen kann die wrapper-Funktion `add_metadata_from_scheme` verwendet werden. Hierzu muss lediglich der Pfad zum ausgefüllten Schema als `filepath` angeggeben werden. Optional kann noch eine Liste von `zuschreibungen` angegeben werden (default ist `NULL`). Wenn der Datensatz **NICHT** geharvested werden soll, muss `harvesting=FALSE` gesetzt werden (default ist `TRUE`). Die Funktion gibt die `dataset_uid` des neu erstellten Datensatzes zurück

Die einzelnen Schritte innerhalb der Funktion werden nachfolgend kurz beschrieben.

```r
dataset_uid <- add_metadata_from_scheme(filepath="path/to/schema.xlsx", 
                                        harvesting = TRUE, 
                                        zuschreibungen = NULL)
```

### Datensatzkennung erstellen
Bevor ein neuer Datensatz erstellt werden kann, muss eine passende Kennung erzeugt werden. Diese setzt sich im Kanton Thurgau wie folgt zusmamen: departement-amt-laufende Numemer (z.B. sk-stat-1). ODS erlaubt es eine Kennung für mehrere Datensätze anzulegen, da intern automatisch eine eindeutige `dataset_uid` zugewiesen wird. Daher muss darauf geachtet werden, dass die Kennungen eindeutig sind, um Verwirrungen zu vermeiden. Die `create_new_dataset_id` gewährleistet eindeutige Kennungen, indem sie einer gegebenen Teilkennung die korrekte laufende Nummer zuweist.

``` r
dataset_id <- create_new_dataset_id(part_id = "sk-stat")
## returns "sk-stat-116" 
```
### Template Datensatz duplizieren
Um gleichbleibende Metadaten nicht jedes mal neu einfügen zu müssen, lohnt es sich im ODS einen template Datensatz zu erstellen, der dann immer wieder dupliziert und neu befüllt wird. Dies kann mit der `duplicate_dataset` Funktion erreicht werden. Natürlich kann so auch jeder andere Datensatz kopiert dupliziert werden (nur Metadaten, nicht Datenquelle).
Hierbei muss die `dataset_uid` des zu kopierenden Datensatzes als `copy_id`angegeben werden. Ausserdem die neue Kennung als `new_id` sowie der neue Titel als `title`. Hier bitte auf die richtige Kennung und einen eindeutigen Titel achten. Die Funktion gibt die `dataset_uid` des neu erzeugten Datensatz zurück.

```r
dataset_uid <- duplicate_dataset(copy_id = "da_xxxxxx",
                                new_id = dataset_id,
                                title = new_title)
## returns dataset_uid in format da-xxxxxx
```

### Metadaten einfügen
Metadate können mithilfe der `set_metadata` Funktion eingefügt werden. Beim Parameter `dataset_id` muss die `dataset_uid` in Form `da-xxxxxx` anegeben werden. Dieser Parameter gibt an, für welchen Datensatz Metadaten gesetzt werden sollen. Die verfügbaren Werte für `template` können den Metadaten eines Datensatzes entnommen werden (Funktion `get_metadata(dataset_uid)`). Für data.tg.ch sind dies `custom`,`visualization`,`dcat`,`default`,`dcat_ap_ch` oder `internal`. Diese Werte sind als eine Art Übergruppe der einzelnen Metadaten zu verstehen und tauchen so teilweise auch im ODS Backend auf. Als `meta_name` muss der entsprechende Wert des Metadaten FelDes angegeben werden (z.B. `title`). Schliesslich muss der Wert, der gesetzt werden soll als `meta_value` angegeben werden. Für manche Metadaten Felder muss eine Liste als `meta_value` angegeben werden. Innerhalb der `add_metadata_from_scheme` Funktion wird für diesen Umstand kontrolliert und es werden automatisch listen erzeugt, wo es notwendig ist. Weitere Informatioenn können der offiziellen [Dokumentation der ODS Management API](https://betahelp.opendatasoft.com/management-api/#dataset-metadata) entnommen werden.

```r
set_metadata(dataset_id = "da-xxxxxx",
             template="default",
             meta_name="title",
             meta_value = "New Title for Dataset")

```

## Daten hinzufügen

### Wrapper Funktion

Um CSV Dateien vom lokalen System ins ODS zu laden, den im vorherigen Schritt erstellten Metadatensatz mit der Datenresource zu verbinden und die Spaltenbeschreibungen und Datentypen zu bearbeiten, kann die `add_data_to_dataset` Funktion verwendet werden. Als Parameter muss hier die `dataset_uid` anegegeben werden, die `add_metadata_from_scheme` zurück gibt. Ausserdem muss der Pfad zum ausgefüllten Schema sowie zum lokalen CSV File mit den Daten angegeben werden. Schliesslich muss ein Titel für die Resource auf ODS angegeben werden.

```r
add_data_to_dataset(
  dataset_uid = dataset_uid,
  schema = "path/to/schema.xlsx",
  ogd_file = "path/to/upload_data.csv",
  resource_title = "New Resource Title"
)
```

Die enthaltenen Schritte werden nun kurz erläutert.

### Lokale CSV Datei auf ODS hochladen

Das aufbereitete CSV File kann mit der `upload_file_to_ods` Funktion auf ODS hochgeladen werden. Dabei muss nur der Pfad zum entsprechenden File angegeben werden. Dei Funktion gibt eine Liste mit verschiedenen Metadaten des Files zurück, u.a. die `file_id`, die für die Verknüpfung mit dem Datensatz benötigt wird. Eine Übersicht über alle Files auf ODS kann mit der `list_ods_files` angezeigt werden. Die Funktion erzeugt einen Datensatz den Metadaten aller Files.

```r
ods_files <- list_ods_files()
# returns dataframe with metadata on all files on ODS

filename_ods <- upload_file_to_ods("path/to/upload_data.csv")
```

### Ressource mit Metadaten verknüpfen

Nachdem das CSV File hochgeladen wurde, muss es noch mit dem entsprechenden Metadatensatz verknüpft werden. Dies kann mithilfe der `add_resource_to_data` bewerkstelligt werden. Hierzu wird die vorhin erwähnte `file_id` als Parameter benötigt. Diese kann auch der File Liste entnommen werden, die durch `list_ods_files` erzeugt wird. Als zweiter Parameter muss die `dataset_uid` des Datensatzes mit dem das File verknüpft werden soll, angegeben werden. Schliesslich muss ein Titel für die Ressource angegeben werden.

```r
add_resource_to_data(resource = filename_ods$file_id,
                      dataset_uid = dataset_uid,
                      title = "The new resource Title")
# Uses the filename_ods list created by the upload_file_to_ods command
```

### Spaltennamen und -beschreibungen sowie Datentypen ergänzen

Abschliessend müsssen noch die Spaltennamen bearbeitet, die Spaltenbeschreibungen hinzugefügt und die entsprechenden Datentypen zugewiesen werden. Wenn vorhanden, können ausserdem noch Einheiten hinzugefügt werden, was eine verbesserte Anzeige im ODS zur Folge hat, die Daten selbst aber nicht verändert. Für diese Aktionen werden die folgenden Funktionen verwendet:

* `rename_field`
* `add_description_to_field`
* `add_type`
* `add_unit`
* `add_timeserie_precision`
* `make_fields_sortable`


#### rename_field

Die Funktion benötigt als Parameter die `dataset_id`, den aktuellen namen im ODS (`old_name`), den neuen Namen (`new_name`) sowie das neue Label (`new_label`). Eigentlich sollte das Label den Namen bezeichnen, der beim Hovern über den Spaltennamen im ODS erscheint. Allerdings erscheint im ODS die Beschreibung der Spalten. Deshalb ist zu empfehlen den gleichen Wert für `new_name` und `new_label` zu verwenden.
```r 
rename_field(
        dataset_uid = "da-xxxxxx",
        old_name = "current_var_name",
        new_name = "new_var_name",
        new_label = "new_var_name"
      )

```

Innerhalb der wrapper Funktion wird gecheckt, ob sich der aktuelle Name im ODS vom Namen im Excel Schema unterscheidet und entsprechend angepasst (Name aus Excel wird übernommen).

#### add_description_to_field

Mit der Funktion kann eine Variablenbeschreibung hinzugefügt/geändert werden. Dazu muss wieder die entsprechende `dataset_uid` sowie der Name der Variable (`field_name`)  angegeben werden. Die neue Beschreibung kann dann als `new_description` Parameter angegeben werden.
```r
add_description_to_field(
      dataset_uid = "da-xxxxxx",
      field_name = "current_var_name",
      new_description = "New Description vor variable"
    )
```

#### add_type

Die Definition des Datentyps funktioniert nach dem gleichen Prinzip wie das Hinzufügen der Beschreibung. Wieder müssen `dataset_uid` und `field_name` aneggeben werden. Der gewünschte Datentyp wird als `new_type` an die Funktion übergeben. Die verfügbaren Datentypen sind `text`,`int`,`double`,`geo_point_2d`,`geo_shape`,`date`,`datetime` und `file`.


```r
add_type(
      dataset_uid = "da-xxxxxx",
      field_name = "current_var_name",
      new_type  = "int"
    )
# sets datatype to integer
```

#### add_unit

Falls möglich kann eine Einheit hinzugefügt werden. Verfügbare Einheiten auf ODS köönen [hier](https://betahelp.opendatasoft.com/management-api/#units) eingesehen werden.
Wenn im Schema keine Einheit angegeben wird, überspringt die wrapper Funktion diesen Schritt

```r
add_unit(
        dataset_uid = "da-xxxxxx",
        field_name = "current_var_name",
        unit = "kg"
        )
# adds unit kilogramm
```

#### add_timeserie_precision


Mit dieser Funktion kann bestimmt werden wie Datumsangaben angezeigt werden sollen. Als `year` oder `day` im Falle von `date`; als `hour` oder `minute` für `datetime`.
Hierbei handelt es sich um eine sogenannte "Annotation". Weitere Annotationen können [hier](https://betahelp.opendatasoft.com/management-api/#annotate) eingesehen werden.



```r 
add_datetime_precision(
        dataset_uid = "da-xxxxxx",
        field_name = "jahr",
        annotation_args = "year"
      )
```


#### make_fields_sortable

Da Textfelder per Default nicht sortierbar sidn, muss dies explizit definiert werden. Dazu wird im Prozess die `make_fields_sortable` Funktion verwendet. Diese bewirkt, dass im Frontend alle Spalten mit dem Datentyp "Text" sortierbar werden. Die gewünschten Felder müssen unter dem Argument `fields` als Vektor angegeben werden. Werden Felder angegeben, die einen anderen Datentyp als Text aufweisen, werden diese Felder NICHT verändert.

```r
make_fields_sortable(
  dataset_uid = "da-xxxxxx",
  fields = c("name", "gemeinde", "kanton", "other_text_field")
)

```

Alternativ kann auch die die `make_all_fields_sortable` Funktion verwendet werden. Diese macht ALLE Spalten mit dem Datentyp Text sortierbar.

```r
make_all_fields_sortable(dataset_uid = "da-xxxxxx")

```

## Datensatz veröffentlichen

Datensätze können mithilfe der `publish_dataset` veröffentlicht werden. Dazu muss lediglich die `dataset_uid` Datensatzes angegeben werden. Es ist zu beachten, dass die Sicherheitseinstellungen (wer kann den Datensatz sehen) mit dieser Funktion NICHT verändert werden. 

```r

publish_dataset("da-xxxxxx")

```


## Datensatz löschen

Datensätze können mithilfe der `delete_dataset` gelöscht werden. Dazu muss lediglich die `dataset_uid`, die `dataset_id` oder der Titel des Datensatzes angegeben werden. Vor der Löschung wird ausserdem noch einmal nach einer Bestätigung gefragt, um versehentliche Löschungen zu vermeiden. 

```r
