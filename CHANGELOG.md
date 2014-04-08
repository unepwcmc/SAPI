### 0.6.8 (2014-04-08)

**Species+ Admin tool**
* Fixes creating new taxa (copy ancestors from parent)
* Adds synonyms and trade names download

**Trade Admin tool**
* Fixes resolving hybrids & trade names

**API**
* Fixes filtering by reporter_type in dashboard_stats

### 0.6.4 (2014-04-01)

This is a bug fix release:

**Species+**
* Fixes display of quotas with -1 value, as they should show as "in prep" on Species+
* Fixes "VALID" value on EU Decisions download to use new way to
  calculate it from the start and end events

**Species+ Admin tool**
* Fixes the calculation of is_current value for EU Suspensions, to use
  the start and end event, instead of the is_current attribute in the
table

### 0.6.0 (2014-03-17)
**API**
* Fixes dashboard stats

**Checklist**
* fixes issue in Checklist PDF to do with incorrect html markup

**Species+ Admin tool**
* distribution download

**Trade**
* Fixes to hybrids import
* Fixes to report upload taxon resolution
* Fixes to sandbox batch / individual operations
* Fixes to validations, including hybrids
* Fixes to searching by hybrids, synonyms, accepted names
* Searching by reported_as for the admin tool
* Fixes to public interface, including cap on number of results displayed online

### 0.5.0 (2014-02-25)
**Species+**

* Fixes issues with autocomplete speed;
* Fixes issue with inherited EU listings;
* Fixes issue with strange names showing under Subspecies and synonyms;

**Admin tool**

* Adds EU annex regulation and EU suspension regulations bulk management;
* Adds Quotas bulk creation;
* Admin can now mark geo entities as not current

**CITES Checklist**

* Fixes bug with appendix dropdown;

**Trade**

* Adds download by net/gross export/imports format;
* Adds download with commas/semi-colons on admin interface;
* Improves usability of editing sandbox shipments;
* Improves usability of managing shipments;
* Adds scripts to import trade names, hybrids, shipments and permits data;
* Adds feature to register public interface downloads, and allows downloading that list of public downloads;
* Adds features to delete shipments;
* Adds public interface to view shipments in the different possible formats;

### 0.4.1
* fixes synonyms showing as subspecies
* fixes hybrids showing as synonyms

### 0.4.0 (2013-12-18)
* adds functionality for managing trade data:
  - filtering by all shipment properties
  - adding / editing / deleting individual shipments
* adds downloads of trade data
* adds search by common names to Species+
* adds search by territories to Species+
* adds a number of features and bugfixes for species management tool
 
### 0.3.6 (2013-11-22)
* fixes some IE issues
* upgrades newrelic agent
* adds a licence

### 0.3.3 (2013-11-11)
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
