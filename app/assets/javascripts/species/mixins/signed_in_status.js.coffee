Species.SignedInStatus = Ember.Mixin.create

  isSignedIn: ( ->
    Cookies.get('speciesplus.signed_in') == '1'
  ).property()
