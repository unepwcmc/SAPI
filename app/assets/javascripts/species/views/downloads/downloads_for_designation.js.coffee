Species.DownloadsForDesignation = Ember.View.extend
  classNames: ['tab-content']

Species.DownloadsForCites = Species.DownloadsForDesignation.extend
  templateName: 'species/downloads_for_cites'

Species.DownloadsForEu = Species.DownloadsForDesignation.extend
  templateName: 'species/downloads_for_eu'

Species.DownloadsForCms = Species.DownloadsForDesignation.extend
  templateName: 'species/downloads_for_cms'