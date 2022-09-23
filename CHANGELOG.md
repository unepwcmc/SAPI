### 1.8.2

* Mobile terms and conditions, and privacy policy

### 1.8.1

* Updated CITES Trade Database user guidance
* CITES Wildlife TradeView links added to CITES Trade Database layout
* CITES Wildlife TradeView link added to Species+ 'Related Resources' drop down
* EU Analysis link updated in Species+ 'Related Resources' drop down
* Common names bulk upload:
  * new data csv added
  * import task modified to remove duplicates with different cases, e.g. Shark and shark
* Diactritics ignored during country filtering

### 1.8.0

**Intersessional decisions**

* Make direct association between Eu Decisions and Documents
* Add validation on Eu Opinions (Event or Intersessional doc, not both at least one of the two)
* Update Eu Decisions SQL views
* Update FE to display link to Intersessional doc or static text based on user session

### 1.7.1

**CITES Trade DB**

* Update to version 2022.1(replace zip file on the server, update ENV var, text updates)

### 1.7.0

**Multilingual extension of Tradeplus**

* localise SQL views
* fix formatting rules

### 1.6.5

**CITES Trade DB**

* Update to version 2021.1(replace zip file on the server, update ENV var, text updates)

**Species +**

* Add new distributions and distributions tags files
* Small fix to helpers_import distribution tags header

### 1.6.4

**Trade exemption, quotas and reservations data updates**

* Update trade exemption, quotas and reservations

### 1.6.3

**Add Identification type column to ID Documents download**

* Add Identification type column to ID Documents download

### 1.6.2

**Trade shipments pagination fix**

* Retain query parameters when moving to next page on trade shipments search functionality

### 1.6.1

**CITES Checklist pdf updates and surveys**

* Update CITES Checklist pdf covers
* Add tracking for Hotjar survey

### 1.6.0

**Rails and Ruby upgrade**

* Upgrade Ruby version to 2.3.1
* Upgrade Rails version to 4.0.6 (please check official documentation for details https://guides.rubyonrails.org/upgrading_ruby_on_rails.html#upgrading-from-rails-3-2-to-rails-4-0)

### 1.5.1

**Bug fixes and eu opinions bulk upload**

* Add new eu opinions bulk upload file for Conolophus
* Fix aru validation rule bug
* Fix distribution not copied across when splitting bug

**Eu opinions**

* Add private_url attribute to event and show only if user logged in

### 1.5.0

**Add TradePlus support**

* Add SQL views to support TradePlus queries
* Add/Refactor internal API endpoints to work with TradePlus

### 1.4.2

**Database download event tracking**

* Add event tracking to full database download from CITES Trade

### 1.4.1

**ID Materials updates**

* Amend document ordering, so that non ID Materials are ordered by date
* Add ID materials export to admin interface

### 1.4.0

**EU Opinions**

* Add new EU decision type (called SRG Referral)
* Change the name of current no opinion iii) to SRG Referral;
* Add new entity SRG History
* Change the name of current no opinion ii) to In consultation and changing it from an official EU decision to a non-opinion/notification for information only (SRG History)
* Add a second new SRG History, called Discussed at SRG (no decision taken)
* Add the new column SRG History to the EU decisions table in the Species+ public site
* Include validation on the BE so that if the decision_type is blank then the srg_history field should be populated
* On the download checkbox, new radio button to switch between EU decision type filters and "In consultation", and when the latter will be selected all the other filters disappear
* Exclude from the download the EU opinions with EU decision type = blank
or srg history = "Discussed at SRG referral"


### 1.3.0

**CITES ID Manual**

* Change to the documents retrieving, now including ancestor and descendant relative documents
* Change to documents order retrieving (exact match first, than from the highest rank(kingdom) to the lowest)
* Add new event(CITES ID materials) and two types of docs (IDManual and Virtual College)

**Checklist**

* Update api_documents_mview to include the new doc types
* Add relative CITES checklist api to retrieve the new docs
* Add a new worker to dynamically merge Id materials documents based on user filter/search

### 1.2.2

**Species+ Admin:**

* Hotfix for copying EU suspensions across events

### 1.2.1

**Trade Admin**

* Make annual reports submission synchronous again

**Configuration**

* Pull correct email address for automatic emails

### 1.2.0

**Species+ Admin:**

* Nomenclature Changes process for E-Library documents
* Nomenclature Changes bug fixes
* Trade interface logic amendments for EPIX integration
* Trade interface bug fixes

