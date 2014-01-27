Trade.Select2 = Ember.Select.extend

  didInsertElement: () ->

    placeholderText = this.get('prompt') or ''

    # Without this bit of magic the placeholder does not show up.
    @.$().prepend('<option></option>')

    @.$().select2(
      placeholder: placeholderText
      allowClear: true
      dropdownCssClass: 'other_autocomplete'
    )