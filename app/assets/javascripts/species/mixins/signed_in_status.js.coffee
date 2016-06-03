Species.SignedInStatus = Ember.Mixin.create

  isSignedIn: ( ->
    $.cookie('speciesplus.signed_in') == '1'
  ).property()
