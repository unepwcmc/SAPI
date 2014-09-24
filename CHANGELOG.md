### 0.8.3 (2014-09-24)
**Species+:**
* choice of csv separator
* EU Legislation page
* fix to randomly appearing French country names
* activity page

**Species+ Admin:**
* documents management for elibrary
* documents search for elibrary
* changes to event management for purposes of the EU Legislation page

**CITES Trade:**
* choice of csv separator

**CITES Trade Admin:**
* fixes to batch update
* fixes to search by taxa with cascading
* automatic resolution of reported -> accepted taxon concept

### 0.8.2 (unreleased)

### 0.8.1 (unreleased)
**Trade Admin**
* ability to update shipments in batch

**Species+ Admin**
* new event types in preparation for e-library integration

**General**
* Rails upgrade to 3.2.19

### 0.8.0 (2014-08-04)
**CITES Checklist**
* site and outputs available in 3 lngs

### 0.7.11 (2014-07-31)
**Species+**
* user activity tracking

**Species+ Admin tool**
* pages to view user activity in raw form

### 0.7.9 (2014-07-18)
**Species+ Admin tool**
* adding new translation columns to ranks & change types
* adding functionality in the S+ admin panel to manage ranks & change types translations
* adding functionality in the S+ admin panel to set is_current on CitesCop events
* adding import scripts to populate translations of: ranks, change_types, Cites regions, hash annotations
* adding import script to populate CoP start dates 

### 0.7.8 (2014-07-17)
Upgrade to ruby 2.0

### 0.7.0 (2014-06-11)
**Species+ Admin tool**
* Authentication & authorisation
* User stamping
* Internal downloads
* Stronger data consistency checks
* Managing trade validation rules
* Mechanism for mapping CITES <-> IUCN

**Trade Admin tool**
* Improved appendix validation process
* Small interface improvements

**Species+**
* Subspecies pages
* Distribution tags in Species+ & Checklist downloads

### 0.6.9 (2014-04-08)

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
