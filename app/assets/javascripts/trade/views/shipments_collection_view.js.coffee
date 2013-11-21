Trade.ShipmentsCollectionView = Ember.CollectionView.extend

  itemViewClass: Ember.View.extend
    #contextBinding: 'content'

    template: Ember.Handlebars.compile(
      '{{this.quantity}}'
    )
