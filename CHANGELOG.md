### 0.3.3 (unreleased)
* fixes references management pages (distribution, taxonomic references
  and standard references)
* adds statistic pages to the management tool
* adds taxon names download pages per Taxonomy
* fixes small bugs
* fixes import tasks that were using NOT EXISTS and not importing all
  the necessary data
* changes import script tasks to allow appending data from import files
  that was not imported previously (instead of dropping all the data
  before each import)

### 0.3.2 (2013-11-06)
* fixes downloads cache issues
* adds importer, exporter and reporter_type to shipments view
* resets sandbox selection on save changes
* saves reported species name
* fixes CITES suspensions search

### 0.3.1 (2013-10-31)
* Trade Admin: shipment validation bugfixes
* Species Admin: references bugfixes, caching issues
* Species Admin: Instruments CRUD pages

### 0.3.0 (2013-10-22)
* adds secondary validations to trade management tool:
  - term + unit
  - term + purpose
  - species + appendix + year
  - species + term
  - source 'W' + country of origin + distribution
  - source 'W' + exporter + distribution
  - Export country + Origin country
  - Export country + Import country
  - Species name + Source code

### 0.2.0 (2013-10-16)

* updating / deleting individual sandbox shipments
* batch updating / deleting sandbox shipments
* finalising sandbox submit
* viewing shipments

### 0.1.1 (2013-10-08)

* adds territiories to country dropdowns in management tool
* completes calculation of tmp materialized mviews before dropping the live ones
* fixes bugs:
  - management tool (editing EU Suspensions / Opinions, Taxon Concept)
  - cascading listing / current listing calculations (CITES/EU and CMS)
  - Species+ search
