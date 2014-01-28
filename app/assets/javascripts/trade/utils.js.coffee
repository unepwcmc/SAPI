# Some reusable functions...

Trade.Utils = Ember.Mixin.create({

  # http://stackoverflow.com/a/15710692/1932827
  hashCode: (s) ->
    s?.split("").reduce ((a, b) ->
      a = ((a << 5) - a) + b.charCodeAt(0)
      a & a
    ), 0

})