**Configuration**

* Update secrets configs
* Remove old and obsolete configs
* Update deploy scripts to speed up deploy using local assets precompilation

### 1.1.2

* Update exemptions file for CITES suspension in Compliance Tool
* Add script to rebuild Compliance Tool related mviews

### 1.1.1

* Fix and improve distributions import scripts

### 1.1.0

**Compliance Tool:**

* Internal shipments API useful for the Compliance Tool
* Logic and mviews for non-compliant shipments

### 1.0.1

* Hotfix that enables nomenclature changes in production and removes exception notifier.

### 1.0.0

**Species+ Admin:**

* nomenclature changes management

**Trade Admin:**

* ability to ignore secondary errors

### 0.10.1 - E-Library bug fix (deleting documents)

### 0.10.0 - E-Library

### 0.9.6.4
**E-library:**

* events import

**General:**

* upgrade ruby to 2.1.6
* upgrade postgres to 9.4

### 0.9.6.3 (2015-07-21)
Bug fixing

### 0.9.6.2
Bug fixing

### 0.9.6.1
**Species+:**

* fixed cascading CITES suspensions
* fixed displaying EU Anex removals

**Species+ Admin:**

* enabled amending quota URL

### 0.9.6
**Species+ Admin:**

* tracking taxon concept deletions
* new fields in user profile (is CITES authority, organisation, country)

**Species+ API:**

* expose deleted taxon concepts in `taxon_concepts` end-point
* speed improvements to `references` end-point

### 0.9.5 (2015-04-13)
**Species+:**
* adds ability to search by parts of scientific or common name, e.g. 'lupus'
* adds ability to search by non-hyphenated versions of common names, e.g. 'red collared'

**Species+ Admin:**
* fixes selecting event in EU listing change form
* fixes API usage overview page

**Trade:**
* returns hybrids when searching by higher taxa

**Trade Admin:**
* speeds up permit auto-complete
* minor display fixes

**General:**
* adds post-deploy smoke tests

### 0.9.4.2 (2015-03-31)
**Species+:**
* fixes display of quotas in preparation

**Species+ Admin:**
* fixes event dropdown in EU Opinion form

### 0.9.4.1 (2015-03-19)
**Species+ Admin**
* tracking dependents_updated_by_id
* copying exclusions to EU listings

**Trade**
* automatically expand the shipment year range

### 0.9.4 (2015-03-11)
**Species+ Admin:**
* fixes to T -> S and T -> A nomenclature changes processing
* fix for inherited standard reference flag
**Species+:**
* geo entity auto complete matches on parts of name
* calculation of original start date for current EU suspensions
* linking EU Opinions to SRG events
**Trade Admin:**
* fixes to Trade Admin interface
* ability to bulk update some shipment fields with blank value
* speed improvements to permit number auto complete

### 0.9.2 (2015-01-15)
**Species+ Admin:**
* API tracking

**Species+:**
* fix to order of EU Decisions

### 0.9.1 (2015-01-14)
**Species+ Admin:**
* nomenclature management (temporarily disabled)

**Species+**
* Rails security upgrade
* rework of queries to fetch data from views

### 0.9.0 (2014-12-16)
**Species+ Admin:**
* nomenclature management (temporarily disabled)
* changes to user roles (adding API users)

**Species+:**
* fixes to CITES Suspensions downloads and wording of sources

### 0.8.11 (2014-11-25)
**Species+ Admin:**
* fix for phantom opinions
* update of About page

### 0.8.10 (2014-11-20)
**Species+:**
* automatically discover default csv separator from IP
* fixes a bug in EU Decisions download box year selector
* fixes to column headers in EU Decisions download
* rewrite of EU Decisions csv download (using PostgreSQL COPY)

### 0.8.7 (2014-10-15)
**Species+:**
* link to EU legislation page

**Species+ Admin:**
* CITES / CMS taxa mapping

**CITES Trade Admin:**
* fix upload issue for files with a great many permit numbers

**General:**
* task to trim down / sanitize the database for use by collaborators

### 0.8.6 (2014-10-08)
* fixed issue in serializer

### 0.8.5
**Species+:**
* improvements to the activity page

**Species+ Admin:**
* internal notes
* fixes to E-library document bulk upload

**CITES Trade Admin:**
* skip distribution validations for higher taxa
* skip distribution validations when source W and XX
* interface bugfixes

### 0.8.4 (2014-09-26)
Bug-fix release (trade bulk update issue)

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
